include globals.e
include output.e
include specs_ay-3-8910.e
include specs_scc.e
include specs_sn76489.e
include specs_ym2151.e
include specs_ym2413.e
include util.e


global procedure init_kss()
	define("KSS", 1)
	
	set_channel_specs(specs_sn76489,    1,  1)
	set_channel_specs(specs_ay_3_8910,  1,  5)
	set_channel_specs(specs_scc,        1,  8)
	set_channel_specs(specs_ym2151,     1, 13)
	
	activeChannels 		= repeat(0, length(supportedChannels))	
	maxTempo 		= 300
	minVolume 		= 0
	supportsPan 		= 1
	maxLoopDepth 		= 2
 	  adsrLen			= 5
	adsrMax			= 63
	minWavLength		= 32
	maxWavLength		= 32
	minWavSample 		= -128
	maxWavSample		= 127
end procedure



-- Output data suitable for the KSS playback library (WLA-DX)
global procedure output_kss(sequence args)
	atom factor
	integer f, machineSpeed, tableSize, cbSize, patSize, wavSize, songSize, numSongs, extraChips, usesPSG, usesSCC
	sequence freqTbl, oct1, fileEnding, e, s
	
	fileEnding = ".asm"

	extraChips = 0
	usesSCC = 0
	usesPSG = 0
	
	numSongs = 0
	for i = 1 to length(songs) do
		if sequence(songs[i]) then
			numSongs += 1
			if (length(songs[i][1]) + length(songs[i][2]) +
			    length(songs[i][3]) + length(songs[i][4])) != 4 then
				extraChips = or_bits(extraChips, 6)
			end if
			if (length(songs[i][5]) + length(songs[i][6]) +
			    length(songs[i][7])) != 3 then
				usesPSG = or_bits(usesPSG, 1)
			end if
			if (length(songs[i][8]) + length(songs[i][9]) +
			    length(songs[i][10]) + length(songs[i][11]) + length(songs[i][12])) != 5 then
				usesSCC = or_bits(usesSCC, 1)
			end if
			if (length(songs[i][13]) + length(songs[i][14]) +
			    length(songs[i][15]) + length(songs[i][16]) +
			    length(songs[i][17]) + length(songs[i][18]) +
			    length(songs[i][19]) + length(songs[i][20])) != 8 then
				extraChips = or_bits(extraChips, 3)
			end if
			
		end if
	end for


	-- Convert ADSR envelopes to the format used by the YM2151
	for i = 1 to length(adsrs[2]) do
		s = {0, 0, 0, 0}
		e = adsrs[2][i][2]
		s[1] = e[1]
		s[2] = e[2]
		s[3] = e[3]
		s[4] = floor(e[5] / 2) + floor(xor_bits(e[4], 31) / 2) * #10
		adsrs[2][i][2] = s
	end for
	
	for i = 1 to length(mods[2]) do
		s = mods[2][i][2]
		s[3] = or_bits(s[3], #80)
		s[4] += s[5] * #10
		s[5] = s[6] + #C0
		mods[2][i][2] = s[1..5]
	end for
	
	for i = 1 to length(feedbackMacros[1]) do
		feedbackMacros[2][i][2] = (feedbackMacros[2][i][2])*8
		feedbackMacros[2][i][3] = (feedbackMacros[2][i][3])*8
	end for
	
	
	outFile = open(shortFilename & fileEnding, "wb")
	if outFile = -1 then
		ERROR("Unable to open file: " & shortFilename & fileEnding, -1)
	end if
	s = date()
	printf(outFile, "; Written by XPMC at %02d:%02d:%02d on " & WEEKDAYS[s[7]] & " " & MONTHS[s[2]] & " %d, %d." & {13, 10, 13, 10},
	       s[4..6] & {s[3], s[1] + 1900})
	       
	--if updateFreq = 50 then
	--	puts(outFile, ".DEFINE XPMP_50_HZ" & {13, 10})
	--	machineSpeed = 3546893
	--else
		machineSpeed = 3579545
	--end if


	puts(outFile, 
		".IFDEF XPMP_MAKE_KSS" & CRLF &
		".memorymap" & CRLF &
   		"defaultslot 0" & CRLF &
   		"slotsize $8010" & CRLF &
   		"slot 0 0" & CRLF &
		".endme" & CRLF & CRLF &
		".rombanksize $8010" & CRLF &
		".rombanks 1" & CRLF & CRLF &
   		".orga   $0000" & CRLF &   
   		".db      \"KSCC\"   ; Magic string" & CRLF &
   		".dw   $0000   ; Load address" & CRLF &
   		".dw   $8000   ; Data length" & CRLF &
   		".dw   $7FF0   ; Driver initialize function" & CRLF &
   		".dw   $0000   ; Play address" & CRLF &
   		".db   $00   ; No. of banks" & CRLF &
   		".db   $00   ; extra" & CRLF &
   		".db   $00   ; reserved" & CRLF)
   	printf(outFile,
   		".db   $%02x   ; Extra chips" & CRLF & CRLF &
		".incbin \"kss.bin\"" & CRLF & CRLF &
		".ELSE" & CRLF & CRLF, extraChips)

	if sum(assoc_get_references(volumeMacros)) = 0 then --not length(volumeMacros[1]) then
		puts(outFile, ".DEFINE XPMP_VMAC_NOT_USED" & CRLF)
	end if
	if sum(assoc_get_references(pitchMacros)) = 0 then
		puts(outFile, ".DEFINE XPMP_EPMAC_NOT_USED" & CRLF)
	end if
	if sum(assoc_get_references(vibratos)) = 0 then
		puts(outFile, ".DEFINE XPMP_MPMAC_NOT_USED" & CRLF)
	end if
	if not usesEN[1] then
		puts(outFile, ".DEFINE XPMP_ENMAC_NOT_USED" & CRLF)
	end if
	if not usesEN[2] then
		puts(outFile, ".DEFINE XPMP_EN2MAC_NOT_USED" & CRLF)
	end if
	if usesPSG then
		puts(outFile, ".DEFINE XPMP_USES_AY" & CRLF)
	end if
	if usesSCC then
		puts(outFile, ".DEFINE XPMP_USES_SCC" & CRLF)
	end if
	if and_bits(extraChips, 2) then
		if and_bits(extraChips, 1) then
			puts(outFile, ".DEFINE XPMP_USES_FMUNIT" & CRLF)
		else			
			puts(outFile, ".DEFINE XPMP_USES_SN76489" & CRLF)
		end if
	end if
	
	for i = 1 to length(supportedChannels)-1 do
		for j = 1 to length(usesEffect[i]) do
			if usesEffect[i][j] then
				printf(outFile, ".DEFINE XPMP_CHN%d_USES_%s" & CRLF, {i - 1, EFFECT_STRINGS[j]})
			end if
		end for
	end for

	tableSize  = output_wla_table("xpmp_dt_mac", dutyMacros,   1, 1, #80)
	tableSize += output_wla_table("xpmp_v_mac",  volumeMacros, 1, 1, #80)
	tableSize += output_wla_table("xpmp_VS_mac", volumeSlides, 1, 1, #80)
	tableSize += output_wla_table("xpmp_EP_mac", pitchMacros,  1, 1, #80)
	tableSize += output_wla_table("xpmp_FB_mac", feedbackMacros,    1, 1, #80)
	tableSize += output_wla_table("xpmp_EN_mac", arpeggios,    1, 1, #80)
	tableSize += output_wla_table("xpmp_MP_mac", vibratos,     0, 1, #80)
	tableSize += output_wla_table("xpmp_CS_mac", panMacros,    1, 1, #80)
	tableSize += output_wla_table("xpmp_WT_mac", waveformMacros, 1, 1, #80)
	tableSize += output_wla_table("xpmp_ADSR",   adsrs,        0, 1, 0)
	tableSize += output_wla_table("xpmp_MOD",    mods,         0, 1, 0)

	if verbose then
		printf(1, "Size of effect tables: %d bytes\n", tableSize)
	end if

	wavSize = 0
	puts(outFile, "xpmp_waveform_data:")
	for i = 1 to length(waveforms[1]) do
		for j = 1 to length(waveforms[2][i][2]) do
			if j = 1 then
				puts(outFile, CRLF & ".db ")
			end if				
			printf(outFile, "$%02x", and_bits(waveforms[2][i][2][j],255))
			wavSize += 1
			if j < length(waveforms[2][i][2]) then
				puts(outFile, ",")
			end if

		end for
	end for
	puts(outFile, {13, 10, 13, 10})
	
	cbSize = 0
	puts(outFile, "xpmp_callback_tbl:" & {13, 10})
	for i = 1 to length(callbacks) do
		puts(outFile, ".dw " & callbacks[i] & {13, 10})
		cbSize += 2
	end for
	puts(outFile, {13, 10})

	if verbose then
		printf(1, "Size of callback table: %d bytes\n", cbSize)
	end if

	patSize = 0
	for n = 1 to length(patterns[2]) do
		printf(outFile, "xpmp_pattern%d:", n)
		for j = 1 to length(patterns[2][n]) do
			if remainder(j, 16) = 1 then
				puts(outFile, CRLF & ".db ")
			end if				
			printf(outFile, "$%02x", and_bits(patterns[2][n][j], #FF))
			if j < length(patterns[2][n]) and remainder(j, 16) != 0 then
				puts(outFile, ",")
			end if
			end for
		puts(outFile, CRLF)
		patSize += length(patterns[2][n])
	end for

	puts(outFile, {13, 10} & "xpmp_pattern_tbl:" & CRLF)
	for n = 1 to length(patterns[2]) do
		printf(outFile, ".dw xpmp_pattern%d" & {13, 10}, n)
		patSize += 2
	end for
	puts(outFile, {13, 10})
		
	if verbose then
		printf(1, "Size of patterns table: %d bytes\n", patSize)
	end if

	songSize = 0
	for n = 1 to length(songs) do
		if sequence(songs[n]) then
			for i = 1 to length(supportedChannels)-1 do
				printf(outFile, "xpmp_s%d_channel_" & supportedChannels[i] & ":", n)
				for j = 1 to length(songs[n][i]) do
					if remainder(j, 16) = 1 then
						puts(outFile, CRLF & ".db ")
					end if				
					printf(outFile, "$%02x", and_bits(songs[n][i][j], #FF))
					if j < length(songs[n][i]) and remainder(j, 16) != 0 then
						puts(outFile, ",")
					end if
					end for
				puts(outFile, CRLF)
				printf(1, "Song %d, Channel " & supportedChannels[i] & ": %d bytes, %d / %d ticks\n", {n, length(songs[n][i]), round2(songLen[n][i]), round2(songLoopLen[n][i])})
				songSize += length(songs[n][i])
			end for
		end if
	end for

	puts(outFile, {13, 10} & "xpmp_song_tbl:" & CRLF)
	for n = 1 to length(songs) do
		if sequence(songs[n]) then
			for i = 1 to length(supportedChannels)-1 do
				printf(outFile, ".dw xpmp_s%d_channel_" & supportedChannels[i] & {13, 10}, n)
				songSize += 2
			end for
		end if
	end for

	puts(outFile, ".ENDIF" & CRLF)
	
	if verbose then
		printf(1, "Total size of song(s): %d bytes\n", songSize + patSize + wavSize + tableSize + cbSize)
	end if

	close(outFile)
end procedure


add_target(TARGET_KSS, "kss", routine_id("init_kss"), routine_id("output_kss"))
