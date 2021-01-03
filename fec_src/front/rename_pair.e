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

class RENAME_PAIR

inherit
	SCANNER_SYMBOLS;
	USED_ATTRIBUTE;

creation
	parse
	
feature { ANY }

	original_name: FEATURE_NAME;
	new_name: FEATURE_NAME; 
	
	position: POSITION; -- Position von original_name.

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Rename_pair = Feature_name "as" Feature_name.
		do
			position := s.current_symbol.position;
memstats(218);
			!!original_name.parse(s); 
			s.check_keyword(s_as);
memstats(219);
			!!new_name.parse(s);
		end; -- parse
		
--------------------------------------------------------------------------------

invariant
	original_name /= Void;
	new_name /= Void
end -- RENAME_PAIR
