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

class MULTI_BRANCH

inherit
	SCANNER_SYMBOLS;
	INSTRUCTION;
	LIST[WHEN_PART]
		rename
			make as list_make
		end;
	PARSE_EXPRESSION;
	FRIDISYS;

creation
	parse

--------------------------------------------------------------------------------
	
feature { ANY }

-- expression: EXPRESSION;  -- (geerbt) Der untersuchte Wert.

	else_part: COMPOUND;   -- Else-Teil oder Void wenn dieser fehlt.

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Multi_branch = "inspect" Expression 
	--                [When_part_list] [Else_part] "end".
	-- When_part_list = When_part [When_part_list].
	-- When_part = "when" Choices "then" Compound.
	-- Else_part = "else" Compound.
		require
			s.current_symbol.type = s_inspect
		local
			when_part: WHEN_PART;
		do
			list_make;
			s.next_symbol;
			parse_expression(s);
			from
memstats(132);
				!!when_part.parse(s);
				add(when_part)
			until
				s.current_symbol.type /= s_when
			loop
memstats(133);
				!!when_part.parse(s);
				add(when_part)
			end;
			if s.current_symbol.type = s_else then
				s.next_symbol; 
memstats(134);
				!!else_part.parse(s);
			end;
			s.check_keyword(s_end);			
		end; -- parse

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		local 
			i: INTEGER;
			choice_list: SORTABLE_LIST[INTEGER,CHOICE];
			c,pc: CHOICE;
			pos: POSITION; -- sebug: nur wegen Bug in SE nštig
		do
			expression.validity(fi,Void);
			if expression.type.is_character then
				is_integer := false
			else
				is_integer := true
				if not expression.type.is_integer then
					pos := expression.position;
					pos.error(msg.vomb2);
				end;
			end;		
memstats(135);
			!!choice_list.make;
			from
				i := 1;
			until
				i > count
			loop
				item(i).validity(fi,is_integer,choice_list,Current);
				i := i + 1;
			end;
			if has_positive and then first_unique /= Void then
				c.position.error(msg.vomb3);
			else
				choice_list.sort;
				if choice_list.count > 1 then
					from 
						pc := choice_list @ 1;
						i := 2
					until 
						i > choice_list.count
					loop
						c := choice_list @ i;
						if c.upper_value >= c.lower_value and  -- Nicht leeres Intervall
						   c.lower_value <= pc.upper_value     -- Das mit dem vorigen Ÿberlappt
						then
							if c.unique_feature = Void then
								c.position.error(msg.vomb4);
							else
								c.position.error(msg.vomb5);
							end;
						end;
						pc := c;
						i := i + 1; 
					end;
				end;
			end;
			if else_part /= Void then
				else_part.validity(fi);
			end;
		end; -- validity

feature { NONE }

	is_integer: BOOLEAN;  -- true bei integer, false bei character
		
--------------------------------------------------------------------------------

feature { WHEN_PART }

	has_positive: BOOLEAN; -- gibt es Konstanten > 0, die nicht UNIQUE sind?
	
	set_has_positive is
		do
			has_positive := true
		end; -- set_has_positive
		
	first_unique: CHOICE; -- erste UNIQUE-Konstante in Choices oder Void

	set_first_unique(c: CHOICE) is
		do
			first_unique := c;
		end; -- set_first_unique
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
		local
			multi: MULTI_SUCCESSORS;
			l_type: LOCAL_TYPE;
			next_block,else_block: BASIC_BLOCK;
			next_succ: ONE_SUCCESSOR;
			succ: BLOCK_SUCCESSORS;
			i: INTEGER;
			weight, then_weight: INTEGER;
		do
			weight := code.current_weight;
			if count /= 0 then
				if else_part = Void then
					then_weight := weight // count
				else
					then_weight := weight // (count + 1)
				end;
				if is_integer then
					l_type := globals.local_integer
				else
					l_type := globals.local_character
				end;
				else_block := recycle.new_block(then_weight);
				next_block := recycle.new_block(weight);
				next_succ := recycle.new_one_succ(next_block);
memstats(365);
				!!multi.make(expression.compile(code).need_local(code,l_type),else_block);
				from
					succ := multi;
					i := 1
				until
					i > count
				loop
					item(i).compile(code,multi,succ,then_weight);
					succ := next_succ;
					i := i + 1;
				end;
				code.finish_block(next_succ,else_block);
				if else_part /= Void then
					else_part.compile(code)
				end;
				code.finish_block(next_succ,next_block);
			else
				if else_part /= Void then
					else_part.compile(code)
				end;
			end;
		end; -- compile

--------------------------------------------------------------------------------

end -- MULTI_BRANCH
