include globals.e
include util.e

integer allowFloats,
        currentBase

allowFloats = 0
currentBase = 10


-- Convert an ASCII string to a wide char string
global function ascii_to_wide(sequence s)
	sequence t
	
	t = ""
	for i = 1 to length(s) do
		t &= s[i] & 0
	end for
	
	return t
end function


-- Read a string (anything but whitespace or EOF)
global function get_string()
	sequence s
	integer c
	
	skip_whitespace()
	
	s = ""
	c = 0
	while c != -1 do
		c = getch()
		if c = -1 or c = ' ' or c = '\t' or c = 13 or c = 10 then
			exit
		else
			s &= c
		end if
	end while
	
	ungetch()
	
	return s
end function


-- Read a string of characters that belong to the set specified in validChars
global function get_string_in_range(sequence validChars)
	sequence s
	integer c
	
	skip_whitespace()

	s = ""
	c = 0
	while c != -1 do
		c = getch()
		if find(c, validChars) <= 0 then
			exit
		else
			s &= c
		end if
	end while
	
	ungetch()
	
	return s
end function


-- Read a string of characters until some character in endChars is found
global function get_string_until(sequence endChars)
	sequence s
	integer c
	
	skip_whitespace()
	s = ""
	c = 0
	while c != -1 do
		c = getch()
		if find(c, endChars) > 0 then
			exit
		else
			s &= c
		end if
	end while
	
	ungetch()
	
	return s
end function


global function get_alpha_string()
	sequence s
	integer c
	
	skip_whitespace()

	s = ""
	c = 0
	while c != -1 do
		c = getch()
		if (c >= 'A' and c <= 'Z') or
		   (c >= 'a' and c <= 'z') then
			s &= c
		else
			exit
		end if
	end while
	
	ungetch()
	
	return s
end function


global procedure allow_floats_in_numeric_strings()
	allowFloats = 1
end procedure

global procedure set_numeric_base(integer b)
	currentBase = b
end procedure

-- Read a string of digits
global function get_numeric_string()
	sequence s
	integer c, prefix, prefixOk, sign
	
	skip_whitespace()

	s = ""
	c = 0
	prefixOk = 0
	prefix = 0
	sign = 0

	while c != -1 do
		c = getch()
		if (c >= '0' and c <= '9') or 
		   (c = '-' and not length(s)) or
		   (c = '.' and allowFloats and length(s) and (not (prefix = 'x' or currentBase = 16))) or
		   ((c = 'x' or c = 'd') and prefixOk) or
		   ((prefix = 'x' or currentBase = 16) and ((c >= 'a' and c <= 'f') or (c >= 'A' and c <= 'F'))) then
		   	if (c = '0' and (not length(s)) and prefix = 0) then
		   		prefixOk = 1
		   	else
		   		if ((c = 'x' or c = 'd') and prefixOk) then
		   			prefix = c
		   		end if
		   		prefixOk = 0
		   	end if
		   	if (c >= 'a' and c <= 'f') then
		   		c -= ' '
		   	end if
		   	if c = '-' then
		   		if sign = 0 then
			   		sign = -1
			   	end if
			else
				s &= c
			end if
		else
			exit
		end if
	end while
	
	ungetch()
	
	if prefix = 'x' then
		if length(s) > 2 then
			s = '#' & s[3..length(s)]
		else
			s = ""
		end if
	elsif prefix = 'd' then
		if length(s) > 2 then
			s = s[3..length(s)]
		else
			s = ""
		end if
	elsif currentBase = 16 then
		if length(s) then
			s = '#' & s
		end if
	end if
	
	allowFloats = 0
	currentBase = 10
	
	if sign = -1 then
		s = "-" & s
	end if
	
	return s
end function


-- Read a string of alphanumeric characters
global function get_alphanum_string()
	sequence s
	integer c
	
	skip_whitespace()

	s = ""
	c = 0
	while c != -1 do
		c = getch()
		if (c >= '0' and c <= '9') or
		   (c >= 'A' and c <= 'Z') or
		   (c >= 'a' and c <= 'z') then
			s &= c
		else
			exit
		end if
	end while
	
	ungetch()
	
	return s
end function


-- Return the substring of s from first..last
global function substr(sequence s, integer first, integer last)
	sequence t
	
	t = ""
	
	-- Make sure the indices are ok
	if first < 1 then
		first = 1
	end if
	if first > length(s) then
		first = length(s)
	end if
	if last < 1 then
		last = 1
	end if
	if last > length(s) then
		last = length(s)
	end if
	
	-- The slice must have positive length
	if first <= last then
		t = s[first..last]
	end if
	
	return t
end function


-- Return the substring of s from first..last
global function substr2(sequence s, integer first, integer last)
	sequence t
	
	t = ""
	
	-- The slice must have positive length
	if first >= 1 and first <= length(s) and last >= 1 and last <= length(s) and first <= last then
		t = s[first..last]
	end if
	
	return t
end function


global function strinsert(sequence s, integer pos, sequence data)
	if pos + length(data) - 1 > length(s) then
		s &= repeat(0, pos + length(data) - length(s) - 1)
	end if
	
	for i = 1 to length(data) do
		s[pos + i - 1] = data[i]
	end for
	
	return s
end function


-- Split an alphanumeric string into {alpha_part, numeric_part}
global function split_alphanum_string(sequence s)
	integer j
	
	j = 0
	for i = 1 to length(s) do
		if s[i] >= '0' and s[i] <= '9' then
			j = i
			exit
		end if
	end for
	
	return {substr(s, 1, j-1), substr(s, j, length(s))}
end function

