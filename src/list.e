include string.e


global constant
	LIST_MAIN = 2,	-- Index of the main part of the list (before |)
	LIST_LOOP = 3,	-- Index of the loop part of the list (after |)
	LIST_TYPE = 4,
	LIST_POS = 3,	-- Index of the list position data
	LIST_RET = 3,	-- Index of the returned data from step_list
	LIST_VAL = 3	-- Index of the value in the returned data from step_list


integer wtListOk
sequence listDelimiter
wtListOk = 0
listDelimiter = "{}"


global procedure allow_wt_list()
	wtListOk = 1
end procedure

global procedure set_list_delimiters(sequence delim)
	listDelimiter = "()"
end procedure


-- Read a {}-enclosed list of numbers separated by spaces or commas. The list can
-- contain a loop, beginning at | and ranging to the end of the list.
global function get_list()
	sequence s,t
	integer c, commaOk, endOk, pipeOk, concatTo, rept
	object o
	atom startVal, stopVal, stepVal
	
	-- s[2] will contain everything before the |, s[3] everything after it.
	s = {GET_FAIL, {}, {}}
	
	commaOk = 0		-- Not ok to read a comma
	pipeOk = 1		-- Ok to read a |
	endOk = 0		-- Not ok to read a }
	concatTo = LIST_MAIN	-- Concatenate to s[2]
	
	skip_whitespace()
	
	c = getch()
	
	if c = listDelimiter[1] then
		while 1 do
			skip_whitespace()
			set_numeric_base(userDefinedBase)
			t = get_numeric_string()
			
			if length(t) then
				o = value(t)
				if o[1] = GET_SUCCESS then
					skip_whitespace()
					c = getch()
					if c = ':' then
						startVal = floor(o[2])
						set_numeric_base(userDefinedBase)
						t = get_numeric_string()
						o = value(t)
						rept = 0
						if o[1] = GET_SUCCESS then
							stopVal = floor(o[2])
							skip_whitespace()
							c = getch()
							if c = ':' then
								if userDefinedBase = 10 then
									allow_floats_in_numeric_strings()
								end if
								set_numeric_base(userDefinedBase)
								t = get_numeric_string()
								o = value(t)
								if o[1] = GET_SUCCESS then
									stepVal = o[2]
								else
									ERROR("Malformed interval: " & t, lineNum)
								end if
								c = getch()
								if c = '\''then
									t = get_numeric_string()
									o = value(t)
									if o[1] = GET_SUCCESS then
										if o[2] < 1 then
											ERROR("Repeat value must be >= 1", lineNum)
										end if
										rept = o[2]
									else
										ERROR("Expected a repeat value, got " & t, lineNum)
									end if
								else
									ungetch()
								end if
							elsif c = '\'' then
								if rept then
									ERROR("Found more than one repeat value for the same interval", lineNum)
								end if
								if stopVal < startVal then
									stepVal = -1
								else
									stepVal = 1
								end if
								t = get_numeric_string()
								o = value(t)
								if o[1] = GET_SUCCESS then
									if o[2] < 1 then
										ERROR("Repeat value must be >= 1", lineNum)
									end if
									rept = o[2]
								else
									ERROR("Expected a repeat value, got " & t, lineNum)
								end if
																
							else
								ungetch()
								if stopVal < startVal then
									stepVal = -1
								else
									stepVal = 1
								end if
							end if
						else
							ERROR("Malformed interval: " & t, lineNum)
						end if
						if (stopVal < startVal and stepVal >= 0) then
							WARNING(sprintf("Auto-negating step value for interval %d:%d", {startVal, stopVal}), lineNum)
							stepVal = -stepVal
						elsif (stopVal > startVal and stepVal <= 0) then
							WARNING(sprintf("Auto-negating step value for interval %d:%d", {startVal, stopVal}), lineNum)
							stepVal = -stepVal
						end if

						if stepVal = 0 then
							ERROR("Step value must be non-zero", lineNum)
						end if
						
						if not rept then
							rept = 1
						end if
						
						for i = startVal to stopVal by stepVal do
							for j = 1 to rept do
								s[concatTo] &= floor(i)
							end for
						end for
					
					elsif c = '\'' then
						startVal = floor(o[2])
						set_numeric_base(userDefinedBase)
						t = get_numeric_string()
						o = value(t)
						if o[1] = GET_SUCCESS then
							if o[2] < 1 then
								ERROR("Repeat value must be >= 1", lineNum)
							else
								if o[2] > 100 then
									WARNING("Ignoring repeat values > 100", lineNum)
									o[2] = 1
								end if
								for i = 1 to o[2] do
									s[concatTo] &= startVal
								end for
							end if
						else
							ERROR("Expected a repeat value, got " & t, lineNum)
						end if
					else
						ungetch()
						s[concatTo] &= o[2]
					end if
					commaOk = 1
					pipeOk = 1
					endOk = 1
				else
					ERROR("Syntax error: " & t, lineNum)
				end if
			else
				c = getch()
				if c = ',' then
					if not commaOk then
						ERROR("Unexpected comma", lineNum)
					end if
					commaOk = 0
					pipeOk = 0
					endOk = 0
				elsif c = '|' then
					if concatTo = LIST_MAIN and pipeOk then
						concatTo = LIST_LOOP
						commaOk = 0
						pipeOk = 0
						endOk = 0
					else
						ERROR("Unexpected |", lineNum)
					end if
				elsif c = listDelimiter[2] then
					if endOk then
						s[1] = GET_SUCCESS
						exit
					else
						ERROR("Malformed list", lineNum)
					end if
				elsif c = ';' then
					while c != 10 and c != -1 do
						c = getch()
					end while
				elsif c = '\"' then
					t = ""
					c = getch()
					while c != '\"' and c != -1 do
						t &= c
						c = getch()
					end while
					s[concatTo] &= {t}
				elsif c = '\'' or c = ':' then
					ERROR("Unexpected " & c, lineNum)
				elsif c = 'W' and wtListOk then
					c = getch()
					if c = 'T' then
						t = get_numeric_string()
						o = value(t)
						if o[1] = GET_SUCCESS then
							s[concatTo] &= {{-1, 'W', 'T', o[2]}}
							commaOk = 1
							pipeOk = 1
							endOk = 1
						else
							ERROR("Expected a number, got " & t, lineNum)
						end if
					else
						ERROR("Expected WT, got W" & c, lineNum)
					end if
				elsif c = -1 then
					exit
				end if
			end if
		end while
	else
		ERROR("Expected {, got " & c, lineNum)
	end if
	
	if s[1] = GET_SUCCESS then
		while 1 do
			skip_whitespace()
			c = getch()
			if c = '+' or c = '-' or c = '*' or c = '\'' then
				skip_whitespace()
				allow_floats_in_numeric_strings()
				t = get_numeric_string()
				if length(t) then
					o = value(t)
					if o[1] = GET_SUCCESS then
						if c = '+' then
							s[2] = floor(s[2] + o[2])
							s[3] = floor(s[3] + o[2])
						elsif c = '-' then
							s[2] = floor(s[2] - o[2])
							s[3] = floor(s[3] - o[2])
						elsif c = '*' then
							s[2] = floor(s[2] * o[2])
							s[3] = floor(s[3] * o[2])
						elsif c = '\'' then
							if o[2] < 1 then
								ERROR("Repeat value must be >= 1", lineNum)
							end if
							if o[2] > 100 then
								WARNING("Repeat values > 100 are ignored", lineNum)
							else
								t = {}
								for i = 2 to 3 do
									t = {}
									for j = 1 to length(s[i]) do
										for k = 1 to o[2] do
											t &= s[i][j]
										end for
									end for
									s[i] = t
								end for
							end if
						end if
					else
						ERROR("Syntax error: " & t, lineNum)
					end if
				else
					ERROR("Expected a numeric constant after " & c, lineNum)
				end if
			else
				ungetch()
				exit
			end if
		end while
	end if
	
	-- Reset these configurations
	wtListOk = 0
	listDelimiter = "{}"
	
	return s
end function


-- Step through a list
-- Return {new_position next_item}
global function step_list(sequence l, sequence pos)
	sequence t
	if pos[1] <= length(l[pos[2]]) then
		t = {l[pos[2]][pos[1]]}
		pos[1] += 1
		t = pos[1..2] & t
	else 
		if length(l[LIST_LOOP]) then
			pos[2] = LIST_LOOP
			pos[1] = 1
			t = {l[pos[2]][pos[1]]}
			pos[1] += 1
			t = pos[1..2] & t
		else
			t = {length(l[2]), 2, l[2][length(l[2])]}
		end if
	end if
	
	return t
end function
		
	
-- Return a sequence containing a text-form representation on a list returned by get_list
-- 
-- Examples:
--   {GET_SUCCESS, {1, 2, 3}, {}} -> "{1 2 3}"
--   {GET_SUCCESS, {1, 2, 3}, {4, 5}} -> "{1 2 3 | 4 5}"
--   {GET_SUCCESS, {}, {4, 5}} -> "{| 4 5}"
--
global function sprint_list(sequence l)
	sequence t
	
	t = "{"
	for i = 1 to length(l[LIST_MAIN]) do
		if sequence(l[LIST_MAIN][i]) then
			if l[LIST_MAIN][i][1] = -1 then
				t &= sprintf("WT%d", l[LIST_MAIN][i][4])
			else
				t &= l[LIST_MAIN][i] & " "
			end if
		else
			t &= sprintf("%d", l[LIST_MAIN][i])
		end if
		if i < length(l[LIST_MAIN]) then
			t &= ' '
		end if
	end for
	
	if length(l[LIST_LOOP]) then
		t &= " | "
		for i = 1 to length(l[LIST_LOOP]) do
			if sequence(l[LIST_MAIN][i]) then
				if l[LIST_MAIN][i][1] = -1 then
					t &= sprintf("WT%d", l[LIST_MAIN][i][4])
				end if
			else
				t &= sprintf("%d", l[LIST_LOOP][i])
			end if
			if i < length(l[LIST_LOOP]) then
				t &= ' '
			end if
		end for
	end if
	
	return t & '}'
end function


global function is_empty_list(sequence l)
	return (length(l[LIST_MAIN]) + length(l[LIST_LOOP])) = 0
end function
