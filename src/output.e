-- File output functions for XPMC

include assoc.e
include globals.e
include list.e
--include mdx.e
include vgm.e
include wav.e
--include ym.e


-- Output table data in WLA-DX format 
global function output_wla_table(sequence name, sequence tbl, integer canLoop, integer scaling, integer loopDelim)
	integer bytesWritten, dat
	
	bytesWritten = 0
	
	if length(tbl[ASSOC_KEY]) then
		for i = 1 to length(tbl[ASSOC_KEY]) do
			printf(outFile, name & "_%d:", tbl[ASSOC_KEY][i])
			for j = 1 to length(tbl[ASSOC_DATA][i][LIST_MAIN]) do
				dat = and_bits(tbl[ASSOC_DATA][i][LIST_MAIN][j] * scaling, #FF)
				if canLoop and dat = loopDelim then dat += 1 end if

				if canLoop and j = length(tbl[ASSOC_DATA][i][LIST_MAIN]) and length(tbl[ASSOC_DATA][i][LIST_LOOP]) = 0 then
					if j > 1 then
						printf(outFile, ", $%02x", loopDelim)
					end if
					--? tbl[ASSOC_DATA][i]
					printf(outFile, {13, 10} & name & "_%d_loop:" & {13, 10}, tbl[ASSOC_KEY][i])
					printf(outFile, ".db $%02x, $%02x", {dat, loopDelim}) --and_bits(tbl[ASSOC_DATA][i][LIST_MAIN][j] * scaling, #FF), loopDelim})
					bytesWritten += 3
				elsif j = 1 then
					printf(outFile, {13, 10} & ".db $%02x", dat) --and_bits(tbl[ASSOC_DATA][i][LIST_MAIN][j] * scaling, #FF))
					bytesWritten += 1
				else
					printf(outFile, ", $%02x", dat) --and_bits(tbl[ASSOC_DATA][i][LIST_MAIN][j] * scaling, #FF))
					bytesWritten += 1
				end if
			end for
			if canLoop and length(tbl[ASSOC_DATA][i][LIST_LOOP]) then
				if length(tbl[ASSOC_DATA][i][LIST_MAIN]) then
					printf(outFile, ", $%02x", loopDelim)
					bytesWritten += 1
				end if
				printf(outFile, {13, 10} & name & "_%d_loop:" & {13, 10}, tbl[ASSOC_KEY][i])
				for j = 1 to length(tbl[ASSOC_DATA][i][LIST_LOOP]) do
					dat = and_bits(tbl[ASSOC_DATA][i][LIST_LOOP][j] * scaling, #FF)
					if dat = loopDelim and canLoop then dat += 1 end if
					if j = 1 then
						printf(outFile, ".db $%02x", dat) --and_bits(tbl[ASSOC_DATA][i][LIST_LOOP][j] * scaling, #FF))
					else
						printf(outFile, ", $%02x", dat) --and_bits(tbl[ASSOC_DATA][i][LIST_LOOP][j] * scaling, #FF))
					end if
					bytesWritten += 1
				end for
				printf(outFile, ", $%02x", loopDelim)
				bytesWritten += 1
			end if
			puts(outFile, {13, 10})
		end for
		puts(outFile, name & "_tbl:" & {13, 10})
		for i = 1 to length(tbl[ASSOC_KEY]) do
			printf(outFile, ".dw " & name & "_%d" & {13, 10}, tbl[ASSOC_KEY][i])
			bytesWritten += 2
		end for
		if canLoop then
			puts(outFile, name & "_loop_tbl:" & {13, 10})
			for i = 1 to length(tbl[ASSOC_KEY]) do
				printf(outFile, ".dw " & name & "_%d_loop" & {13, 10}, tbl[ASSOC_KEY][i])
				bytesWritten += 2
			end for
		end if
		puts(outFile, {13, 10})
	else
		puts(outFile, name & "_tbl:" & {13, 10})
		if canLoop then
			puts(outFile, name & "_loop_tbl:" & {13, 10})
		end if
		puts(outFile, {13, 10})
	end if
	return bytesWritten
end function


-- Output table data in m68k-as format 
global function output_m68kas_table(sequence name, sequence tbl, integer canLoop, integer scaling, integer longPointers)
	integer bytesWritten,ptrSize
	sequence ptrDecl
	
	bytesWritten = 0
	
	if longPointers then
		ptrDecl = "dc.l "
		ptrSize = 4
	else
		ptrDecl = "dc.w "
		ptrSize = 2
	end if
	
	if length(tbl[ASSOC_KEY]) then
		for i = 1 to length(tbl[ASSOC_KEY]) do
			--printf(outFile, ".globl " & name & "_%d", tbl[1][i])
			printf(outFile, name & "_%d:", tbl[ASSOC_KEY][i])
			for j = 1 to length(tbl[ASSOC_DATA][i][LIST_MAIN]) do
				if canLoop and j = length(tbl[2][i][2]) and length(tbl[2][i][3]) = 0 then
					if j > 1 then
						puts(outFile, ", 0x80")
					end if
					--printf(outFile, CRLF & ".globl " & name & "_%d_loop" & CRLF, tbl[1][i])
					printf(outFile, CRLF & name & "_%d_loop:" & CRLF, tbl[1][i])
					printf(outFile, "dc.b 0x%02x, 0x80", and_bits(tbl[2][i][2][j] * scaling, #FF))
					bytesWritten += 3
				elsif j = 1 then
					printf(outFile, CRLF & "dc.b 0x%02x", and_bits(tbl[2][i][2][j] * scaling, #FF))
					bytesWritten += 1
				else
					printf(outFile, ", 0x%02x", and_bits(tbl[2][i][2][j] * scaling, #FF))
					bytesWritten += 1
				end if
			end for
			if canLoop and length(tbl[2][i][3]) then
				if length(tbl[2][i][2]) then
					puts(outFile, ", 0x80")
					bytesWritten += 1
				end if
				--printf(outFile, {13, 10} & ".globl " & name & "_%d_loop" & CRLF, tbl[1][i])
				printf(outFile, {13, 10} & name & "_%d_loop:" & CRLF, tbl[1][i])
				for j = 1 to length(tbl[2][i][3]) do
					if j = 1 then
						printf(outFile, "dc.b 0x%02x", and_bits(tbl[2][i][3][j] * scaling, #FF))
					else
						printf(outFile, ", 0x%02x", and_bits(tbl[2][i][3][j] * scaling, #FF))
					end if
					bytesWritten += 1
				end for
				puts(outFile, ", 128")
				bytesWritten += 1
			end if
			puts(outFile, CRLF)
		end for
		puts(outFile, ".globl " & name & "_tbl" & CRLF)
		puts(outFile, name & "_tbl:" & CRLF)
		for i = 1 to length(tbl[1]) do
			printf(outFile, ptrDecl & name & "_%d" & CRLF, tbl[1][i])
			bytesWritten += ptrSize
		end for
		puts(outFile, ptrDecl & "0" & CRLF)
		bytesWritten += 2
		if canLoop then
			puts(outFile, ".globl " & name & "_loop_tbl" & CRLF)
			puts(outFile, name & "_loop_tbl:" & CRLF)
			for i = 1 to length(tbl[1]) do
				printf(outFile, ptrDecl & name & "_%d_loop" & CRLF, tbl[1][i])
				bytesWritten += ptrSize
			end for
			puts(outFile, ptrDecl & "0" & CRLF)
			bytesWritten += ptrSize
		end if
		puts(outFile, {13, 10})
	else
		puts(outFile, ".globl " & name & "_tbl" & {13, 10})
		puts(outFile, name & "_tbl:" & {13, 10})
		if canLoop then
			puts(outFile, ".globl " & name & "_loop_tbl" & CRLF)
			puts(outFile, name & "_loop_tbl:" & CRLF)
		end if
		puts(outFile, ptrDecl & "0" & CRLF)
		bytesWritten += ptrSize
		puts(outFile, CRLF)
	end if
	return bytesWritten
end function


global function output_c_table(sequence name, sequence tbl, integer canLoop)
	integer bytesWritten
	
	bytesWritten = 0
	
	
	if length(tbl[ASSOC_KEY]) then
		for i = 1 to length(tbl[ASSOC_KEY]) do
			printf(outFile, "const unsigned char " & name & "_%d[] =" & {13, 10} & "{" & {13, 10}, tbl[ASSOC_KEY][i])
			for j = 1 to length(tbl[ASSOC_DATA][i][LIST_MAIN]) do
				if canLoop and j = length(tbl[ASSOC_DATA][i][LIST_MAIN]) and length(tbl[ASSOC_DATA][i][LIST_LOOP]) = 0 then
					if j > 1 then
						puts(outFile, ",128")
						bytesWritten += 1
					end if
					printf(outFile, "};" & {13, 10} & "const unsigned char " & name & "_%d_loop[] =" & {13, 10} & "{" & {13, 10}, tbl[1][i])
					printf(outFile, "%d,128" & CRLF & "};", tbl[ASSOC_DATA][i][LIST_MAIN][j])
					bytesWritten += 1
				elsif j = 1 then
					printf(outFile, "%d", tbl[ASSOC_DATA][i][LIST_MAIN][j])
					bytesWritten += 1
				else
					if remainder(j,16)=0 then
						puts(outFile, CRLF)
					end if
					printf(outFile, ",%d", tbl[ASSOC_DATA][i][LIST_MAIN][j])
					bytesWritten += 1
				end if
			end for
			if canLoop and length(tbl[2][i][3]) then
				if length(tbl[2][i][2]) then
					puts(outFile, ",128" & CRLF & "};")
					bytesWritten += 1
				end if
				printf(outFile, {13, 10} & "const unsigned char " & name & "_%d_loop[] =" & {13, 10} & "{" & {13, 10}, tbl[1][i])
				for j = 1 to length(tbl[2][i][3]) do
					if j = 1 then
						printf(outFile, "%d", tbl[2][i][3][j])
						bytesWritten += 1
					else
						if remainder(j,16)=0 then
							puts(outFile, CRLF)
						end if
						printf(outFile, ",%d", tbl[2][i][3][j])
						bytesWritten += 1
					end if
				end for
				puts(outFile, ",128" & CRLF & "};")
				bytesWritten += 1
			end if
			puts(outFile, {13, 10})
		end for
		puts(outFile, "const unsigned char *" & name & "_tbl[] =" & {13, 10} & "{" & {13, 10})
		for i = 1 to length(tbl[1]) do
			printf(outFile, name & "_%d", tbl[ASSOC_KEY][i])
			bytesWritten += 4
			if i < length(tbl[1]) then
				puts(outFile, ",")
			end if
			puts(outFile, {13, 10})
		end for
		puts(outFile, "};" & {13, 10})
		if canLoop then
			puts(outFile, "const unsigned char *" & name & "_loop_tbl[] = " & {13, 10} & "{" & {13, 10})
			for i = 1 to length(tbl[1]) do
				printf(outFile, name & "_%d_loop", tbl[1][i])
				bytesWritten += 4
				if i < length(tbl[1]) then
					puts(outFile, ",")
				end if
				puts(outFile, {13, 10})
			end for
			puts(outFile, "};")
		end if
		puts(outFile, {13, 10})
	else
		puts(outFile, "const unsigned char **" & name & "_tbl;" & {13, 10})
		if canLoop then
			puts(outFile, "const unsigned char **" & name & "_loop_tbl;" & {13, 10})
		end if
		puts(outFile, {13, 10})
	end if
	return bytesWritten
end function






-- Output MDX data for the X68000 (YM2151)
global procedure output_x68()
	atom factor
	integer f, machineSpeed, tableSize, cbSize, songSize, numSongs
	sequence freqTbl, oct1, fileEnding, s, e

	-- Force an .mdx file ending since it's the only format supported	
	fileEnding = ".mdx"

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
		feedbackMacros[ASSOC_DATA][i][2] = (feedbackMacros[2][i][2])*8
		feedbackMacros[ASSOC_DATA][i][3] = (feedbackMacros[2][i][3])*8
	end for
	
	numSongs = 0
	for i = 1 to length(songs) do
		if sequence(songs[i]) then
			numSongs += 1
		end if
	end for
	
	if numSongs = 1 then
	--	write_mdx(shortFilename & fileEnding, 1)
	else
		for i = 1 to length(songs) do
			if sequence(songs[i]) then
	--			write_mdx(shortFilename & sprintf("_song%d", i) & fileEnding, i)
			end if
		end for
	end if
end procedure





global procedure output_gba()
	integer first, songSize, tableSize
	sequence s
	
	outFile = open(shortFilename & ".c", "wb")
	if outFile = -1 then
		ERROR("Unable to open file: " & shortFilename & ".c", -1)
	end if

	s = date()
	printf(outFile, "// Written by XPMC at %02d:%02d:%02d on " & WEEKDAYS[s[7]] & " " & MONTHS[s[2]] & " %d, %d." & {13, 10, 13, 10},
	       s[4..6] & {s[3], s[1] + 1900})

	tableSize = 0
	tableSize =  output_c_table("xpmp_dt_mac", dutyMacros,   1)
	tableSize += output_c_table("xpmp_v_mac",  volumeMacros, 1)
	tableSize += output_c_table("xpmp_p_mac",  panMacros,    1)
	tableSize += output_c_table("xpmp_VS_mac", volumeSlides, 1)
	tableSize += output_c_table("xpmp_EP_mac", pitchMacros,  1)
	tableSize += output_c_table("xpmp_EN_mac", arpeggios,    1)
	tableSize += output_c_table("xpmp_MP_mac", vibratos,     0)
	
	--puts(outFile, "const xpmp_callback xpmp_callback_tbl[] =" & {13, 10} & "{" & {13, 10})
	--for i = 1 to length(callbacks) do
	--	puts(outFile, callbacks[i])
	--	puts(outFile, ",")
	--	puts(outFile, {13, 10})
	--end for
	--puts(outFile, "NULL" & {13, 10} & "};" & {13, 10})
	
	songSize = 0

	if verbose then
		printf(1, "Size of effect tables: %d bytes\n", tableSize)
	end if
	
	for n = 1 to length(songs) do
		if sequence(songs[n]) then
			for i = 1 to length(supportedChannels)-1 do
				printf(outFile, "const unsigned char xpmp_s%d_channel_" & supportedChannels[i] & "[] = " & {13,10} & "{" & {13, 10}, n)
				for j = 1 to length(songs[n][i]) do
					printf(outFile, "0x%02x", songs[n][i][j])
					songSize += 1
					if j < length(songs[n][i]) then
						puts(outFile, ",")
					end if
					if remainder(j, 16) = 0 then
						puts(outFile, {13, 10})
					end if
				end for
				puts(outFile, "};" & {13, 10})
				printf(1, "Song %d, Channel " & supportedChannels[i] & ": %d bytes, %d / %d ticks\n", {n, length(songs[n][i]), -floor(-songLen[n][i]), -floor(-songLoopLen[n][i])})
			end for
		end if
	end for
	
	puts(outFile, {13, 10} & "unsigned char const *xpmp_song_tbl[] = " & {13, 10} & "{" & {13, 10})
	first = 1
	for n = 1 to length(songs) do
		if sequence(songs[n]) then
			for i = 1 to length(supportedChannels)-1 do
				if first then
					first = 0
				else
					puts(outFile, "," & {13,10})
				end if
				printf(outFile, "xpmp_s%d_channel_" & supportedChannels[i], n)
				songSize += 2
			end for
		end if
	end for
	puts(outFile, {13, 10} & "};" & {13, 10})

	if verbose then
		printf(1, "Total size of song(s): %d bytes\n", songSize + tableSize) -- + cbSize + wavSize)
	end if
	
	close(outFile)
end procedure


global procedure output_nds()
	integer first, songSize, tableSize
	
	outFile = open(shortFilename & ".c", "wb")
	if outFile = -1 then
		ERROR("Unable to open file: " & shortFilename & ".c", -1)
	end if

	tableSize = 0
	tableSize =  output_c_table("xpmp_dt_mac", dutyMacros,   1)
	tableSize += output_c_table("xpmp_v_mac",  volumeMacros, 1)
	tableSize += output_c_table("xpmp_p_mac",  panMacros,    1)
	tableSize += output_c_table("xpmp_VS_mac", volumeSlides, 1)
	tableSize += output_c_table("xpmp_EP_mac", pitchMacros,  1)
	tableSize += output_c_table("xpmp_EN_mac", arpeggios,    1)
	tableSize += output_c_table("xpmp_MP_mac", vibratos,     0)
	
	--puts(outFile, "const xpmp_callback xpmp_callback_tbl[] =" & {13, 10} & "{" & {13, 10})
	--for i = 1 to length(callbacks) do
	--	puts(outFile, callbacks[i])
	--	puts(outFile, ",")
	--	puts(outFile, {13, 10})
	--end for
	--puts(outFile, "NULL" & {13, 10} & "};" & {13, 10})

	if verbose then
		printf(1, "Size of effect tables: %d bytes\n", tableSize)
	end if
	
	songSize = 0
	
	for n = 1 to length(songs) do
		if sequence(songs[n]) then
			for i = 1 to length(supportedChannels)-1 do
				printf(outFile, "const unsigned char xpmp_s%d_channel_" & supportedChannels[i] & "[] = " & {13,10} & "{" & {13, 10}, n)
				for j = 1 to length(songs[n][i]) do
					printf(outFile, "0x%02x", songs[n][i][j])
					songSize += 1
					if j < length(songs[n][i]) then
						puts(outFile, ",")
					end if
					if remainder(j, 16) = 0 then
						puts(outFile, {13, 10})
					end if
				end for
				puts(outFile, "};" & {13, 10})
				printf(1, "Song %d, Channel " & supportedChannels[i] & ": %d bytes, %d / %d ticks\n", {n, length(songs[n][i]), -floor(-songLen[n][i]), -floor(-songLoopLen[n][i])})
			end for
		end if
	end for
	
	puts(outFile, {13, 10} & "unsigned char const *xpmp_song_tbl[] = " & {13, 10} & "{" & {13, 10})
	first = 1
	for n = 1 to length(songs) do
		if sequence(songs[n]) then
			for i = 1 to length(supportedChannels)-1 do
				if first then
					first = 0
				else
					puts(outFile, "," & {13,10})
				end if
				printf(outFile, "xpmp_s%d_channel_" & supportedChannels[i], n)
				songSize += 2
			end for
		end if
	end for
	puts(outFile, {13, 10} & "};" & {13, 10})

	if verbose then
		printf(1, "Total size of song(s): %d bytes\n", songSize + tableSize) -- + cbSize + wavSize)
	end if
	
	close(outFile)
end procedure



-- Output YM data for the Atari ST (YM2149)
global procedure output_ast(integer writeYM)
	atom factor
	integer f, machineSpeed, tableSize, cbSize, songSize, numSongs
	sequence freqTbl, oct1, fileEnding, s, e

	-- Force a .ym file ending since it's the only format supported	
	fileEnding = ".ym"

	numSongs = 0
	for i = 1 to length(songs) do
		if sequence(songs[i]) then
			numSongs += 1
		end if
	end for
	
	if numSongs = 1 then
--		write_ym(shortFilename & fileEnding, 1, 1773400)
	else
		for i = 1 to length(songs) do
			if sequence(songs[i]) then
--				write_ym(shortFilename & sprintf("_song%d", i) & fileEnding, i, 1773400)
			end if
		end for
	end if
end procedure



global procedure output_pc4(integer writeWAV)
	atom factor
	integer f, machineSpeed, tableSize, cbSize, songSize, numSongs
	sequence freqTbl, oct1, fileEnding, s, e

	-- Force a .wav file ending since it's the only format supported	
	fileEnding = ".wav"

	numSongs = 0
	for i = 1 to length(songs) do
		if sequence(songs[i]) then
			numSongs += 1
		end if
	end for
	
	if numSongs = 1 then
		--write_wav_4ksynth(shortFilename & fileEnding, 1)
	else
		for i = 1 to length(songs) do
			if sequence(songs[i]) then
				--write_wav_4ksynth(shortFilename & sprintf("_song%d", i) & fileEnding, i)
			end if
		end for
	end if
end procedure
