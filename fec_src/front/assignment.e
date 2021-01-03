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

class ASSIGNMENT

inherit
	SCANNER_SYMBOLS;
	INSTRUCTION;
	PARSE_EXPRESSION
		rename
			expression as right
		end;
	WRITEABLE
		rename
			writeable          as left,
			writeable_position as position,
			type               as left_type,
			is_attribute       as left_attribute,
			is_local           as left_local,
			is_result          as left_result
		end;
	FRIDISYS;
	
creation
	parse
	
--------------------------------------------------------------------------------
	
feature { ANY }

--	left : INTEGER;       -- (geerbt) das Ziel in Kleinbuchstaben 

--	right : EXPRESSION;  -- (geerbt) die Quelle

	is_attempt: BOOLEAN; -- true für Assignment_attempt

--	position: POSITION;  -- (geerbt)

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Assignment = Identifier ":=" Expression.
	-- Assignment_attempt = Identifier "?=" Expression.
		require
			s.current_symbol.type = s_identifier;
			-- nächsten Symbol ist s_receives
		do
			parse_writeable(s);
			is_attempt :=  s.current_symbol.type = s_may_receive;				
			check 
				s.current_symbol.type = s_receives or 
				s.current_symbol.type = s_may_receive
			end;
			s.next_symbol;
			parse_expression(s);
		end; -- parse
		
--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		do
			validity_of_writeable(fi);
			right.validity(fi,left_type);
			if is_attempt then
				if not left_type.is_reference(fi) then
					position.error(msg.vjrv1);
				end;
			else
				if not right.is_conforming_to(fi,left_type) and then
				   not(right.is_current and then left_type.is_like_current) 
				then
-- write_string("left = <<"); left_type.print_type; write_string(">>  right = <<"); right.type.print_type; write_string(">>%N");
					position.error(msg.vbar1);
				end;
			end;
		end; -- validity

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
		do
			if is_attempt then compile_assignment_attempt(code,right.compile(code),right.type)
			              else compile_assignment        (code,right.compile(code),right.type)
			end;
		end; -- compile

--------------------------------------------------------------------------------

end -- ASSIGNMENT
