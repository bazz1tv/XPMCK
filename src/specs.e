include globals.e

global constant
	SPEC_DUTYCHANGE = 1,
	SPEC_VOLCHANGE	= 2,
	SPEC_FM		= 3,
	SPEC_ADSR	= 4,
	SPEC_FILTER	= 5,
	SPEC_RING	= 6,
	SPEC_WAVE	= 7,
	SPEC_PCM	= 8,
	SPEC_HWTE	= 9,
	SPEC_HWVE	= 10,
	SPEC_DETUNE	= 11,
	SPEC_MINOCT	= 12,
	SPEC_MAXOCT	= 13,
	SPEC_MAXVOL	= 14,
	SPEC_MINNOTE	= 15,
	SPEC_TYPE	= 16

global constant
	TYPE_SN76489	= 1,
	TYPE_YM2151	= 2,
	TYPE_YM2413	= 3,
	TYPE_YM2612	= 4,
	TYPE_YM3812	= 5,
	TYPE_AY_3_8910	= 6,
	TYPE_SCC	= 7,
	TYPE_SID	= 8,
	TYPE_POKEY	= 9,
	TYPE_MIKEY	= 10,
	TYPE_YMF292	= 11,
	TYPE_SPC	= 12,
	TYPE_GBAPU	= 13,
	TYPE_HUC6280=14
	

global procedure set_channel_specs(sequence specs, integer firstPhysChan, integer firstLogicalChan)
	sequence s
	
	supportsDutyChange 	= strinsert(supportsDutyChange,   firstLogicalChan, substr(specs[SPEC_DUTYCHANGE], firstPhysChan, length(specs[SPEC_DUTYCHANGE])))
	supportsVolumeChange 	= strinsert(supportsVolumeChange, firstLogicalChan, substr(specs[SPEC_VOLCHANGE], firstPhysChan, length(specs[SPEC_VOLCHANGE])))
	supportsFM		= strinsert(supportsFM,           firstLogicalChan, substr(specs[SPEC_FM], firstPhysChan, length(specs[SPEC_FM])))
	supportsADSR		= strinsert(supportsADSR,         firstLogicalChan, substr(specs[SPEC_ADSR], firstPhysChan, length(specs[SPEC_ADSR])))
	supportsFilter		= strinsert(supportsFilter,       firstLogicalChan, substr(specs[SPEC_FILTER], firstPhysChan, length(specs[SPEC_FILTER])))
	supportsRing		= strinsert(supportsRing,         firstLogicalChan, substr(specs[SPEC_RING], firstPhysChan, length(specs[SPEC_RING])))
	supportsWave 		= strinsert(supportsWave,         firstLogicalChan, substr(specs[SPEC_WAVE], firstPhysChan, length(specs[SPEC_WAVE])))
	supportsPCM 		= strinsert(supportsPCM,          firstLogicalChan, substr(specs[SPEC_PCM], firstPhysChan, length(specs[SPEC_PCM])))
	supportsHwToneEnv	= strinsert(supportsHwToneEnv,    firstLogicalChan, substr(specs[SPEC_HWTE], firstPhysChan, length(specs[SPEC_HWTE])))
	supportsHwVolEnv	= strinsert(supportsHwVolEnv,     firstLogicalChan, substr(specs[SPEC_HWVE], firstPhysChan, length(specs[SPEC_HWVE])))
	supportsDetune		= strinsert(supportsDetune,       firstLogicalChan, substr(specs[SPEC_DETUNE], firstPhysChan, length(specs[SPEC_DETUNE])))
	minOctave 		= strinsert(minOctave,            firstLogicalChan, substr(specs[SPEC_MINOCT], firstPhysChan, length(specs[SPEC_MINOCT])))
	maxOctave 		= strinsert(maxOctave,            firstLogicalChan, substr(specs[SPEC_MAXOCT], firstPhysChan, length(specs[SPEC_MAXOCT])))
	maxVolume 		= strinsert(maxVolume,            firstLogicalChan, substr(specs[SPEC_MAXVOL], firstPhysChan, length(specs[SPEC_MAXVOL])))
	minNote 		= strinsert(minNote,              firstLogicalChan, substr(specs[SPEC_MINNOTE], firstPhysChan, length(specs[SPEC_MINNOTE])))	

	channelType		= strinsert(channelType, firstLogicalChan, repeat(specs[SPEC_TYPE], length(specs[SPEC_DUTYCHANGE]) + 1 - firstPhysChan))
	
	if length(supportedChannels) < length(supportsDutyChange) then
		s = supportedChannels
		for i = length(s) + 1 to length(supportsDutyChange) do
			supportedChannels &= 'A' + i - 1
		end for
	end if
end procedure


