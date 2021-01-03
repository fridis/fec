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

class DEBUG_INSTRUCTION

inherit
	SCANNER_SYMBOLS;
	INSTRUCTION;
	LIST[INTEGER]      -- Die debug-Keys.
		rename
			make as list_make
		end;
			
creation
	parse
	
--------------------------------------------------------------------------------
	
feature { ANY }

	compound: COMPOUND;
	
--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Debug = "debug" [Debug_keys] Compound "end".
		require
			s.current_symbol.type = s_debug
		do
			list_make;
			s.next_symbol;
			if has_debug_keys(s) then
				parse_debug_keys(s);
			end;					
memstats(80);
			!!compound.parse(s);		
			s.check_keyword(s_end);
		end; -- parse

--------------------------------------------------------------------------------
	
feature { NONE }

	parse_debug_keys (s: SCANNER) is
	-- Debug_keys = "(" Debug_key_list ")".
	-- Debug_key_list = {Debug_key ","}.
	-- Debug_key = Manifest_string.
	
		require
			s.current_symbol.type = s_left_parenthesis
		do
			s.next_symbol;
			if s.current_symbol.type = s_string then
				from
					s.check_and_get_string(0);
					add_tail(s.last_string);
				until
					s.current_symbol.type /= s_comma
				loop
					s.next_symbol;
					s.check_and_get_string(msg.dbg_ky_expected);
					add_tail(s.last_string);
				end;
			end;
			s.check_right_parenthesis(msg.rpr_db_expected);
		end; -- parse_debug_keys

--------------------------------------------------------------------------------
		
	has_debug_keys (s: SCANNER): BOOLEAN is 
	-- prüft, ob dies der Anfang von Debug_keys ist
		local
			last_index: INTEGER; 
		do
			last_index := s.current_symbol_index;
			if s.current_symbol.type = s_left_parenthesis then
				s.next_symbol; 
				if s.current_symbol.type = s_right_parenthesis then -- empty key list
					Result := true
				elseif s.current_symbol.type = s_string then
					s.next_symbol;
					if s.current_symbol.type = s_comma then
						Result := true
					else
						if s.current_symbol.type = s_right_parenthesis then
							s.next_symbol;
							if s.current_symbol.type /= s_dot then
								Result := true;
							end;
						end;
					end;
				end;
			end; 
			s.reset_current_symbol(last_index);
		end; -- has_debug_keys

--------------------------------------------------------------------------------
-- VALIDITY ÜBERPRÜFUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		do
			compound.validity(fi)
		end; -- validity
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
		do
			if globals.create_debug_check then
				compound.compile(code)
			end;
		end; -- compile		

--------------------------------------------------------------------------------

end -- DEBUG_INSTRUCTION	
