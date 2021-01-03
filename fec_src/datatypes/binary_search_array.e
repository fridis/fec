--------------------------------------------------------------------------------
-- FEC -- Native Eiffel Compiler for SUN/SPARC
--
--  Copyright (C) 1997 Fridtjof Siebert
--    EMail: fridi@gr.opengroup.org
--    SMail: Fridtjof Siebert 
--           5b rue du 26 mai 1944
--           38940 St. Martin le Vinoux
--           Grenoble
--
--  This program is free software; you can redistribute it and/or modify
--  it under the terms of the GNU General Public License as published by
--  the Free Software Foundation; Version 2.
--
--  This program is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
--  GNU General Public License for more details.
--
--  You should have received a copy of the GNU General Public License
--  along with this program; if not, write to the Free Software
--  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
--
--------------------------------------------------------------------------------

class BINARY_SEARCH_ARRAY[KEY -> COMPARABLE,ELEMENT -> SORTABLE[KEY]]  

-- Array class providing a routine for binary search.

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
