include globals.e
include output.e
include specs_sn76489.e
include specs_ym2413.e
include util.e
include vgm.e


global procedure init_sms()
	define("SMS", 1)       
	
	set_channel_specs(specs_sn76489, 1, 1)
	set_channel_specs(specs_ym2413,  1, 5)
	
	activeChannels 		= repeat(0, length(supportedChannels))	
	maxTempo 		= 300
	minVolume 		= 0
	supportsPan 		= 0
	maxLoopDepth 		= 2
	supportsPAL 		= 1
end procedure




-- Output data suitable for the SEGA Master System / Game Gear playback library (WLA-DX)
global procedure output_sms(sequence args)
	atom factor
	integer f, machineSpeed, tableSize, cbSize, patSize, songSize, numSongs
	sequence freqTbl, oct1, fileEnding, s, palNtscString, e
	
	if args[1] = 1 then
		fileEnding = ".vgm"
	elsif args[1] = 2 then
		fileEnding = ".vgz"
	else
		fileEnding = ".asm"
	end if
	
	numSongs = 0
	for i = 1 to length(songs) do
		if sequence(songs[i]) then
			numSongs += 1
		end if
	end for

	-- Convert ADSR envelopes to the format used by the YM2413
	for i = 1 to length(adsrs[2]) do
		s = {0, 0}
		e = adsrs[2][i][2]
		s[1] = e[1] * #10 + e[2]
		s[2] = xor_bits(e[3], 15) * #10 + e[4]
		adsrs[2][i][2] = s
	end for
	
	if args[1] then
		if numSongs = 1 then
			write_vgm(shortFilename & fileEnding, 1, PSG_ENABLED, YM2151_DISABLED, supportsPAL, YM2612_DISABLED)
		else
			for i = 1 to length(songs) do
				if sequence(songs[i]) then
					write_vgm(shortFilename & sprintf("_song%d", i) & fileEnding, i, PSG_ENABLED, YM2151_DISABLED, supportsPAL, YM2612_DISABLED)
				end if
			end for
		end if
	else
		outFile = open(shortFilename & fileEnding, "wb")
		if outFile = -1 then
			ERROR("Unable to open file: " & shortFilename & fileEnding, -1)
		end if

		s = date()
		printf(outFile, "; Written by XPMC at %02d:%02d:%02d on " & WEEKDAYS[s[7]] & " " & MONTHS[s[2]] & " %d, %d." & {13, 10, 13, 10},
		       s[4..6] & {s[3], s[1] + 1900})
		       
		if not supportsPAL then
			puts(outFile, ".DEFINE XPMP_GAME_GEAR" & {13, 10})
		end if

		if updateFreq = 50 then
			puts(outFile, ".DEFINE XPMP_50_HZ" & {13, 10})
			machineSpeed = 3546893
			palNtscString = ".db 1"
		else
			machineSpeed = 3579545
			palNtscString = ".db 0"
		end if

		if target = TARGET_SMS and tune then
			puts(outFile, ".DEFINE XPMP_TUNE_SMS" & CRLF)
		end if


		-- Output the SGC header
		puts(outFile,
		".IFDEF XPMP_MAKE_SGC" & CRLF & CRLF &
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
		".db \"SGC\"" & CRLF &
		".db $1A" & CRLF &
		".db 1\t\t; Version" & CRLF &
		palNtscString & CRLF & 
		".db 0, 0" & CRLF &
		".dw $0400\t; Load address" & CRLF &
		".dw $0400\t; Init address" & CRLF &
		".dw $0408\t; Play address" & CRLF &
		".dw $dff0\t; Stack pointer" & CRLF &
		".dw 0\t\t; Reserved" & CRLF &
		".dw $040C\t; RST 08" & CRLF &
		".dw $040C\t; RST 10" & CRLF &
		".dw $040C\t; RST 18" & CRLF &
		".dw $040C\t; RST 20" & CRLF &
		".dw $040C\t; RST 28" & CRLF &
		".dw $040C\t; RST 30" & CRLF &
		".dw $040C\t; RST 38" & CRLF &
		".db 0, 0, 1, 2\t; Mapper setting (none)" & CRLF &
		".db 0\t\t; Start song" & CRLF &
		sprintf(".db %d\t\t; Number of songs", numSongs) & CRLF &
		".db 0, 0\t; Sound effects (none)" & CRLF &
		sprintf(".db %d\t\t; System type", 1-supportsPAL) & CRLF &
		".dw 0,0,0,0,0,0,0,0,0,0,0 ; Reserved" & CRLF &
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
		puts(outFile, ".INCBIN \"sgc.bin\"" & CRLF & CRLF)
		puts(outFile, ".ELSE" & CRLF & CRLF) 
	
	
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

		if supportsPAL then
			f = 0
			for i = 5 to 13 do
				f += length(songs[1][i])
			end for
			if f > 9 then
				puts(outFile, ".DEFINE XPMP_ENABLE_FM" & {13,10})
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
		tableSize += output_wla_table("xpmp_EN_mac", arpeggios,    1, 1, #80)
		tableSize += output_wla_table("xpmp_MP_mac", vibratos,     0, 1, #80)
		tableSize += output_wla_table("xpmp_CS_mac", panMacros,    1, 1, #80)

		puts(outFile, "xpmp_ADSR_tbl:" & CRLF)
		for i = 1 to length(adsrs[ASSOC_DATA]) do
			printf(outFile, ".db $%02x,$%02x" & CRLF, adsrs[ASSOC_DATA][i][LIST_MAIN])
			tableSize += 2
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
					printf(outFile, ".dw xpmp_s%d_channel_" & supportedChannels[i] & {13, 10}, n)
					songSize += 2
				end for
			end if
		end for

		if verbose then
			printf(1, "Total size of song(s): %d bytes\n", songSize + patSize + tableSize + cbSize)
		end if

		puts(outFile, ".ENDIF")
		close(outFile)
	end if
end procedure


add_target(TARGET_SMS, "sms", routine_id("init_sms"), routine_id("output_sms"))
