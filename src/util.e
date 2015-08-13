-- Utility functions for XPMC

include globals.e


-- Output an error message and abort execution
global procedure ERROR(sequence msg, integer line)
	if line = -1 then
		puts(1, shortFilename & ", Error: " & msg & "\n")
	else
		printf(1, shortFilename & "@%d, Error: " & msg & "\n", line)
	end if
	--while get_key() = -1 do end while
	abort(0)
end procedure


-- Output a warning message
global procedure WARNING(sequence msg, integer line)
	if warningsAreErrors then
		ERROR(msg, line)
	else
		if line = -1 then
			puts(1, shortFilename & ", Warning: " & msg & "\n")
		else
			printf(1, shortFilename & "@%d, Warning: " & msg & "\n", line)
		end if
	end if
end procedure


global procedure ADD_CMD(integer chn, sequence cmd)
	songs[songNum][chn] &= cmd
	--? cmd
end procedure


-- Define a symbol with a given name and value
global procedure define(sequence what, object val)
	integer i
	
	i = find(what, defines[1])
	if i >= 1 then
		defines[2][i] = val
	else
		defines[1] = append(defines[1], what)
		defines[2] = append(defines[2], val)
	end if
end procedure


-- Check if a symbol with a given name is defined
global function is_defined(sequence what)
	if find(what, defines[1]) >= 1 then
		return 1
	end if
	return 0
end function


-- Return the absolute value of a
global function abs(atom a)
	if a < 0 then
		return -a
	end if
	return a
end function


global function ceil2(atom a)
	return -floor(-a)
end function


global function round2(atom a)
	if abs(a) - floor(abs(a)) > 0.5 then
		return ceil2(a)
	end if
	return floor(a)
end function


global function max(sequence s)
	integer m
	
	m = s[1]
	for i = 1 to length(s) do
		if s[i] > m then
			m = s[i]
		end if
	end for
	
	return m
end function


global function min(sequence s)
	integer m
	
	m = s[1]
	for i = 1 to length(s) do
		if s[i] < m then
			m = s[i]
		end if
	end for
	
	return m
end function


global function getch()
	integer c
	
	c = -1
	if fileDataPos <= length(fileData) then
		c = fileData[fileDataPos]
		fileDataPos += 1
	end if
	
	return c
end function


-- Unget the last read character  
global procedure ungetch()
	if fileDataPos > 1 then
		fileDataPos -= 1
	end if
end procedure


-- Consume whitespace
global procedure skip_whitespace()
	integer c
	
	c = 0
	while c != -1 do
		c = getch()
		if c = ' ' or c = '\t' or c = 13 or c = 10 then
			if c = 10 then
				lineNum += 1
			end if
		else
			exit
		end if
	end while
	
	ungetch()
end procedure


-- Sum up all elements of s
global function sum(sequence s)
	atom n
	
	n = 0
	for i = 1 to length(s) do
		n += s[i]
	end for
	
	return n
end function


-- Push o onto s and return s
global function push(sequence s, object o)
	return append(s, o)
end function


-- Pop the top element from s and return {top of s, rest of s}
global function pop(sequence s)
	object o
	
	o = 0
	
	if length(s) then
		o = s[length(s)]
		if length(s) > 1 then
			s = s[1..length(s) - 1]
		else
			s = {}
		end if
	end if
	
	return {o, s}
end function


-- Check if o is in the range of min and max
--
-- Examples:
--   in_range(1, 0, 5) -> 1
--   in_range({1,2,3}, 1, 10) -> 1
--   in_range({1,2}, {0,0}, 5) -> 1
--   in_range({1,2}, {2,0}, 5) -> 0     (min[1]>o[1])
--   in range({1,2}, {0,0,0}, 5) -> 0   (too many elements in min)
--
global function in_range(object o, object min, object max)
	if atom(o) then
		if atom(min) and atom(max) then
			return ((o >= min) and (o <= max))
		else
			return 0
		end if
	else
		if atom(min) and atom(max) then
			for i = 1 to length(o) do
				if o[i] < min or o[i] > max then
					return 0
				end if
			end for
		elsif atom(min) and sequence(max) then
			if length(max) = length(o) then
				for i = 1 to length(o) do
					if o[i] < min or o[i] > max[i] then
						return 0
					end if
				end for
			else
				return 0
			end if
		elsif sequence(min) and atom(max) then
			if length(min) = length(o) then
				for i = 1 to length(o) do
					if o[i] < min[i] or o[i] > max then
						return 0
					end if
				end for
			else
				return 0
			end if
		else
			if length(min) = length(max) and length(max) = length(o) then
				for i = 1 to length(o) do
					if o[i] < min[i] or o[i] > max[i] then
						return 0
					end if
				end for
			else
				return 0
			end if
		end if
	end if
	
	return 1
end function


-- Return true (1) if o is a digit or a sequence of digits
global function is_numeric(object o)
	return in_range(o, '0', '9')
end function


-- Return true (1) if o is a letter in the english alphabet or a sequence of such letters
global function is_alpha(object o)
	return in_range(o, 'a', 'z') or in_range(o, 'A', 'Z')
end function


global function is_alphanum(object o)
	if atom(o) then
		return (is_alpha(o) or is_numeric(o))
	end if
	for i = 1 to length(o) do
		if ((not is_alpha(o[i])) and (not is_numeric(o[i]))) then
			return 0
		end if
	end for
	return 1
end function


-- Get an unsigned word (16 bits) from file fh
global function get_word(integer fh)
	integer dw
	
	dw = getc(fh)
	dw += (getc(fh)*#100)
	return dw
end function


-- Get a signed word (16 bits) from file fh
global function get_sword(integer fh)
	integer dw
	
	dw = getc(fh)
	if dw = -1 then
		return 65536
	end if
	dw += (getc(fh) * #100)
	if and_bits(dw, #8000) then
		return -(32768 - and_bits(dw, #7FFF))
	end if
	return dw
end function


-- Get a dword (32 bits) from file fh
global function get_dword(integer fh)
	atom dw
	
	dw = getc(fh)
	dw += (getc(fh) * #100)
	dw += (getc(fh) * #10000)
	dw += (getc(fh) * #1000000)
	return dw
end function


global procedure put_word(integer fh, integer w)
	puts(fh,{w, floor(w/#100)})
end procedure


global procedure put_sword(integer fh, integer w)
	if w<0 then
		w = or_bits(32768+w, #8000)
	end if
	puts(fh,{w, floor(w/#100)})
end procedure


global procedure put_dword(integer fh, atom dw)
	puts(fh,{dw, floor(dw/#100), floor(dw/#10000), floor(dw/#1000000)})
end procedure


global function swap_word(integer w)
	return and_bits(w, #FF) * #100 + floor(w / #100)
end function


global function swap_dword(atom dw)
	return swap_word(and_bits(dw, #FFFF)) * #10000 + swap_word(floor(dw / #10000))
end function


-- Clear bit nr b in i and return the new value
global function clear_bit(integer i, integer b)
	return and_bits(i, not_bits(power(2, b)))
end function


-- Set bit nr b in i and return the new value
global function set_bit(integer i, integer b)
	return or_bits(i, power(2, b))
end function


global procedure add_target(integer targetNum, sequence targetName, integer initId, integer outputId)
	targetList[TRG_NAME][targetNum] = targetName
	targetList[TRG_INIT_PROC][targetNum] = initId
	targetList[TRG_OUTP_PROC][targetNum] = outputId
end procedure




