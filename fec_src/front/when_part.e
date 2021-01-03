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

class WHEN_PART

inherit
	SCANNER_SYMBOLS;
	LIST[CHOICE]
		rename
			make as list_make
		end;

creation
	parse
	
--------------------------------------------------------------------------------
	
feature { ANY }
	
	then_part: COMPOUND;   
	
--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- When_part = "when" Choices "then" Compound.
	-- Choices = {Choice ","...}
		local
			choice: CHOICE;
		do
			list_make;
			s.check_keyword(s_when);
			if s.first_of_choice then
				from
memstats(241);
					!!choice.parse(s);
					add_tail(choice);
				until
					s.current_symbol.type /= s_comma
				loop
					s.next_symbol;
memstats(242);
					!!choice.parse(s);
					add_tail(choice);
				end;
			end; 
			s.check_keyword(s_then);
memstats(243);
			!!then_part.parse(s);
		end; -- parse

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE; 
	          int: BOOLEAN;
	          choice_list: LIST[CHOICE];
	          mb: MULTI_BRANCH) is
		local
			i: INTEGER;
			c: CHOICE;
		do
			from
				i := 1
			until
				i > count
			loop
				c := item(i);
				choice_list.add(c);
				c.validity(fi,int);
				if c.unique_feature /= Void then
					if mb.first_unique = Void then
						mb.set_first_unique(c)
					else
						if c.unique_feature.origin /= mb.first_unique.unique_feature.origin then
							c.position.error(msg.vomb6);
						end;
					end;
				elseif c.lower_value > 0 or c.upper_value > 0 then
					mb.set_has_positive;
				end;
				i := i + 1;
			end;
			then_part.validity(fi)
		end; -- validity
		
--------------------------------------------------------------------------------
-- CODE Generation:                                                           --
--------------------------------------------------------------------------------

	compile (code: ROUTINE_CODE;
				multi: MULTI_SUCCESSORS; 
	         succ: BLOCK_SUCCESSORS;
	         then_weight: INTEGER) is 
	-- compile this when part as a successor for multi. Finish the
	-- previous basic block using succ as successor.
		local
			when_block: BASIC_BLOCK;
			new_choice: MULTI_CHOICE;
			choice: CHOICE;
			i: INTEGER;
		do
			when_block := recycle.new_block(then_weight);
			code.finish_block(succ,when_block);
			from
				i := 1
			until
				i > count
			loop
				choice := item(i);
memstats(497);
				!!new_choice.make(choice.lower_value,choice.upper_value,when_block);
				multi.add_choice(new_choice);
				i := i + 1
			end;
			then_part.compile(code);
		end; -- compile;
		
--------------------------------------------------------------------------------

end -- WHEN_PART
