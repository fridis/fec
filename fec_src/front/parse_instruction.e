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

class PARSE_INSTRUCTION
-- um diese Klasse zu benutzen, mu§ von ihr geerbt werden und parse_instruction aufgerufen werden.

inherit
	SCANNER_SYMBOLS;

feature { ANY }

	instruction: INSTRUCTION;  -- Das Ergebnis von parse_instruction
	
feature { NONE }	
	
	parse_instruction (s: SCANNER) is
	-- Parst Type und schreibt den Wert nach instruction
	-- Instruction = Creation |
	--               Call |
	--               Assignment |
	--               Assignment_attempt |
	--               Conditional |
	--               Mulit_branch |
	--               Loop |
	--               Debug |
	--               Check |
	--               Retry.
		local
			last_index : INTEGER; 
			sym: INTEGER; 
		do
memstats(201);
			inspect s.current_symbol.type 
			when s_retry            then !RETRY_INSTRUCTION   !instruction.parse(s)
			when s_check            then !CHECK_INSTRUCTION   !instruction.parse(s)
			when s_debug            then !DEBUG_INSTRUCTION   !instruction.parse(s)
			when s_from             then !LOOP_INSTRUCTION    !instruction.parse(s)
			when s_inspect          then !MULTI_BRANCH        !instruction.parse(s)
			when s_if               then !CONDITIONAL         !instruction.parse(s)
			when s_exclamation_mark then !CREATION_INSTRUCTION!instruction.parse(s)
			when s_identifier then 
				last_index := s.current_symbol_index;
				s.next_symbol;
				sym := s.current_symbol.type; 
				s.reset_current_symbol(last_index);
				if sym = s_receives or else
				   sym = s_may_receive
				then
memstats(374);
					!ASSIGNMENT!instruction.parse(s);
				else
memstats(375);
					!CALL!instruction.parse(s,false);
				end;
			else
memstats(376);
				!CALL!instruction.parse(s,false);
			end;
		ensure 
			instruction /= Void
		end; -- parse_instruction

end -- PARSE_INSTRUCTION
