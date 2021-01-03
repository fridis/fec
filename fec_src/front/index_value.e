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

class INDEX_VALUE

inherit
	PARSE_MANIFEST_CONSTANT
	SCANNER_SYMBOLS;

creation
	parse
	
feature { ANY }
	
	identifier : INTEGER;  -- if the term is an idendetifier: its name, else 0

	-- constant : MANIFEST_CONSTANT;  -- the value of this INDEX_VALUE, inherited
	                                  -- from PARSE_MANIFEST_CONSTANT  
	
	parse (s: SCANNER) is
	-- Index_value = Indentifier | Manifest_constant.
		do
			if s.current_symbol.type = s_identifier then 
				s.check_and_get_identifier(0); 
				identifier := s.last_identifier;
			else
				parse_manifest_constant(s);
			end; 			
		end; -- parse

end -- INDEX_VALUE
