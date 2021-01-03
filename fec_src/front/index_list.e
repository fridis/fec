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

class INDEX_LIST

inherit
	LIST[INDEX_CLAUSE]
	rename 
		make as list_make
	end;
	SCANNER_SYMBOLS;
	
creation
	parse, clear
	
feature { ANY }

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Index_list = {Index_clause ";" ...}.
		local
			index_clause: INDEX_CLAUSE;
		do
			list_make;
			from
			until 
				not s.first_of_index_clause
			loop
memstats(117);
				!!index_clause.parse(s);
				add_tail(index_clause);
				s.remove_redundant_semicolon;
			end	
		end; -- parse

	clear is
	-- create an empty list
		do
			list_make;
		end;  -- clear
			
--------------------------------------------------------------------------------

end -- INDEX_LIST

	
