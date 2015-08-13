-- POKEY (Atari XL/XE etc)

include specs.e

global constant specs_pokey = {
	{ 7,   7,   7,   7},	-- Supports @
	{ 1,   1,   1,   1},	-- Supports volume change
	{ 0,   0,   0,   0},	-- Supports FM
	{ 0,   0,   0,   0},	-- Supports ADSR
	{ 1,   1,   1,   1},	-- Supports filter
	{ 0,   0,   0,   0},	-- Supports ring modulation
	{ 0,   0,   0,   0},	-- Supports WT
	{ 0,   0,   0,   0},	-- Supports XPCM
	{ 0,   0,   0,   0},	-- Supports @te
	{ 0,   0,   0,   0},	-- Supports @ve
	{ 1,   1,   1,   1},	-- Supports detuning
	{ 1,   1,   1,   1},	-- Minimum octave
	{ 9,   9,   9,   9},	-- Maximum octave
	{15,  15,  15,  15},	-- Maximum volume
	{ 1,   1,   1,   1},	-- Lowest possible note is A in octave 2
	TYPE_POKEY
}	