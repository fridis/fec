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

class TYPE_LIST

inherit
	SCANNER_SYMBOLS;
	LIST[TYPE]	
		rename
			make as list_make
		end;
	PARSE_TYPE
--		export
--			{ NONE } all
		end;

creation
	parse, clear, make_from_formal_generics
	
feature { ANY }

--------------------------------------------------------------------------------

	parse (s: SCANNER; may_be_anchored: BOOLEAN) is
	-- Type_list = {Type "," ...}.
		do	
			list_make;
			if s.first_of_type then
				from
					parse_type(s);
					add(type);
				until
					s.current_symbol.type /= s_comma
				loop
					s.next_symbol;
					extended_parse_type(s,may_be_anchored);
					add(type);
				end;	
			end;
		end; -- parse_rename	

	clear is
	-- create an empty list
		do
			list_make;
		end;  -- clear

	make_from_formal_generics (formal: FORMAL_GENERIC_LIST) is
	-- fŸr die aktuellen formalen Parameter von "like Current"
		local
			fgn: FORMAL_GENERIC_NAME;
			i: INTEGER;
		do
			list_make;
			from
				i := 1
			until
				i > formal.count
			loop
memstats(390);
				!!fgn.make(i,(formal @ i),(formal @ i).position);
				add(fgn);
				i := i + 1;
			end;
		end; -- make_from_formal_generics

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

end -- TYPE_LIST
