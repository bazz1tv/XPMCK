include globals.e
include output.e
include specs_ym2151.e
include vgm.e
include util.e



global procedure init_cps()
	define("CPS", 1)
	
	set_channel_specs(specs_ym2151, 1, 1)

	activeChannels 		= repeat(0, length(supportedChannels))
	maxTempo 		= 300
	minVolume 		= 0
	maxLoopDepth 		= 2
	supportsPan 		= 1
	supportsPAL 		= 0
	adsrLen			= 5
	adsrMax			= 63
	minWavLength 		= 0
	maxWavLength 		= 0
	minWavSample 		= 0
	maxWavSample		= 0	
end procedure


-- Output VGM data for the CPS-1 (YM2151)
global procedure output_cps(sequence args)
	atom factor
	integer f, machineSpeed, tableSize, cbSize, songSize, numSongs
	sequence freqTbl, oct1, fileEnding, s, e

	-- Force a .vgm file ending since it's the only format supported	
	if args[1] = 1 then
		fileEnding = ".vgm"
	elsif args[1] = 2 then
		fileEnding = ".vgz"
	end if

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
		--s[2] = s[2] * 8 + s[3]
		--mods[2][i][2] = s[1..2]
		s[3] = or_bits(s[3], #80)
		s[4] += s[5] * #10
		s[5] = s[6] + #C0
		mods[2][i][2] = s[1..5]
	end for
	
	for i = 1 to length(feedbackMacros[1]) do
		feedbackMacros[2][i][2] = (feedbackMacros[2][i][2])*8
		feedbackMacros[2][i][3] = (feedbackMacros[2][i][3])*8
	end for
	
	numSongs = 0
	for i = 1 to length(songs) do
		if sequence(songs[i]) then
			numSongs += 1
		end if
	end for
	
	if numSongs = 1 then
		write_vgm(shortFilename & fileEnding, 1, PSG_DISABLED, YM2151_ENABLED, YM2413_DISABLED, YM2612_DISABLED)
	else
		for i = 1 to length(songs) do
			if sequence(songs[i]) then
				write_vgm(shortFilename & sprintf("_song%d", i) & fileEnding, i, PSG_DISABLED, YM2151_ENABLED, YM2413_DISABLED, YM2612_DISABLED)
			end if
		end for
	end if
end procedure


add_target(TARGET_CPS, "cps", routine_id("init_cps"), routine_id("output_cps"))
