class BINARY_SEARCH_ARRAY[KEY -> COMPARABLE,ELEMENT -> SORTABLE[KEY]]  

inherit
	ARRAY[ELEMENT];

creation
	make
	
feature { ANY }
			
	binary_search(key: KEY; low,up: INTEGER): INTEGER is
		-- sucht Result=key in item(low..up). Ergebnis ist der Index oder -1.
		-- Aufwand: O(ln(up-low+1)), ln(up-low+1)+1 Vergleiche
		local
			min,max,mid,cmp: INTEGER 
		do
			from 
				min := low;
				max := up;
				cmp := -1;
			invariant  
				min > low implies key >= item(min - 1).key
				max < up  implies key <= item(max + 1).key				 
			variant 
				max-min	 
			until  
				min>max 
			loop 
				mid := (min+max) // 2; 
				cmp := key.three_way_comparison(item(mid).key); 
				if cmp <= 0 then max := mid-1 end 
				if cmp >= 0 then min := mid+1 end 
			end 
			if cmp=0 then 
				Result := mid 
			else
				Result := -1;
			end
		end; -- binary_search
			
end -- BINARY_SEARCH_ARRAY
