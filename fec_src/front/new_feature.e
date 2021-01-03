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

class NEW_FEATURE 

inherit
	SCANNER_SYMBOLS;
	
creation
	parse
	
feature { ANY }

	is_frozen: BOOLEAN; 
	
	name: FEATURE_NAME;

	parse (s: SCANNER) is
	-- New_feature = ["frozen"] Feature_name
		do
			if s.current_symbol.type = s_frozen then 
				s.next_symbol;
				is_frozen := true;
			end;
memstats(141);
			!!name.parse(s);
		end; -- parse

end -- NEW_FEATURE
		
