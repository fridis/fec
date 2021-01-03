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

class INDEX_CLAUSE

inherit
	SCANNER_SYMBOLS;

creation
	parse
	
feature { ANY }
	
	index: INTEGER;  -- the Index identifier or 0 if not present

	values: LIST[INDEX_VALUE]; 
	
	parse (s: SCANNER) is
	-- Index_clause = [Index] Index_terms.
	-- Index = Identifier ":".
	-- Index_terms = {Index_value "," ...}+.
		local
			pos: INTEGER;
			value: INDEX_VALUE;  
		do
			pos := s.current_symbol_index;
			if s.current_symbol.type = s_identifier then 
				s.check_and_get_identifier(0)
				if s.current_symbol.type = s_colon then
					index := s.last_identifier
					s.next_symbol
				else
					index := 0; 
					s.reset_current_symbol(pos)
				end
			end
			from
memstats(114);
memstats(115);
				!!values.make;
				!!value.parse(s);
				values.add(value)
			until
				s.current_symbol.type /= s_comma
			loop	
				s.next_symbol;
memstats(116);
				!!value.parse(s);
				values.add(value)
			end; 
		ensure 
			values /= Void
		end; -- parse

end -- INDEX_CLAUSE
