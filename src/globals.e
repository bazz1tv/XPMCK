-- Global constants and variables for XPMC

-- Target enumerators (* = currently supported)
global constant	TARGET_UNKNOWN = 0,
		TARGET_SMS = 1,		-- SEGA Master System *
		TARGET_NES = 2,		-- Nintendo Entertainment System
		TARGET_GBA = 3,		-- Gameboy Advance
		TARGET_NDS = 4,		-- Nintendo DS
		TARGET_GBC = 5,		-- Gameboy Color (and DMG) *
		TARGET_SMD = 6,		-- SEGA Megadrive *
		TARGET_SAT = 7,		-- SEGA Saturn
		TARGET_XGS = 8,		-- XGameStation Micro Edition
		TARGET_SGG = 9,		-- SEGA Game Gear *
		TARGET_CPS = 10,	-- Capcom Play System * (should be replaced by TARGET_VGM)
		TARGET_X68 = 11,	-- X68000
		TARGET_AST = 12,	-- Atari ST
		TARGET_C64 = 13,	-- Commodore 64 *
		TARGET_PCE = 14,	-- NEC PC Engine / TurboGrafx 16
		TARGET_ZXS = 15,	-- ZX Spectrum
		TARGET_PC4 = 16,	-- PC 4k synth
		TARGET_CLV = 17,	-- ColecoVision *
		TARGET_KSS = 18,
		TARGET_CPC = 19,	-- Amstrad CPC *
		TARGET_AT8 = 20,	-- Atari 8-bit (XL/XE etc)
		TARGET_MSX = 21,	-- MSX
		TARGET_VGM = 22,	-- For all-out fantasy machine chip fest tracks
		TARGET_SFC = 23,	-- Super Famicom (and SNES)
		TARGET_LYX = 24,	-- Atari Lynx
		TARGET_NGP = 25,	-- NeoGeo Pocket Color
		
		TARGET_LAST = 26
		

global constant TRG_NAME = 1,
		TRG_INIT_PROC = 2,
		TRG_OUTP_PROC = 3
		
		
global constant	CMD_NOTE   = #00,	-- cc+dd+eff+gg+aa+b
                CMD_REST   = #0C,	-- r	
                CMD_REST2  = #0D,	-- s
                CMD_VOLUP  = #0E,	-- v+
                CMD_VOLDN  = #0F,	-- v-
                CMD_OCTAVE = #10,	-- o
		CMD_DUTY   = #20,	-- @
		CMD_VOL2   = #30,
		CMD_OCTUP  = #40,	-- >
		CMD_OCTDN  = #50,	-- <
		CMD_VOLOUP = #60,
		CMD_NOTE2  = #60,	-- (short form)
		CMD_REST3  = #6D,	-- r (short form)
		CMD_VOLUPC = #6E,	-- v++
		CMD_VOLDNC = #6F,	-- v--
		CMD_VOLODN = #70,
		CMD_PULSE  = #70,
		CMD_ARP2   = #80,
		CMD_ARPOFF = #90,
		CMD_FBKMAC = #191,	-- FBM
		CMD_SSG	   = #92,
		CMD_FILTER = #193,	-- FT
		CMD_HWRM   = #94,
		CMD_PULMAC = #195,	-- @pw
		CMD_JSR    = #196,
		CMD_RTS    = #197,
		CMD_SYNC   = #98,
		CMD_HWES   = #98,	-- es
		CMD_HWNS   = #99,	-- n
		CMD_LEN	   = #9A,	-- l
		CMD_WRMEM  = #9B,	-- w
		CMD_WRPORT = #9C,	-- w()
		CMD_RLEN   = #9D,
		CMD_WAVMAC = #19E,	-- WTM
		CMD_TRANSP = #9F,	-- K
		CMD_MODE   = #A0,	-- M
		CMD_FEEDBK = #B0,	-- FB
		CMD_OPER   = #C0,	-- O
		CMD_RSCALE = #D0,	-- RS
		CMD_CBOFF  = #E0,
		CMD_CBONCE = #E1,
		CMD_CBEVNT = #E2,
		CMD_CBEVVC = #E3,
		CMD_CBEVVM = #E4,
		CMD_CBEVOC = #E5,
		CMD_CBNOTE = #E6,
		CMD_HWTE   = #E8,	-- @te
		CMD_HWVE   = #E9,	-- @ve
		CMD_HWAM   = #EA,
		CMD_MODMAC = #1EB,	-- MOD
		CMD_LDWAVE = #1EC,	-- WT
		CMD_DETUNE = #ED,	-- D
		CMD_ADSR   = #1EE,	-- ADSR
		CMD_MULT   = #EF,	-- MF
		CMD_VOLSET = #F0,	-- v
		CMD_VOLMAC = #1F1,	-- @v
		CMD_DUTMAC = #1F2,	-- @@
		CMD_PORMAC = #F3,
		CMD_PANMAC = #1F4,	-- CS
		CMD_VIBMAC = #1F5,	-- MP
		CMD_SWPMAC = #1F6,	-- EP
		CMD_VSLMAC = #F7,
		CMD_ARPMAC = #1F8,	-- EN
		CMD_JMP    = #F9,
		CMD_DJNZ   = #FA,
		CMD_LOPCNT = #FB,
		CMD_APMAC2 = #1FC,	
		CMD_J1	   = #FD,
		CMD_END	   = #FF


global constant PSG_DISABLED	= 0,
		PSG_ENABLED	= 1,
		YM2151_DISABLED	= 0,
		YM2151_ENABLED	= 1,
		YM2413_DISABLED = 0,
		YM2413_ENABLED 	= 1,
		YM2612_DISABLED	= 0,
		YM2612_ENABLED	= 1,
		YM3812_DISABLED	= 0,
		YM3812_ENABLED  = 1


global constant USES_EN  = 1,
		USES_EN2 = 2,
		USES_EP  = 3,
		USES_MP  = 4,
		USES_DM  = 5,
		USES_PM  = 6

global constant CUTOFF_VALUE = 1,
		CUTOFF_TYPE = 2
		
global constant CT_NORMAL = 1,
		CT_FRAMES = 2,
		CT_NEG = 3,
		CT_NEG_FRAMES = 4
		
global constant EFFECT_STRINGS = {"EN","EN2","EP","MP","DM","PM"}


global constant	NOTES = {'c', -2, 'd', -2, 'e', 'f', -2, 'g', -2, 'a', -2, 'b', 'r', 's'}

-- Octave 1 frequencies
global constant	OCTAVE1 =
{
	32.7032,	-- C
	34.6479,	-- C+ / D-
	36.7081,	-- D
	38.8909,	-- D+ / E-
	41.2035,	-- E
	43.6536,	-- F
	46.2493,	-- F+ / G-
	48.9995,	-- G
	51.9130,	-- G+ / A-
	55.0000,	-- A
	58.2705,	-- A+ / B-
	61.7354		-- B
}

-- Alternative frequencies for the SEGA Master System PSG
global constant	OCTAVE1_ALT_SMS = OCTAVE1 * 0.99370454545454545454545454545455


--global constant	SUPPORTED_LENGTHS = {32, 16, 8, 4, 2, 1}
--global constant ODD_LENGTHS       = {  24, 12, 6, 3}
global constant STANDARD_LENGTHS = {32, 16, 8, 4, 2, 1}
global constant EXTENDED_LENGTHS = {32, 24, 16, 12, 8, 6, 4, 3, 2, 1}

global constant	DIGITS = "0123456789",
		ALPHABET = "ABCDEFGHIJKLMNOPQRSTUVWXYZ",
		ALPHANUM = DIGITS & ALPHABET & lower(ALPHABET),
		ALPHANUM2 = ALPHANUM & '@'

global constant	MONTHS = {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"}
global constant	WEEKDAYS = {"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"}

global constant CRLF = {13, 10}


global atom	updateFreq

global integer 	target,
		verbose,
		warningsAreErrors,
		fileDataPos,
		inFile,
		outFile,
		lineNum,
		songNum,
		keepChannelsActive,
		maxTempo,
		minVolume,
		minWavLength,
		maxWavLength,
		maxWavSample,
		minWavSample,
		supportsPan,		-- Target supports some form of panning (@CS)
		supportsPAL,		-- Target has a 50 Hz video mode
		octaveRev,
		enRev,
		gbNoise,
		gbVolCtrl,
		rest,
		rest2,
		tie,
		slur,
		adsrLen,		
		adsrMax,
		implicitAdsrId,
		maxLoopDepth,
		tune,
		userDefinedBase,
		lastWasChannelSelect,
		bypass,
		longestDelay,
		useFractionalDelays	-- Use fixed-point note lengths with fractional part (allows for
					-- finer granularity is tempo settings).
		

global sequence cmdLine,
		fileData,
		restOfLine,
		shortFilename,
		supportedChannels,	-- Channel names supported on the target
		songTitle,		-- Title of the song
		songComposer,		-- The original composer of the song
		songProgrammer,		-- The person who made this particular version of the song (wrote the MML)
		songGame,		-- Game that the song originally comes from
		songAlbum,		-- Album on which the song is featured
		activeChannels,		-- Currently active channels
		supportsDutyChange,	-- Channel supports variable duty cycles
		supportsVolumeChange,	-- Channel volume can be changed (not just be set too on/off)
		supportsPCM,		-- Fixed frequency, samples tied to specific notes
		supportsWave,		-- Variable frequency
		supportsHwToneEnv,
		supportsHwVolEnv,
		supportsDetune,
		supportsFM,		-- Channel is an FM channel (YM2151, YM2413, YM2612)
		supportsADSR,
		supportsFilter,		-- Channel supports filtering
		supportsRing,		-- Channel supports ring modulation
		supportedLengths,
		maxVolume,
		machineVolLimit,
		minNote,
		minOctave,
		maxOctave,
		macros,
		patterns,
		pattern,
		patName,
		loopStack,
		volumeMacros,
		panMacros,
		dutyMacros,
		pitchMacros,
		feedbackMacros,
		pulseMacros,
		arpeggios,
		vibratos,
		portamentos,
		volumeSlides,
		callbacks,
		waveforms,
		waveformMacros,
		tuple,
		pcms,
		adsrs,
		mods,
		channelType,
		filters,
		usesEN,
		usesEffect,
		currentLength,
		currentNoteFrames,
		currentOctave,
		currentTempo,
		currentCutoff,
		currentNote,
		currentVolume,
		loopPoint,
		lastSetLength,
		pendingOctChange,
		songs,
		songLen,
		songLoopLen,
		hasAnyNote,
		shortestDelay,
		defines,
		dontCompile,
		hasElse,
		targetList
		

targetList = repeat(repeat(0, TARGET_LAST), 3)
