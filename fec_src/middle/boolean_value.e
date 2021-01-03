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

class BOOLEAN_VALUE 

-- Boolean values consisting of a condition and true- and false-lists.
--
-- used during the creation of the intermediate code.

inherit
	VALUE
		redefine
			fix_boolean,
			need_boolean,
			invert_boolean
		end;
	CONDITIONS;

creation { RECYCLE_OBJECTS }
	clear
		
--------------------------------------------------------------------------------

feature { ANY }

	test1,test2: LOCAL_VAR;  -- test2 may be void, then use const_test2
	
	const_test2: INTEGER;
	
	condition: INTEGER;   -- c_* as defined in CONDITIONS

	true_list, false_list: LIST[BRANCH_FIXUP]; 

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is
		do
			test1 := Void;
			test2 := Void;
			const_test2 := 0;
			condition := 0;
			true_list := Void;
			false_list := Void;
		end; -- clear

--------------------------------------------------------------------------------

feature { ANY }

	make (tst1,tst2: LOCAL_VAR;
			const_tst2: INTEGER;
	      cond: INTEGER) is
		require
			need_variable_to_test:
				tst1 /= Void;
			cant_compare_real_with_const:
				tst1.type.is_real_or_double implies tst2 /= Void;
		do
			test1 := tst1;
			test2 := tst2;
			const_test2 := const_tst2;
			condition := cond;
			true_list := Void;
			false_list := Void;
		end; -- make

--------------------------------------------------------------------------------

feature { ANY }

	need_local_no_exp (code: ROUTINE_CODE; type: LOCAL_TYPE) : LOCAL_VAR is 
	-- load this value into a local variable
		local
			t,f,n: BASIC_BLOCK;
			one_succ: ONE_SUCCESSOR;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
		do
			if not type.is_boolean then 
				write_string("Compilerfehler: BOOLEAN_VALUE.need_local_no_exp#1%N");
			end;
			Result := recycle.new_local(code,type);
			t := recycle.new_block(code.current_weight);
			f := recycle.new_block(code.current_weight);
			n := recycle.new_block(code.current_weight);
			one_succ := recycle.new_one_succ(n);
			fix_boolean(code,t,f,t);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_bool(Result,true);
			code.add_cmd(ass_const_cmd);
			code.finish_block(one_succ,f);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_bool(Result,false);
			code.add_cmd(ass_const_cmd);
			code.finish_block(one_succ,n);
		end; -- need_local_no_exp

--------------------------------------------------------------------------------

	load_address (code: ROUTINE_CODE) : LOCAL_VAR is 
	-- load address of this value into a local variable
		local
			locl: LOCAL_VAR;
		do
			locl := need_local(code,globals.local_boolean);
			Result := recycle.new_local(code,globals.local_pointer);
			code.add_cmd(recycle.new_load_adr_cmd(Result,locl));
		end; -- load_address

--------------------------------------------------------------------------------

	fix_boolean (code: ROUTINE_CODE; t,f,next: BASIC_BLOCK) is
	-- for boolean values: creates a branches to t and f for true and false 
	-- conditions, respectively. code.current_block is set to next. 
		local
			two_succ: TWO_SUCCESSORS;
		do
			fix_list(true_list,t);
			fix_list(false_list,f);
			two_succ := recycle.new_two_succ;
			two_succ.make(test1,test2,const_test2,condition,t,f);
			code.finish_block(two_succ,next);
		end; -- fix_boolean
		
feature { NONE }

	fix_list (list: LIST[BRANCH_FIXUP]; to: BASIC_BLOCK) is
		local
			i: INTEGER; 
		do
			if list /= Void then
				from 
					i := 1
				until
					i > list.count
				loop
					(list @ i).fix(to);
					i := i + 1;
				end;
			end;
		end; -- fix_list

--------------------------------------------------------------------------------

	need_boolean (code: ROUTINE_CODE): BOOLEAN_VALUE is 
	-- create a BOOLEAN_VALUE from this boolean value
		do
			Result := Current;
		end; -- need_boolean

--------------------------------------------------------------------------------

feature { CALL }

	fix_true (code: ROUTINE_CODE; t: BASIC_BLOCK) is
	-- creates branches to t for true condition. After this, false_list 
	-- still has to be fixed to the false branch. 
	-- sets code.current_block to t.
		local
			two_succ: TWO_SUCCESSORS;
			fixup: BRANCH_FIXUP;
		do
			fix_list(true_list,t);
			two_succ := recycle.new_two_succ;
			two_succ.make(test1,test2,const_test2,condition,t,Void);
			code.finish_block(two_succ,t);
memstats(278); 
			!!fixup.make(two_succ,false);
			if false_list=Void then
memstats(279); 
				!!false_list.make;
			end;
			false_list.add(fixup);
		end; -- fix_true

	fix_false (code: ROUTINE_CODE; f: BASIC_BLOCK) is
	-- creates branches to f for false condition. After this, true_list 
	-- still has to be fixed to the true branch. 
	-- sets code.current_block to f.
		local
			two_succ: TWO_SUCCESSORS;
			fixup: BRANCH_FIXUP;
		do
			fix_list(false_list,f);
			two_succ := recycle.new_two_succ;
			two_succ.make(test1,test2,const_test2,condition,Void,f);
			code.finish_block(two_succ,f);
memstats(281); 
			!!fixup.make(two_succ,true);
			if true_list=Void then
memstats(282); 
				!!true_list.make;
			end;
			true_list.add(fixup);
		end; -- fix_false

feature { CALL, BOOLEAN_VALUE } 

	add_false_fixups(f: LIST[BRANCH_FIXUP]) is
		local
			i: INTEGER;
		do
			if f/=Void then
				if false_list=Void then
memstats(283); 
					!!false_list.make;
				end;
				from
					i := 1
				until
					i > f.count
				loop
					false_list.add(f @ i)
					i := i + 1
				end;
			end; 
		end; -- add_false_fixups

	add_true_fixups(t: LIST[BRANCH_FIXUP]) is
		local
			i: INTEGER;
		do
			if t/=Void then
				if true_list=Void then
memstats(284); 
					!!true_list.make;
				end;
				from
					i := 1
				until
					i > t.count
				loop
					true_list.add(t @ i)
					i := i + 1
				end;
			end; 
		end; -- add_true_fixups

--------------------------------------------------------------------------------

feature { ANY }

	invert_boolean (code: ROUTINE_CODE): VALUE is 
	-- create the value of "not Current" for a boolean Current
		local
			bv: BOOLEAN_VALUE;
		do
			bv := recycle.new_boolval; 
			bv.make(test1,test2,const_test2,invert_condition(condition));
			bv.add_false_fixups(true_list);
			bv.add_true_fixups(false_list);
			Result := bv;
		end; -- invert_boolean

--------------------------------------------------------------------------------

end -- BOOLEAN_VALUE
