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

class SORTABLE_LIST[KEY -> COMPARABLE,ELEMENT -> SORTABLE[KEY]]

-- A list of sortable elements that provides features to sort the
-- elements and to do binary searches.

inherit
	LIST[ELEMENT];
	
creation
	make

--------------------------------------------------------------------------------

feature { ANY }

	sort is
	-- sort this list
		do
			if count > 0 then
				if tmp=Void or else tmp.upper < count then
memstats(238);
					!!tmp.make(1,data.upper);
				end;
				sort_data := data;
				sort_recursive(1,count);
			end;
		end; -- sort
		
	get_sorted: ARRAY[ELEMENT] is
	-- get a sorted array of this lists' elements but keep this list unchanged.
		local
			i: INTEGER;
		do
			if tmp=Void or else tmp.upper < count then
memstats(238);
				!!tmp.make(1,data.upper);
			end;
memstats(424); 
			!!sort_data.make(1,count);
			from
				i := 1
			until
				i > count
			loop
				sort_data.put(data @ i,i);
				i := i + 1;
			end;
			sort_recursive(1,count); 
			Result := sort_data;
		end; -- get_sorted

--------------------------------------------------------------------------------

feature { NONE }

	tmp, sort_data: ARRAY[ELEMENT];
	
	sort_recursive (l,r: INTEGER) is
	-- Diese Routine sortiert das Feld sort_data @ l..r und ruft sich
	-- dazu rekursiv auf um die linke bzw. rechte HŠlfte zu sortieren.
	-- Aufwand: n*ln2(n) Vergleiche, 2*n*ln2(n) Kopien
		local
			m,i,li,ri: INTEGER;
			le,re: ELEMENT;
		do
			if l<r then
				m := (l + r) // 2;
				sort_recursive(l,m); 
				sort_recursive(m+1,r);
				-- sort_data @ l..m und sort_data @ m+1..r sortiert nach tmp @ l..r:
				from
					i := l;
					li := l; 
					ri := m + 1;
				until
					i > r
				loop
					if li > m then
						tmp.put(sort_data @ ri,i); 
						ri := ri + 1;
					elseif ri > r then
						tmp.put(sort_data @ li,i);
						li := li + 1;
					else
						le := sort_data @ li;
						re := sort_data @ ri;
						if le.key < re.key then
							tmp.put(le,i);
							li := li + 1;
						else
							tmp.put(re,i); 
							ri := ri + 1;
						end;
					end;
					i := i + 1;
				end;
				-- tmp @ l..r zurŸckkopieren nach sort_data @ l..r:
				from
					i := l
				until
					i > r
				loop
					sort_data.put(tmp @ i,i);
					i := i + 1;
				end;	
			end;
		end; -- sort_recursive

--------------------------------------------------------------------------------

feature { ANY }

	find (what: KEY): ELEMENT is
		require
		-- nach dem letzten sort darf kein Element hinzugefŸgt worden sein.
		local
			min,max,mid,cmp: INTEGER 
		do
			from 
				min := 1;
				max := count;
				cmp := -1;
			invariant  
				min > 1     implies what >= (data @ (min - 1)).key
				max < count implies what <= (data @ (max + 1)).key				 
			variant 
				max-min	 
			until  
				min>max 
			loop 
				mid := (min+max) // 2; 
				cmp := what.three_way_comparison((data @ mid).key); 
				if cmp <= 0 then max := mid-1 end 
				if cmp >= 0 then min := mid+1 end 
			end 
			if cmp=0 then 
				Result := data @ mid 
			end
		end; -- find

--------------------------------------------------------------------------------

end -- SORTABLE_LIST
