include globals.e
include output.e
include specs_ay-3-8910.e
include util.e


global procedure init_cpc()
	define("CPC", 1)

	set_channel_specs(specs_ay_3_8910,  1, 1)
	
	activeChannels 		= repeat(0, length(supportedChannels))
	
	maxTempo 		= 300
	minVolume 		= 0
	supportsPan 		= 1
	maxLoopDepth 		= 2
	supportsPAL		= 1	
	updateFreq		= 50.0		-- Use PAL as default
end procedure



-- Output data suitable for the Amstrad CPC playback library (WLA-DX)
global procedure output_cpc(sequence args)
	atom factor
	integer f, machineSpeed, tableSize, cbSize, patSize, songSize, numSongs
	sequence freqTbl, oct1, fileEnding, s
	
	fileEnding = ".asm"

	numSongs = 0
	for i = 1 to length(songs) do
		if sequence(songs[i]) then
			numSongs += 1
		end if
	end for
	
	outFile = open(shortFilename & fileEnding, "wb")
	if outFile = -1 then
		ERROR("Unable to open file: " & shortFilename & fileEnding, -1)
	end if

	s = date()
	printf(outFile, "; Written by XPMC at %02d:%02d:%02d on " & WEEKDAYS[s[7]] & " " & MONTHS[s[2]] & " %d, %d." & {13, 10, 13, 10},
	       s[4..6] & {s[3], s[1] + 1900})

	puts(outFile, ".DEFINE XPMP_CPC" & CRLF)
	puts(outFile, ".DEFINE XPMP_USES_AY" & CRLF)

	if updateFreq = 50 then
		puts(outFile, ".DEFINE XPMP_50_HZ" & CRLF)
		machineSpeed = 3546893
	else
		machineSpeed = 3579545
	end if

	if target = TARGET_SMS and tune then
		puts(outFile, ".DEFINE XPMP_TUNE_SMS" & CRLF)
	end if

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
	tableSize += output_wla_table("xpmp_CS_mac", panMacros,    1, 1, #80)

	if verbose then
		printf(1, "Size of effect tables: %d bytes\n", tableSize)
	end if

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

	if verbose then
		printf(1, "Total size of song(s): %d bytes\n", songSize + patSize + tableSize + cbSize)
	end if

	close(outFile)
end procedure


add_target(TARGET_CPC, "cpc", routine_id("init_cpc"), routine_id("output_cpc"))
