-- SPC (S-DSP)

include specs.e

global constant specs_spc = {
	{  1,   1,   1,   1,   1,   1,   1,   1},	-- Supports @
	{  1,   1,   1,   1,   1,   1,   1,   1},	-- Supports volume change
	{  0,   0,   0,   0,   0,   0,   0,   0},	-- Supports FM
	{  1,   1,   1,   1,   1,   1,   1,   1},	-- Supports ADSR
	{  1,   1,   1,   1,   1,   1,   1,   1},	-- Supports filter
	{  0,   0,   0,   0,   0,   0,   0,   0},	-- Supports ring modulation
	{  1,   1,   1,   1,   1,   1,   1,   1},	-- Supports WT
	{  1,   1,   1,   1,   1,   1,   1,   1},	-- Supports XPCM
	{  0,   0,   0,   0,   0,   0,   0,   0},	-- Supports @te
	{  2,   2,   2,   2,   2,   2,   2,   2},	-- Supports @ve
	{  1,   1,   1,   1,   1,   1,   1,   1},	
	{  1,   1,   1,   0,   1,   1,   1,   1},	-- Min octave
	{ 12,  12,  12,  12,  12,  12,  12,  12},	-- Max octave
	{127, 127, 127, 127, 127, 127, 127, 127},	-- Max volume
	{  1,   1,   1,   1,   1,   1,   1,   1},
	TYPE_SPC
}