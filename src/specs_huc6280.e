-- HuC6280

include specs.e

global constant specs_huc6280 = {
	{ 0,   0,   0,   0,   1,   1},	-- Supports @
	{ 1,   1,   1,   1,   1,   1},	-- Supports volume change
	{ 0,   0,   0,   0,   0,   0},	-- Supports FM
	{ 0,   0,   0,   0,   0,   0},	-- Supports ADSR
	{ 0,   0,   0,   0,   0,   0},	-- Supports filter
	{ 0,   0,   0,   0,   0,   0},	-- Supports ring modulation
	{ 1,   1,   1,   1,   1,   1},	-- Supports WT
	{ 0,   0,   0,   1,   0,   0},	-- Supports XPCM
	{ 0,   0,   0,   0,   0,   0},	-- Supports @te
	{ 0,   0,   0,   0,   0,   0},	-- Supports @ve
	{ 1,   1,   1,   1,   1,   1},	
	{ 1,   1,   1,   0,   1,   1},	-- Min octave
	{ 12,  12,  12,  12,  12,  12},	-- Max octave
	{31,  31,  31,  31,  31,  31},	-- Max volume
	{ 1,   1,   1,   1,   1,   1},
	TYPE_HUC6280
}