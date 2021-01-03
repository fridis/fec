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

class ASSERTION_CLAUSE

inherit
	SCANNER_SYMBOLS;
	PARSE_EXPRESSION;
	RUNTIME_CHECKS;
	
creation	
	parse
	
creation { ASSERTION_CLAUSE }
	new_view

--------------------------------------------------------------------------------
	
feature { ANY }

	tag: INTEGER;              -- Tag_mark der Assertion oder 0

	position: POSITION;
	
--	expression: EXPRESSION;   -- (geerbt) Die Assertion oder Void 

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Assertion_clause = [Tag_mark] Unlabeled_assertion_clause.
	-- Unlabeled_assertion_clause = Boolean_expression | Comment.
	-- Tag_mark = Identifier ":".
		local
			pos: INTEGER; 
			is_tag: BOOLEAN;
		do
			position := s.current_symbol.position;
			-- get tag_mark:
			pos := s.current_symbol_index;
			if s.current_symbol.type = s_identifier then 
				s.check_and_get_identifier(0); 
				if s.current_symbol.type = s_colon then
					tag := s.last_identifier; 
					s.next_symbol;
				else
					s.reset_current_symbol(pos); 
				end; 
			end; 
			
			-- check if next is another tag_mark or an expression:
			if s.current_symbol.type = s_identifier then 
				pos := s.current_symbol_index;
				s.next_symbol; 
				is_tag := s.current_symbol.type=s_colon;
				s.reset_current_symbol(pos);
			else
				is_tag := false;
			end;
			
			if not is_tag and s.first_of_expression then 
				parse_expression(s); 
			end; 
		end; -- parse
		
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE) is
		do
			if expression /= Void then
				expression.validity(fi,Void);
				expression.check_boolean_expression;
			end;
		end; -- validity

--------------------------------------------------------------------------------

feature { ASSERTION }

	view (pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST): ASSERTION_CLAUSE is
	-- get the view of an assertion inherited through the specified
	-- parent_clause
		do
			!!Result.new_view(Current,pc,old_args,new_args);
		end; -- view

feature { NONE }

	new_view (original: ASSERTION_CLAUSE; pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST) is
		do
			tag := original.tag;
			position := original.position;
			expression := original.expression.view(pc,old_args,new_args);
		end; -- new_view
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }

	compile(code: ROUTINE_CODE; 
	        error_handler: INTEGER
	        branch_on_error: BASIC_BLOCK) is
	-- create code to check assertion_clause. If assertion does not hold,
	-- call error_handler if present or set code.result_local to 
	-- the pos_and_tag entry corresponding to the failed assertion
	-- and branch to branch_on_error.
		do
			if expression /= Void then
				check_condition(code,
				                expression.compile(code),
				                error_handler,
				                branch_on_error,
				                position,
				                tag);
			end;
		end; -- compile

--------------------------------------------------------------------------------
	
end -- ASSERTION_CLAUSE
