include globals.e
include output.e
include specs_spc.e
include util.e


global procedure init_sfc()
	define("SFC", 1)
	define("SNES", 1)
	define("SPC", 1)
	
	set_channel_specs(specs_spc, 1, 1)

	activeChannels 		= repeat(0, length(supportedChannels))
	maxTempo 			= 300
	minVolume 			= 0
	supportsPan 		= 1
	maxLoopDepth 		= 2
	minWavLength		= 32
	maxWavLength		= 16384
	minWavSample 		= 0
	maxWavSample		= 31
	--updateFreq			= 50.0		-- Use PAL as default	
end procedure


global procedure output_sfc(sequence args)
	atom factor,f2,r2,smallestDiff
	integer f, tableSize, cbSize, songSize, wavSize, pcmSize, patSize, numSongs, pcmBank, column
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
	
	if sum(assoc_get_references(volumeMacros)) = 0 then 
		puts(outFile, ".DEFINE XPMP_VMAC_NOT_USED" & CRLF)
	end if
	if sum(assoc_get_references(pitchMacros)) = 0 then
		puts(outFile, ".DEFINE XPMP_EPMAC_NOT_USED" & CRLF)
	end if
	if sum(assoc_get_references(vibratos)) = 0 then
		puts(outFile, ".DEFINE XPMP_MPMAC_NOT_USED" & CRLF)
	end if
	--if not usesEN[1] then
	--	puts(outFile, ".DEFINE XPMP_ENMAC_NOT_USED" & CRLF)
	--end if
	--if not usesEN[2] then
	--	puts(outFile, ".DEFINE XPMP_EN2MAC_NOT_USED" & CRLF)
	--end if

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
	tableSize += output_wla_table("xpmp_EN_mac", arpeggios,    1, 1, #80)
	tableSize += output_wla_table("xpmp_MP_mac", vibratos,     0, 1, #80)
	tableSize += output_wla_table("xpmp_CS_mac", panMacros,    1, 1, #00)
	tableSize += output_wla_table("xpmp_WT_mac", waveformMacros, 1, 1, #80)
	tableSize += output_wla_table("xpmp_MOD",    mods,         0, 1, 0)

	wavSize = 0
	puts(outFile, "xpmp_waveform_data:")
	for i = 1 to length(waveforms[ASSOC_KEY]) do
		for j = 1 to length(waveforms[ASSOC_DATA][i][LIST_MAIN]) do
			if j = 1 then
				puts(outFile, CRLF & ".db ")
			end if				
			printf(outFile, "$%02x", waveforms[ASSOC_DATA][i][LIST_MAIN][j])
			wavSize += 1
			if j < length(waveforms[ASSOC_DATA][i][LIST_MAIN]) then
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

	puts(outFile, "xpmp_pcm_table:" & CRLF)
	for i = 1 to 12 do --length(pcms[ASSOC_KEY]) do
		printf(outFile, ".dw xpmp_pcm%d" & CRLF, i-1)
		printf(outFile, ".dw :xpmp_pcm%d" & CRLF, i-1)
	end for
	puts(outFile, CRLF)
		
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

	pcmSize = 0
	pcmBank = 2
	printf(outFile, CRLF & ".bank %d slot 6" & CRLF & ".org $0000" & CRLF, pcmBank)
	pcmBank += 1
	for i = 1 to 12 do --length(pcms[ASSOC_KEY]) do
		printf(outFile, "xpmp_pcm%d:", i-1)
		f = 0
		for j = 1 to length(pcms[ASSOC_DATA]) do
			if pcms[ASSOC_KEY][j] = i-1 then
				f = j
				exit
			end if
		end for
		if f then
		pcms[ASSOC_DATA][f][3] &= #80*8
		column = 1
		for j = 1 to length(pcms[ASSOC_DATA][f][3]) do
			if remainder(column, 32) = 1 then
				puts(outFile, CRLF & ".db ")
			end if				
			printf(outFile, "$%02x", round2(pcms[ASSOC_DATA][f][3][j] / 8))
			pcmSize += 1
			if remainder(pcmSize, #2000) = 0 then
				printf(outFile, CRLF & ".bank %d slot 6" & CRLF & ".org $0000", pcmBank)
				pcmBank += 1
				column = 0
			end if
			if j < length(pcms[ASSOC_DATA][f][3]) and
			   remainder(column,32) != 0 then
				puts(outFile, ",")
			end if
			column += 1
		end for
		end if
		puts(outFile, CRLF)
	end for
	puts(outFile, {13, 10, 13, 10})

	if verbose then
		printf(1, "Size of XPCM data: %d bytes\n", pcmSize)
	end if
	
	if verbose then
		printf(1, "Total size of song(s): %d bytes\n", songSize + patSize + tableSize + cbSize + wavSize + pcmSize)
	end if
	
	close(outFile)
end procedure


add_target(TARGET_SFC, "sfc", routine_id("init_sfc"), routine_id("output_sfc"))
