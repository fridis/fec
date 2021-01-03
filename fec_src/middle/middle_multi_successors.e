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

deferred class MIDDLE_MULTI_SUCCESSORS

-- Marks a basic block that ends with a inspect-instruction

inherit
	BLOCK_SUCCESSORS;
	FRIDISYS;
	
--------------------------------------------------------------------------------

feature { NONE }

	test: LOCAL_VAR;  -- Die zu testende Variable

	choices: SORTABLE_LIST[INTEGER,MULTI_CHOICE];  -- Die zu testenden Bedingungen

	else_block: BASIC_BLOCK;      -- und der Else-Teil oder Void

--------------------------------------------------------------------------------

feature { ANY }
	
	make (new_test: LOCAL_VAR; new_else_block: BASIC_BLOCK) is 
	-- NOTE: This successor must not be used for more than one basic_block (as  
	-- possible with ONE_SUCCESSOR).
		require
			new_test /= Void;
			new_else_block /= Void;
		do
			test := new_test;
memstats(136);
			!!choices.make;
			else_block := new_else_block;
		ensure
			else_block = new_else_block;
			test = new_test;
		end; -- make

--------------------------------------------------------------------------------

	add_choice (new_choice: MULTI_CHOICE) is
		do
			choices.add(new_choice);
		end; -- add_choice

--------------------------------------------------------------------------------
	
feature { BASIC_BLOCK }

	get_alive (code: ROUTINE_CODE) is
		local
			i: INTEGER;
			then_part: BASIC_BLOCK;
		do
			if alive=Void then
memstats(419);
				!!alive.make(code.locals.count)
			else
				alive.make(code.locals.count)
			end;
			if else_block=Void then
				alive.clear
			else
				alive.copy(else_block.alive);
			end;
			from 
				i := 1
			until
				i > choices.count
			loop
				then_part := (choices @ i).then_part;
				if then_part /= else_block then
					alive.union(then_part.alive)
				end;
				i := i + 1;
			end;
			alive.include(test.number);
		end; -- get_alive

--------------------------------------------------------------------------------

feature { ANY }
	
	print_succ is
		local
			i: INTEGER;
		do
			write_string("INSPECT "); test.print_local; write_string("%N"); 
			from
				i := 1
			until
				i > choices.count
			loop
				write_string("WHEN CHOICE"); write_integer(i); 
				write_string(" THEN "); 
				write_integer((choices @ i).then_part.object_id)
				write_string("%N");
				i := i + 1;
			end;
			if else_block /= Void then
				write_string("ELSE "); write_integer(else_block.object_id);
				write_string("%N");
			end;
			write_string("END;%N");
		end; -- print_succ
		
--------------------------------------------------------------------------------

end -- MIDDLE_MULTI_SUCCESSORS
