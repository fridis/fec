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

class OLD_EXPRESSION

inherit
	EXPRESSION;
	SCANNER_SYMBOLS;
	PARSE_EXPRESSION;
	
creation
	parse
	
creation { OLD_EXPRESSION }
	new_view
	
--------------------------------------------------------------------------------
	
feature { ANY }

--	expression : EXPRESSION; 	-- (geerbt) Der Ausdruck hinter "old".

--	position : POSITION;        -- (geerbt)

--	type: TYPE;                 -- (geerbt)

--------------------------------------------------------------------------------

	parse (s: SCANNER) is 
	-- Old = "old" Expression.
		require
			s.current_symbol.type = s_old
		do
			position := s.current_symbol.position;
			s.next_symbol;
			op_prec_expression(s,s_old);
		end; 

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE; expected_type: TYPE) is
		do
			if not fi.doing_postcondition then
				position.error(msg.vaol1); 
			end;
			expression.validity(fi, expected_type);
			type := expression.type;
		end; -- validity

--------------------------------------------------------------------------------

feature { ASSERTION }

	view (pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST): OLD_EXPRESSION is
	-- get the view of this call inherited through the specified
	-- parent_clause. 
		do
			!!Result.new_view(Current,pc,old_args,new_args);
		end; -- view

feature { NONE }

	new_view (original: OLD_EXPRESSION; pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST) is
		do
			position := original.position;
			expression := original.expression.view(pc,old_args,new_args);
		end; -- new_view

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE): VALUE is
		do
			-- nyi:
			Result := expression.compile(code);
		end; -- compile
			
--------------------------------------------------------------------------------

end -- OLD_EXPRESSION	
