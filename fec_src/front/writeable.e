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

class WRITEABLE
-- CREATION_INSTRUCTION und ASSIGNMENT erben von dieser Klasse

inherit
	DATATYPE_SIZES;
	COMPILE_ASSIGN;
	COMMANDS;
	FRIDISYS;

feature { ANY }

	writeable: INTEGER;
	
	writeable_position: POSITION;
	
--------------------------------------------------------------------------------

feature { NONE }

	parse_writeable(s: SCANNER) is
		do
			writeable_position := s.current_symbol.position;
			s.check_and_get_identifier(msg.id_wrt_expected);
			writeable := s.last_identifier;
		end; -- parse_writeable;
		
--------------------------------------------------------------------------------

	type: TYPE;
	
	is_attribute: FEATURE_INTERFACE;   
	is_local: LOCAL_OR_ARGUMENT;      
	is_result: BOOLEAN;            

	validity_of_writeable (fi: FEATURE_INTERFACE) is
		do
			if fi.type /= Void and then writeable = globals.string_result then
				type := fi.type;
				is_result := true
			else
				is_attribute := fi.interface.feature_list.find(writeable);
				if is_attribute /= Void then
					if not is_attribute.feature_value.is_variable_attribute then
						writeable_position.error(msg.veen3);
						is_attribute := Void
					else
						type := is_attribute.type;
						fi.feature_value.set_calls(is_attribute.number);
					end; 
				else
					is_local := fi.local_identifiers.find(writeable);
					if is_local = Void then
						writeable_position.error(msg.veen4); 
						is_local := Void;
					elseif is_local.is_argument then
						writeable_position.error(msg.veen5);
						is_local := Void;
					else
						type := is_local.type;
					end; 
				end;
			end;
			if type = Void then
				type := globals.type_any
			end;
		end; -- validity_of_writeable

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile_assignment (code: ROUTINE_CODE; 
	                    assign_value: VALUE; 
	                    assign_type: TYPE) is
	-- Creates code that assigns assign_value, which is of type assign_type to 
	-- the writeable entity.
		local
			offset: INTEGER;
			dst: LOCAL_VAR;
			dst_is_indirect: BOOLEAN;
			attr: FEATURE_INTERFACE;
			once_result_global: INTEGER;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
		do
			if     is_local /= Void then 
				dst := is_local.local_var;
			elseif is_result        then 
				if code.fi.feature_value.is_once then
					once_result_global := once_result_name(code.fi);
					dst := recycle.new_local(code,globals.local_pointer);
					ass_const_cmd := recycle.new_ass_const_cmd;
					ass_const_cmd.make_assign_const_symbol(dst, once_result_global,0);
					code.add_cmd(ass_const_cmd);
					offset := 0;
					dst_is_indirect := true;
				else
					dst := code.result_local;
					if code.expanded_result then
						offset := 0;
						dst_is_indirect := true;
					end;
				end;
			else -- is_attribute /= Void
				if code.fi.parent_clause = Void then
					attr := is_attribute
				else
					attr := code.fi.get_new_feature(writeable);
				end;
				offset := code.class_code.actual_class.attribute_offsets @ attr.number
				dst := code.current_local;
				dst_is_indirect := true;
			end;
			compile_assign.clone_or_copy(code,
			                             type,
			                             assign_type,
			                             assign_value,
			                             dst,
			                             offset,
			                             dst_is_indirect);
		end; -- compile_assignment

--------------------------------------------------------------------------------

	compile_assignment_attempt (code: ROUTINE_CODE; 
	                            assign_value: VALUE; 
	                            assign_type: TYPE) is
	-- Creates code that tries to assign assign_value, which is of type assign_type to 
	-- the writeable entity. This requires the writeable to be a reference
		local
			src, dst_type, num: LOCAL_VAR;
			read_mem_cmd: READ_MEM_COMMAND;
			call_cmd: CALL_COMMAND;
			args: LIST[LOCAL_VAR];
		do
			compile_assign.clone_or_copy_no_dst(code,
			                                    type,
			                                    assign_type,
			                                    assign_value);
			src := compile_assign.cloned_or_copied.need_local(code,globals.local_reference);
			dst_type := compile_assign.clone_and_copy.compile_get_type_descriptor(code,type,false);
			num := recycle.new_local(code,globals.local_integer);
			read_mem_cmd := recycle.new_read_mem_cmd;
			read_mem_cmd.make_read_offset(num,td_number,0,dst_type);
			code.add_cmd(read_mem_cmd);
			args := recycle.new_args_list;
			args.add(num);
			args.add(src);
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,
			                     globals.string_conforms_to_number,
			                     args,
			                     globals.local_reference);
			code.add_cmd(call_cmd);
			compile_assignment(code,call_cmd.result_local,type);
		end; -- compile_assignment_attempt
		
--------------------------------------------------------------------------------

	address_of_writeable (code: ROUTINE_CODE): LOCAL_VAR is
	-- Creates code that determines the address of the writeable entity.
		local
			attr: FEATURE_INTERFACE;
			off_ind: OFFSET_INDIRECT_VALUE;
			once_result_global: INTEGER;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
		do
			if     is_local /= Void then 
				Result := is_local.local_var.load_address(code);
			elseif is_result        then 
				if code.fi.feature_value.is_once then
					once_result_global := once_result_name(code.fi);
					Result := recycle.new_local(code,globals.local_pointer);
					ass_const_cmd := recycle.new_ass_const_cmd;
					ass_const_cmd.make_assign_const_symbol(Result, once_result_global,0);
					code.add_cmd(ass_const_cmd);
				else
					if code.expanded_result then
						Result := code.result_local;
					else
						Result := code.result_local.load_address(code);
					end;
				end;
			else -- is_attribute /= Void
				if code.fi.parent_clause = Void then
					attr := is_attribute
				else
					attr := code.fi.get_new_feature(writeable);
				end;
				off_ind := recycle.new_off_ind;
				off_ind.make(code.class_code.actual_class.attribute_offsets @ attr.number,code.current_local);
				Result := off_ind.load_address(code);
			end;
		end; -- address_of_writeable

--------------------------------------------------------------------------------
	
end -- WRITEABLE
