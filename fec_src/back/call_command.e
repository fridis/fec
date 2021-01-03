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

class CALL_COMMAND   

inherit
	MIDDLE_CALL_COMMAND;
	SPARC_CONSTANTS;
	FRIDISYS;
	
creation	{ RECYCLE_OBJECTS }
	clear

--------------------------------------------------------------------------------

feature { ANY }

	result_local: LOCAL_VAR;

feature { NONE }

	result_type: LOCAL_TYPE;

	get_res_type (code: ROUTINE_CODE; res_type: LOCAL_TYPE) is
		do
			if res_type=Void then
				result_type := Void
				result_local := Void;
			else
				result_type := res_type;
				result_local := recycle.new_local(code,res_type);
			end;
		end -- get_res_type

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }
	
	clear is 
		do
			next := Void;
			prev := Void;
			dynamic := Void;
			static := 0;
			result_type := Void; 
			arguments := Void;
			result_local := Void;
		end; -- clear
		
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
		local
			i, arg_word: INTEGER;
			cmd: COMMAND;
			arg, new_arg: LOCAL_VAR;
			result_reg: LOCAL_VAR;
		do
			from 
				i := 1;
				arg_word := 0;
			until
				i > arguments.count
			loop
				arg := arguments @ i;
				if arg.type.is_real_or_double then  -- reals and doubles are first stored in the stacke frame
					copy_arg_to_stack_frame(code,block,arg_word,arg);
					load_arg_into_reg(code,block,arg_word);
					if arg.type.is_double then 
						arg_word := arg_word + 1;
						load_arg_into_reg(code,block,arg_word);
					end;
				else
					copy_arg_or_adr_into_reg_or_stack_frame(code,block,arg_word,arg);
				end;
				arg_word := arg_word + 1;
				i := i + 1;
			end;

			if result_local /= Void then
				if result_type.is_expanded then
					copy_arg_or_adr_into_reg_or_stack_frame(code,block,arg_word,result_local)
					arg_word := arg_word + 1;
				else
					-- insert "move result_local,%o0/%f0" after this command:
					if     result_type.is_real   then result_reg := code. fp_registers @ f0;
					elseif result_type.is_double then result_reg := code.dfp_registers @ f0;
					                             else result_reg := code.    registers @ o0;
					end;
					block.insert(recycle.new_ass_cmd(result_local,result_reg),next);
				end;
			end;
			
			code.set_stack_arguments_size(arg_word);
			
		end; -- expand

feature { NONE }

	arg_offset (arg_word: INTEGER): INTEGER is
	-- returns the offset from %sp to the stack position of the argument arg_word, where
	-- arg_word is 0 for the first argument and incremented by one for each argument except
	-- doubles, which increment it by two.
		do
			Result := 68+4*arg_word;
		end; -- arg_offset

	copy_arg_to_stack_frame (code: ROUTINE_CODE; block: BASIC_BLOCK; arg_word: INTEGER; locl: LOCAL_VAR) is
	-- copy locl to %sp+arg_offset(arg_word), even if arg_word is passed in a register.
		local
			write_mem_cmd: WRITE_MEM_COMMAND;
		do
			write_mem_cmd := recycle.new_write_mem_cmd;
			write_mem_cmd.make_write_offset(arg_offset(arg_word),0,code.registers @ sp,locl);
			block.insert_and_expand(code,write_mem_cmd,Current);
		end; -- copy_arg_to_stack_frame

	load_arg_into_reg(code: ROUTINE_CODE; block: BASIC_BLOCK; arg_word: INTEGER) is
	-- load argument at %sp+arg_offset(arg_word) into the correct out-register if it
	-- is passed in an out register. Do nothing otherwise.
		local
			read_mem_cmd: READ_MEM_COMMAND;
		do
			if arg_word < 6 then
				read_mem_cmd := recycle.new_read_mem_cmd;
				read_mem_cmd.make_read_offset(code.registers @ (o0+arg_word),arg_offset(arg_word),0,code.registers @ sp);
				block.insert_and_expand(code,read_mem_cmd,Current);
			end;
		end; -- load_arg_into_reg

	copy_arg_or_adr_into_reg_or_stack_frame(code: ROUTINE_CODE;
	                                        block: BASIC_BLOCK;
	                                        arg_word: INTEGER;
	                                        arg: LOCAL_VAR) is
		local
			new_arg: LOCAL_VAR;
		do
			if arg.type.is_expanded then
				new_arg := recycle.new_local(code,globals.local_pointer);
				block.insert(recycle.new_load_adr_cmd(new_arg,arg),Current);
			else 
				new_arg := arg;
			end;
			copy_arg_into_reg_or_stack_frame(code,block,arg_word,new_arg);
		end; -- copy_arg_or_adr_into_reg_or_stack_frame

	copy_arg_into_reg_or_stack_frame (code: ROUTINE_CODE; 
	                                  block: BASIC_BLOCK; 
	                                  arg_word: INTEGER; 
	                                  locl: LOCAL_VAR) is
	-- this copies locl into the correct out register or to it's position in the stack frame according
	-- to arg_word.
		do
			if arg_word >= 6 then
				copy_arg_to_stack_frame(code,block,arg_word,locl);
			else
				block.insert_and_expand(code,recycle.new_ass_cmd(code.registers @ (o0+arg_word),locl),Current);
			end;
		end; -- copy_arg_into_reg_or_stack_frame

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	get_alive (alive: SET) is
	-- löscht jede von diesem Befehl geschriebene Variable aus alive und
	-- fügt jede gelesene Variable in alive ein.
	-- alive := (alive \ written variables) U read variables.
		do
			if result_local /= Void then
				alive.exclude(result_local.number);
			end;		
			if dynamic /= Void then
				alive.include(dynamic.number)
			end;
		end; -- get_alive
		
	get_conflict_matrix (code: ROUTINE_CODE; alive: SET; weight: INTEGER) is
	-- Bestimmt alive und trägt alle im Konflikt stehenden Variablen in 
	-- code.conflict_matrix ein. Die bijektive Hülle des Konfliktgrafen wird
	-- danach noch bestimmt, so dass es reicht wenn ein Konflikt nur einmal
	-- (d.h. bei der Zuweisung an eine Variable) eingetragen wird. 
	-- Zusätzlich wird alive wie bei get_alive bestimmt und must_not_be_volatile
	-- gesetzt für diejenigen locals, die während eines Aufrufs leben.
		do
			if dynamic /= Void then
				dynamic.inc_use_count(weight)
			end;
			code.must_not_be_volatile.union(alive);
			get_alive(alive);
		end; -- get_conflict_matrix

--------------------------------------------------------------------------------

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt nötige Befehle nach der Registervergabe ein und entfernt unnötige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
		do
			if dynamic /= Void then
				if dynamic.gp_register < 0 then
					block.insert_and_expand2(code,recycle.new_ass_cmd(code.temp1_register,dynamic),Current);
					dynamic := code.temp1_register;
				end;
			end;
			block.insert(recycle.new_nop_cmd,next);		
		ensure then
			dynamic /= Void implies dynamic.gp_register >= 0;
		end; -- expand2
		
--------------------------------------------------------------------------------

	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			if dynamic=Void then
				mc.reloc_wdisp30(mc.pc, static);
				mc.asm_call;
			else
				mc.asm_jmpl(dynamic.gp_register,0,o0+7);
			end;
		end; -- create_machine_code

--------------------------------------------------------------------------------

	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			if dynamic=Void then
				write_string("call    "); 
				write_string(strings @ static); 
			else
				write_string("jmpl    "); dynamic.print_local;
			end;
			write_string("%N");
		end; -- print_machine_code

--------------------------------------------------------------------------------

	print_cmd is 
		local
			i: INTEGER; 
			l: LOCAL_VAR;
		do
			if result_local /= Void then
				result_local.print_local;
				write_string(" := "); 
			end;
			write_string("call");
			if dynamic/=Void then	
				write_string("[");
				dynamic.print_local
				write_string("]");
			else
				write_string("[%"");
				write_string(strings @ static); 
				write_string("%"]");
			end;
			write_string("("); 
			from
				i := 1
			until
				i > arguments.count 
			loop
				if i>1 then
					write_string(","); 
				end; 
				l := arguments @ i;
				if l/=Void then
					l.print_local;
				end;
				i := i + 1;
			end;
			write_string(")%N"); 
		end; -- print_cmd 

--------------------------------------------------------------------------------

end -- CALL_COMMAND
