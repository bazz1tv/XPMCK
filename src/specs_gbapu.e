-- Gameboy APU

include specs.e

global constant specs_gbapu = {
	{ 3,   3,  -1,   1},	-- Supports @
	{ 1,   1,   1,   1},	-- Supports volume change
	{ 0,   0,   0,   0},	-- Supports FM
	{ 0,   0,   0,   0},	-- Supports ADSR
	{ 0,   0,   0,   0},	-- Supports filter
	{ 0,   0,   0,   0},	-- Supports ring modulation
	{ 0,   0,   1,   0},	-- Supports WT
	{ 0,   0,   0,   0},	-- Supports XPCM
	{ 7,   0,   0,   0},	-- Supports @te
	{ 7,   7,   0,   7},	-- Supports @ve
	{ 1,   1,   0,   0},	
	{ 2,   2,   1,   1},	-- Min octave
	{ 7,   7,   7,  11},	-- Max octave
	{15,  15,   3,  15},	-- Max volume
	{ 1,   1,   1,   1},
	TYPE_GBAPU
}