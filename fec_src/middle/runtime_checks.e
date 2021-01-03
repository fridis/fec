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

class RUNTIME_CHECKS

-- this class provides routines that help to create code for runtime checking.

inherit
	DATATYPE_SIZES;
	CONDITIONS;
	COMPILE_ASSIGN;

creation 
	{ NONE }

--------------------------------------------------------------------------------

feature 
	
	check_void (code: ROUTINE_CODE;
	            var: LOCAL_VAR;
	            pos: POSITION) is
	-- check if var /= Void and cause a run time error if this is not the case
		local
			boolval: BOOLEAN_VALUE;
		do
			if globals.create_reference_check then
				boolval := recycle.new_boolval;
				boolval.make(var,Void,0,c_not_equal);				
				check_condition(code,
				                boolval,
				                globals.string_void_reference,
				                Void,
				                pos,
				                0);
			end;
		end; -- check_void

--------------------------------------------------------------------------------

	check_precondition (code: ROUTINE_CODE;
	                    type: TYPE;
	                    called_class: CLASS_INTERFACE;
	                    fi: FEATURE_INTERFACE;
	                    args: LIST[LOCAL_VAR];
	                    pos: POSITION;
	                    is_unqualified: BOOLEAN) is
	-- if fi has a precondition and precondition check is enabled, check the
	-- precondition on a call with the given argument list and create an error
	-- message in case the precondition does not hold.
	-- is_unqualified must be set iff fi is called in an unqualified call. This information
	-- is needed when duplicating an inherited routine.
		local
			failed_condition,pos_and_tag,td: LOCAL_VAR;
			boolval: BOOLEAN_VALUE;
			error_block, ok_block: BASIC_BLOCK;
			continue: ONE_SUCCESSOR;
			call_cmd: CALL_COMMAND;
			non_formal_generic_type,static_type: TYPE;
			ac, static_ac: ACTUAL_CLASS;
			new_args: LIST[LOCAL_VAR];
			i: INTEGER;
		do
			if globals.create_require_check and then
				fi.has_precondition
			then
				call_cmd := recycle.new_call_cmd;
				if type.is_formal_generic then
					non_formal_generic_type := type.base_type(code.fi);
				else
					non_formal_generic_type := type;
				end;
--print("cp: "); print(strings @ fi.key); 
--print(" nfgt "); non_formal_generic_type.print_type;
--print(" in "); code.class_code.actual_class.key.print_name; 
				if is_unqualified then
					ac := non_formal_generic_type.actual_class_code_no_parent(code);
				else
					ac := non_formal_generic_type.actual_class_code(code);
				end;
--print(" ac: "); ac.key.print_name; 
--print("%N");
				static_type := fi.get_static_precondition_type.view_client(code.fi,Void,non_formal_generic_type,called_class);
--print("s_ac: "); static_type.print_type; print(" in "); code.class_code.actual_class.key.print_name;
				if is_unqualified then
					static_ac := static_type.actual_class_code_no_parent(code);
				else
					static_ac := static_type.actual_class_code(code);
				end;
--print(".%N");
-- nyi: Das hier (ac vs static_ac) erscheint alles doppelt gemoppelt, das geht sicher auch einfacher!
				if not static_ac.key.actual_generics.is_empty and then
					not static_ac.is_expanded
				then
				-- add the type-descriptor of the static type as an extra argument if it is a generic
				-- type. 
					new_args := recycle.new_args_list;
					from 
						i := 1 
					until 
						i > args.count 
					loop
						new_args.add(args @ i);
						i := i + 1;
					end;
					td := compile_assign.clone_and_copy.compile_get_type_descriptor(code,static_type,is_unqualified);
					new_args.add(td);
				else
					new_args := args;
				end;
				call_cmd.make_static(code,
				                     fi.get_static_precondition_name(ac),
				                     new_args,
				                     globals.local_pointer);
				failed_condition := call_cmd.result_local;
				code.add_cmd(call_cmd);
				boolval := recycle.new_boolval;
				boolval.make(failed_condition,Void,0,c_equal);				
				error_block := recycle.new_block(1);
				ok_block := recycle.new_block(code.current_weight);
				continue := recycle.new_one_succ(ok_block);
				boolval.fix_boolean(code,ok_block,error_block,error_block);
				pos_and_tag := get_pos_and_tag(code,pos,0);
				call_precondition_failed(code,pos_and_tag,failed_condition);
				code.finish_block(continue,ok_block);
			end;
		end;  -- check_precondition

--------------------------------------------------------------------------------

	get_pos_and_tag(code: ROUTINE_CODE;
	                pos: POSITION;
	                tag: INTEGER): LOCAL_VAR is
	-- create a new local_var and assign to pos_and_tag entry of pos and tag to it.
		local
			ass_const_cmd: ASSIGN_CONST_COMMAND;
		do
			Result := recycle.new_local(code,globals.local_pointer);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_symbol(Result,
			                                       code.class_code.const_pos_and_tags,
			                                       code.class_code.const_pos_and_tag_offset);
			code.add_cmd(ass_const_cmd);
			code.class_code.add_pos_and_tag(pos,tag);
		end; -- get_pos_and_tag

	call_error_handler(code: ROUTINE_CODE; 
	                   error_handler: INTEGER; 
	                   pos_and_tag: LOCAL_VAR) is
	-- create code to call error_handler
	-- tag_string is passed to the handler only if set_tag is true.
		local
			args: LIST[LOCAL_VAR];
			call_cmd: CALL_COMMAND;
		do
			args := recycle.new_args_list;
			args.add(pos_and_tag);
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,
			                     error_handler,
			                     args,
			                     Void);
			code.add_cmd(call_cmd);
		end; -- call_error_handler

	call_precondition_failed(code: ROUTINE_CODE; 
	                         pos_and_tag: LOCAL_VAR;
	                         pos_and_tag_of_assertion: LOCAL_VAR) is
	-- create code to call error_handler
	-- tag_string is passed to the handler only if set_tag is true.
		local
			args: LIST[LOCAL_VAR];
			call_cmd: CALL_COMMAND;
		do
			args := recycle.new_args_list;
			args.add(pos_and_tag);
			args.add(pos_and_tag_of_assertion);
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,
			                     globals.string_precondition_failed,
			                     args,
			                     Void);
			code.add_cmd(call_cmd);
		end; -- call_precondition_failed

--------------------------------------------------------------------------------

	check_condition(code: ROUTINE_CODE; 
	                condition: VALUE;
	                error_handler: INTEGER;
	                branch_on_error: BASIC_BLOCK;
	                pos: POSITION;
	                tag: INTEGER) is
	-- if not condition then call error_handler 
	-- tag_string is passed to the handler only if set_tag is true.
		local
			false_block,true_block: BASIC_BLOCK;
			continue: ONE_SUCCESSOR;
			pos_and_tag: LOCAL_VAR;
			ass_cmd: ASSIGN_COMMAND;
		do
			true_block := recycle.new_block(code.current_weight);
			false_block := recycle.new_block(1);
			condition.fix_boolean(code,true_block,false_block,false_block);
			pos_and_tag := get_pos_and_tag(code,pos,tag);
			if branch_on_error = Void then
				call_error_handler(code,error_handler,pos_and_tag);
				continue := recycle.new_one_succ(true_block);
			else
				ass_cmd := recycle.new_ass_cmd(code.result_local,pos_and_tag);
				code.add_cmd(ass_cmd);
				continue := recycle.new_one_succ(branch_on_error);
			end;
			code.finish_block(continue,true_block);
		end; -- check_condition
	
--------------------------------------------------------------------------------

end -- RUNTIME_CHECKS
