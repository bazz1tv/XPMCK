include specs.e

global constant specs_sn76489 = {
	{-1,  -1,  -1,   1},	-- Supports duty cycle change
	{ 1,   1,   1,   1},	-- Supports volume change
	{ 0,   0,   0,   0},	-- Supports FM
	{ 0,   0,   0,   0},	-- Supports ADSR
	{ 0,   0,   0,   0},	-- Supports filter
	{ 0,   0,   0,   0},	-- Supports ring modulation
	{ 0,   0,   0,   0},	-- Supports WT
	{ 0,   0,   0,   0},	-- Supports XPCM
	{ 0,   0,   0,   0},	-- Supports @te
	{ 0,   0,   0,   0},	-- Supports @ve
	{ 1,   1,   1,   0},	-- Supports detuning
	{ 2,   2,   2,   2},	-- Minimum octave
	{ 7,   7,   7,   7},	-- Maximum octave
	{15,  15,  15,  15},	-- Maximum volume
	{10,  10,  10,  10},	-- Lowest possible note is A in octave 2
	TYPE_SN76489
}
