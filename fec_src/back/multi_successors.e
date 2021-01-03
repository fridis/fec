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

class MULTI_SUCCESSORS

inherit
	MIDDLE_MULTI_SUCCESSORS;
	COMMANDS;
	SPARC_CONSTANTS;
	
creation
	make
	
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt für die Zielarchitektur nötige zusätzliche Befehle vor der Registervergabe
	-- ein
		local
			new_test: LOCAL_VAR;
			ass_cmd: ASSIGN_COMMAND;
			choice, new_choice, last_choice: MULTI_CHOICE;
			i,c: INTEGER;
		do
			-- We might destroy test, so we better copy it to a new variable, in case
			-- the old value is needed somewhere else
			new_test := recycle.new_local(code,test.type);
			ass_cmd := recycle.new_ass_cmd(new_test,test);
			block.add_tail(ass_cmd);
			
			-- simplify choice-list: add choices that branch to the else block
			if choices.count > 0 then
				choices.sort;
				from
					c := choices.count;
					last_choice := choices @ 1;
					if last_choice.lower > Minimum_integer then
						!!new_choice.make(Minimum_integer,last_choice.lower-1,else_block);
						choices.add(new_choice);
					end;
					i := 2;
				until
					i > c
				loop
					choice := choices @ i;
					if choice.lower - 1 > last_choice.upper then
memstats(137); 
						!!new_choice.make(last_choice.upper+1,choice.lower-1,else_block);
						choices.add(new_choice);
					end;
					last_choice := choice;
					i := i + 1;
				end; 
				choices.sort;
			end;
			-- nyi: check simm13, for all i with (choices @ i).upper - (choices @ (i-1).upper > max_simm13: load const into local_var
		end; -- expand

--------------------------------------------------------------------------------

	get_conflict_matrix (code: ROUTINE_CODE; weight: INTEGER) is
	-- Trägt alle im Konflikt stehenden Variablen in code.conflict_matrix 
	-- ein. Die bijektive Hülle des Konfliktgrafen wird danach noch bestimmt, 
	-- so dass es reicht wenn ein Konflikt nur einmal (d.h. bei der Zuweisung 
	-- an eine Variable) eingetragen wird. 
	-- Der use_count jeder benutzten 
	-- Local_var wird um weight erhöht.
		do
			code.add_conflict(test,alive); -- This is only necessary if test is really destroyed
			test.inc_use_count(choices.count * weight);
		end; -- get_conflict_matrix;

--------------------------------------------------------------------------------

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt nötige Befehle nach der Registervergabe ein und entfernt unnötige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
	-- expand2 darf keine neuen Register allozieren, da die Registervergabe bereits
	-- vorbei ist.
		local
			ari_cmd: ARITHMETIC_COMMAND;
			i,subtracted: INTEGER;
			choice: MULTI_CHOICE;
		do
			if test.gp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(code.temp1_register,test),Void);
				test := code.temp1_register;
			end;
			if choices.count > 0 then
-- for a inspect of the form
--   inspect test
--   when 10..12 then case_1
--   when 16     then case_2
--   when 17..24 then case_3
--   else             else_block 
--   end
--
-- create these commands:
--   subcc   test, 10, test
--   bl      else_block     # less than 10
--   nop
--   subcc   test, 2, test
--   ble     case_1         # 10..12
--   nop
--   subcc   test, 4, test
--   bl      else_block     # 13..15 to else block
--   nop
--   be      case_2         # 16
--   nop
--   subcc   test, 8, test
--   ble     case_3         # 17..24
--   nop
--   ba      else_block     # greater then 24

				from
					subtracted := 0;
					i := 1;
				until
					i > choices.count
				loop
					choice := choices @ i;
					if i = choices.count or else (choice.then_part /= (choices @ (i+1)).then_part) then
						ari_cmd := recycle.new_ari_cmd;
						ari_cmd.make_binary_const(b_sub,test,test,choice.upper - subtracted);  
						subtracted := choice.upper;
						ari_cmd.activate_set_cc;
						block.add_tail(ari_cmd);
						block.add_tail(recycle.new_bra_cmd(false,icc_le,choice.then_part));
						block.add_tail(recycle.new_nop_cmd);
					end;
					i := i + 1;
				end;
				block.add_tail(recycle.new_bra_cmd(false,icc_a,else_block));
				block.add_tail(recycle.new_nop_cmd);
			end;
		end; -- expand2

--------------------------------------------------------------------------------

end -- MULTI_SUCCESSORS
