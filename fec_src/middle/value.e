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

deferred class VALUE 

-- Abstract class that represents constants, temporary values and semi-strict
-- boolean expressions.
--
-- This class is only used during the generation of the intermediate 
-- representation.

inherit
	FRIDISYS;
	CONDITIONS;
	DATATYPE_SIZES;

--------------------------------------------------------------------------------

feature { NONE } 

	need_local_no_exp (code: ROUTINE_CODE; l_type: LOCAL_TYPE) : LOCAL_VAR is 
	-- load this value into a local variable
		require
			not l_type.is_expanded
		deferred
		end; -- need_local_no_exp

feature { ANY }

	need_local (code: ROUTINE_CODE; l_type: LOCAL_TYPE) : LOCAL_VAR is 
	-- load this value into a local variable
		local
			type_descr: LOCAL_VAR;
			read_mem_cmd: READ_MEM_COMMAND;
			args: LIST[LOCAL_VAR];
			call_cmd: CALL_COMMAND;
		do
			if l_type.is_expanded then
			-- nyi: l_type.is_bit
				type_descr := recycle.new_local(code,globals.local_pointer);
				Result := recycle.new_local(code,l_type);
				read_mem_cmd := recycle.new_read_mem_cmd;
				read_mem_cmd.make_read_global(type_descr,
				                              type_descriptor_name(l_type.expanded_class.key.code_name));
				code.add_cmd(read_mem_cmd);
memstats(427);
				!!args.make; 
				args.add(type_descr);
				args.add(Result.load_address(code));
				args.add(load_address(code));
				call_cmd := recycle.new_call_cmd;
			-- nyi: Don't use std_copy, but memcpy or something
				call_cmd.make_static(code,globals.string_std_copy_name,args,Void);
				code.add_cmd(call_cmd);
			else
				Result := need_local_no_exp(code,l_type);
			end;
		end; -- need_local

--------------------------------------------------------------------------------

	load_address (code: ROUTINE_CODE) : LOCAL_VAR is 
	-- load address of this value into a local variable
		deferred
		end; -- load_address

--------------------------------------------------------------------------------

	fix_boolean (code: ROUTINE_CODE; t,f,next: BASIC_BLOCK) is
	-- for boolean values: creates branches to t and f for true and false 
	-- conditions, respectively. code.current_block is set to next. 
		require
			t /= Void;
			f /= Void;
			next /= Void;
		do
			need_boolean(code).fix_boolean(code,t,f,next);
		end; -- fix_boolean

--------------------------------------------------------------------------------

	need_boolean (code: ROUTINE_CODE): BOOLEAN_VALUE is 
	-- create a BOOLEAN_VALUE from this boolean value
		do
			Result := recycle.new_boolval;
			Result.make(need_local(code,globals.local_boolean),Void,0,c_not_equal);
		end; -- need_boolean

--------------------------------------------------------------------------------

	invert_boolean (code: ROUTINE_CODE): VALUE is 
	-- create the value of "not Current" for a boolean Current
		do
			Result := need_boolean(code).invert_boolean(code);
		end; -- invert_boolean

--------------------------------------------------------------------------------

end -- VALUE
