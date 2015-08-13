include globals.e
include output.e
include specs_sid.e
include util.e


global procedure init_c64()
	define("C64", 1)

	set_channel_specs(specs_sid, 1, 1)

	activeChannels 		= repeat(0, length(supportedChannels))
	maxTempo 		= 300
	minVolume 		= 0
	supportsPan 		= 0
	maxLoopDepth 		= 2
	updateFreq		= 50.0		-- Use PAL as default
end procedure


-- Output data suitable for the Commodore 64 playback library (WLA-DX)
global procedure output_c64(sequence args)
	atom factor
	integer f, machineSpeed, tableSize, cbSize, songSize, patSize, numSongs
	sequence freqTbl, oct1, fileEnding, e, s
	
	fileEnding = ".asm"

	-- Convert ADSR envelopes to the format used by the SID
	for i = 1 to length(adsrs[2]) do
		s = {0, 0}
		e = adsrs[2][i][2]
		s[1] = xor_bits(e[1], 15) * #10 + xor_bits(e[2], 15)
		s[2] = e[3] * #10 + xor_bits(e[4], 15)
		adsrs[2][i][2] = s
	end for
	
	for i = 1 to length(filters[2]) do
		s = filters[2][i][2]
		if s[1] = 0 then
			s[1] = #10
		elsif s[1] = 1 then
			s[1] = #40
		elsif s[1] = 2 then
			s[1] = #20
		else
			s[1] = #50
		end if
		s[3] *= #10
		s = {s[1], and_bits(s[2], 7), floor(s[2] / 8), s[3]}
		filters[2][i][2] = s
	end for
	
	for i = 1 to length(dutyMacros[2]) do
		for j = 1 to length(dutyMacros[2][i][2]) do
			dutyMacros[2][i][2][j] = power(2, dutyMacros[2][i][2][j]) * #10
		end for
		for j = 1 to length(dutyMacros[2][i][3]) do
			dutyMacros[2][i][3][j] = power(2, dutyMacros[2][i][3][j]) * #10
		end for
	end for
	
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

	puts(outFile,
	".IFDEF XPMP_MAKE_SID" & CRLF & CRLF &
	".MEMORYMAP" & CRLF &
	"\tDEFAULTSLOT 0"  & CRLF &
	"\tSLOTSIZE $8000"  & CRLF &
	"\tSLOT 0 $0000"  & CRLF &
	".ENDME"  & CRLF & CRLF)
	puts(outFile,
	".ROMBANKSIZE $8000"  & CRLF &
	".ROMBANKS 1"  & CRLF &
	".BANK 0 SLOT 0"  & CRLF &
	".ORGA $00"  & CRLF & CRLF)
	puts(outFile,
	".db \"PSID\""  & CRLF &
	".db $00,$01\t; Version"  & CRLF &
	".db $00,$76\t; Data address"  & CRLF &
	".dw 0\t\t; Load address (defined by first two bytes of psid.bin)"  & CRLF &
	".dw 0\t\t; Init address (same as load address)" & CRLF &
	".dw $1110\t; Play address" & CRLF &
	sprintf(".dw $%02x%02x\t; Songs",{and_bits(numSongs, #FF), floor(numSongs / #100)}) & CRLF &
	".dw $0100\t; Start song" & CRLF &
	".dw 0,0\t\t; Speed" & CRLF)
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
	s = songProgrammer & sprintf(", %d", s[1] + 1900)
	if length(s) >= 32 then
		puts(outFile, ".db \"" & s[1..31] & "\", 0" & CRLF)
	else
		puts(outFile, ".db \"" & s & "\"")
		for i = 1 to 32 - length(s) do
			puts(outFile, ", 0")
		end for
		puts(outFile, CRLF)
	end if
	puts(outFile,".INCBIN \"psid.bin\"" & CRLF)
	
	puts(outFile, CRLF & ".ELSE" & CRLF & CRLF)

	if updateFreq = 50 then
		puts(outFile, ".DEFINE XPMP_50_HZ" & {13, 10})
	else
		machineSpeed = 3579545
	end if

	if sum(assoc_get_references(volumeMacros)) = 0 then --not length(volumeMacros[1]) then
		puts(outFile, ".DEFINE XPMP_VMAC_NOT_USED" & CRLF)
	end if
	if sum(assoc_get_references(pitchMacros)) = 0 then
		puts(outFile, ".DEFINE XPMP_EPMAC_NOT_USED" & CRLF)
	end if
	if sum(assoc_get_references(dutyMacros)) = 0 then
		puts(outFile, ".DEFINE XPMP_DTMAC_NOT_USED" & CRLF)
	end if
	if sum(assoc_get_references(pulseMacros)) = 0 then
		puts(outFile, ".DEFINE XPMP_PWMAC_NOT_USED" & CRLF)
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
		
	-- Write frequency table
	--factor = 0.5
	--for i = 0 to 7 do
	--	puts(outFile, ".dw ")
	--	for n = 1 to 12 do
	--		f = floor((OCTAVE1[n] * factor) / 0.06097)
	--		printf(outFile, "$%04x", f)
	--		if n < 12 then
	--			puts(outFile, ",")
	--		end if
	--	end for
	--	puts(outFile, {13,10})
	--	factor *= 2.0
	--end for
	--puts(outFile, {13, 10})

	tableSize  = output_wla_table("xpmp_dt_mac", dutyMacros,   1, 1, #00)
	tableSize += output_wla_table("xpmp_v_mac",  volumeMacros, 1, 1, #80)
	tableSize += output_wla_table("xpmp_VS_mac", volumeSlides, 1, 1, #80)
	tableSize += output_wla_table("xpmp_EP_mac", pitchMacros,  1, 1, #80)
	tableSize += output_wla_table("xpmp_PW_mac", pulseMacros,  1, 1, #80)
	tableSize += output_wla_table("xpmp_EN_mac", arpeggios,    1, 1, #80)
	tableSize += output_wla_table("xpmp_MP_mac", vibratos,     0, 1, #80)
	tableSize += output_wla_table("xpmp_CS_mac", panMacros,    1, 1, #80)
	--tableSize += output_wla_table("xpmp_ADSR",   adsrs,        0, 1, #80)
	tableSize += output_wla_table("xpmp_FT",     filters,      0, 1, #80)
	

	puts(outFile,"xpmp_ADSR_tbl:" & CRLF)

	for i = 1 to length(adsrs[2]) do
		printf(outFile, ".db $%02x, $%02x" & CRLF, adsrs[2][i][2])
	end for
	puts(outFile, CRLF)
	
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
				printf(outFile, ".dw xpmp_s%d_channel_" & supportedChannels[i] & CRLF, n)
				songSize += 2
			end for
		end if
	end for

	if verbose then
		printf(1, "Total size of song(s): %d bytes\n", songSize + patSize + tableSize + cbSize)
	end if

	puts(outFile, ".ENDIF" & CRLF)
	
	close(outFile)
end procedure


add_target(TARGET_C64, "c64", routine_id("init_c64"), routine_id("output_c64"))
