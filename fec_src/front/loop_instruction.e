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

class LOOP_INSTRUCTION

inherit
	SCANNER_SYMBOLS;
	INSTRUCTION;
	PARSE_EXPRESSION
		export { NONE } all
		end;
	
creation
	parse
	
--------------------------------------------------------------------------------
	
feature { ANY }

	initialization: COMPOUND; -- from-part
	
	invariant_assertion: ASSERTION;  -- Invariante oder Void
	variant_expression: EXPRESSION;  -- Variante oder Void
	variant_tag: INTEGER;      -- Optionaler Tag der Variante (sonst 0)
	
	exit: EXPRESSION;         -- Abbruchsbedingung
	body: COMPOUND;           -- der Schleifenkšrper
	
--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Loop = Initialization
	--        Invariant
	--        Variant
	--        Loop_body
	--        end.
	-- Initialization = "from" Compound.
	-- Loop_body = Exit "loop" Compound.
	-- Exit = "until" Expression.
		require
			s.current_symbol.type = s_from;
		do
			s.next_symbol;
memstats(127);
memstats(128);
			!!initialization.parse(s);
			parse_invariant(s);
			parse_variant(s);
			s.check_keyword(s_until);
			parse_expression(s);
			exit := expression;
			s.check_keyword(s_loop);
			!!body.parse(s);
			s.check_keyword(s_end);
		end; -- parse
		
--------------------------------------------------------------------------------

feature { NONE }

	parse_invariant (s: SCANNER) is
	-- Invariant = ["invariant" Assertion].
	-- Variant = "variant" [Tag_mark] Expression.
	-- Tag_mark = Tag ":".
	-- Tag = Identifier.
	-- Loop_body = Exit "loop" Compound.
	-- Exit = "until" Expression.
		do
			if s.current_symbol.type = s_invariant then
				s.next_symbol;
memstats(129);
				!!invariant_assertion.parse(s);
			else
				invariant_assertion := Void;
			end; 
		end; -- parse_invariant
	
	parse_variant (s: SCANNER) is
	-- Variant = ["variant" [Tag_mark] Expression].
	-- Tag_mark = Tag ":".
	-- Tag = Identifier.
		local
			last_index: INTEGER;
			tag: INTEGER;
		do
			if s.current_symbol.type = s_variant then
				s.next_symbol;
				if s.current_symbol.type = s_identifier then
					last_index := s.current_symbol_index;
					s.check_and_get_identifier(0);
					tag := s.last_identifier;
					if s.current_symbol.type = s_colon then
						s.next_symbol;
						variant_tag := tag;
					else
						s.reset_current_symbol(last_index);
					end;
				end;
				parse_expression(s);
				variant_expression := expression;
			end;
		end; -- parse_variant

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		local
			pos: POSITION; -- sebug: nur wegen Bug in SE
		do
			initialization.validity(fi);
			exit.validity(fi,Void);
			exit.check_boolean_expression;
			if invariant_assertion /= Void then 
				invariant_assertion.validity(fi);
			end;
			if variant_expression /= Void then
				variant_expression.validity(fi,Void);
				if not variant_expression.type.is_conforming_to(fi,integer_type) then
					pos := variant_expression.position;
					pos.error(msg.loop_variant); 
				end;
			end;
			body.validity(fi);
		end; -- validity

feature { NONE }

	integer_type : TYPE is
	-- sebug: should be once (SE bug)
		do
			Result := globals.type_integer;
		end; -- integer_type
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
		local
			loop_start: ONE_SUCCESSOR;
			exit_block, body_block, next_block: BASIC_BLOCK;
			weight: INTEGER;
		do
			weight := code.current_weight;
			initialization.compile(code);
			exit_block := recycle.new_block(weight * 2);
			body_block := recycle.new_block(weight * 2);
			next_block := recycle.new_block(weight);
			loop_start := recycle.new_one_succ(exit_block);
			code.finish_block(loop_start,body_block);
			body.compile(code);
			code.finish_block(loop_start,exit_block);
			exit.compile(code).fix_boolean(code,next_block,body_block,next_block);
		end; -- compile		

--------------------------------------------------------------------------------

end -- LOOP_INSTRUCTION
