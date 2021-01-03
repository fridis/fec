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

class FEATURE_NAME

inherit
	SCANNER_SYMBOLS;
	USED_ATTRIBUTE;
	
creation
	parse
	
feature { ANY }

	name: INTEGER; -- Name dieser Feature. Dieser name ist entweder direkt der
	               -- Bezeichner, oder "+" gefolgt von dem PrŠfixoperator oder
	               -- "*" gefolgt von dem Infix-Operator. In jedem Fall ist name
	               -- in Kleinbuchstaben umgewandelt, so da§ Namen direkt 
	               -- miteinander verglichen werden kšnnen.
	               
	position: POSITION;

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Feature_name = Identifier | Prefix | Infix
	-- Prefix = "prefix" Manifest_String
	-- Infix = "infix" Manifest_String
		do
			position := s.current_symbol.position;
			if s.current_symbol.type=s_prefix then
				parse_prefix(s);
			elseif s.current_symbol.type=s_infix then
				parse_infix(s);
			else
				s.check_and_get_identifier(msg.id_ftr_expected);
				name := s.last_identifier;
			end;
		end; -- parse

--------------------------------------------------------------------------------

feature { NONE }

	tmp_str: STRING is
		once
			!!Result.make(80); 
		end; -- tmp_str

	parse_prefix (s: SCANNER) is 
		do
			s.next_symbol;
			s.check_and_get_string(msg.prefix_expected); 
			tmp_str.copy("+");
			tmp_str.append(strings @ s.last_string);
			tmp_str.to_lower;
			name := strings # tmp_str;
			if name /= globals.string_prefix_not   and
			   name /= globals.string_prefix_plus  and
			   name /= globals.string_prefix_minus and
			   not check_free(tmp_str)
			then
				position.error(msg.ill_prefix);
				name := globals.string_prefix_plus
			end;
		end; -- parse_prefix

	parse_infix (s: SCANNER) is 
		do
			s.next_symbol;
			s.check_and_get_string(msg.infix_expected);
			tmp_str.copy("*");
			tmp_str.append(strings @ s.last_string);
			tmp_str.to_lower;
			name := strings # tmp_str;
			if name /= globals.string_infix_plus and
			   name /= globals.string_infix_minus and
			   name /= globals.string_infix_times and
			   name /= globals.string_infix_divide and
			   name /= globals.string_infix_div and
			   name /= globals.string_infix_mod and
			   name /= globals.string_infix_power and
			   name /= globals.string_infix_less and
			   name /= globals.string_infix_less_or_equal and
			   name /= globals.string_infix_greater and
			   name /= globals.string_infix_greater_or_equal and
			   name /= globals.string_infix_and and
			   name /= globals.string_infix_and_then and
			   name /= globals.string_infix_or and
			   name /= globals.string_infix_or_else and
			   name /= globals.string_infix_xor and
			   name /= globals.string_infix_implies and
			   not check_free(tmp_str)
			then
				position.error(msg.ill_infix);
				name := globals.string_infix_plus;
			end;
		end; -- parse_infix

--------------------------------------------------------------------------------

	check_free (free: STRING) : BOOLEAN is -- von parse verwendet, um free-operator auf GŸltigkeit zu testen
		do
			inspect free @ 2 
			when '@','#','|','&' then
				if free.index_of(' ' ,1) > 0 or 
					free.index_of('%T',1) > 0 or 
					free.index_of('%N',1) > 0 or 
					free.index_of('%R',1) > 0 or 
					free.index_of('%B',1) > 0 or 
					free.index_of('%F',1) > 0
				then
					Result := false
				else
					Result := true
				end;
			else
				Result := false
			end
		end; -- check_free
		
--------------------------------------------------------------------------------

end -- FEATURE_NAME
