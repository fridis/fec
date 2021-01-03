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

class PS_ARRAY[KEY -> COMPARABLE,ELEMENT -> SORTABLE[KEY]]  -- Partly sorted Array

-- A Partly sorted array. This is a sorted array data structure that allows
-- fast insertion and retrieval of elements and fast sorting of the complete
-- array. 
--
-- This array stores n Elments in sorted subarray whose sizes are powers of two.
-- For every "1" at Position i in the binary representation of n there is a 
-- sorted array of 2^i Elements. So for n=10, we have two arrays, eight are
-- stored in one sorted array, two in another. Adding one Element to this list
-- will add a new array with a single Element (which is sorted). Adding yet
-- another element forces to join the new element, and the elements in the
-- one- and two-element-arrays into one sorted four-element-array. 

creation
	make
	
feature { NONE }

	data: BINARY_SEARCH_ARRAY[KEY,ELEMENT];

	msb_of_count: INTEGER;   -- 2^log2(count) = Most significant bit of count.

-- Es gilt stehts:
-- data besteht aus einzelnen Blöcken mit den Indizes 1..1,2..3,.4..7,8..15 usw.,
-- allgemein Block Nummer i reicht von 2^(i-1) bis 2^i-1, für i = 1,2,3,..
-- Jeder dieser Blöcke enthält gültigen Daten nur dann, wenn 
-- count // 2^(i-1) \\ 2 = 1, also wenn Bit i in count gesetzt ist.

	min_size: INTEGER is 7;        -- minimum number of elements allocated.
	msb_of_min_size: INTEGER is 3; -- msb(min_size)
	
feature { ANY }
		
	count: INTEGER;    -- number of elements in the array
	
	is_empty: BOOLEAN is 
		do
			Result := count=0
		ensure
			Result = (count=0)
		end;  -- is_empty

	make is -- create an empty array
		do
memstats(213);
			!!data.make(1,min_size);
			count := 0; 
			msb_of_count := 0;
		ensure
			count = 0
		end; -- make	
		
	add (element: ELEMENT) is 
		-- add element to the array
		-- Aufwand: O(ln(n)) im Durchschnitt,
		--          O(n)     im schlimmsten Fall.
		-- Grund: In 50%   der Fälle ist count // 1 \\ 2 = 1
		--        in 25%   der Fälle ist count // 2 \\ 2 = 1
		--        in 12.5% der Fälle ist count // 4 \\ 2 = 1
		-- und damit ergibt sich der durchschnittliche Aufwand zu
		--       A = 1 + 1/2*2 + 1/4*4 + 1/8*8 + ... + 1/n*n mit n = 2^m.
		--         = SUM(i=0..ln(n)) : (1/(2^i)) * 2^i 
		--         = SUM(i=0..ln(n): 1)
		--         = ln(n) + 1
		-- also: A = O(ln(n)).
		-- Im schlimmsten Fall gilt
		--       A = 1 + 2 + 4 + 8 + ... + n
		--         = 2*n-1 
		-- also: A = O(n).
		local
			first_empty,c_div_fe: INTEGER;
			index: INTEGER;
		do
			count := count + 1;
			if count=1 then
				msb_of_count := 1;
			elseif count = 2*msb_of_count then
				msb_of_count := count;
				if count>data.upper then
memstats(214);
					data.resize(1,count*2-1);
				end;
			end;
			
			from  -- Berechne first_empty := GCD(count,2^63):
				first_empty := 1;
				c_div_fe := count;
			until
				c_div_fe \\ 2 = 1
			loop
				first_empty := 2*first_empty;
				c_div_fe := c_div_fe // 2;
			end;

			data.put(element,first_empty);
			from -- Alle Element in 1..first_empty-1 zusammen mit neuem Element nach
			     -- first_empty..2*first_empty-1 sortieren
				index := 1;
			until
				index = first_empty
			loop
				join_arrays(index,first_empty,index);
				index := index * 2;
			end;
		end;  -- add

	find (key: KEY): ELEMENT is
	-- Aufwand: O(ln(n)) im Durchschnitt, 
	--          O(ln(n)^2) im schlimmsten Fall.
	-- In 50% der Fälle ist erste binäre Suche erfolgreich (1/2*ln(n/2))
	-- in 25% der Fälle die zeite: (1/4*ln(n/4))
	-- in 12,5% der Fälle die dritte: (1/8*ln(n/8))
	-- also zusammen: 
	--   1*ln(n/2)+1/2*ln(n/4)+1/4*ln(n/8)+1/(n/2)*ln(1)
	--  <= ln(n)*(1+1/2+1/4+...+1/(n/2)) <= 2*ln(n).
		local
			index,c_mod_index,search_index: INTEGER;
		do
--print("find start:%N");
			from
				index := 2*msb_of_count;
				c_mod_index := count;
			until
				c_mod_index = 0 or 
				Result /= Void
			loop
--print("find loop:%N");
				index := index // 2;
				if c_mod_index >= index then
--print("find binary search:%N");
					search_index := data.binary_search(key,index,2*index-1);
--print("find bin srch done:%N");
					if search_index >= 0 then
						Result := data @ search_index;
					end;
					c_mod_index := c_mod_index - index;
				end;
--print("find loop end.%N");
			end;
--print("find end.%N");
		end; -- find

	has (key: KEY): BOOLEAN is
	-- Aufwand wie find.
		do
			Result := find(key) /= Void
		end; -- has

	replace (element: ELEMENT) is
	-- Sucht find(element.key) und ersetzt es durch element
	-- Aufwand: O(ln(n)) im Durchschnitt, 
	--          O(ln(n)^2) im schlimmsten Fall.
	-- In 50% der Fälle ist erste binäre Suche erfolgreich (1/2*ln(n/2))
	-- in 25% der Fälle die zeite: (1/4*ln(n/4))
	-- in 12,5% der Fälle die dritte: (1/8*ln(n/8))
	-- also zusammen: 
	--   1*ln(n/2)+1/2*ln(n/4)+1/4*ln(n/8)+1/(n/2)*ln(1)
	--  <= ln(n)*(1+1/2+1/4+...+1/(n/2)) <= 2*ln(n).
		require
			-- find(element.key) /= Void
		local
			index,c_mod_index,search_index: INTEGER;
		do
			from
				index := 2*msb_of_count;
				c_mod_index := count;
				search_index := -1;
			until
				search_index >= 0
			loop
				index := index // 2;
				if c_mod_index >= index then
					search_index := data.binary_search(element.key,index,2*index-1);
					c_mod_index := c_mod_index - index;
				end;
			end;
			data.put(element,search_index);
		end; -- replace

	get_sorted : SORTED_ARRAY[KEY,ELEMENT] is
	-- erzeugt ein komplett sortiertes Feld
	-- Aufwand: O(n): 2*n Kopien, 2*n Vergleiche 
		local
			index,c_div_index,result_len,l1,l2,j: INTEGER;
		do
memstats(215);
			!!Result.make(1,count);
			from
				index := 1;
				c_div_index := count;
			until
				c_div_index = 0
			loop
				if c_div_index \\ 2 = 1 then				
					from
						l1 := index-1;
						l2 := result_len-1;
						j := index + result_len;
					until
						j = 0
					loop
						if l1 < 0 or else
							(l2 >= 0 and then
							 (data @ (index+l1)).key < (Result @ (1+l2)).key)
						then Result.put(Result @ (1+l2)    ,j); l2 := l2 - 1;
						else Result.put(data   @ (index+l1),j); l1 := l1 - 1;
						end;
						j := j - 1;
					end;
					result_len := result_len + index;
				end;
				index := index * 2;
				c_div_index := c_div_index // 2;
			end;
		ensure 
			Result.lower = 1;
			Result.upper = count;
		end; -- get_sorted

feature { NONE }
	
	join_arrays(src,dst,len: INTEGER) is
		-- nimmt die sortierten Elemente von 
		-- data @ src..src+len-1 und 
		-- data @ dst..dst+len-1 und erzeugt daraus das sortierte Feld
		-- data @ dst..dst+2*len-1. 
		-- Aufwand: O(2*len), genauer 2*len Kopien, 2*len-1 Vergleiche
		local
			j,l1,l2: INTEGER;
		do
			from
				j := 2*len;
				l1 := len-1;
				l2 := len-1;
			until
				j = 0
			loop
				j := j - 1;
				if l1 < 0 or else
					(l2 >= 0 and then
					(data @ (src+l1)).key < (data @ (dst+l2)).key)
				then data.put(data @ (dst+l2),dst+j); l2 := l2 - 1;
				else data.put(data @ (src+l1),dst+j); l1 := l1 - 1;
				end;
			end;	
		end; -- join_arrays
		
end -- PS_ARRAY


