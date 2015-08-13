include target_sms.e

	
global procedure init_sgg()
	define("SGG", 1)
	
	set_channel_specs(specs_sn76489, 1, 1)

	activeChannels 		= repeat(0, length(supportedChannels))
	maxTempo 		= 300
	minVolume 		= 0
	maxLoopDepth 		= 2
	supportsPan 		= 1
end procedure


-- Note that the SMS output function is re-used here.
add_target(TARGET_SGG, "sgg", routine_id("init_sgg"), routine_id("output_sms"))
