include globals.e
include output.e
include specs_sn76489.e
include specs_ym2612.e
include util.e
include vgm.e


global procedure init_gen()
	define("GEN", 1)
	define("SMD", 1)
	
	set_channel_specs(specs_sn76489, 1, 1)
	set_channel_specs(specs_ym2612,  1, 5)

	activeChannels 		= repeat(0, length(supportedChannels))

	maxTempo 		= 300
	minVolume 		= 0
	supportsPan 		= 1
	maxLoopDepth 		= 2
	supportsPAL 		= 1
	adsrLen			= 5
	adsrMax			= 63
	minWavLength 		= 1
	maxWavLength 		= 2097152 -- 2MB
	minWavSample 		= 0
	maxWavSample		= 255
end procedure



-- Output data suitable for the SEGA Genesis (Megadrive) playback library
global procedure output_gen(sequence args)
	atom factor
	integer f, machineSpeed, tableSize, cbSize, songSize, patSize, numSongs
	sequence freqTbl, oct1, fileEnding, s, e
	
	if args[1] = 1 then
		fileEnding = ".vgm"
	elsif args[1] = 2 then
		fileEnding = ".vgz"
	else
		fileEnding = ".s"
	end if

	-- Convert ADSR envelopes to the format used by the YM2612
	for i = 1 to length(adsrs[2]) do
		s = {0, 0, 0, 0}
		e = adsrs[2][i][2]
		s[1] = e[1]
		s[2] = e[2]
		s[3] = e[3]
		s[4] = floor(e[5] / 2) + floor(xor_bits(e[4], 31) / 2) * #10
		adsrs[2][i][2] = s
	end for
	
	for i = 1 to length(mods[ASSOC_DATA]) do
		s = mods[ASSOC_DATA][i][LIST_MAIN]
		s[2] = s[2] * 8 + s[3]
		mods[ASSOC_DATA][i][LIST_MAIN] = s[1..2]
	end for
	
	for i = 1 to length(feedbackMacros[1]) do
		feedbackMacros[ASSOC_DATA][i][LIST_MAIN] = (feedbackMacros[ASSOC_DATA][i][LIST_MAIN])*8
		feedbackMacros[ASSOC_DATA][i][LIST_LOOP] = (feedbackMacros[ASSOC_DATA][i][LIST_LOOP])*8
	end for
	
	numSongs = 0
	for i = 1 to length(songs) do
		if sequence(songs[i]) then
			numSongs += 1
		end if
	end for
	
	if args[1] then
		if numSongs = 1 then
			write_vgm(shortFilename & fileEnding, 1, PSG_ENABLED, YM2151_DISABLED, YM2413_DISABLED, YM2612_ENABLED)
		else
			for i = 1 to length(songs) do
				if sequence(songs[i]) then
					write_vgm(shortFilename & sprintf("_song%d", i) & fileEnding, i, PSG_ENABLED, YM2151_DISABLED, YM2413_DISABLED, YM2612_ENABLED)
				end if
			end for
		end if
	else
		outFile = open(shortFilename & fileEnding, "wb")
		if outFile = -1 then
			ERROR("Unable to open file: " & shortFilename & fileEnding, -1)
		end if

		s = date()
		printf(outFile, "# Written by XPMC at %02d:%02d:%02d on " & WEEKDAYS[s[7]] & " " & MONTHS[s[2]] & " %d, %d." & CRLF & CRLF,
		       s[4..6] & {s[3], s[1] + 1900})
		       
		if updateFreq = 50 then
			puts(outFile, ".equ XPMP_50_HZ, 1" & CRLF)
			machineSpeed = 3546893
		else
			machineSpeed = 3579545
		end if
		
		tableSize  = output_m68kas_table("xpmp_dt_mac", dutyMacros,   1, 1, 0)
		tableSize += output_m68kas_table("xpmp_v_mac",  volumeMacros, 1, 1, 0)
		tableSize += output_m68kas_table("xpmp_VS_mac", volumeSlides, 1, 1, 0)
		tableSize += output_m68kas_table("xpmp_EP_mac", pitchMacros,  1, 1, 0)
		tableSize += output_m68kas_table("xpmp_EN_mac", arpeggios,    1, 1, 0)
		tableSize += output_m68kas_table("xpmp_FB_mac", feedbackMacros,1, 1, 0)
		tableSize += output_m68kas_table("xpmp_MP_mac", vibratos,     0, 1, 0)
		tableSize += output_m68kas_table("xpmp_CS_mac", panMacros,    1, 1, 0)
		tableSize += output_m68kas_table("xpmp_ADSR",   adsrs,        0, 1, 0)
		tableSize += output_m68kas_table("xpmp_MOD",    mods,         0, 1, 0)

		cbSize = 0
		
		if verbose then
			printf(1, "Size of effect tables: %d bytes\n", tableSize)
		end if

		patSize = 0
		for n = 1 to length(patterns[2]) do
			printf(outFile, "xpmp_pattern%d:", n)
			for j = 1 to length(patterns[2][n]) do
				if remainder(j, 16) = 1 then
					puts(outFile, CRLF & "dc.b ")
				end if				
				printf(outFile, "0x%02x", and_bits(patterns[2][n][j], #FF))
				if j < length(patterns[2][n]) and remainder(j, 16) != 0 then
					puts(outFile, ",")
				end if

			end for
			puts(outFile, CRLF)
			patSize += length(patterns[2][n])
		end for

		puts(outFile, CRLF & ".globl xpmp_pattern_tbl" & CRLF)
		puts(outFile, "xpmp_pattern_tbl:" & CRLF)
		for n = 1 to length(patterns[2]) do
			printf(outFile, "dc.w xpmp_pattern%d" & {13, 10}, n)
			patSize += 4
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
							puts(outFile, CRLF & "dc.b ")
						end if				
						printf(outFile, "0x%02x", and_bits(songs[n][i][j], #FF))
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

		puts(outFile, CRLF & ".globl xpmp_song_tbl")
		puts(outFile, CRLF & "xpmp_song_tbl:" & CRLF)
		for n = 1 to length(songs) do
			if sequence(songs[n]) then
				for i = 1 to length(supportedChannels)-1 do
					s = sprintf("xpmp_s%d_channel_" & supportedChannels[i], n)
					printf(outFile, "dc.w %s" & CRLF, {s})
					songSize += 4
				end for
			end if
		end for
		puts(outFile, "dc.w 0" & CRLF)
		songSize += 4
		
		if verbose then
			printf(1, "Total size of song(s): %d bytes\n", songSize + patSize + tableSize + cbSize)
		end if
		
		close(outFile)
	end if
end procedure


add_target(TARGET_SMD, "gen", routine_id("init_gen"), routine_id("output_gen"))
