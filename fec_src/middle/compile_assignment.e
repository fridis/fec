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

class COMPILE_ASSIGNMENT
-- This provides routines required for argument passing and assignment to 
-- writeable entities. 

inherit
	DATATYPE_SIZES;
	COMMANDS;

--------------------------------------------------------------------------------

feature

	cloned_or_copied: VALUE;

	clone_or_copy_no_dst (code: ROUTINE_CODE; 
	                      dst_type,src_type: TYPE; 
	                      src: VALUE) is
		do
			clone_or_copy(code,dst_type,src_type,src,Void,0,false);
		end; -- clone_or_copy_no_dst

	clone_or_copy (code: ROUTINE_CODE; 
	               dst_type,src_type: TYPE; 
	               src: VALUE;
	               dst: LOCAL_VAR;
	               dst_offset: INTEGER;
	               dst_is_indirect: BOOLEAN) is
	-- check if clone or copy is necessary. If dst /= Void, dst specifies the
	-- target for the assignment. If dst = Void, cloned_or_copied will be set to
	-- the value specifying the cloned or copied (or unchanged) src value of
	-- type dst_type.
	-- if dst /= Void and not dst_is_indirect, dst ist the destination of the 
	-- assignment.
	-- if dst /= Void and dst_is_indirect, dst + dst_offset is the address of the
	-- destination.
		require
			src /= Void;
		local
			dst_ref, src_ref: BOOLEAN;
			dst_l_type,src_l_type: LOCAL_TYPE;
			call_cmd: CALL_COMMAND;
			args: LIST[LOCAL_VAR];
			type_descr,res_local: LOCAL_VAR;
			read_mem_cmd: READ_MEM_COMMAND;
			write_mem_cmd: WRITE_MEM_COMMAND;
			ari_cmd: ARITHMETIC_COMMAND;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
			off_ind: OFFSET_INDIRECT_VALUE;
			new_src, new_dst, adr_of_dst: LOCAL_VAR;
			new_src_value: VALUE;
			copy_fi: FEATURE_INTERFACE;
		do
			dst_ref := dst_type.actual_is_reference(code);
			src_ref := src_type.actual_is_reference(code);
			if dst_ref then
				if not src_ref then
					clone_and_copy.compile_clone(code,src,src_type);
					new_src_value := clone_and_copy.cloned_object;
				else
					new_src_value := src.need_local(code,globals.local_reference);
				end;
				if dst = Void then
					cloned_or_copied := new_src_value
				else
					new_src := new_src_value.need_local(code,globals.local_reference);
					if dst_is_indirect then
						write_mem_cmd := recycle.new_write_mem_cmd;
						write_mem_cmd.make_write_offset(dst_offset,0,dst,new_src);
						code.add_cmd(write_mem_cmd);
					else
						code.add_cmd(recycle.new_ass_cmd(dst,new_src));
					end;
				end;
			else -- not dst_ref
				dst_l_type := dst_type.local_type(code);
				if not dst_l_type.is_expanded then -- basic types like INTEGER, CHARACTER,...
					if src_ref then
						new_src := recycle.new_local(code,dst_l_type);
						read_mem_cmd := recycle.new_read_mem_cmd;
						read_mem_cmd.make_read_offset(new_src,0,0,src.need_local(code,globals.local_reference));
						code.add_cmd(read_mem_cmd);
						new_src_value := new_src;
						src_l_type := dst_l_type;
					else
						new_src_value := src;	
						src_l_type := src_type.local_type(code);
						-- INTEGER -> REAL -> DOUBLE conversion:
						if src_l_type.is_integer and then dst_l_type.is_real_or_double or else
							src_l_type.is_real    and then dst_l_type.is_double
						then
							new_src := recycle.new_local(code,dst_l_type);
							code.add_cmd(recycle.new_ass_cmd(new_src,new_src_value.need_local(code,src_l_type)));
							src_l_type := dst_l_type;
							new_src_value := new_src;
						end;
					end;
					if dst = Void then
						cloned_or_copied := new_src_value
					else
						new_src := new_src_value.need_local(code,src_l_type);
						if dst_is_indirect then
							write_mem_cmd := recycle.new_write_mem_cmd;
							write_mem_cmd.make_write_offset(dst_offset,0,dst,new_src);
							code.add_cmd(write_mem_cmd);
						else
							code.add_cmd(recycle.new_ass_cmd(dst,new_src));
						end;
					end;
				else -- copy to expanded
					if dst = Void then
						new_dst := recycle.new_local(code,dst_l_type);
						adr_of_dst := new_dst.load_address(code);
						cloned_or_copied := new_dst;
					elseif dst_is_indirect then
						adr_of_dst := recycle.new_local(code,globals.local_pointer);
						ari_cmd := recycle.new_ari_cmd;
						ari_cmd.make_binary_const(b_add,adr_of_dst,dst,dst_offset);
						code.add_cmd(ari_cmd);
					else
						adr_of_dst := dst.load_address(code);
					end;
					copy_fi := dst_l_type.expanded_class.base_class.get_inherited_feature(globals.general_ancestor_name,globals.string_copy);
					if not src_ref and then 
					   src_type.local_type(code).expanded_class = dst_l_type.expanded_class and then
					   copy_fi.origin.name = globals.string_general
					then
						-- optimization if copy() was not redefined: memcpy
						clone_and_copy.do_compile_standard_copy(code,src,src_type,adr_of_dst);
					else
						if src_ref then
							new_src := src.need_local(code,globals.local_reference);
						else
							clone_and_copy.compile_standard_clone(code,src,src_type);
							new_src := clone_and_copy.cloned_object;
						end;
						args := recycle.new_args_list;
						args.add(adr_of_dst);
						args.add(new_src);
						call_cmd := recycle.new_call_cmd;
						copy_fi := dst_l_type.expanded_class.base_class.get_inherited_feature(globals.general_ancestor_name,globals.string_copy);
						call_cmd.make_static(code,
						                     copy_fi.get_static_name(dst_type.actual_class_code(code)),
						                     args,
						                     Void);
						code.add_cmd(call_cmd);
					end;
				end;
			end;
		end; -- clone_or_copy

	clone_and_copy: CLONE_AND_COPY is 
		once
			!!Result
		end; -- clone_and_copy

--------------------------------------------------------------------------------

end -- COMPILE_ASSIGNMENT
