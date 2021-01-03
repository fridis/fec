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

class CLONE_AND_COPY

-- Compile GENERAL.[standard_]copy/clone

inherit
	COMMANDS;
	DATATYPE_SIZES;
	CLASSES;

--------------------------------------------------------------------------------

feature { ANY }

	compile_clone (code: ROUTINE_CODE;
	               original: VALUE;
	               original_type: TYPE) is
		do
			if original_type.is_reference(code.fi) then
				do_compile_clone(code,original,Void,globals.string_copy);
			else
				do_compile_clone(code,original,original_type,0);
				do_compile_standard_copy(code,original,original_type,cloned_object);
				do_compile_clone(code,cloned_object,Void,globals.string_copy);
			end;
		end; -- compile_clone
		
	compile_standard_clone (code: ROUTINE_CODE;
	               original: VALUE;
	               original_type: TYPE) is
		do
			if original_type.is_reference(code.fi) then
				do_compile_clone(code,original,Void,globals.string_standard_copy);
			else
				do_compile_clone(code,original,original_type,0);
				do_compile_standard_copy(code,original,original_type,cloned_object);
			end;
		end; -- compile_standard_clone

	cloned_object: LOCAL_VAR;

--------------------------------------------------------------------------------

feature { NONE }

	do_compile_clone(code: ROUTINE_CODE; 
	              original: VALUE; 
	              original_type: TYPE; 
	              copy_routine: INTEGER) is
	-- Create code for clone(). original specifies the original object, which might be a
	-- reference or expanded object. original_type gives its type or may be void for 
	-- a reference original. copy_routine is the name of the routine to call to copy
	-- originals variable attributes. It should be either globals.string_copy or
	-- globals.string_standard_copy or 0 for no initialization.
		local
			original_local, new_type, new_object: LOCAL_VAR;
			original_l_type: LOCAL_TYPE;
			args: LIST[LOCAL_VAR];
			ass_const_cmd: ASSIGN_CONST_COMMAND;
			call_cmd: CALL_COMMAND;
			copy_rout: FEATURE_INTERFACE; 
		do
			if original_type = Void then
				original_l_type := globals.local_reference
			else
				original_l_type := original_type.local_type(code);
			end;
			if original_l_type.is_reference then
				original_local := original.need_local(code,globals.local_reference);
				new_type := compile_read_type_descr(code,original_local);
			else
				original_local := original.load_address(code);
				new_type := recycle.new_local(code,globals.local_pointer);
				ass_const_cmd := recycle.new_ass_const_cmd;
				ass_const_cmd.make_assign_const_symbol(new_type,
				          type_descriptor_name(original_type.actual_class_name_code(code).corresponding_reference.code_name),0);
				code.add_cmd(ass_const_cmd);
			end;
			args := recycle.new_args_list; 
			args.add(new_type);
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,
			                     globals.string_allocate_object,
			                     args,
			                     globals.local_pointer);
			-- NOTE: the Result type.is_pointer although it actually is a reference. But
			-- allocate_object is not an Eiffel routine, so the result is treated like a normal
			-- reference, but immediately assigned to a is_reference variable.
			code.add_cmd(call_cmd);
			new_object := recycle.new_local(code,globals.local_reference);
			code.add_cmd(recycle.new_ass_cmd(new_object,call_cmd.result_local));
			if copy_routine /= 0 then
				args := recycle.new_args_list;
				args.add(new_object);
				args.add(original_local);
				copy_rout := get_class(globals.string_general).feature_list.find(copy_routine);
				compile_dynamic_call(code,
				                     new_object,
				                     globals.type_general,
				                     copy_rout.number,
				                     args,
				                     Void);
			end;
			cloned_object := new_object;
		end; -- do_compile_clone

--------------------------------------------------------------------------------

feature { ANY }

	compile_standard_copy(code: ROUTINE_CODE; 
	                      arg_value: VALUE; 
	                      arg_type: TYPE) is
	-- Compile unqualified call to standard_copy()
		do
			do_compile_standard_copy(code,arg_value,arg_type,code.current_local);
		end; -- compile_standard_copy
			
	do_compile_standard_copy(code: ROUTINE_CODE; 
	                      arg_value: VALUE; 
	                      arg_type: TYPE;
	                      dst_adr: LOCAL_VAR) is
	-- NOTE: For an expanded arg_type, this can be used to copy and object to
	--       dst_adr, even if dst_adr is not code.current_local.
		require
			arg_type.local_type(code).is_reference implies dst_adr = code.current_local
		local
			i: INTEGER;
			fl: ARRAY[FEATURE_INTERFACE];
			fi: FEATURE_INTERFACE;
			arg_local, feat_descr: LOCAL_VAR;
			args: LIST[LOCAL_VAR];
			l_type: LOCAL_TYPE;
			current_offset: INTEGER;
			arg_offset,l,src,dst: LOCAL_VAR;
			read_mem_cmd: READ_MEM_COMMAND;
			write_mem_cmd: WRITE_MEM_COMMAND;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
			call_cmd: CALL_COMMAND;
			ari_cmd: ARITHMETIC_COMMAND;
		do
			l_type := arg_type.local_type(code);
			if l_type.is_reference then
				from
					fl := code.fi.interface.feature_list;
					arg_local := arg_value.need_local(code,globals.local_reference);
					feat_descr := compile_read_feature_descr(code,
					                                         arg_local,
					                                         code.class_code.actual_class.base_class.like_current,
					                                         true);
					i := fl.lower;
				until
					i > fl.upper
				loop
					fi := fl @ i;
					if fi.feature_value.is_variable_attribute then
						arg_offset := recycle.new_local(code,globals.local_integer);
						read_mem_cmd := recycle.new_read_mem_cmd;
						read_mem_cmd.make_read_offset(arg_offset,
			                           fd_feature_array+reference_size*(fi.number-1),
			                           0,
			                           feat_descr);
						code.add_cmd(read_mem_cmd);
						current_offset := code.class_code.actual_class.attribute_offsets @ fi.number;
--write_string("code.fi.interface.key"); write_string(strings @ code.fi.interface.key); write_string("code.fi.key="); write_string(strings @ code.fi.key); write_string("  fi.key="); write_string(strings @ fi.key); write_string("%N");
						l_type := fi.type.local_type_no_parent(code);
						if l_type.is_expanded then
							src := recycle.new_local(code,globals.local_pointer);
							ari_cmd := recycle.new_ari_cmd;
							ari_cmd.make_binary(b_add,src,arg_local,arg_offset);
							code.add_cmd(ari_cmd);
							dst := recycle.new_local(code,globals.local_pointer);
							ari_cmd := recycle.new_ari_cmd;
							ari_cmd.make_binary_const(b_add,dst,dst_adr,current_offset);
							code.add_cmd(ari_cmd);
							l := recycle.new_local(code,globals.local_integer);
							ass_const_cmd := recycle.new_ass_const_cmd;
							ass_const_cmd.make_assign_const_int(l,l_type.expanded_class.size);
							code.add_cmd(ass_const_cmd);
							args := recycle.new_args_list;
							args.add(dst); 
							args.add(src);
							args.add(l);
							call_cmd := recycle.new_call_cmd;
							call_cmd.make_static(code,globals.string_memcpy,args,Void);
							code.add_cmd(call_cmd);
						else
							l := recycle.new_local(code,l_type);
							read_mem_cmd := recycle.new_read_mem_cmd;
							read_mem_cmd.make_read_indexed(l,arg_local,arg_offset);
							code.add_cmd(read_mem_cmd);
							write_mem_cmd := recycle.new_write_mem_cmd;
							write_mem_cmd.make_write_offset(current_offset,0,dst_adr,l);
							code.add_cmd(write_mem_cmd);
						end;
					end;
					i := i + 1;
				end;
			elseif l_type.is_expanded then
				arg_local := arg_value.load_address(code);
				l := recycle.new_local(code,globals.local_integer);
				ass_const_cmd := recycle.new_ass_const_cmd;
				ass_const_cmd.make_assign_const_int(l,l_type.expanded_class.size);
				code.add_cmd(ass_const_cmd);
				args := recycle.new_args_list;
				args.add(dst_adr);
				args.add(arg_local);
				args.add(l);
				call_cmd := recycle.new_call_cmd;
				call_cmd.make_static(code,globals.string_memcpy,args,Void);
				code.add_cmd(call_cmd);
			else
				-- nyi: INTEGER -> REAL -> DOUBLE
				write_mem_cmd := recycle.new_write_mem_cmd;
				write_mem_cmd.make_write_offset(0,0,dst_adr,arg_value.need_local(code,l_type));
				code.add_cmd(write_mem_cmd);
			end;
		end; -- compile_standard_copy

--------------------------------------------------------------------------------

feature { ANY }

	compile_get_type_descriptor(code: ROUTINE_CODE;
	                            type: TYPE;
	                            is_no_parent: BOOLEAN): LOCAL_VAR is
	-- load type descriptor of type in a local_var. This takes care of types that are not
	-- statically known when compiling a routine.
	-- is_no_parent is set when type is no inherited type, this case occurs 
	-- only when compiling standard_copy or when calling a precondition for an
	-- unqualified call.
		local
			base_type: TYPE;
			tcn: TRUE_CLASS_NAME;
			type_desc,true_types: LOCAL_VAR;
			ac: ACTUAL_CLASS;
			read_mem_cmd: READ_MEM_COMMAND;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
		do	
			Result := recycle.new_local(code,globals.local_pointer);
			if is_no_parent then
				base_type := type.base_type(code.fi);
			else
				base_type := type.base_type(code.fi.seed);
			end;
			tcn := base_type.true_class_name_code_parent(code,is_no_parent);
			if tcn = Void then
				if code.fi.doing_precondition then
					-- the precondition code is not duplicated, instead, the static
					-- type descriptor is passed as an additional argument if it is 
					-- generic.
					type_desc := code.static_generic_type_of_precondition;
				else
					type_desc := compile_read_type_descr(code,code.current_local);
				end;
				ac := code.class_code.actual_class;
				ac.true_types.add(base_type);
				if is_no_parent then
					ac.true_types_features.add(code.fi.interface.no_feature);
					ac.true_types_actual_classes.add(base_type.actual_class_code_no_parent(code));
				else
					ac.true_types_features.add(code.fi);
					ac.true_types_actual_classes.add(base_type.actual_class_code(code));
				end;
				true_types := recycle.new_local(code,globals.local_pointer);
				read_mem_cmd := recycle.new_read_mem_cmd;
				read_mem_cmd.make_read_offset(true_types,td_true_types,0,type_desc);
				code.add_cmd(read_mem_cmd);
				read_mem_cmd := recycle.new_read_mem_cmd;
				read_mem_cmd.make_read_offset(Result,reference_size*(ac.true_types.count-1),0,true_types);
				code.add_cmd(read_mem_cmd);
			else
				ass_const_cmd := recycle.new_ass_const_cmd;
				ass_const_cmd.make_assign_const_symbol(Result,type_descriptor_name(tcn.code_name),0);
				code.add_cmd(ass_const_cmd);
			end;	
		ensure
			Result.type.is_pointer;
		end; -- compile_get_type_descriptor

--------------------------------------------------------------------------------

	compile_read_type_descr(code: ROUTINE_CODE; 
	                        object: LOCAL_VAR): LOCAL_VAR is
	-- create code that loads the address of the type descriptor of the object 
	-- referenced by object to the local var Result.
		local
			read_mem_cmd: READ_MEM_COMMAND;
		do
			Result := recycle.new_local(code,globals.local_pointer);
			read_mem_cmd := recycle.new_read_mem_cmd;
			read_mem_cmd.make_read_offset(Result,
			                      	      obj_type_descr_offset,
			                      	      0,
			                              object);
			code.add_cmd(read_mem_cmd);
		end; -- compile_read_type_descr

	compile_read_feature_descr(code: ROUTINE_CODE; 
	                           object: LOCAL_VAR;
	                           static_type: TYPE;
	                           is_no_parent: BOOLEAN): LOCAL_VAR is
	-- create code that loads the address of the feature descriptor for the static
	-- view from static_type of the object referenced by object to Result.
	-- is_no_parent is set when static_type is no inherited type, 
	-- this case occurs only when compiling standard_copy.
		local
			td, static_td, col: LOCAL_VAR;
			read_mem_cmd: READ_MEM_COMMAND;
			tcn: TRUE_CLASS_NAME;
		do
			tcn := static_type.true_class_name_code_parent(code,is_no_parent);
			td := compile_read_type_descr(code,object);
			Result := recycle.new_local(code,globals.local_pointer);
			if tcn /= Void then -- statically known color
				read_mem_cmd := recycle.new_read_mem_cmd;
				read_mem_cmd.make_read_offset(Result,
				                              0,
				                              color_name(tcn.code_name),
				                              td);
				code.add_cmd(read_mem_cmd);
			else -- color depends on current's actual generics
				static_td := compile_get_type_descriptor(code,static_type,is_no_parent);
				col := recycle.new_local(code,globals.local_integer);
				read_mem_cmd := recycle.new_read_mem_cmd;
				read_mem_cmd.make_read_offset(col,td_color,0,static_td);
				code.add_cmd(read_mem_cmd);
				read_mem_cmd := recycle.new_read_mem_cmd;
				read_mem_cmd.make_read_indexed(Result,col,td);
				code.add_cmd(read_mem_cmd);
			end;
		end; -- compile_read_feature_descr
	
	compile_dynamic_call(code: ROUTINE_CODE;
	                     call_target: LOCAL_VAR;
	                     static_type: TYPE;
	                     called_feature_number: INTEGER;
	                     args: LIST[LOCAL_VAR];
	                     result_type: TYPE) is
	-- create code for a dynamically bound call to called_feature_number of call_target 
	-- with given static_type. If result_type/=Void dynamic_call_result will be set to
	-- the routines result.
		local
			feat_descr, rout: LOCAL_VAR;
			read_mem_cmd: READ_MEM_COMMAND;
			local_type: LOCAL_TYPE;
			call_cmd: CALL_COMMAND;
		do
			feat_descr := compile_read_feature_descr(code,call_target,static_type,false);
			rout := recycle.new_local(code,globals.local_integer);
			read_mem_cmd := recycle.new_read_mem_cmd;
			read_mem_cmd.make_read_offset(rout,
			                              fd_feature_array+reference_size*(called_feature_number-1),
			                              0,
			                              feat_descr);
			code.add_cmd(read_mem_cmd);
			if result_type/=Void then
				local_type := result_type.local_type(code)
			else
				local_type := Void
			end;
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_dynamic(code,
				                   rout,
				                   args,
				                   local_type);
			dynamic_call_result := call_cmd.result_local;
			code.add_cmd(call_cmd);
		end; -- compile_dynamic_call
	
	dynamic_call_result: LOCAL_VAR;

--------------------------------------------------------------------------------
	
end -- CLONE_AND_COPY
