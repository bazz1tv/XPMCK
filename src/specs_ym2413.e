include specs.e

global constant specs_ym2413 = {
	{15,  15,  15,  15,  15,  15,  15,  15,  15},	-- Supports @
	{ 1,   1,   1,   1,   1,   1,   1,   1,   1},	-- Supports volume change
	{ 1,   1,   1,   1,   1,   1,   1,   1,   1},	-- Supports FM
	{ 1,   1,   1,   1,   1,   1,   1,   1,   1},	-- Supports ADSR
	{ 0,   0,   0,   0,   0,   0,   0,   0,   0},	-- Supports filter
	{ 0,   0,   0,   0,   0,   0,   0,   0,   0},	-- Supports ring modulation
	{ 0,   0,   0,   0,   0,   0,   0,   0,   0},	-- Supports WT	
	{ 0,   0,   0,   0,   0,   0,   0,   0,   0},	-- Supports XPCM
	{ 1,   1,   1,   1,   1,   1,   1,   1,   1},	-- Supports @te
	{63,  63,  63,  63,  63,  63,  63,  63,  63},	-- Supports @ve
	{ 1,   1,   1,   1,   1,   1,   1,   1,   1},	
	{ 1,   1,   1,   1,   1,   1,   1,   1,   1},	-- Min octave
	{ 7,   7,   7,   7,   7,   7,   7,   7,   7},	-- Max octave
	{15,  15,  15,  15,  15,  15,  15,  15,  15},	-- Max volume
	{ 1,   1,   1,   1,   1,   1,   1,   1,   1},	-- Min playable note
	TYPE_YM2413
}
