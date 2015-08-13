-- VGM related functions for XPMC
--
-- TODO:
--	* Add proper support for the YM2413.
--	* Add support for the YM3812.
--	* Add support for the RF5C68

include globals.e
include util.e
include specs.e
include zlib.e


constant CHN_DATAPOS	= 2,
	 CHN_DELAY	= 3,
	 CHN_NOTE	= 4,
	 CHN_NOTEOFFS	= 5,
	 CHN_OCTAVE	= 6,
	 CHN_DUTY	= 7,
	 CHN_VOLUME = 11,
	 CHN_VOLMAC	= 14,
	 CHN_ENMAC 	= 15,
	 CHN_EN2MAC	= 16,
	 CHN_EPMAC 	= 17,
	 CHN_MPMAC 	= 18,
	 CHN_DETUNE	= 21,
	 CHN_PANMAC = 22,
	 CHN_MODE	= 23,
     CHN_OPER	= 26,
	 CHN_DUTMAC = 32,
	 CHN_FBKMAC = 33,
     CHN_PATTERN= 34,
     CHN_CHANNEL= 35,
     CHN_OLDPOS	= 36,
     CHN_PREVNOTE	= 37,
     CHN_DELAYLATCH	= 38,
     CHN_TRANSPOSE	= 39

constant VGM_CMD_W_PSG 		= #50,
	 VGM_CMD_W_YM2413 	= #51,
	 VGM_CMD_W_YM2612L 	= #52,
	 VGM_CMD_W_YM2612H	= #53,
	 VGM_CMD_W_YM2151	= #54,
	 VGM_CMD_W_YM3812	= #55,
	 VGM_CMD_W_RF5C68	= #5F
	 

constant VGM_STEP_FRAME = 0,
         VGM_STEP_NOTE = #80


integer volChange, freqChange
sequence channel, vgmData, lastChannelSetting

integer ID_VGM_NEW_NOTEOFFS, ID_VGM_NEW_FREQOFFS, ID_VGM_NEW_DUTY,
	ID_VGM_NEW_VOLUME, ID_VGM_NEW_FEEDBACK, ID_VGM_NEW_PANNING

	
procedure vgm_step_effect(integer chn, integer effectId, sequence effectList, integer trigger, integer effectProc)
	if channel[chn][effectId][1] then
		if trigger = VGM_STEP_NOTE and and_bits(channel[chn][effectId][1], #80) = VGM_STEP_FRAME then
			channel[chn][effectId][LIST_POS] = {1, LIST_MAIN}
		end if
		if trigger = VGM_STEP_NOTE or and_bits(channel[chn][effectId][1], #80) = VGM_STEP_FRAME then
			channel[chn][effectId][LIST_RET] = 
				step_list(effectList[2][and_bits(channel[chn][effectId][1], #7F)], channel[chn][effectId][LIST_POS])
			if effectProc != -1 then
				call_proc(effectProc, {{chn, trigger, effectId}})
			end if
		end if
	end if
end procedure



-- Write a VGM file based on the compiled song data.
--
-- Arguments:
--
--	fname:	Filename of the VGM
--	song:	Song number (1..number of songs in mml)
--	psg:	Non-zero if PSG is used in the song
--	ym2151: Non-zero if YM2151 is used in the song
--	ym2413:	Non-zero if YM2413 is used in the song
--	ym2612:	Non-zero if YM2612 is used in the song
--
global procedure write_vgm(sequence fname, integer song, integer psg, integer ym2151, integer ym2413, integer ym2612)
	atom factor, totalWaits, loopWaits
	integer f, fhi, machineSpeed, songSize,
	        cmd, vol, delay, nChannels,
	        chnUpdateDelay, pcmDelay, pcmDelayReload, pcmDataPos,
	        pcmDataLen, rhythm, compressVgm
	sequence freqTbl, oct1, fileEnding, s, 
	         channelDone, channelLooped, iterations, gd3,
	         cmdPos, loopPos, pcmData

	if ym2413 then
		if length(supportedChannels)-1 = 13 then
			if length(songs[song][5])  = 1 and
			   length(songs[song][6])  = 1 and
			   length(songs[song][7])  = 1 and
			   length(songs[song][8])  = 1 and
			   length(songs[song][9])  = 1 and
			   length(songs[song][10]) = 1 and
			   length(songs[song][11]) = 1 and
			   length(songs[song][12]) = 1 and
			   length(songs[song][13]) = 1 then
			   	-- Disable the YM2413 if none of its channels are used
				ym2413 = 0
			end if
		else
			ym2413 = 0
		end if
	end if

	if ym2612 then
		if length(supportedChannels)-1 = 10 then
			if length(songs[song][5]) = 1 and
			   length(songs[song][6]) = 1 and
			   length(songs[song][7]) = 1 and
			   length(songs[song][8]) = 1 and
			   length(songs[song][9]) = 1 and
			   length(songs[song][10]) = 1 then
			   	-- Disable the YM2612 if none of its channels are used
				ym2612 = 0
			end if
		else
			ym2612 = 0
		end if
	end if
			
	nChannels = length(supportedChannels)-1
	
	compressVgm = 0
	if (fname[length(fname)]='z' or fname[length(fname)]='Z') then
		compressVgm = 1
	end if
	
	if compressVgm then
		outFile = gzopen(fname, "wb9 ")
		if outFile = Z_NULL then
			ERROR("Unable to open file: " & fname, -1)
		end if
	else
		outFile = open(fname, "wb")
		if outFile = -1 then
			ERROR("Unable to open file: " & fname, -1)
		end if
	end if
	
	if verbose then
		puts(1,"Generating VGM data\n")
	end if

	if updateFreq = 50 then
		machineSpeed = 3546893
	else
		machineSpeed = 3579545
	end if
	if target = TARGET_SMS and tune then
		oct1 = OCTAVE1_ALT_SMS
	else
		oct1 = OCTAVE1
	end if
	freqTbl = {0, 0, 0, 0}

	-- Set up the frequency table for the PSG
	factor = 2.0
	freqTbl[1] = repeat(0, 12 * 6)
	for i = 2 to 7 do
		for n = 1 to 12 do
			freqTbl[1][(i - 2) * 12 + n] = floor(machineSpeed / (oct1[n] * factor * 32))
		end for
		factor *= 2.0
	end for

	-- Set up the frequency table for the YM2413
	if ym2413 then
		oct1 = OCTAVE1
		freqTbl[2] = repeat(0, 12)
		for n = 1 to 12 do
			freqTbl[2][n] = floor((oct1[n] * power(2, 18) / 50000))
		end for
	end if
	
	if ym2612 then
		-- freqTbl[3] = {617, 653, 692, 733, 777, 823, 872, 924, 979, 1037, 1099, 1164}
		freqTbl[3] = {649, 688, 729, 772, 818, 867, 918, 973, 1031, 1092, 1157, 1226}
	end if

	if ym2151 then
		freqTbl[4] = {14,0,1,2,4,5,6,8,9,10,12,13}
	end if
	
	vgmData = {#56, #67, #6D, #20,	-- "Vgm "
		   0, 0, 0, 0,		-- EOF offset, filled in later
		   #50, #01, 0, 0}	-- VGM version (1.50)
	if psg then
		vgmData &= int_to_bytes(machineSpeed)
	else
		vgmData &= int_to_bytes(0)
	end if
	if ym2413 then
		vgmData &= int_to_bytes(machineSpeed)
	else
		vgmData &= int_to_bytes(0)	
	end if
	vgmData &= int_to_bytes(0)	-- GD3 tag offset
	vgmData &= int_to_bytes(0)	-- Total samples
	vgmData &= int_to_bytes(0)	-- Loop offset
	vgmData &= int_to_bytes(0)	-- Loop samples
	vgmData &= int_to_bytes(floor(updateFreq))
	vgmData &= {9, 0, 8, 0}		-- Noise feedback pattern / shift width
	if ym2612 then
		vgmData &= int_to_bytes(7.6*1000000)
	else
		vgmData &= int_to_bytes(0)	
	end if
	if ym2151 then
		vgmData &= int_to_bytes(machineSpeed)
	else
		vgmData &= int_to_bytes(0)	
	end if
	vgmData &= int_to_bytes(#0C)	-- Data offset
	vgmData &= {0, 0, 0, 0, 0, 0, 0, 0}

	totalWaits 	= 0
	loopWaits 	= 0
	channelDone 	= repeat(0, nChannels)
	channelLooped 	= repeat(0, nChannels)
	iterations 	= {0, 0}

	-- Keeps track of the numbers of waits and current size of the VGM data
	-- at the point of each command for each channel. Used for calculating
	-- the offset and length of loops in the VGM.
	cmdPos = repeat(0, nChannels)
	for i = 1 to nChannels do
		cmdPos[i] = repeat(0, length(songs[song][i]))
	end for
	loopPos = {}

	-- Used for avoiding unnecessary writes to the PSG port.
	-- Contains the last value that have been output ({frequency, volume, panning, dac_on}) for
	-- each channel.
	lastChannelSetting = repeat({-1, -1, #FF, 0}, nChannels)

	--  1 dataPtr,
	--  2 dataPos,
	--  3 delay,
	--  4 note,
	--  5 noteOffs,
	--  6 octave,
	--  7 duty,
	--  8 freq,
	--  9 freqOffs,
	-- 10 freqOffsLatch,
	-- 11 volume,
	-- 12 volOffs,
	-- 13 volOffsLatch,
	-- 14 vMac,
	-- 15 enMac,
	-- 16 en2Mac,
	-- 17 epMac,
	-- 18 mpMac,
	-- 19 loops,
	-- 20 loopIndex,
	-- 21 detune,
	-- 22 csMac,
	-- 23 mode,
	-- 24 feedback,
	-- 25 adsr,
	-- 26 operator,
	-- 27 mult,
	-- 28 ams,
	-- 29 fms,
	-- 30 lfo,
	-- 31 rateScale,
	-- 32 dtMac,
	-- 33 fbMac,
	-- 34 pattern,
	-- 35 chnNum,
	-- 36 oldPos,
	-- 37 prevNote,
	-- 38 delayLatch
	-- 39 transpose
	channel = repeat({song,
			  1,
			  #100,
			  0,
			  0,
			  0,
			  4,
			  0,
			  0,
			  0,
			  0,
			  0,
			  0,
	                  {0, 0, {1, 2}},	-- vMac
	                  {0, 0, {1, 2}},	-- enMac
	                  {0, 0, {1, 2}},	-- en2Mac
	                  {0, 0, {1, 2}},	-- epMac
	                  {0, 0, 0},		-- mpMac
	                  {0, 0},		-- loops
	                  0,			-- loopIndex
	                  0,			-- detune
	                  {0, #FF, {1, 2}},	-- csMac
	                  0,			-- mode
	                  0,			-- feedback
	                  {0, 0, 0, 0, 0},	-- adsr
	                  0,			-- operator
	                  0,			-- mult
	                  0,			-- ams
	                  0,			-- fms
	                  {0, 0, 0},		-- lfo
	                  0,			-- rateScale
	                  {0, 0, {1, 2}},	-- dtMac
	                  {0, 0, {1, 2}},	-- fbMac
	                  0,			-- pattern
	                  0,			-- chnNum
	                  0,			-- oldPos
	                  {0, 0},		-- prevNote
	                  0,			-- delayLatch
	                  0			-- transpose
	                 }, nChannels)
	
	if ym2413 then
		vgmData &= {VGM_CMD_W_YM2413, #0F, #08}
		vgmData &= {VGM_CMD_W_YM2413, #02, #00}
		vgmData &= {VGM_CMD_W_YM2413, #0E, #20}
		rhythm = 0
	end if	
	
	if ym2612 then
		-- Write PCM data bank if needed
		if length(pcms[1]) then
			pcmDataLen = 0
			for i = 1 to length(pcms[1]) do
				pcmDataLen += length(pcms[2][i][3])
			end for
			vgmData &= {#67, #66, #00} & int_to_bytes(pcmDataLen)
			for i = 1 to length(pcms[1]) do
				vgmData &= pcms[2][i][3]
			end for
			if verbose then
				printf(1, "Total size of PCM data bank: %d bytes\n", pcmDataLen)
			end if
		end if
	
		for i = 5 to nChannels do
			channel[i][CHN_VOLUME] = {0, 0, 0, 0}
			lastChannelSetting[i][2] = {-1, -1, -1, -1}
		end for
		
		-- Turn on left and right output for all channels
		vgmData &= {VGM_CMD_W_YM2612L, #B4, #C0}
		vgmData &= {VGM_CMD_W_YM2612L, #B5, #C0}
		vgmData &= {VGM_CMD_W_YM2612L, #B6, #C0}
		vgmData &= {#53, #B4, #C0}
		vgmData &= {#53, #B5, #C0}
		vgmData &= {#53, #B6, #C0}
		
		-- Turn off DAC, LFO
		vgmData &= {VGM_CMD_W_YM2612L, #90, #00}
		vgmData &= {VGM_CMD_W_YM2612L, #22, #00}
		vgmData &= {VGM_CMD_W_YM2612L, #27, #00}
		vgmData &= {VGM_CMD_W_YM2612L, #2B, #00}
		
	end if
	
	if ym2151 then
		for i = 1 to nChannels do
			channel[i][CHN_VOLUME] = {0, 0, 0, 0}
			lastChannelSetting[i][2] = {-1, -1, -1, -1}
		end for

		-- Turn on left and right output for all channels
		vgmData &= {VGM_CMD_W_YM2151, #20, #C0}
		vgmData &= {VGM_CMD_W_YM2151, #21, #C0}
		vgmData &= {VGM_CMD_W_YM2151, #22, #C0}
		vgmData &= {VGM_CMD_W_YM2151, #23, #C0}
		vgmData &= {VGM_CMD_W_YM2151, #24, #C0}
		vgmData &= {VGM_CMD_W_YM2151, #25, #C0}
		vgmData &= {VGM_CMD_W_YM2151, #26, #C0}
		vgmData &= {VGM_CMD_W_YM2151, #27, #C0}
		
		vgmData &= {VGM_CMD_W_YM2151, #18, #00}
		vgmData &= {VGM_CMD_W_YM2151, #1B, #C0}
	end if
		
	pcmDelay = -1
	pcmDelayReload = -1
	
	--? songs[1]
	
	while sum(channelDone) != nChannels do
		for i = 1 to nChannels do
			--if not channel[i][CHN_PATTERN] then
			channel[i][CHN_CHANNEL] = i
			--end if
			
			if not channelDone[i] then
				freqChange = 0
				volChange = 0
				channel[i][CHN_DELAY] -= #100

				-- Check if the whole part of the delay has reached 0
				if and_bits(channel[i][CHN_DELAY], #FFFF00) = 0 then
					iterations[2] = 0
					-- Repeat until a note command has been read
					while freqChange != 2 do
						if channel[i][CHN_PATTERN] then
							cmd = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
						else
							cmd = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
						end if
						if not channel[i][CHN_PATTERN] then
							cmdPos[i][channel[i][CHN_DATAPOS]] = {length(vgmData), totalWaits}
						end if
						
						if and_bits(cmd, #F0) = CMD_NOTE or
						   and_bits(cmd, #F0) = CMD_OCTUP or
						   and_bits(cmd, #F0) = CMD_OCTDN or
						   and_bits(cmd, #F0) = CMD_NOTE2 then
							-- Do the octave change if specified
							if and_bits(cmd, #F0) = CMD_OCTUP then
								if channelType[i] = TYPE_SN76489 then
									channel[i][6] += 12
								elsif ym2413 and in_range(i, 5, 13) then
									channel[i][6] += 1
								elsif channelType[i] = TYPE_YM2612 then
									channel[i][6] += 1
								elsif channelType[i] = TYPE_YM2151 then
									channel[i][6] += 1
								end if
								cmd = or_bits(and_bits(cmd, #0F), CMD_NOTE2)
							elsif and_bits(cmd, #F0) = CMD_OCTDN then
								if channelType[i] = TYPE_SN76489 then
									channel[i][6] -= 12
								elsif ym2413 and in_range(i, 5, 13) then
									channel[i][6] -= 1
								elsif channelType[i] = TYPE_YM2612 then
									channel[i][6] -= 1
								elsif channelType[i] = TYPE_YM2151 then
									channel[i][6] -= 1
								end if
								cmd = or_bits(and_bits(cmd, #0F), CMD_NOTE2)
							end if

							if cmd = CMD_VOLUP then
								channel[i][CHN_DATAPOS] += 1
								if channel[i][CHN_PATTERN] then
									vol = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
								else
									vol = songs[channel[i][1]][channel[i][CHN_CHANNEL]][channel[i][CHN_DATAPOS]]
								end if
								if and_bits(vol, #80) then
									vol = vol - #100
								end if
								if sequence(channel[i][CHN_VOLUME]) then
									if channel[i][CHN_OPER] then
										channel[i][CHN_VOLUME][channel[i][CHN_OPER]] += vol
									else
										channel[i][CHN_VOLUME] += vol
									end if
								else
									channel[i][CHN_VOLUME] += vol
								end if
								channel[i][CHN_VOLMAC][1] = 0
								volChange = 1
								
							elsif cmd = CMD_VOLUPC then
							elsif cmd = CMD_VOLDNC then
							
							else
							
								-- If the previous note was a rest we need to trigger
								-- a volume change since the channel is currently muted.
								if channel[i][CHN_NOTE] = CMD_REST then
									volChange = 1
								end if

								-- Note number is stored in low 4 bits of the command byte.
								channel[i][CHN_NOTE] = and_bits(cmd, #0F)

								if and_bits(cmd, #F0) = CMD_NOTE2 then
									channel[i][CHN_DELAY] += channel[i][CHN_DELAYLATCH]
								else
									channel[i][CHN_DATAPOS] += 1

									-- Delays are 16.8 unsigned fixed point. In the song data
									-- they are stored either in two bytes (0-7FFF, for short delays)
									-- or three bytes (0-3FFFFF, for long delays).
									if channel[i][CHN_PATTERN] then
										delay = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
										if and_bits(delay, #80) then
											channel[i][CHN_DATAPOS] += 1
											delay = and_bits(delay, #7F) * #80 + patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
										end if
										channel[i][CHN_DATAPOS] += 1
										delay = delay * #100 + patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
									else
										delay = songs[channel[i][1]][channel[i][CHN_CHANNEL]][channel[i][CHN_DATAPOS]]
										if and_bits(delay, #80) then
											channel[i][CHN_DATAPOS] += 1
											delay = and_bits(delay, #7F) * #80 + songs[channel[i][1]][channel[i][CHN_CHANNEL]][channel[i][CHN_DATAPOS]]
										end if
										channel[i][CHN_DATAPOS] += 1
										delay = delay * #100 + songs[channel[i][1]][channel[i][CHN_CHANNEL]][channel[i][CHN_DATAPOS]]
									end if

									channel[i][CHN_DELAY] += delay
								end if

								-- The note can only be heard if the whole part of the delay
								-- is greater than zero.
								if channel[i][CHN_DELAY] > #FF then
									freqChange = 2
								end if

								if channel[i][CHN_NOTE] < CMD_REST then
									-- Reset volume macro
									if channel[i][CHN_VOLMAC][1] then
										vgm_step_effect(i, CHN_VOLMAC, volumeMacros, VGM_STEP_NOTE, ID_VGM_NEW_VOLUME)
									end if
									-- Reset arpeggio (cumulative)
									if channel[i][CHN_ENMAC][1] then
										vgm_step_effect(i, CHN_ENMAC, arpeggios, VGM_STEP_NOTE, ID_VGM_NEW_NOTEOFFS)
									end if
									-- Reset arpeggio (non-cumulative)
									if channel[i][CHN_EN2MAC][1] then
										vgm_step_effect(i, CHN_EN2MAC, arpeggios, VGM_STEP_NOTE, ID_VGM_NEW_NOTEOFFS)
									end if
									-- Reset pitch sweep
									if channel[i][CHN_EPMAC][1] then
										vgm_step_effect(i, CHN_EPMAC, pitchMacros, VGM_STEP_NOTE, ID_VGM_NEW_FREQOFFS)
									end if
									-- Reset vibrato
									if channel[i][CHN_MPMAC][1] then
										if and_bits(channel[i][CHN_MPMAC][1], #80) = VGM_STEP_NOTE then
											if channel[i][CHN_MPMAC][3] = 0 then
												channel[i][9] = channel[i][10]
												channel[i][10] = -channel[i][10]
												channel[i][CHN_MPMAC][3] = vibratos[2][and_bits(channel[i][CHN_MPMAC][1], #7F)][2][2]
												freqChange = 1
											end if
											channel[i][CHN_MPMAC][3] -= 1	-- Decrease vibrato delay
										else
											channel[i][CHN_MPMAC][LIST_POS] = vibratos[2][and_bits(channel[i][CHN_MPMAC][1], #7F)][2][1]
											channel[i][9] = 0
											channel[i][10] = vibratos[2][and_bits(channel[i][CHN_MPMAC][1], #7F)][2][3]
										end if
									end if
									-- Reset duty macro
									if channel[i][CHN_DUTMAC][1] then
										vgm_step_effect(i, CHN_DUTMAC, dutyMacros, VGM_STEP_NOTE, ID_VGM_NEW_DUTY)
									end if

									-- Reset feedback macro
									if channel[i][33][1] then
										vgm_step_effect(i, 33, feedbackMacros, VGM_STEP_NOTE, ID_VGM_NEW_FEEDBACK)
									end if

									-- Reset panning
									if channel[i][CHN_PANMAC][1] then 
										vgm_step_effect(i, CHN_PANMAC, panMacros, VGM_STEP_NOTE, ID_VGM_NEW_PANNING)								
									end if
								end if
							end if
							
						elsif and_bits(cmd, #F0) = CMD_OCTAVE then
							cmd -= minOctave[i]
							if channelType[i] = TYPE_SN76489 then
								channel[i][CHN_OCTAVE] = and_bits(cmd, #0F) * 12
								
							elsif ym2413 and in_range(i, 5, 13) then
								channel[i][CHN_OCTAVE] = and_bits(cmd, #0F)
								
							elsif channelType[i] = TYPE_YM2612 then
								channel[i][CHN_OCTAVE] = and_bits(cmd, #0F)
								
							elsif channelType[i] = TYPE_YM2151 then
								channel[i][CHN_OCTAVE] = and_bits(cmd, #0F)
							end if

						elsif and_bits(cmd, #F0) = CMD_DUTY then
							channel[i][32][1] = 0
							if psg and i = 4 then
								channel[i][7] = and_bits(xor_bits(cmd, 1), 1) * 4
								
							elsif ym2413 and in_range(i, 5, 13) then
								channel[i][7] = and_bits(cmd, #0F) * 16
								
							elsif ym2612 and in_range(i, 5, 10) then
								channel[i][7] = and_bits(cmd, 7)
								vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
								            #B0 + remainder((i - 5), 3),
								            channel[i][7] + channel[i][24]}
								            
							elsif channelType[i] = TYPE_YM2151 then
								channel[i][7] = and_bits(cmd, 7)
								vgmData &= {VGM_CMD_W_YM2151, #20 + i - 1, and_bits(#C0, channel[i][22][2]) + channel[i][7] + channel[i][24]}
							end if

						elsif and_bits(cmd, #F0) = CMD_VOL2 then
							if sequence(channel[i][CHN_VOLUME]) then
								if channel[i][CHN_OPER] then
									channel[i][CHN_VOLUME][channel[i][CHN_OPER]] = and_bits(cmd, #0F)
								else
									channel[i][CHN_VOLUME] = repeat(and_bits(cmd, #0F), length(channel[i][CHN_VOLUME]))
								end if
							else
								channel[i][CHN_VOLUME] = and_bits(cmd, #0F)
							end if
							channel[i][CHN_VOLMAC][1] = 0
							volChange = 1

						elsif cmd = CMD_HWTE then
							if ym2413 and in_range(i, 5, 13) then
								channel[i][CHN_DATAPOS] += 1
								if channel[i][CHN_PATTERN] then
									channel[i][21] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
								else
									channel[i][21] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
								end if
								if channel[i][CHN_OPER] = 0 or channel[i][CHN_OPER] = 1 then
									vgmData &= {#51, #00, channel[i][21] * #20 + channel[i][27]}
								end if
								if channel[i][CHN_OPER] = 0 or channel[i][CHN_OPER] = 2 then
									vgmData &= {#51, #01, channel[i][21] * #20 + channel[i][27]}
								end if
								--? {#51, #00, channel[i][21] * #20 + channel[i][27]} & channel[i][CHN_OPER]
							end if

						elsif cmd = CMD_HWVE then
							if ym2413 and in_range(i, 5, 13) then
								channel[i][CHN_DATAPOS] += 1
								if channel[i][CHN_PATTERN] then
									vgmData &= {#51, #02, patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]}
								else
									vgmData &= {#51, #02, songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]}
									--? {#51, #02, songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]}
								end if
							end if
							
						elsif cmd = CMD_JSR then
							channel[i][CHN_DATAPOS] += 1
							channel[i][CHN_PATTERN] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]] + 1
							--songs[channel[i][1]][nChannels+1] = patterns[2][channel[i][CHN_PATTERN]]
							channel[i][CHN_OLDPOS] = channel[i][CHN_DATAPOS]
							channel[i][CHN_DATAPOS] = 0
						
						elsif cmd = CMD_RTS then
							channel[i][CHN_DATAPOS] = channel[i][CHN_OLDPOS]
							channel[i][CHN_PATTERN] = 0
							
						-- Callbacks are ignored when outputting to VGM
						elsif cmd = CMD_ARPOFF then
							channel[i][15][1] = 0
							channel[i][16][1] = 0
							channel[i][CHN_NOTEOFFS] = 0

						elsif cmd = CMD_CBONCE or cmd = CMD_CBEVNT then
							channel[i][CHN_DATAPOS] += 1

						elsif cmd = CMD_MULT then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][27] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][27] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							if ym2413 and in_range(i, 5, 13) then
								if channel[i][CHN_OPER] = 0 or channel[i][CHN_OPER] = 1 then
									vgmData &= {VGM_CMD_W_YM2413, #00, channel[i][21] * #20 + channel[i][27]}
								end if
								if channel[i][CHN_OPER] = 0 or channel[i][CHN_OPER] = 2 then
									vgmData &= {VGM_CMD_W_YM2413, #01, channel[i][21] * #20 + channel[i][27]}
								end if
							
							elsif channelType[i] = TYPE_YM2612 then
								if channel[i][CHN_OPER] then
									vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
										    #30 + (channel[i][CHN_OPER] - 1)*4 + remainder((i - 5), 3),
										    channel[i][21] * #10 + channel[i][27]}
								else
									for j = 0 to 3 do
										vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
											    #30 + j*4 + remainder((i - 5), 3),
											    channel[i][21] * #10 + channel[i][27]}
									end for
								end if
							elsif channelType[i] = TYPE_YM2151 then
								if channel[i][CHN_OPER] then
									vgmData &= {VGM_CMD_W_YM2151,
										    #40 + (channel[i][CHN_OPER] - 1)*8 + i - 1,
										    channel[i][21] * #10 + channel[i][27]}
								else
									for j = 0 to 3 do
										vgmData &= {VGM_CMD_W_YM2151,
											    #40 + j*8 + i - 1,
											    channel[i][21] * #10 + channel[i][27]}
									end for
								end if
							end if
							
						elsif and_bits(cmd, #F0) = CMD_MODE then
							channel[i][CHN_MODE] = and_bits(cmd, #0F)
							if ym2413 and in_range(i, 11, 13) then
								channel[11][CHN_MODE] = and_bits(cmd, #0F)
								channel[12][CHN_MODE] = and_bits(cmd, #0F)
								channel[13][CHN_MODE] = and_bits(cmd, #0F)
								rhythm = and_bits(cmd, #0F) * #20
								vgmData &= {VGM_CMD_W_YM2413, #16, #20, #51, #26, #05}
								vgmData &= {VGM_CMD_W_YM2413, #17, #57, #51, #27, #01}
								vgmData &= {VGM_CMD_W_YM2413, #18, #57, #51, #28, #01}							
							elsif ym2612 and i = 10 then
								if channel[i][CHN_MODE] = 2 then
									--vgmData &= {#52, #2A, #00, #52, #2B, #80}
								else
									vgmData &= {VGM_CMD_W_YM2612L, #2B, #00}
								end if
							elsif ym2151 then
								if i = 8 and channel[i][CHN_MODE] = 0 then
									vgmData &= {VGM_CMD_W_YM2151, #0F, #00}
								end if
							end if
			
						elsif and_bits(cmd, #F0) = CMD_OPER then
							channel[i][CHN_OPER] = and_bits(cmd, #0F)
							
						elsif and_bits(cmd, #F0) = CMD_FEEDBK then
							if ym2413 and in_range(i, 5, 13) then
								--channel[i][24] = and_bits(cmd, 7)
								channel[i][CHN_DATAPOS] += 1
								if channel[i][CHN_PATTERN] then
									channel[i][24] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
								else
									channel[i][24] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
								end if

								vgmData &= {#51, and_bits(cmd, #0F), channel[i][24]}
								
							elsif channelType[i] = TYPE_YM2612 then
								channel[i][24] = and_bits(cmd, 7) * 8
								vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
								            #B0 + remainder((i - 5), 3),
								            channel[i][7] + channel[i][24]}
								            
							elsif channelType[i] = TYPE_YM2151 then
								channel[i][24] = and_bits(cmd, 7) * 8
								vgmData &= {VGM_CMD_W_YM2151,
								            #20 + i - 1,
								            and_bits(#C0, channel[i][22][2]) + channel[i][7] + channel[i][24]}
							
							end if
							--? vgmData[length(vgmData)-2..length(vgmData)]
							
						elsif cmd = CMD_ADSR then
							channel[i][CHN_DATAPOS] += 1
							if ym2413 and in_range(i, 5, 13) then
								if channel[i][CHN_PATTERN] then
									channel[i][25] = adsrs[2][patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]][2]
								else
									channel[i][25] = adsrs[2][songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]][2]
								end if
								if channel[i][CHN_OPER] = 0 or channel[i][CHN_OPER] = 1 then
									vgmData &= {#51, #04, channel[i][25][1]}
									vgmData &= {#51, #06, channel[i][25][2]}
								end if
								if channel[i][CHN_OPER] = 0 or channel[i][CHN_OPER] = 2 then
									vgmData &= {#51, #05, channel[i][25][1]}
									vgmData &= {#51, #07, channel[i][25][2]}
								end if
								
							elsif channelType[i] = TYPE_YM2612 then
								f = and_bits(channel[i][25][2], #80)
								if channel[i][CHN_PATTERN] then
									channel[i][25] = adsrs[2][patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]][2]
								else
									channel[i][25] = adsrs[2][songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]][2]
								end if
								channel[i][25][2] = or_bits(channel[i][25][2], f)
								if channel[i][CHN_OPER] then
									vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
										    #50 + (channel[i][CHN_OPER] - 1)*4 + remainder((i - 5), 3),
										    channel[i][25][1] + channel[i][31]}
									vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
										    #60 + (channel[i][CHN_OPER] - 1)*4 + remainder((i - 5), 3),
										    channel[i][25][2]}
									vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
										    #70 + (channel[i][CHN_OPER] - 1)*4 + remainder((i - 5), 3),
										    channel[i][25][3]}
									vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
										    #80 + (channel[i][CHN_OPER] - 1)*4 + remainder((i - 5), 3),
										    channel[i][25][4]}
								else
									for j = 0 to 3 do
										vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
											    #50 + j*4 + remainder((i - 5), 3),
											    channel[i][25][1] + channel[i][31]}
										vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
											    #60 + j*4 + remainder((i - 5), 3),
											    channel[i][25][2]}
										vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
											    #70 + j*4 + remainder((i - 5), 3),
											    channel[i][25][3]}
										vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
											    #80 + j*4 + remainder((i - 5), 3),
											    channel[i][25][4]}
									end for
								end if
								
							elsif channelType[i] = TYPE_YM2151 then
								f = and_bits(channel[i][25][2], #80)
								if channel[i][CHN_PATTERN] then
									channel[i][25] = adsrs[2][patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]][2]
								else
									channel[i][25] = adsrs[2][songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]][2]
								end if
								channel[i][25][2] = or_bits(channel[i][25][2], f)
								if channel[i][CHN_OPER] then
									vgmData &= {VGM_CMD_W_YM2151,
										    #80 + (channel[i][CHN_OPER] - 1)*8 + i - 1,
										    channel[i][25][1] + channel[i][31]}
									vgmData &= {VGM_CMD_W_YM2151,
										    #A0 + (channel[i][CHN_OPER] - 1)*8 + i - 1,
										    channel[i][25][2]}
									vgmData &= {VGM_CMD_W_YM2151,
										    #C0 + (channel[i][CHN_OPER] - 1)*8 + i - 1,
										    channel[i][25][3]}
									vgmData &= {VGM_CMD_W_YM2151,
										    #E0 + (channel[i][CHN_OPER] - 1)*8 + i - 1,
										    channel[i][25][4]}
								else
									for j = 0 to 3 do
										vgmData &= {VGM_CMD_W_YM2151,
											    #80 + j*8 + i - 1,
											    channel[i][25][1] + channel[i][31]}
										vgmData &= {VGM_CMD_W_YM2151,
											    #A0 + j*8 + i - 1,
											    channel[i][25][2]}
										vgmData &= {VGM_CMD_W_YM2151,
											    #C0 + j*8 + i - 1,
											    channel[i][25][3]}
										vgmData &= {VGM_CMD_W_YM2151,
											    #E0 + j*8 + i - 1,
											    channel[i][25][4]}
									end for
								end if
							
							end if
						
						elsif cmd = CMD_LEN then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								delay = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
								if and_bits(delay, #80) then
									channel[i][CHN_DATAPOS] += 1
									delay = and_bits(delay, #7F) * #80 + patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
								end if
								channel[i][CHN_DATAPOS] += 1
								delay = delay * #100 + patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								delay = songs[channel[i][1]][channel[i][CHN_CHANNEL]][channel[i][CHN_DATAPOS]]
								if and_bits(delay, #80) then
									channel[i][CHN_DATAPOS] += 1
									delay = and_bits(delay, #7F) * #80 + songs[channel[i][1]][channel[i][CHN_CHANNEL]][channel[i][CHN_DATAPOS]]
								end if
								channel[i][CHN_DATAPOS] += 1
								delay = delay * #100 + songs[channel[i][1]][channel[i][CHN_CHANNEL]][channel[i][CHN_DATAPOS]]
							end if
							channel[i][CHN_DELAYLATCH] = delay

							
						elsif cmd = CMD_RSCALE then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][31] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]] * #40
							else
								channel[i][31] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]] * #40
							end if
							if channelType[i] = TYPE_YM2612 then
								if channel[i][CHN_OPER] then
									vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
										    #50 + (channel[i][CHN_OPER] - 1)*4 + remainder((i - 5), 3),
										    channel[i][25][1] + channel[i][31]}
								else
									for j = 0 to 3 do
										vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
											    #50 + j*4 + remainder((i - 5), 3),
											    channel[i][25][1] + channel[i][31]}
									end for
								end if
							elsif channelType[i] = TYPE_YM2151 then
								if channel[i][CHN_OPER] then
									vgmData &= {VGM_CMD_W_YM2151,
										    #80 + (channel[i][CHN_OPER] - 1)*8 + i - 1,
										    channel[i][25][1] + channel[i][31]}
								else
									for j = 0 to 3 do
										vgmData &= {VGM_CMD_W_YM2151,
											    #80 + j*8 + i - 1,
											    channel[i][25][1] + channel[i][31]}
									end for
								end if
							end if
							
						elsif cmd = CMD_VOLSET then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								if sequence(channel[i][CHN_VOLUME]) then
									if channel[i][CHN_OPER] then
										channel[i][CHN_VOLUME][channel[i][CHN_OPER]] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
									else
										channel[i][CHN_VOLUME] = repeat(patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]], length(channel[i][CHN_VOLUME]))
									end if
								else
									channel[i][CHN_VOLUME] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
								end if
							else
								if sequence(channel[i][CHN_VOLUME]) then
									if channel[i][CHN_OPER] then
										channel[i][CHN_VOLUME][channel[i][CHN_OPER]] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
									else
										channel[i][CHN_VOLUME] = repeat(songs[channel[i][1]][i][channel[i][CHN_DATAPOS]], length(channel[i][CHN_VOLUME]))
									end if
								else
									channel[i][CHN_VOLUME] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
								end if
							end if
							channel[i][CHN_VOLMAC][1] = 0
							volChange = 1
							
						elsif cmd = CMD_VOLMAC then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][CHN_VOLMAC][1] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][CHN_VOLMAC][1] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							channel[i][CHN_VOLMAC][3] = step_list(volumeMacros[2][and_bits(channel[i][CHN_VOLMAC][1], #7F)], {1, 2})
							if sequence(channel[i][CHN_VOLUME]) then
								if channel[i][CHN_OPER] then
									channel[i][CHN_VOLUME][channel[i][CHN_OPER]] = channel[i][CHN_VOLMAC][3][3]
								else
									channel[i][CHN_VOLUME] = repeat(channel[i][CHN_VOLMAC][3][3], length(channel[i][CHN_VOLUME]))
								end if
							else
								channel[i][CHN_VOLUME] = channel[i][CHN_VOLMAC][3][3]
							end if
							--channel[i][CHN_VOLUME] = channel[i][CHN_VOLMAC][3][3]
							volChange = 1

						elsif cmd = CMD_PANMAC then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][CHN_PANMAC][1] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][CHN_PANMAC][1] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							channel[i][CHN_PANMAC][3] = step_list(panMacros[2][and_bits(channel[i][CHN_PANMAC][1], #7F)], {1, 2})
							if channel[i][CHN_PANMAC][3][3] then
								if and_bits(channel[i][CHN_PANMAC][3][3], #80) then
									if psg and i < 5 then
										channel[1][CHN_PANMAC][2] = clear_bit(channel[1][CHN_PANMAC][2], i - 1)
										channel[1][CHN_PANMAC][2] =   set_bit(channel[1][CHN_PANMAC][2], i + 3)
									elsif channelType[i] = TYPE_YM2612 then
										channel[i][CHN_PANMAC][2] = clear_bit(channel[i][CHN_PANMAC][2], 6)
										channel[i][CHN_PANMAC][2] =   set_bit(channel[i][CHN_PANMAC][2], 7)
									elsif channelType[i] = TYPE_YM2151 then
										channel[i][CHN_PANMAC][2] = clear_bit(channel[i][CHN_PANMAC][2], 7)
										channel[i][CHN_PANMAC][2] =   set_bit(channel[i][CHN_PANMAC][2], 6)
									end if
								else
									if psg and i < 5 then
										channel[1][CHN_PANMAC][2] = clear_bit(channel[1][CHN_PANMAC][2], i + 3)
										channel[1][CHN_PANMAC][2] =   set_bit(channel[1][CHN_PANMAC][2], i - 1)
									elsif channelType[i] = TYPE_YM2612 then
										channel[i][CHN_PANMAC][2] = clear_bit(channel[i][CHN_PANMAC][2], 7)
										channel[i][CHN_PANMAC][2] =   set_bit(channel[i][CHN_PANMAC][2], 6)
									elsif channelType[i] = TYPE_YM2151 then
										channel[i][CHN_PANMAC][2] = clear_bit(channel[i][CHN_PANMAC][2], 6)
										channel[i][CHN_PANMAC][2] =   set_bit(channel[i][CHN_PANMAC][2], 7)
									end if
								end if
							else
								if channelType[i] = TYPE_SN76489 then
									channel[1][CHN_PANMAC][2] = set_bit(channel[1][CHN_PANMAC][2], i - 1)
									channel[1][CHN_PANMAC][2] = set_bit(channel[1][CHN_PANMAC][2], i + 3)
								elsif channelType[i] = TYPE_YM2612 or channelType[i] = TYPE_YM2151 then
									channel[i][CHN_PANMAC][2] = set_bit(channel[i][CHN_PANMAC][2], 6)
									channel[i][CHN_PANMAC][2] = set_bit(channel[i][CHN_PANMAC][2], 7)
								end if
							end if
							if channelType[i] = TYPE_SN76489 and channel[1][CHN_PANMAC][2] != lastChannelSetting[1][3] and not supportsPAL then
								vgmData &= {#4F, channel[1][CHN_PANMAC][2]}
								lastChannelSetting[1][3] = channel[1][CHN_PANMAC][2]
							elsif channelType[i] = TYPE_YM2612 then
								if sequence(channel[i][30][3]) then
									vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
										    #B4 + remainder((i - 5), 3),
										    and_bits(#C0, channel[i][22][2]) + channel[i][30][3][2]}
								else
									vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
										    #B4 + remainder((i - 5), 3),
										    and_bits(#C0, channel[i][22][2])}
								end if
							elsif channelType[i] = TYPE_YM2151 then
								vgmData &= {VGM_CMD_W_YM2151,
									    #20 + i - 1,
									    and_bits(#C0, channel[i][22][2]) + channel[i][7] + channel[i][24]}
							end if

						elsif cmd = CMD_ARPMAC then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][15][1] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][15][1] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							channel[i][15][3] = step_list(arpeggios[2][and_bits(channel[i][15][1], #7F)], {1, 2})
							channel[i][5] = channel[i][15][3][3]
							--? channel[i][5]
							channel[i][16][1] = 0
							freqChange = 1

						elsif cmd = CMD_DUTMAC then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][32][1] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][32][1] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							if channel[i][32][1] then
								channel[i][32][3] = step_list(dutyMacros[2][and_bits(channel[i][CHN_DUTMAC][1], #7F)], {1, 2})
								--channel[i][9] = 0
								--freqChange = 1
							end if	

						elsif cmd = CMD_FBKMAC then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][33][1] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][33][1] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							if channel[i][33][1] then
								channel[i][33][3] = step_list(feedbackMacros[2][and_bits(channel[i][CHN_FBKMAC][1], #7F)], {1, 2})
								--channel[i][9] = 0
								--freqChange = 1
							end if	

						elsif cmd = CMD_TRANSP then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][CHN_TRANSPOSE] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][CHN_TRANSPOSE] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
						
						elsif cmd = CMD_DETUNE then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][CHN_DETUNE] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][CHN_DETUNE] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							if ym2612 and in_range(i, 5, 10) then
								if channel[i][CHN_OPER] then
									vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
										    #30 + (channel[i][CHN_OPER] - 1)*4 + remainder((i - 5), 3),
										    channel[i][CHN_DETUNE] * #10 + channel[i][27]}
								else
									for j = 0 to 3 do
										vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
											    #30 + j*4 + remainder((i - 5), 3),
											    channel[i][CHN_DETUNE] * #10 + channel[i][27]}
									end for
								end if
							elsif ym2151 then
								if channel[i][CHN_OPER] then
									vgmData &= {VGM_CMD_W_YM2151,
										    #40 + (channel[i][CHN_OPER] - 1)*8 + i - 1,
										    channel[i][CHN_DETUNE] * #10 + channel[i][27]}
								else
									for j = 0 to 3 do
										vgmData &= {VGM_CMD_W_YM2151,
											    #40 + j*8 + i - 1,
											    channel[i][CHN_DETUNE] * #10 + channel[i][27]}
									end for
								end if
							end if

						elsif cmd = CMD_MODMAC then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][30][1] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][30][1] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							if ym2612 and in_range(i, 5, 10) then
								if channel[i][30][1] then
									channel[i][30][3] = mods[2][channel[i][30][1]][2]
									vgmData &= {VGM_CMD_W_YM2612L, #22, channel[i][30][3][1] + 8}
									vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
										    #B4 + remainder((i - 5), 3),
										    and_bits(#C0, channel[i][22][2]) + channel[i][30][3][2]}
								else
									vgmData &= {VGM_CMD_W_YM2612L, #22, 0}
								end if
							elsif ym2151 then
								if channel[i][30][1] then
									channel[i][30][3] = mods[2][channel[i][30][1]][2]
									vgmData &= {VGM_CMD_W_YM2151, #18, channel[i][30][3][1]}
									vgmData &= {VGM_CMD_W_YM2151, #19, channel[i][30][3][2]}
									vgmData &= {VGM_CMD_W_YM2151, #19, channel[i][30][3][3]}
									vgmData &= {VGM_CMD_W_YM2151, #1B, channel[i][30][3][5]}
									vgmData &= {VGM_CMD_W_YM2151, #38 + i - 1, channel[i][30][3][4]}
								else
									vgmData &= {VGM_CMD_W_YM2151, #18, 0}
								end if
							end if

						elsif cmd = CMD_SSG then
							channel[i][CHN_DATAPOS] += 1
							if ym2612 and in_range(i, 5, 10) then
								if channel[i][CHN_PATTERN] then
									-- TODO: Handle this case
								else
									if channel[i][CHN_OPER] then
										if songs[channel[i][1]][i][channel[i][CHN_DATAPOS]] then
											vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
												    #90 + (channel[i][CHN_OPER] - 1)*4 + remainder((i - 5), 3),
												    #8 + songs[channel[i][1]][i][channel[i][CHN_DATAPOS]] - 1}
										else
											vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3), #90 + (channel[i][CHN_OPER] - 1)*4 + remainder((i - 5), 3), 0}
										end if
									else
										for j = 0 to 3 do
											if songs[channel[i][1]][i][channel[i][CHN_DATAPOS]] then
												vgmData &= {#52 + floor((i - 5) / 3),
													    #90 + j*4 + remainder((i - 5), 3),
													    #8 + songs[channel[i][1]][i][channel[i][CHN_DATAPOS]] - 1}
											else
												vgmData &= {#52 + floor((i - 5) / 3), #90 + j*4 + remainder((i - 5), 3), 0}
											end if
										end for
									end if
								end if
							end if
							
						elsif cmd = CMD_HWAM then
							channel[i][CHN_DATAPOS] += 1
							channel[i][25][2] = and_bits(channel[i][25][2], #7F)
							if channel[i][CHN_PATTERN] then
								channel[i][25][2] = or_bits(channel[i][25][2], patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]] * #80)
							else
								channel[i][25][2] = or_bits(channel[i][25][2], songs[channel[i][1]][i][channel[i][CHN_DATAPOS]] * #80)
							end if
							if ym2612 and in_range(i, 5, 10) then
								if channel[i][CHN_OPER] then
									vgmData &= {#52 + floor((i - 5) / 3),
										    #60 + (channel[i][CHN_OPER] - 1)*4 + remainder((i - 5), 3),
										    channel[i][25][2]}
								else
									for j = 0 to 3 do
										vgmData &= {#52 + floor((i - 5) / 3),
											    #60 + j*4 + remainder((i - 5), 3),
											    channel[i][25][2]}
									end for
								end if
							elsif ym2151 then
								if channel[i][CHN_OPER] then
									vgmData &= {#54,
										    #A0 + (channel[i][CHN_OPER] - 1)*8 + i - 1,
										    channel[i][25][2]}
								else
									for j = 0 to 3 do
										vgmData &= {#54,
											    #A0 + j*8 + i - 1,
											    channel[i][25][2]}
									end for
								end if
							end if
							
						elsif cmd = CMD_APMAC2 then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][16][1] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][16][1] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							channel[i][CHN_EN2MAC][3] = step_list(arpeggios[2][and_bits(channel[i][CHN_EN2MAC][1], #7F)], {1, 2})
							channel[i][CHN_ENMAC][1] = 0
							freqChange = 1

						elsif cmd = CMD_SWPMAC then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][CHN_EPMAC][1] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][CHN_EPMAC][1] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							if channel[i][17][1] then
								channel[i][17][3] = step_list(pitchMacros[2][and_bits(channel[i][CHN_EPMAC][1], #7F)], {1, 2})
								channel[i][9] = 0
								freqChange = 1
							else
								channel[i][9] = 0
								freqChange = 1
							end if	

						elsif cmd = CMD_VIBMAC then
							channel[i][CHN_DATAPOS] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][CHN_MPMAC][1] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][CHN_MPMAC][1] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
							if channel[i][CHN_MPMAC][1] then
								channel[i][CHN_MPMAC][3] = vibratos[2][and_bits(channel[i][CHN_MPMAC][1], #7F)][2][1]
								channel[i][9] = 0
								channel[i][10] = vibratos[2][and_bits(channel[i][CHN_MPMAC][1], #7F)][2][3]
								freqChange = 1
							else
								freqChange = 1
								channel[i][9] = 0
							end if

						elsif cmd = CMD_JMP then
							if channel[i][CHN_PATTERN] then
								channel[i][CHN_DATAPOS] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS] + 1] +
								                          patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS] + 2] * #100
							else
								channel[i][CHN_DATAPOS] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS] + 1] +
									                  songs[channel[i][1]][i][channel[i][CHN_DATAPOS] + 2] * #100
							end if		                  
							channelLooped[i] = 1
							if sum(channelLooped) = nChannels then
								loopPos = cmdPos[i][channel[i][CHN_DATAPOS] + 1]
								channelDone = repeat(1, nChannels)
								freqChange = 2
							end if

						elsif cmd = CMD_J1 then
							if channel[i][19][channel[i][20]] = 1 then
								channel[i][20] -= 1
								if channel[i][CHN_PATTERN] then
									channel[i][CHN_DATAPOS] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS] + 1] +
									                          patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS] + 2] * #100
								else
									channel[i][CHN_DATAPOS] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS] + 1] +
											          songs[channel[i][1]][i][channel[i][CHN_DATAPOS] + 2] * #100
								end if
							else
								channel[i][CHN_DATAPOS] += 2
							end if
						
						elsif cmd = CMD_DJNZ then
							channel[i][19][channel[i][20]] -= 1
							if channel[i][19][channel[i][20]] != 0 then
								if channel[i][CHN_PATTERN] then
									channel[i][CHN_DATAPOS] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS] + 1] +
									                          patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS] + 2] * #100
								else
									channel[i][CHN_DATAPOS] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS] + 1] +
											          songs[channel[i][1]][i][channel[i][CHN_DATAPOS] + 2] * #100
								end if
							else
								channel[i][20] -= 1
								channel[i][CHN_DATAPOS] += 2
							end if

						elsif cmd = CMD_LOPCNT then
							channel[i][CHN_DATAPOS] += 1
							channel[i][20] += 1
							if channel[i][CHN_PATTERN] then
								channel[i][19][channel[i][20]] = patterns[2][channel[i][CHN_PATTERN]][channel[i][CHN_DATAPOS]]
							else
								channel[i][19][channel[i][20]] = songs[channel[i][1]][i][channel[i][CHN_DATAPOS]]
							end if
						
						elsif cmd = CMD_WRMEM then
							channel[i][CHN_DATAPOS] += 3
						elsif cmd = CMD_WRPORT then
							channel[i][CHN_DATAPOS] += 3
							
						elsif cmd = CMD_END then
							channel[i][4] = cmd
							channelDone[i] = 1
							freqChange = 2

						end if

						channel[i][CHN_DATAPOS] += 1
						iterations[2] += 1
						if iterations[2] = 131072 then
							puts(1, "Internal error: Appears to be stuck in an infinite loop. Exiting\n")
							? {i, channel[1][2], channel[2][2], channel[3][2], channel[4][2]}
							exit
						end if
					end while
				else

					-- Update effects as needed
					if channel[i][CHN_VOLMAC][1] then
						vgm_step_effect(i, CHN_VOLMAC, volumeMacros, VGM_STEP_FRAME, ID_VGM_NEW_VOLUME)
					end if
					if channel[i][CHN_ENMAC][1] then
						vgm_step_effect(i, CHN_ENMAC, arpeggios, VGM_STEP_FRAME, ID_VGM_NEW_NOTEOFFS)
					end if
					if channel[i][CHN_EN2MAC][1] then
						vgm_step_effect(i, CHN_EN2MAC, arpeggios, VGM_STEP_FRAME, ID_VGM_NEW_NOTEOFFS)
					end if
					if channel[i][CHN_EPMAC][1] then
						vgm_step_effect(i, CHN_EPMAC, pitchMacros, VGM_STEP_FRAME, ID_VGM_NEW_FREQOFFS)
					end if
					if channel[i][CHN_MPMAC][1] then
						if and_bits(channel[i][CHN_MPMAC][1], #80) = VGM_STEP_FRAME then
							if channel[i][CHN_MPMAC][3] = 0 then
								channel[i][9] = channel[i][10]
								channel[i][10] = -channel[i][10]
								channel[i][CHN_MPMAC][3] = vibratos[2][and_bits(channel[i][CHN_MPMAC][1], #7F)][2][2]
								freqChange = 1
							end if
							channel[i][18][3] -= 1
						end if
					end if
					if channel[i][CHN_DUTMAC][1] then
						vgm_step_effect(i, CHN_DUTMAC, dutyMacros, VGM_STEP_FRAME, ID_VGM_NEW_DUTY)
					end if

					if channel[i][CHN_FBKMAC][1] then
						vgm_step_effect(i, 33, feedbackMacros, VGM_STEP_FRAME, ID_VGM_NEW_FEEDBACK)
					end if

					-- Panning
					if channel[i][CHN_PANMAC][1] then 
						vgm_step_effect(i, CHN_PANMAC, panMacros, VGM_STEP_FRAME, ID_VGM_NEW_PANNING)

					end if
				end if
				if channel[i][4] = CMD_END or channel[i][4] = CMD_REST then
					if ((sequence(lastChannelSetting[i][2]) and sum(lastChannelSetting[i][2]) != 0) or
					    (integer(lastChannelSetting[i][2]) and lastChannelSetting[i][2] != 0)) or
					   (ym2612 and i = 10 and channel[i][CHN_MODE] = 2) then
						if channelType[i] = TYPE_SN76489 then
							vgmData &= {#50, or_bits(#9F, (i - 1) * #20)}
							vgmData &= {#50, or_bits(#1F, (i - 1) * #20)}
							lastChannelSetting[i] = {-1, 0, lastChannelSetting[i][3]}
						elsif ym2413 and in_range(i, 5, 13) then
							if channel[i][CHN_MODE] = 0 then
								--vgmData &= {#51, #30 + (i - 5), channel[i][7] + #0F}
								vgmData &= {#51, #20 + (i - 5), floor(channel[i][8] / #100)}
								--lastChannelSetting[i] = {-1, 0, lastChannelSetting[i][3]}
							elsif i = 11 and channel[i][CHN_MODE] = 1 then
								rhythm = and_bits(rhythm, #20) --#2F)
								vgmData &= {#51, #0E, rhythm}
							elsif i = 12 and channel[i][CHN_MODE] = 1 then
								--rhythm = and_bits(rhythm, #36)
								--vgmData &= {#51, #0E, rhythm}
							elsif i = 13 and channel[i][CHN_MODE] = 1 then
								--rhythm = and_bits(rhythm, #39)
								--vgmData &= {#51, #0E, rhythm}
							end if
						elsif channelType[i] = TYPE_YM2612 then
							if channel[i][CHN_MODE] = 0 then
								vgmData &= {#52, -- + floor((i - 5) / 3),
								            #28,
								            i +floor((i - 5) / 3)- 5} --remainder(i - 5, 3)}
								--lastChannelSetting[i] = {-1, lastChannelSetting[i][2], lastChannelSetting[i][3]}
							elsif channel[i][CHN_MODE] = 2 and i = 10 then
								if lastChannelSetting[i][4] then
									-- Turn off DAC
									vgmData &= {#52, #2B, #00}
									lastChannelSetting[i][4] = 0
								end if
							end if
						elsif channelType[i] = TYPE_YM2151 then
							vgmData &= {#54, #08, i - 1}
						end if
					end if
					if channel[i][4] = CMD_END then
						channelDone[i] = 1
						channelLooped[i] = 1
					end if
				else	
					if freqChange and not channelDone[i] then
						if i < 4 and psg then
							if channel[i][CHN_OCTAVE] + channel[i][CHN_NOTE] + channel[i][CHN_NOTEOFFS] + channel[i][CHN_TRANSPOSE] < 0 then
								channel[i][8] = freqTbl[1][1]
							elsif channel[i][CHN_OCTAVE] + channel[i][CHN_NOTE] + channel[i][CHN_NOTEOFFS] + channel[i][CHN_TRANSPOSE] > 71 then --59 then
								channel[i][8] = freqTbl[1][72] --[60]
							else
								channel[i][8] = freqTbl[1][channel[i][CHN_OCTAVE] + channel[i][CHN_NOTE] + channel[i][CHN_NOTEOFFS] + channel[i][CHN_TRANSPOSE] + 1]
							end if
							channel[i][8] -= channel[i][9] + channel[i][21]

							if channel[i][8] >= #03EF then
								channel[i][8] = #03EF
							elsif channel[i][8] < #001C then
								channel[i][8] = #001C
							end if
							if channel[i][8] != lastChannelSetting[i][1] then
								vgmData &= {#50, or_bits(#80 + (i - 1) * #20, and_bits(channel[i][8], #0F))}
								vgmData &= {#50, floor(and_bits(channel[i][8], #3F0) / #10)}
								lastChannelSetting[i][1] = channel[i][8]
							end if
						elsif i = 4 and psg then
							vgmData &= {#50, #E0 + channel[i][CHN_DUTY] + and_bits(channel[i][CHN_NOTE] + channel[i][CHN_NOTEOFFS] + channel[i][CHN_TRANSPOSE], 3)}
							vgmData &= {#50, #60 + channel[i][CHN_DUTY] + and_bits(channel[i][CHN_NOTE] + channel[i][CHN_NOTEOFFS] + channel[i][CHN_TRANSPOSE], 3)}
							--printf(1, "$%02x\n", #E0 + channel[i][CHN_DUTY] + and_bits(channel[i][CHN_NOTE] + channel[i][CHN_NOTEOFFS] + channel[i][CHN_TRANSPOSE], 3))
							--? freqChange
						elsif in_range(i, 5, 13) and ym2413 then
							if freqChange = 2 then
								-- KEY_OFF
								vgmData &= {#51, #20 + (i - 5), floor(channel[i][8] / #100)}
							end if
							if i = 11 and channel[i][CHN_MODE] = 1 then
								vgmData &= {#51, #0E, #20} --and_bits(rhythm,#2F)}
								--? {#51, #0E, and_bits(rhythm,#2F)}
								rhythm = or_bits(rhythm, #10)
								vgmData &= {#51, #0E, #3F} --rhythm}
								--? {#51, #0E, rhythm}
								--vgmData &= {#51, #16, #20, #51, #26, #05}
								--? {1 , 2, 3}
							elsif i = 12 and channel[i][CHN_MODE] = 1 then
								--vgmData &= {#51, #0E, and_bits(rhythm,#36)}
								--rhythm = or_bits(rhythm, #08)
								--vgmData &= {#51, #0E, rhythm}
								--vgmData &= {#51, #17, #50, #51, #27, #05}
							elsif i = 13 and channel[i][CHN_MODE] = 1 then
								--vgmData &= {#51, #0E, and_bits(rhythm,#39)}
								--rhythm = or_bits(rhythm, #02)
								--vgmData &= {#51, #0E, rhythm}
								--vgmData &= {#51, #18, #C0, #51, #28, #01}
							else
								f = (channel[i][CHN_OCTAVE] + 1) * 12 + channel[i][CHN_NOTE] + channel[i][CHN_NOTEOFFS] + channel[i][CHN_TRANSPOSE]
								if f < 0 then
									channel[i][8] = freqTbl[2][1]
									fhi = 0
								elsif f > 95 then
									channel[i][8] = freqTbl[2][12]
									fhi = 7 * #200
								else
									channel[i][8] = freqTbl[2][remainder(f, 12) + 1]
									fhi = floor(f / 12) * #200
								end if
								channel[i][8] += channel[i][9] + channel[i][21]

								if channel[i][8] >= 511 then
									channel[i][8] = 511
								elsif channel[i][8] < 0 then
									channel[i][8] = 0
								end if
								channel[i][8] += fhi

								if channel[i][8] != lastChannelSetting[i][1] then
									vgmData &= {#51, #10 + (i - 5), and_bits(channel[i][8], #FF)}
									lastChannelSetting[i][1] = channel[i][8]
								end if
								vgmData &= {#51, #20 + (i - 5), floor(channel[i][8] / #100) + #30}
								--printf(1, "Ch%d: Writing %02x to %02x, ", {i-5, and_bits(channel[i][8], #FF), #10 + (i - 5)})
								--printf(1, "%02x to %02x\n", {floor(channel[i][8] / #100) + #30, #20 + (i - 5)})
							end if								
						elsif channelType[i] = TYPE_YM2612 then
							if i = 10 and channel[i][CHN_MODE] = 2 then
								-- PCM mode
								pcmDelay = 0
								pcmDelayReload = 5
								f = channel[i][CHN_OCTAVE]*12 + channel[i][CHN_NOTE] + channel[i][CHN_NOTEOFFS] + channel[i][CHN_TRANSPOSE]
								if assoc_find_key(pcms, f) then
									pcmDataLen = length(pcms[2][assoc_find_key(pcms, f)][3])
									pcmDataPos = 0
									for j = 1 to length(pcms[1]) do
										if pcms[1][j] < f then
											pcmDataPos += length(pcms[2][j][3])
										end if
									end for
									--printf(1,"Found matching PCM data for note %d. Offset = %d, length = %d\n",{f, pcmDataPos, pcmDataLen})
									vgmData &= #E0 & int_to_bytes(pcmDataPos)
									if lastChannelSetting[i][4] = 0 then
										vgmData &= {#52, #2B, #80}
										lastChannelSetting[i][4] = 1
									end if
									pcmDataPos = 1
								else
									WARNING(sprintf("No matching PCM sample found for note %d", f), -1)
								end if
							else	
								-- FM mode
								if freqChange = 2 then
									-- KEY_OFF
									vgmData &= {#52, 
										    #28,
										    i + floor((i - 5) / 3) - 5} 
								end if
								f = channel[i][CHN_OCTAVE] * 12 + channel[i][CHN_NOTE] + channel[i][CHN_NOTEOFFS] + channel[i][CHN_TRANSPOSE] 
								if f < 0 then
									channel[i][8] = freqTbl[3][1]
								elsif f > 95 then
									channel[i][8] = freqTbl[3][12] + 7 * #800
								else
									channel[i][8] = freqTbl[3][remainder(f, 12) + 1] + floor(f / 12) * #800
								end if
								if channel[i][8] != lastChannelSetting[i][1] then
									vgmData &= {#52 + floor((i - 5) / 3),
										    #A4 + remainder((i - 5), 3),
										    floor(channel[i][8] / #100)}
									vgmData &= {#52 + floor((i - 5) / 3),
										    #A0 + remainder((i - 5), 3),
										    and_bits(channel[i][8], #FF)}
									--? vgmData[length(vgmData)-5..length(vgmData)]
									lastChannelSetting[i][1] = channel[i][8]
								end if
								vgmData &= {#52, 
									    #28,
									    #F0 + i +floor((i - 5) / 3)- 5} 
								--? vgmData[length(vgmData)-2..length(vgmData)]
							end if
						elsif channelType[i] = TYPE_YM2151 then
							--puts(1,"KEY_ON\n")
							if freqChange = 2 then
								-- KEY_OFF
								vgmData &= {#54, #08, i - 1}
							end if
							f = (channel[i][CHN_OCTAVE] + 1) * 12 + channel[i][CHN_NOTE] + channel[i][CHN_NOTEOFFS] + channel[i][CHN_TRANSPOSE]
							if f < 0 then
								channel[i][8] = freqTbl[4][1]
							elsif f > 95 then
								channel[i][8] = freqTbl[4][12] + 7 * #10
							else
								channel[i][8] = freqTbl[4][remainder(f, 12) + 1] + floor(f / 12) * #10
								if remainder(f, 12) = 0 then
									channel[i][8] -= #10
								end if
							end if
							if i = 8 and channel[i][CHN_MODE] = 1 then
								-- Noise mode
								if channel[i][8] != lastChannelSetting[i][1] then
									vgmData &= {VGM_CMD_W_YM2151,
										    #0F,
										    #80 + remainder(channel[i][8], #1F)}
									--lastChannelSetting[i][1] = channel[i][8]
								end if
							end if
							--else
								-- FM mode
								if channel[i][8] != lastChannelSetting[i][1] then
									vgmData &= {VGM_CMD_W_YM2151,
										    #28 + i - 1,
										    channel[i][8]}
									lastChannelSetting[i][1] = channel[i][8]
								end if
							--end if
							-- KEY_ON
							vgmData &= {VGM_CMD_W_YM2151, #08, #E8 + i - 1} 
						end if
					end if
					
					if volChange then
						if channelType[i] = TYPE_SN76489 then
							vol = channel[i][CHN_VOLUME] + channel[i][12]
							if vol != lastChannelSetting[i][2] then
								if vol > 15 then
									vol = 15
								elsif vol < 0 then
									vol = 0
								end if
								vgmData &= {VGM_CMD_W_PSG, or_bits(#90 + xor_bits(vol, 15), (i - 1) * #20)}
								vgmData &= {VGM_CMD_W_PSG, or_bits(#10 + xor_bits(vol, 15), (i - 1) * #20)}
								lastChannelSetting[i][2] = vol
							end if
						elsif ym2413 and in_range(i, 5, 13) then
							vol = channel[i][CHN_VOLUME] + channel[i][12]
							if vol != lastChannelSetting[i][2] then
								if vol > 15 then
									vol = 15
								elsif vol < 0 then
									vol = 0
								end if
								--if channel[i][CHN_MODE] = 0 then
								--? vol
								lastChannelSetting[i][2] = vol
								vol = xor_bits(vol, 15)
								if channel[i][CHN_MODE] != 1 then
									vol += channel[i][7]
									vgmData &= {#51, #30 + (i - 5), vol}
									--printf(1, "*Ch%d: Writing %02x to %02x\n", {i-5, vol, #30 + (i - 5)})
								else
									--vgmData &= {#51, #30 + (i - 5), vol}
									vgmData &= {#51, #36, #00}
									vgmData &= {#51, #37, #00}
									vgmData &= {#51, #38, #00}
									--printf(1, "#Ch%d: Writing %02x to %02x\n", {i-5, #F0 + vol, #30 + (i - 5)})									
								end if
								--elsif channel[i][CHN_MODE] = 1 and in_range(i, 11, 13) then
								--	vgmData &= {#51, #30 + (i - 2), xor_bits(vol, 15)}
								--	printf(1, "Ch%d: Writing %02x to %02x\n", {i-5, xor_bits(vol, 15), #30 + (i - 2)})
								--end if
								--lastChannelSetting[i][2] = vol
							end if
						elsif channelType[i] = TYPE_YM2612 then
							for j = 1 to 4 do
								--if j = channel[i][CHN_OPER] or channel[i][CHN_OPER] = 0 then
									vol = channel[i][CHN_VOLUME][j] + channel[i][12]
									if vol != lastChannelSetting[i][2][j] then
										if vol > 127 then
											vol = 127
										elsif vol < 0 then
											vol = 0
										end if
										if channel[i][CHN_MODE] = 0 then
											vgmData &= {#52 + floor((i - 5) / 3),
												    #40 + (j - 1) * 4 + remainder((i - 5), 3),
												    xor_bits(vol, 127)}
										--? {i, j, xor_bits(vol, 127)}
										end if
										lastChannelSetting[i][2][j] = vol
									end if
								--end if
							end for
						elsif channelType[i] = TYPE_YM2151 then
							for j = 1 to 4 do
								--if j = channel[i][CHN_OPER] or channel[i][CHN_OPER] = 0 then
									--? {i, j, channel[i][CHN_VOLUME][j]}
									vol = channel[i][CHN_VOLUME][j] + channel[i][12]
									if vol != lastChannelSetting[i][2][j] then
										if vol > 127 then
											vol = 127
										elsif vol < 0 then
											vol = 0
										end if
										vgmData &= {VGM_CMD_W_YM2151,
											    #60 + (j - 1) * 8 + i - 1,
											    xor_bits(vol, 127)}
										lastChannelSetting[i][2][j] = vol
									end if
								--end if
							end for
						end if
					end if
				end if
			end if
		end for
		
		
		if updateFreq = 50 then
			chnUpdateDelay = 882
		else
			chnUpdateDelay = 735
		end if
		
		if ym2612 and channel[10][23] = 2 and pcmDelay >= 0 then
			if pcmDelay > 0 and pcmDelay <= chnUpdateDelay then
				if pcmDelay < 16 then
					vgmData &= or_bits(#70, pcmDelay)
				else
					vgmData &= {#61, and_bits(pcmDelay, #FF), floor(pcmDelay / #100)}
				end if
				chnUpdateDelay -= pcmDelay
				totalWaits += pcmDelay
			end if
			pcmDelay = pcmDelayReload
			while pcmDelay <= chnUpdateDelay do
				if pcmDataPos <= pcmDataLen then
					vgmData &= or_bits(#80, pcmDelay)
					chnUpdateDelay -= pcmDelay
					totalWaits += pcmDelay
					pcmDataPos += 1
				else
					--vgmData &= {#52, #2A, #00}
					pcmDelay = -1
					exit
				end if
			end while
			if chnUpdateDelay > 0 and chnUpdateDelay < pcmDelay then
				pcmDelay -= chnUpdateDelay
			end if
		end if
		
		if chnUpdateDelay = 882 then
			vgmData &= #63
		elsif chnUpdateDelay = 735 then
			vgmData &= #62
		elsif chnUpdateDelay > 0 then
			if chnUpdateDelay < 16 then
				vgmData &= or_bits(#70, chnUpdateDelay)
			else
				vgmData &= {#61, and_bits(chnUpdateDelay, #FF), floor(chnUpdateDelay / #100)}
			end if
		end if
		
		totalWaits += chnUpdateDelay
		
		iterations[1] += 1
		if iterations[1] = 54000 then
			puts(1, "Internal error: Appears to be stuck in an infinite loop. Exiting\n")
			? {channel[1][2], channel[2][2], channel[3][2], channel[4][2]}
			exit
		end if
	end while
	--? vgmData[#40..length(vgmData)]
	
	if length(loopPos) then
		vgmData = vgmData[1..#18] &
			  int_to_bytes(totalWaits) &
			  int_to_bytes(loopPos[1] - #1C) &
			  int_to_bytes(totalWaits - loopPos[2]) &
			  vgmData[#25..length(vgmData)]
		loopPos[2] = totalWaits - loopPos[2]
	else
		vgmData = vgmData[1..#18] & int_to_bytes(totalWaits) & vgmData[#1D..length(vgmData)]
		loopPos = {0, 0}
	end if	

	vgmData &= #66
	
	-- Set EOF offset and GD3 offset
	vgmData = vgmData[1..4] & int_to_bytes(length(vgmData) - 4) & vgmData[9..length(vgmData)]
	vgmData = vgmData[1..#14] & int_to_bytes(length(vgmData) - #14) & vgmData[#19..length(vgmData)]


	if compressVgm then
		if gzwrite(outFile, vgmData) != length(vgmData) then
		end if
	else
		puts(outFile, vgmData)
	end if

	-- Create GD3 tag
	s = date()
	gd3 = ascii_to_wide(songTitle & 0 & 0)
	if equal(songGame, "Unknown") then
		gd3 &= ascii_to_wide(songAlbum & 0 & 0)
	else
		gd3 &= ascii_to_wide(songGame & 0 & 0)
	end if
	if ym2612 then
		gd3 &= ascii_to_wide("Sega Genesis" & 0 & 0)
	elsif ym2151 then
		gd3 &= ascii_to_wide("Capcom Play system" & 0 & 0)
	elsif supportsPAL then
		gd3 &= ascii_to_wide("Sega Master System" & 0 & 0)
	else
		gd3 &= ascii_to_wide("Sega Game Gear" & 0 & 0)
	end if
	gd3 &= ascii_to_wide(songProgrammer & 0 & 0)
	gd3 &= ascii_to_wide(sprintf("%04d/%02d/%02d", {s[1] + 1900, s[2], s[3]}) & 0)
	gd3 &= ascii_to_wide("XPMC" & 0)
	gd3 &= ascii_to_wide("Composer: " & songComposer & 0)
	gd3 = "Gd3 " &
	      {0, 1, 0, 0} &
	      int_to_bytes(length(gd3)) &
	      gd3


	if compressVgm then
		if gzwrite(outFile, gd3) != length(gd3) then
		end if
		if gzclose(outFile) != Z_OK then
		end if
	else
		puts(outFile, gd3)
		close(outFile)
	end if

	if verbose then
		for i = 1 to nChannels do
			printf(1, "Song %d, Channel " & supportedChannels[i] & ": %d / %d ticks\n", {song, round2(songLen[song][i]), round2(songLoopLen[song][i])})
		end for
		printf(1,"VGM size: %d bytes + %d bytes GD3\nVGM length: %d / %d seconds\n", {length(vgmData), length(gd3), floor(totalWaits / 44100), floor(loopPos[2] / 44100)})
	end if
end procedure


procedure vgm_new_noteoffs(sequence args)
	integer i,old
	i = args[1]
	old = channel[i][CHN_NOTEOFFS]
	if args[3] = CHN_EN2MAC or and_bits(channel[i][args[3]][1], #80) != args[2] then
		channel[i][CHN_NOTEOFFS] = channel[i][args[3]][LIST_RET][LIST_VAL]
	else
		channel[i][CHN_NOTEOFFS] += channel[i][args[3]][LIST_RET][LIST_VAL]
	end if
	if old != channel[i][CHN_NOTEOFFS] and freqChange != 2 then
		freqChange = 1
	end if
end procedure
ID_VGM_NEW_NOTEOFFS = routine_id("vgm_new_noteoffs")


procedure vgm_new_freqoffs(sequence args)
	integer i
	i = args[1]
	if and_bits(channel[i][args[3]][1], #80) != args[2] then
		channel[i][9] = channel[i][args[3]][LIST_RET][LIST_VAL]
	else
		channel[i][9] += channel[i][args[3]][LIST_RET][LIST_VAL]
	end if
	if freqChange != 2 then
		freqChange = 1
	end if
end procedure
ID_VGM_NEW_FREQOFFS = routine_id("vgm_new_freqoffs")


procedure vgm_new_volume(sequence args)
	integer i
	i = args[1]
	if sequence(channel[i][CHN_VOLUME]) then
		if channel[i][CHN_OPER] then
			channel[i][CHN_VOLUME][channel[i][CHN_OPER]] = channel[i][CHN_VOLMAC][LIST_RET][LIST_VAL]
		else
			channel[i][CHN_VOLUME] = repeat(channel[i][CHN_VOLMAC][LIST_RET][LIST_VAL], length(channel[i][CHN_VOLUME]))
		end if
	else
		channel[i][CHN_VOLUME] = channel[i][CHN_VOLMAC][LIST_RET][LIST_VAL]
	end if
	volChange = 1
end procedure
ID_VGM_NEW_VOLUME = routine_id("vgm_new_volume")


procedure vgm_new_duty(sequence args)
	integer i,old
	i = args[1]

	old = channel[i][7]
	channel[i][7] = channel[i][CHN_DUTMAC][3][3]
	if channelType[i] = TYPE_SN76489 and i = 4 then
		channel[i][7] = and_bits(xor_bits(channel[i][7], 1), 1) * 4
		--? channel[i][7]
		if old != channel[i][7] and freqChange != 2 then
			freqChange = 1
		end if
	elsif channelType[i] = TYPE_YM2413 then
		channel[i][7] = and_bits(channel[i][7], #0F) * 16
	elsif channelType[i] = TYPE_YM2612 then
		channel[i][7] = and_bits(channel[i][7], 7)
		vgmData &= {#52 + floor((i - 5) / 3),
		            #B0 + remainder((i - 5), 3),
		            channel[i][7] + channel[i][24]}
	end if
end procedure
ID_VGM_NEW_DUTY = routine_id("vgm_new_duty")


procedure vgm_new_feedback(sequence args)
	integer i
	i = args[1]

	channel[i][24] = channel[i][CHN_FBKMAC][LIST_RET][LIST_VAL]
	if channelType[i] = TYPE_YM2612 then
		vgmData &= {#52 + floor((i - 5) / 3),
			    #B0 + remainder((i - 5), 3),
			    channel[i][7] + channel[i][24]}
	end if
end procedure
ID_VGM_NEW_FEEDBACK = routine_id("vgm_new_feedback")


procedure vgm_new_panning(sequence args)
	integer i
	i = args[1]
	
	if channel[i][CHN_PANMAC][3][3] then
		if and_bits(channel[i][CHN_PANMAC][3][3], #80) then
			if channelType[i] = TYPE_SN76489 then
				channel[1][CHN_PANMAC][2] = clear_bit(channel[1][CHN_PANMAC][2], i - 1)
				channel[1][CHN_PANMAC][2] =   set_bit(channel[1][CHN_PANMAC][2], i + 3)
			elsif channelType[i] = TYPE_YM2612 then
				channel[i][CHN_PANMAC][2] = clear_bit(channel[i][CHN_PANMAC][2], 6)
				channel[i][CHN_PANMAC][2] =   set_bit(channel[i][CHN_PANMAC][2], 7)
			elsif channelType[i] = TYPE_YM2151 then
				channel[i][CHN_PANMAC][2] = clear_bit(channel[i][CHN_PANMAC][2], 7)
				channel[i][CHN_PANMAC][2] =   set_bit(channel[i][CHN_PANMAC][2], 6)
			end if
		else
			if channelType[i] = TYPE_SN76489 then
				channel[1][CHN_PANMAC][2] = clear_bit(channel[1][CHN_PANMAC][2], i + 3)
				channel[1][CHN_PANMAC][2] =   set_bit(channel[1][CHN_PANMAC][2], i - 1)
			elsif channelType[i] = TYPE_YM2612 then
				channel[i][CHN_PANMAC][2] = clear_bit(channel[i][CHN_PANMAC][2], 7)
				channel[i][CHN_PANMAC][2] =   set_bit(channel[i][CHN_PANMAC][2], 6)
			elsif channelType[i] = TYPE_YM2151 then
				channel[i][CHN_PANMAC][2] = clear_bit(channel[i][CHN_PANMAC][2], 6)
				channel[i][CHN_PANMAC][2] =   set_bit(channel[i][CHN_PANMAC][2], 7)
			end if
		end if
	else
		if channelType[i] = TYPE_SN76489 then
			channel[1][CHN_PANMAC][2] = set_bit(channel[1][CHN_PANMAC][2], i - 1)
			channel[1][CHN_PANMAC][2] = set_bit(channel[1][CHN_PANMAC][2], i + 3)
		elsif channelType[i] = TYPE_YM2612 or channelType[i] = TYPE_YM2151 then
			channel[i][CHN_PANMAC][2] = set_bit(channel[i][CHN_PANMAC][2], 6)
			channel[i][CHN_PANMAC][2] = set_bit(channel[i][CHN_PANMAC][2], 7)
		end if
	end if
	if channelType[i] = TYPE_SN76489 and channel[1][CHN_PANMAC][2] != lastChannelSetting[1][3] then
		vgmData &= {#4F, channel[1][CHN_PANMAC][2]}
		lastChannelSetting[1][3] = channel[1][CHN_PANMAC][2]
	elsif channelType[i] = TYPE_YM2612 then
		if sequence(channel[i][30][3]) then
			vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
				    #B4 + remainder((i - 5), 3),
				    and_bits(#C0, channel[i][CHN_PANMAC][2]) + channel[i][30][3][2]}
		else
			vgmData &= {VGM_CMD_W_YM2612L + floor((i - 5) / 3),
				    #B4 + remainder((i - 5), 3),
				    and_bits(#C0, channel[i][CHN_PANMAC][2])}
		end if
	elsif channelType[i] = TYPE_YM2151 then
		vgmData &= {VGM_CMD_W_YM2151,
			    #20 + i - 1,
			    and_bits(#C0, channel[i][CHN_PANMAC][2]) + channel[i][7] + channel[i][24]}
	end if
end procedure
ID_VGM_NEW_PANNING = routine_id("vgm_new_panning")
