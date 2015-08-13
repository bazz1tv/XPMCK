include specs.e

global constant specs_ym2612 = {
	{  7,   7,   7,   7,   7,   7},	-- Supports @
	{  1,   1,   1,   1,   1,   1},	-- Supports volume change
	{  1,   1,   1,   1,   1,   1},	-- Supports FM
	{  1,   1,   1,   1,   1,   1},	-- Supports ADSR
	{  0,   0,   0,   0,   0,   0},	-- Supports filter
	{  0,   0,   0,   0,   0,   0},	-- Supports ring modulation
	{  0,   0,   0,   0,   0,   1},	
	{  0,   0,   0,   0,   0,   1},
	{  0,   0,   0,   0,   0,   0},
	{  0,   0,   0,   0,   0,   0},
	{  1,   1,   1,   1,   1,   1},
	{  1,   1,   1,   1,   1,   0},	-- Min octave
	{  7,   7,   7,   7,   7,   7},	-- Max octave
	{127, 127, 127, 127, 127, 127},	-- Max volume
	{  1,   1,   1,   1,   1,   1},	-- Min playable note
	TYPE_YM2612
}
