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

class CONDITIONAL

inherit
	SCANNER_SYMBOLS;
	INSTRUCTION;
	PARSE_EXPRESSION
	rename
		expression as condition
	end;
	
creation
	parse
	
--------------------------------------------------------------------------------
	
feature { ANY }

--	condition: EXPRESSION;    -- (geerbt) Die Bedingung

	then_part: COMPOUND;      -- die Anweisungen die bedingt ausgeführt werden sollen
	
	elseif_part: CONDITIONAL; -- Wenn "elseif" vorhanden, dann enthält dies den 
	                          -- gesamten Rest der Anweisung.
	                          
	else_part : COMPOUND;     -- der ELSE-Teil oder Void falls elseif_part /= Void oder
	                          -- kein "else" vorhanden ist.

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Conditional = "if" Conditional_clause .
	-- Conditional_clause = Then_part Conditional_tail.
	-- Then_part = Expression "then" Compound.
	-- Conditional_tail = Elseif | Else | "end".
	-- Elseif = "elseif" Conditional_clause.
	-- Else = "else" Compound "end".
		require
			s.current_symbol.type = s_if or
			s.current_symbol.type = s_elseif
		do
			s.next_symbol;
			parse_expression(s);
			s.check_keyword(s_then);
memstats(74);
			!!then_part.parse(s);
			if s.current_symbol.type = s_elseif then
memstats(75);
				!!elseif_part.parse(s);
				else_part := Void;
			else
				elseif_part := Void;
				if s.current_symbol.type = s_else then
					s.next_symbol;
memstats(76);
					!!else_part.parse(s);
				else
					else_part := Void;
				end;
				s.check_keyword(s_end);
			end;
		ensure
			elseif_part /= Void implies else_part = Void;
		end; -- parse

--------------------------------------------------------------------------------
-- VALIDITY ÜBERPRÜFUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		do
			condition.validity(fi,Void);
			condition.check_boolean_expression;
			then_part.validity(fi);
			if elseif_part /= Void then
				elseif_part.validity(fi);
			elseif else_part /= Void then
				else_part.validity(fi)
			end;
		end; -- validity
						
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
		local
			continue: ONE_SUCCESSOR;
			then_block,else_block,next_block: BASIC_BLOCK;
			weight: INTEGER;
		do
			weight := code.current_weight;
			then_block := recycle.new_block(weight // 2);
			next_block := recycle.new_block(weight);
			continue := recycle.new_one_succ(next_block);
			if elseif_part /= Void or else_part /= Void then 
				else_block := recycle.new_block(weight // 2);
				condition.compile(code).fix_boolean(code,then_block,else_block,then_block);
				then_part.compile(code);
				code.finish_block(continue,else_block);
				if elseif_part /= Void then
					elseif_part.compile(code)
				else
					else_part.compile(code)
				end;
			else
				condition.compile(code).fix_boolean(code,then_block,next_block,then_block);
				then_part.compile(code);
			end;
			code.finish_block(continue,next_block);
		end; -- compile		

--------------------------------------------------------------------------------

end -- CONDITIONAL
