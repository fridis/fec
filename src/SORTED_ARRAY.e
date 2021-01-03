class SORTED_ARRAY[KEY -> COMPARABLE,ELEMENT -> SORTABLE[KEY]]  

inherit
	BINARY_SEARCH_ARRAY[KEY,ELEMENT];

creation
	make
	
feature { ANY }
			
	find (key: KEY): ELEMENT is
		local
			index: INTEGER;
		do
			index := binary_search(key,lower,upper); 
			if index >= 0 then
				Result := item(index);
			end; 
		end; -- find
			
	has (key: KEY): BOOLEAN is
		do
			Result := binary_search(key,lower,upper) >= 0; 
		end; -- has
			
end -- SORTED_ARRAY
