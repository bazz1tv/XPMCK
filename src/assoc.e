global constant
	ASSOC_KEY = 1,
	ASSOC_DATA = 2,
	ASSOC_REF = 3,
	ASSOC_EXTRA = 4
	
	
global function assoc_create()
	return {{}, {}, {}, {}}
end function


global function assoc_append(sequence l, object key, object data)
	l[ASSOC_KEY] = append(l[ASSOC_KEY], key)
	l[ASSOC_DATA] = append(l[ASSOC_DATA], data)
	l[ASSOC_REF] &= 0
	l[ASSOC_EXTRA] = append(l[ASSOC_EXTRA], {})
	return l
end function

global function assoc_find_key(sequence l, object key)
	return find(key, l[ASSOC_KEY])
end function


global function assoc_get_data(sequence l, object key)
	return l[ASSOC_DATA][assoc_find_key(l, key)]
end function


global function assoc_insert_extra_data(sequence l, object key, object data)
	l[ASSOC_EXTRA][assoc_find_key(l, key)] &= data
	return l
end function


global function assoc_get_extra_data(sequence l, object key)
	return l[ASSOC_EXTRA][assoc_find_key(l, key)]
end function


global function assoc_reference(sequence l, object key)
	l[ASSOC_REF][assoc_find_key(l, key)] = 1
	return l
end function


global function assoc_is_referenced(sequence l, object key)
	return l[ASSOC_REF][assoc_find_key(l, key)]
end function


global function assoc_get_keys(sequence l)
	return l[ASSOC_KEY]
end function


global function assoc_get_references(sequence l)
	return l[ASSOC_REF]
end function

