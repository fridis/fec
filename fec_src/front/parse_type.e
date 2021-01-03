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

class PARSE_TYPE
-- um diese Klasse zu benutzen mu§ von ihr geerbt werden und parse_type aufgerufen werden.

inherit
	SCANNER_SYMBOLS;

feature { ANY }

	type: TYPE;  -- Das Ergebnis von parse_type
	
feature { NONE }	

	parse_type (s: SCANNER) is
		do
			extended_parse_type (s,true)
		end; -- parse_type
	
	extended_parse_type (s: SCANNER; may_be_anchor: BOOLEAN) is
	-- Parst Type und schreibt den Wert nach type
	-- Type = Class_type |
	--        Class_type_expanded |
	--        Formal_generic_name |
	--        Anchored |
	--        Bit_type.	
		local
			name: INTEGER;
			fg_num: INTEGER; 
		do
			inspect s.current_symbol.type 
			when s_like       then 
				if not may_be_anchor then
					s.current_symbol.position.error(msg.anchor_parent);
				end;
memstats(206);
				!ANCHORED  !type.parse(s)
			when s_bit        then 
memstats(207);
				!BIT_TYPE  !type.parse(s)
			when s_expanded   then 
memstats(208);
				!CLASS_TYPE!type.parse_expanded(s,may_be_anchor)
			when s_identifier then
				name := s.get_identifier;
				if s.parse_class.formal_generics /= Void then
					fg_num := s.parse_class.formal_generics.find(name);
				else
					fg_num := -1
				end;
				if fg_num >= 0 then
memstats(209);
					!FORMAL_GENERIC_NAME!type.make(fg_num,
					                               s.parse_class.formal_generics @ fg_num,
					                               s.current_symbol.position); 
					s.next_symbol;
				else
					if     name = globals.string_boolean   then s.next_symbol; type := globals.type_boolean
					elseif name = globals.string_character then s.next_symbol; type := globals.type_character
					elseif name = globals.string_integer   then s.next_symbol; type := globals.type_integer
					elseif name = globals.string_real      then s.next_symbol; type := globals.type_real
					elseif name = globals.string_double    then s.next_symbol; type := globals.type_double
					elseif name = globals.string_string    then s.next_symbol; type := globals.type_string
					elseif name = globals.string_any       then s.next_symbol; type := globals.type_any
					elseif name = globals.string_general   then s.next_symbol; type := globals.type_general
					elseif name = globals.string_pointer   then s.next_symbol; type := globals.type_pointer
					else
memstats(210);
						!CLASS_TYPE!type.parse(s,may_be_anchor);
					end;
				end;
			else
memstats(211);
				!CLASS_TYPE!type.parse(s,may_be_anchor);
			end;
		ensure 
			type /= Void
		end; -- extended_parse_type

end -- PARSE_TYPE
