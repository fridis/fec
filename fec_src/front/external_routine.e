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

class EXTERNAL_ROUTINE

inherit
	ROUTINE_BODY
		redefine
			is_external
		end;
	SCANNER_SYMBOLS;
	
creation
	parse
	
feature { ANY }

--------------------------------------------------------------------------------

	language : INTEGER;       -- id der Sprache der externen Routine
	
	external_name : INTEGER;  -- id des externenn Namens oder 0

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- External = "external" Language_name [External_name].
	-- Language_name = Manifest_string.
	-- External_name = "alias" Manifest_string.
		require
			s.current_symbol.type = s_external
		do
			s.next_symbol;
			s.check_and_get_string(msg.lang_expected);
			language := s.last_string; 
			if s.current_symbol.type = s_alias then 
				s.next_symbol;
				s.check_and_get_string(msg.ext_expected); 
				external_name := s.last_string; 
			else
				external_name := 0;
			end; 
		ensure
			language /= 0
		end; -- parse

--------------------------------------------------------------------------------

	is_external : BOOLEAN is
		do
			Result := true
		end; -- is_external

--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE) is
		do
		end; -- validity

--------------------------------------------------------------------------------

end -- EXTERNAL_ROUTINE
