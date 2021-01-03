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

class INIT_EXPANDED

-- this provides routines to initialize the attributes of expanded objects
-- with their default values and call their default initialization routines.
-- inherit INIT_EXPANDE to use its features.
	
--------------------------------------------------------------------------------

creation 
	{ NONE }  -- inherit this class to use its features
	
--------------------------------------------------------------------------------

feature { ANY }

	clear_and_init_expanded(code: ROUTINE_CODE; adr_of_object: LOCAL_VAR; type: TYPE) is
		require
			not type.actual_is_reference(code);
		do
			clearmem(code,adr_of_object,type.actual_class_code(code).size);
			init_expanded(code, adr_of_object,type,true);
		end; -- clear_and_init_expanded

--------------------------------------------------------------------------------

	clearmem(code: ROUTINE_CODE; adr: LOCAL_VAR; size: INTEGER) is
	-- call memset(adr,0,size);
		local
			size_local, zero_local: LOCAL_VAR;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
			args: LIST[LOCAL_VAR];
			call_cmd: CALL_COMMAND;
		do
			zero_local := recycle.new_local(code,globals.local_integer);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_int(zero_local,0);
			code.add_cmd(ass_const_cmd);
			size_local := recycle.new_local(code,globals.local_integer);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_int(size_local,size);
			code.add_cmd(ass_const_cmd);
			args := recycle.new_args_list; 
			args.add(adr);
			args.add(zero_local);
			args.add(size_local);
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,
			                     globals.string_memset,
			                     args,
			                     Void);
			code.add_cmd(call_cmd);
		end; -- clearmem

--------------------------------------------------------------------------------

	init_expanded(code: ROUTINE_CODE; adr_of_object: LOCAL_VAR; type: TYPE; is_expanded: BOOLEAN) is
	-- Creates code that calls the default initialization routine of all
	-- expanded attributes of the object pointer to by adr_of_object.
	-- If is_expanded, then this as well calls type's init routine.
		local
			ac: ACTUAL_CLASS;
			class_interface: CLASS_INTERFACE;
			feature_list: SORTED_ARRAY[INTEGER,FEATURE_INTERFACE];
			fi: FEATURE_INTERFACE;
			feature_type: TYPE;
			off_ind: OFFSET_INDIRECT_VALUE;
			i: INTEGER;
			creators: CREATION_LIST;
			feature_name: INTEGER; 
			call_cmd: CALL_COMMAND;
			args: LIST[LOCAL_VAR];
		do
			ac := type.actual_class_code(code);
			class_interface := ac.base_class;
			feature_list := class_interface.feature_list;
			from
				i := feature_list.lower
			until
				i > feature_list.upper
			loop
				fi := feature_list @ i;
				if fi.feature_value.is_variable_attribute then
					feature_type := fi.type;
					if feature_type.view_client(fi,Void,type,class_interface).local_type(code).is_expanded then
						off_ind := recycle.new_off_ind;
						off_ind.make(ac.attribute_offsets @ fi.number,adr_of_object);
						init_expanded(code,off_ind.load_address(code),feature_type,true);
					end;
				end; 
				i := i + 1;
			end; 
			creators := class_interface.parse_class.creators;
			if is_expanded and then 
				creators /= Void and then
				creators.count > 0 
			then
				feature_name := (creators @ 1).name;
				args := recycle.new_args_list; 
				args.add(adr_of_object);
				call_cmd := recycle.new_call_cmd;
				fi := feature_list.find(feature_name);
				call_cmd.make_static(code,
				                     fi.get_static_name(ac),
				                     args,
				                     Void);
				code.add_cmd(call_cmd);
			end;
		end; -- init_expanded
	
--------------------------------------------------------------------------------

end -- INIT_EXPANDED
