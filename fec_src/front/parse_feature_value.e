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

class PARSE_FEATURE_VALUE
-- um diese Klasse zu benutzen mu§ von ihr geerbt werden und parse_feature_value aufgerufen werden.

inherit
	SCANNER_SYMBOLS;

--------------------------------------------------------------------------------

feature { ANY }

	feature_value: FEATURE_VALUE;  -- Das Ergebnis von parse_feature_value

--------------------------------------------------------------------------------
		
feature { NONE }	
	
	parse_feature_value (s: SCANNER) is
	-- Parst Feature_value und schreibt den Wert nach feature_value.
	-- Feature_value = Manifest_constant | Unique | Routine.
		do			
			inspect s.current_symbol.type 
			when s_unique   then 
memstats(198);
				!UNIQUE_VALUE!feature_value.parse(s)
			when s_plus,
			     s_minus,
			     s_true,
			     s_false,
			     s_integer,
			     s_real,
			     s_character,
			     s_string,
			     s_bit_sequence 
			then 
memstats(199);
				!MANIFEST_CONSTANT_VALUE!feature_value.parse(s);
			else
memstats(200);
				!ROUTINE!feature_value.parse(s);
			end;
		ensure 
			feature_value /= Void
		end; -- parse_feature_value

--------------------------------------------------------------------------------

end -- PARSE_FEATURE_VALUE
