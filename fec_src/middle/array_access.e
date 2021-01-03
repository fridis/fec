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

class ARRAY_ACCESS

-- This class creates code for the routines put, item and infix "@" of ARRAY and
-- its proper heirs. Objects of this class are of no particular use after creation.

inherit
	DATATYPE_SIZES;
	ACTUAL_CLASSES;
	COMMANDS;

creation
	make
	
feature

	make (code: ROUTINE_CODE) is
		local
			element_size: INTEGER;
			element_type: ACTUAL_CLASS_NAME;
			expanded_elements: BOOLEAN;
			storage_feature: FEATURE_INTERFACE;
			storage,off,adr,size_local: LOCAL_VAR;
			storage_offset: INTEGER;
			read_mem_cmd: READ_MEM_COMMAND;
			write_mem_cmd: WRITE_MEM_COMMAND;
			seed: FEATURE_INTERFACE;
		do
			-- get element size:
			element_type := code.fi.origin.actual_class_name(code.class_code.actual_class.key).actual_generics @ 1;
			expanded_elements := element_type.actual_is_expanded;
			if expanded_elements then
				element_size := actual_classes.find(element_type).size;
			else
				element_size := reference_size;
			end;
			
			-- load pointer to array storage (attribute ARRAY.storage)
			storage := recycle.new_local(code,globals.local_pointer);
			storage_feature := code.fi.get_new_feature(globals.string_storage);
			storage_offset := code.class_code.actual_class.attribute_offsets @ storage_feature.number;
			read_mem_cmd := recycle.new_read_mem_cmd;
			read_mem_cmd.make_read_offset(storage,
			                              storage_offset,
											      0,
			                              code.current_local);
			code.add_cmd(read_mem_cmd);
			
			seed := code.fi.seed;
			if seed.key = globals.string_put then

				-- get offset in storage
				off := get_offset(code,(seed.formal_arguments @ 2).local_var,element_size);
			
				if (seed.formal_arguments @ 1).type.local_type(code).is_expanded then
					adr := add_offset(code,storage,off);
					call_memcpy(code,adr,(seed.formal_arguments @ 1).local_var,element_size);
				else
					write_mem_cmd := recycle.new_write_mem_cmd;
					write_mem_cmd.make_write_indexed(storage,
					                                 off,
					                                 (seed.formal_arguments @ 1).local_var);
					code.add_cmd(write_mem_cmd);
				end;
				
			else -- item or infix "@"
			
				-- get offset in storage
				off := get_offset(code,(seed.formal_arguments @ 1).local_var,element_size);
				
				if seed.type.local_type(code).is_expanded then
					adr := add_offset(code,storage,off);
					call_memcpy(code,code.result_local,adr,element_size);
				else
					read_mem_cmd := recycle.new_read_mem_cmd;
					read_mem_cmd.make_read_indexed(code.result_local,
					                               storage,
					                               off);
					code.add_cmd(read_mem_cmd);
				end;
			end;
		end; -- make
		
feature { NONE }

	get_offset(code: ROUTINE_CODE; index: LOCAL_VAR; element_size: INTEGER): LOCAL_VAR is
		local
			ari_cmd: ARITHMETIC_COMMAND;
		do			
			-- get offset in storage
			Result := recycle.new_local(code,globals.local_integer);
			ari_cmd := recycle.new_ari_cmd;
			ari_cmd.make_binary_const(b_mul,Result,index,element_size);
			code.add_cmd(ari_cmd);
		end; -- get_offset

	call_memcpy(code: ROUTINE_CODE; 
	            dst,src: LOCAL_VAR; 
	            element_size: INTEGER) is
		local
			size_local: LOCAL_VAR;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
			call_cmd: CALL_COMMAND;
			args: LIST[LOCAL_VAR];
		do
			size_local := recycle.new_local(code,globals.local_integer);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_int(size_local,element_size);
			code.add_cmd(ass_const_cmd);
			args := recycle.new_args_list;
			args.add(dst);
			args.add(src);
			args.add(size_local);
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,globals.string_memcpy,args,Void);
			code.add_cmd(call_cmd);
		end; -- call_memcpy

	add_offset(code: ROUTINE_CODE; storage,offset: LOCAL_VAR): LOCAL_VAR is
		local
			ari_cmd: ARITHMETIC_COMMAND;
		do
			Result := recycle.new_local(code,globals.local_pointer);
			ari_cmd := recycle.new_ari_cmd;
			ari_cmd.make_binary(b_add,Result,storage,offset);
			code.add_cmd(ari_cmd);
		end; -- add_offset
		
end -- ARRAY_ACCESS
