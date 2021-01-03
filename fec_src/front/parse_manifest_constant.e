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

class PARSE_MANIFEST_CONSTANT
-- to use this class, inherit from it and call parse_manifest_constant

inherit
	SCANNER_SYMBOLS;

feature { ANY }

	constant: MANIFEST_CONSTANT;  -- Das Ergebnis von parse_manifest_constant
	
feature { NONE }	
	
	parse_manifest_constant (s: SCANNER) is
	-- Parst Konstante und schreibt den Wert nach manifest_constant
	-- Manifest_Constant = Boolean_constant |
	--                     Character_constant |
	--                     Integer_or_real |
	--                     Manifest_string |
	--                     Bit_sequence.
		
		do
memstats(202);
			inspect s.current_symbol.type 
			when s_true, s_false then
				!BOOLEAN_CONSTANT!constant.make(s.current_symbol.type=s_true)
				s.next_symbol;
			when s_character then
				!CHARACTER_CONSTANT!constant.make(s.get_character);
				s.next_symbol;	
			when s_plus,s_minus,s_integer,s_real then
				parse_integer_or_real(s)
			when s_string then 
				s.check_and_get_string(0);
				!STRING_CONSTANT!constant.make(s.last_string)
			when s_bit_sequence then
				!BIT_CONSTANT!constant.make(s.get_bit_sequence)
				s.next_symbol;
			else
				s.current_symbol.position.error(msg.const_expected);
				!INTEGER_CONSTANT!constant.make(0);	
			end;	
		ensure
			constant /= Void
		end; -- parse

	parse_integer_or_real (s: SCANNER) is
	-- Integer_or_real   = Integer_constant | Real_constant.
	-- Integer_constant  = [Sign] Integer.
	-- Real_Constant     = [Sign] Real.
	-- Sign              = "+" | "-"
		
		local
			neg: BOOLEAN;
			real: DOUBLE;
			int: INTEGER;  
		do
			neg := s.current_symbol.type = s_minus;
			if neg or s.current_symbol.type = s_plus then
				s.next_symbol;
			end;
			if s.current_symbol.type =s_real then
				real := s.get_real;
				if neg then 
					real := -real
				end;
memstats(203);
				!REAL_CONSTANT!constant.make(real);
				s.next_symbol; 
			else
				if s.current_symbol.type/=s_integer then
					s.current_symbol.position.error(msg.const_expected); 
					if s.current_symbol.type = s_identifier then 
						s.next_symbol
					end;
memstats(204);
					!INTEGER_CONSTANT!constant.make(0)
				else
					int := s.get_integer;
					if neg then 
						int := -int
					end;
memstats(205);
					!INTEGER_CONSTANT!constant.make(int)
					s.next_symbol;
				end;
			end;
		ensure
			constant /= Void
		end; -- parse_integer_or_real

end -- PARSE_MANIFEST_CONSTANT
