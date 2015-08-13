-- WAV input/output functions for XPMC

without warning

include globals.e
include util.e


constant SQUARE=1,SAWTOOTH=2,SINE=4,NOISE=8

constant CHN_DATAPOS	= 2,
	 CHN_WAVEFORM	= 7,
	 CHN_FREQ	= 8,
	 CHN_VOLUME 	= 11,
	 CHN_VOLMAC	= 14,
	 CHN_PANMAC	= 22,
	 CHN_MODE	= 23,
	 CHN_ADSR	= 25,
         CHN_OPER	= 26,
         CHN_PATTERN	= 34,
         CHN_CHANNEL	= 35,
         CHN_OLDPOS	= 36,
         CHN_ENV_LVL	= 37,
         CHN_FILTER	= 38,
         CHN_PREVNOTE	= 39,
         CHN_ENV_PHS	= 40,
         CHN_OUTPUT	= 41,
         CHN_PREVSMP	= 42,
         CHN_SMPPOS	= 43,
         CHN_SMPDLT	= 44
         
         
-- Extract the sample data from a WAV file and convert it to mono with a given sample rate and volume
-- UNFINISHED
global function convert_wav(sequence fname, integer sampleRate, integer volume)
	integer fn
	integer b, w, wavFormat, wavChannels, wavSamplesPerSec, wavAvgBytesPerSec,
	        wavBlockAlign, wavBitsPerSample, samplesInChunk, nextPos, sampleDiv
	sequence s, wavData
	atom dw, dataStart, dataSize, pos, deltaPos
	
	fn = open(fname,"rb")
	if fn < 0 then
		ERROR("Unable to open file: " & fname, lineNum)
	end if

	s = get_bytes(fn, 4)
	if not equal(s, "RIFF") then
		ERROR("No RIFF tag found in " & fname, -1)
	end if
	
	if get_dword(fn) then end if
	
	s = get_bytes(fn,4)
	if not equal(s, "WAVE") then
		ERROR("No WAVE tag found in " & fname, -1)
	end if

	dataSize = -1
	wavData = {}
	
	-- Read the chunks
	while 1 do
		-- Get the chunk ID
		s = get_bytes(fn, 4)
		if length(s) < 4 then
			exit
		end if

		-- Get the chunk size
		dw = get_dword(fn)
	
		if equal(s, "fmt ") then
			wavFormat = get_word(fn)
			wavChannels = get_word(fn)
			wavSamplesPerSec = get_dword(fn)
			wavAvgBytesPerSec = get_dword(fn)
			wavBlockAlign = get_word(fn)
			wavBitsPerSample = get_word(fn)
		
			if wavFormat!=1 or (wavBitsPerSample!=8 and wavBitsPerSample!=16) or wavChannels > 2 then
				ERROR("Unsupported wav format in " & fname, -1)
			end if
		
			if sampleRate > 0 then
				deltaPos = wavSamplesPerSec / sampleRate
			else
				deltaPos = 1.0
			end if
			pos = 1
			
			if deltaPos != 1.0 and verbose then
				printf(1, "Resampling from %d to %d Hz\n", {wavSamplesPerSec,sampleRate})
			end if
			
			if wavChannels > 1 and verbose then
				puts(1, "Converting sample to mono\n")
			end if
			
			if wavBitsPerSample != 8 and verbose then
				puts(1, "Converting sample to 8-bit unsigned\n")
			end if
			
		elsif equal(s, "data") then
			dataStart = where(fn)
			dataSize = dw
			
			sampleDiv = 0
			
			--? {wavBitsPerSample, wavChannels, dataSize, deltaPos}
			
			if wavBitsPerSample = 8 then
				if wavChannels = 1 then
					samplesInChunk = dataSize
					wavData = {}
					while floor(pos) <= samplesInChunk do
						nextPos = floor(pos + deltaPos)
						if floor(pos) < nextPos then
							b = 0
							sampleDiv = 0
							while floor(pos) < nextPos do
								b += getc(fn)
								pos += 1 
								sampleDiv += 1
							end while
						end if
						if sampleDiv then
							wavData &= floor(b / sampleDiv)
						end if
					end while
				elsif wavChannels = 2 then
					samplesInChunk = floor(dataSize / 2)
					wavData = {}
					while floor(pos) <= samplesInChunk do
						nextPos = floor(pos + deltaPos)
						if floor(pos) < nextPos then
							b = 0
							sampleDiv = 0
							while floor(pos) < nextPos do
								b += getc(fn) + getc(fn)
								pos += 1 
								sampleDiv += 1
							end while
						end if
						if sampleDiv then
							wavData &= floor(b / (sampleDiv * 2))
						end if
					end while
				end if
			else
				if wavChannels = 1 then
					samplesInChunk = floor(dataSize / 2)
					wavData = {}
					while floor(pos) <= samplesInChunk do
						nextPos = floor(pos + deltaPos)
						if floor(pos) < nextPos then
							w = 0
							sampleDiv = 0
							while floor(pos) < nextPos do
								w += floor((get_sword(fn) + 32768) / 256)
								pos += 1 
								sampleDiv += 1
							end while
						end if
						if sampleDiv then
							wavData &= floor(w / sampleDiv)
						end if
					end while
				elsif wavChannels = 2 then
					samplesInChunk = floor(dataSize / 4)
					wavData = {}
					while floor(pos) <= samplesInChunk do
						nextPos = floor(pos + deltaPos)
						if floor(pos) < nextPos then
							w = 0
							sampleDiv = 0
							while floor(pos) < nextPos do
								w += floor((get_sword(fn) + 32768) / 256) + floor((get_sword(fn) + 32768) / 256) 
								pos += 1 
								sampleDiv += 1
							end while
						end if
						if sampleDiv then
							wavData &= floor(w / (sampleDiv * 2))
						end if
					end while
				end if
			
			end if

		else
			-- Unhandled chunk type, just skip it.
			for i = 1 to dw do
				b = getc(fn)
			end for
		end if
	end while
	
	close(fn)
	
	if verbose then
		printf(1, "Size of converted sample: %d bytes\n", length(wavData))
	end if
	
	return floor((wavData * volume) / 100.0)
end function



constant SQUARE_DUTY = {
{1,-1,-1,-1,-1,-1,-1,-1},
{1,1,-1,-1,-1,-1,-1,-1},
{1,1,1,1,-1,-1,-1,-1},
{1,1,1,1,1,1,-1,-1}
}

constant ATTACK_RATE = {2,5,10,25,50,100,200,400, 750,1200,1700,2300,3000,4500,6000,8000}
constant DECAY_RATE  = {6,20,50,100,200,500,900,1500, 3000,5000,7500,10000,13500,17500,20500,24000}

integer  squarePhase,noisePhase


