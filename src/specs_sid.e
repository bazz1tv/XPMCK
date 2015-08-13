include specs.e

global constant specs_sid = {
	{ 3,   3,   3},	-- Supports @
	{ 1,   1,   1},	-- Supports volume change
	{ 0,   0,   0},	-- Supports FM
	{ 1,   1,   1},	-- Supports ADSR
	{ 1,   1,   1},	-- Supports filter
	{ 1,   1,   1},	-- Supports ring modulation
	{ 0,   0,   0},
	{ 0,   0,   0},
	{ 0,   0,   0},
	{ 0,   0,   0},
	{ 1,   1,   1},	-- Supports detuning
	{ 0,   0,   0},	-- Min octave
	{ 7,   7,   7},	-- Max octave
	{15,  15,  15},	-- Max volume
	{ 1,   1,   1},	-- Min playable note
	TYPE_SID
}
	