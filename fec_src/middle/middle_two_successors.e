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

deferred class MIDDLE_TWO_SUCCESSORS

-- Terminates a basic block with two successors.

inherit
	BLOCK_SUCCESSORS;
	CONDITIONS;
	FRIDISYS;
	
--------------------------------------------------------------------------------

feature { ANY }

	test1,test2: LOCAL_VAR;  -- The variables to be compared

	const_test2: INTEGER;    -- for integer comparison with test2=Void this gives
	                         -- a constant value to be compared with test1 

	condition: INTEGER;      -- The condition to be tested, as defined in CONDITIONS

	true_branch, false_branch: BASIC_BLOCK;  -- where to branch to for true and false
	                         -- condition.

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is 
		do
			test1 := Void;
			test2 := Void;
			condition := 0;
			true_branch := Void;
			false_branch := Void;
		end; -- clear

--------------------------------------------------------------------------------

feature { ANY }
	
	make (new_test1,new_test2: LOCAL_VAR; 
			new_const_test2: INTEGER;
	      new_condition: INTEGER;
	      new_true,new_false: BASIC_BLOCK) is 
	-- NOTE: This successor must not be used for more than one basic_block (as  
	-- possible with ONE_SUCCESSOR).
		require
			cant_compare_real_with_const:
				new_test1.type.is_real_or_double implies new_test2 /= Void;
			real_or_integer_comparison:
				new_test1.type.is_real_or_double or new_test1.type.is_word_or_byte;
			real_with_real:
				new_test1.type.is_real_or_double implies new_test1.type = new_test2.type;
			int_with_int:
				new_test1.type.is_word_or_byte implies (new_test2 = Void or else new_test2.type.is_word_or_byte);
		do
			test1 := new_test1;
			test2 := new_test2;
			const_test2 := new_const_test2;
			condition := new_condition;
			true_branch := new_true;
			false_branch := new_false
		ensure
			true_branch = new_true;
			false_branch = new_false;
		end; -- make

--------------------------------------------------------------------------------

	set_true (new_true: BASIC_BLOCK) is
		require
			true_branch = Void;
		do
			true_branch := new_true;
		end; -- set_true; 

	set_false (new_false: BASIC_BLOCK) is
		require
			false_branch = Void;
		do
			false_branch := new_false;
		end; -- set_false; 

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	get_alive (code: ROUTINE_CODE) is
		do
			if alive=Void then
memstats(418);
				!!alive.make(code.locals.count)
			else
				alive.make(code.locals.count)
			end;
			alive.copy(true_branch.alive);
			alive.union(false_branch.alive);
			alive.include(test1.number);
			if test2 /= Void then
				alive.include(test2.number);
			end;
		end; -- get_alive

--------------------------------------------------------------------------------

	get_conflict_matrix (code: ROUTINE_CODE; weight: INTEGER) is
	-- Trägt alle im Konflikt stehenden Variablen in code.conflict_matrix 
	-- ein. Die bijektive Hülle des Konfliktgrafen wird danach noch bestimmt, 
	-- so dass es reicht wenn ein Konflikt nur einmal (d.h. bei der Zuweisung 
	-- an eine Variable) eingetragen wird. 
	-- Der use_count jeder benutzten 
	-- Local_var wird um weight erhöht.
		do
			test1.inc_use_count(weight);
			if test2 /= Void then
				test2.inc_use_count(weight);
			end;
		end; -- get_conflict_matrix;

--------------------------------------------------------------------------------

feature { ANY }
	
	print_succ is
		do
			write_string("IF "); test1.print_local; 
			inspect condition
			when c_equal                 then write_string("=");
 			when c_not_equal             then write_string("/=");
 			when c_less                  then write_string("< ");
 			when c_less_or_equal         then write_string("<=");
 			when c_greater_or_equal      then write_string(">=");
 			when c_greater               then write_string("> ");
 			end;
 			if test2 /= Void then
 				test2.print_local;
 			else
 				write_integer(const_test2);
 			end;
			write_string(" THEN "); 
			if true_branch/=Void then
				write_integer(true_branch.object_id)
			else
				write_string("VOID"); 
			end;
			write_string(" ELSE "); 
			if false_branch/=Void then
				write_integer(false_branch.object_id)
			else
				write_string("VOID"); 
			end;
			write_string("%N");
		end; -- print_succ
		
--------------------------------------------------------------------------------

end -- MIDDLE_TWO_SUCCESSORS
