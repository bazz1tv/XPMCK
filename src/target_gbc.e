include globals.e
include output.e
include specs_gbapu.e
include util.e


global procedure init_gbc()
	define("GBC", 1)

	set_channel_specs(specs_gbapu, 1, 1)

	activeChannels 		= repeat(0, length(supportedChannels))
	maxTempo 		= 300
	minVolume 		= 0
	supportsPan 		= 1
	maxLoopDepth 		= 2
	minWavLength		= 32
	maxWavLength		= 32
	minWavSample 		= 0
	maxWavSample		= 15
end procedure


-- Output data suitable for the Gameboy / Gameboy Color playback library (WLA-DX)
global procedure output_gbc(sequence args)
	atom factor,f2,r2,smallestDiff
	integer f, tableSize, cbSize, songSize, wavSize, patSize, numSongs
	sequence closest,s

	outFile = open(shortFilename & ".asm", "wb")
	if outFile = -1 then
		ERROR("Unable to open file: " & shortFilename & ".asm", -1)
	end if

	s = date()
	printf(outFile, "; Written by XPMC at %02d:%02d:%02d on " & WEEKDAYS[s[7]] & " " & MONTHS[s[2]] & " %d, %d." & {13, 10, 13, 10},
	       s[4..6] & {s[3], s[1] + 1900})

	numSongs = 0
	for i = 1 to length(songs) do
		if sequence(songs[i]) then
			numSongs += 1
		end if
	end for
	
	puts(outFile,
	".IFDEF XPMP_MAKE_GBS" & CRLF & CRLF &
	".MEMORYMAP" & CRLF &
	"\tDEFAULTSLOT 1"  & CRLF &
	"\tSLOTSIZE $4000"  & CRLF &
	"\tSLOT 0 $0000"  & CRLF &
	"\tSLOT 1 $4000"  & CRLF &
	".ENDME"  & CRLF & CRLF)
	puts(outFile,
	".ROMBANKSIZE $4000"  & CRLF &
	".ROMBANKS 2"  & CRLF &
	".BANK 0 SLOT 0"  & CRLF &
	".ORGA $00"  & CRLF & CRLF)
	
	puts(outFile,
	".db \"GBS\"" & CRLF &
	".db 1\t\t; Version" & CRLF &
	sprintf(".db %d\t\t; Number of songs", numSongs) & CRLF &
	".db 1\t\t; Start song" & CRLF &
	".dw $0400\t; Load address" & CRLF &
	".dw $0400\t; Init address" & CRLF &
	".dw $0408\t; Play address" & CRLF &
	".dw $fffe\t; Stack pointer" & CRLF &
	".db 0" & CRLF &
	".db 0" & CRLF)
	
	if length(songTitle) >= 32 then
		puts(outFile, ".db \"" & songTitle[1..31] & "\", 0" & CRLF)
	else
		puts(outFile, ".db \"" & songTitle & "\"")
		for i = 1 to 32 - length(songTitle) do
			puts(outFile, ", 0")
		end for
		puts(outFile, CRLF)
	end if
	if length(songComposer) >= 32 then
		puts(outFile, ".db \"" & songComposer[1..31] & "\", 0" & CRLF)
	else
		puts(outFile, ".db \"" & songComposer & "\"")
		for i = 1 to 32 - length(songComposer) do
			puts(outFile, ", 0")
		end for
		puts(outFile, CRLF)
	end if
	if length(songProgrammer) >= 32 then
		puts(outFile, ".db \"" & songProgrammer[1..31] & "\", 0" & CRLF)
	else
		puts(outFile, ".db \"" & songProgrammer & "\"")
		for i = 1 to 32 - length(songProgrammer) do
			puts(outFile, ", 0")
		end for
		puts(outFile, CRLF)
	end if	
	puts(outFile, ".INCBIN \"gbs.bin\"" & CRLF & CRLF)
	puts(outFile, ".ELSE" & CRLF & CRLF) 


	if sum(assoc_get_references(volumeMacros)) = 0 then 
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

	for i = 1 to length(supportedChannels)-1 do
		for j = 1 to length(usesEffect[i]) do
			if usesEffect[i][j] then
				printf(outFile, ".DEFINE XPMP_CHN%d_USES_%s" & CRLF, {i - 1, EFFECT_STRINGS[j]})
			end if
		end for
	end for
	
	if gbNoise = 1 then
		puts(outFile, ".DEFINE XPMP_ALT_GB_NOISE" & CRLF)
	end if
	if gbVolCtrl = 1 then
		puts(outFile, ".DEFINE XPMP_ALT_GB_VOLCTRL" & CRLF)
	end if
	
	tableSize  = output_wla_table("xpmp_dt_mac", dutyMacros,   1, 1, #80)
	tableSize += output_wla_table("xpmp_v_mac",  volumeMacros, 1, 1, #80)
	tableSize += output_wla_table("xpmp_VS_mac", volumeSlides, 1, 1, #80)
	tableSize += output_wla_table("xpmp_EP_mac", pitchMacros,  1, 1, #80)
	tableSize += output_wla_table("xpmp_EN_mac", arpeggios,    1, 1, #80)
	tableSize += output_wla_table("xpmp_MP_mac", vibratos,     0, 1, #80)
	tableSize += output_wla_table("xpmp_CS_mac", panMacros,    1, 1, #80)
	tableSize += output_wla_table("xpmp_WT_mac", waveformMacros, 1, 1, #80)
	
	wavSize = 0
	puts(outFile, "xpmp_waveform_data:")
	for i = 1 to length(waveforms[ASSOC_KEY]) do
		for j = 1 to length(waveforms[ASSOC_DATA][i][LIST_MAIN]) by 2 do
			if j = 1 then
				puts(outFile, CRLF & ".db ")
			end if				
			printf(outFile, "$%02x", waveforms[ASSOC_DATA][i][LIST_MAIN][j]*#10 + waveforms[ASSOC_DATA][i][LIST_MAIN][j+1])
			wavSize += 1
			if j < length(waveforms[ASSOC_DATA][i][LIST_MAIN]) - 1 then
				puts(outFile, ",")
			end if

		end for
	end for
	puts(outFile, {13, 10, 13, 10})
	
	cbSize = 0
	puts(outFile, "xpmp_callback_tbl:" & CRLF)
	for i = 1 to length(callbacks) do
		puts(outFile, ".dw " & callbacks[i] & CRLF)
		cbSize += 2
	end for
	puts(outFile, CRLF)

	if verbose then
		printf(1, "Size of effect tables: %d bytes\n", tableSize)
	end if
	if verbose then
		printf(1, "Size of waveform table: %d bytes\n", wavSize)
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
					songSize += 1
					if j < length(songs[n][i]) and remainder(j, 16) != 0 then
						puts(outFile, ",")
					end if

				end for
				puts(outFile, CRLF)
				printf(1, "Song %d, Channel " & supportedChannels[i] & ": %d bytes, %d / %d ticks\n", {n, length(songs[n][i]), round2(songLen[n][i]), round2(songLoopLen[n][i])})
			end for
		end if
	end for
	
	puts(outFile, {13, 10} & "xpmp_song_tbl:" & CRLF)
	for n = 1 to length(songs) do
		if sequence(songs[n]) then
			for i = 1 to length(supportedChannels)-1 do
				printf(outFile, ".dw xpmp_s%d_channel_" & supportedChannels[i] & CRLF, n)
				songSize += 2
			end for
		end if
	end for

	if verbose then
		printf(1, "Total size of song(s): %d bytes\n", songSize + patSize + tableSize + cbSize + wavSize)
	end if
	
	puts(outFile, ".ENDIF")
	close(outFile)
end procedure


add_target(TARGET_GBC, "gbc", routine_id("init_gbc"), routine_id("output_gbc"))
