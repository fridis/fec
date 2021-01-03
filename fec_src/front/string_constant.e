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

class STRING_CONSTANT

inherit
	MANIFEST_CONSTANT;
	DATATYPE_SIZES;
	
creation
	make

--------------------------------------------------------------------------------
	
feature { ANY }
	
	value: INTEGER;   -- Der Wert dieser Konstanten: Id des Strings

--------------------------------------------------------------------------------

	make (initial_value: INTEGER) is 
		do
			value := initial_value;
		ensure
			value=initial_value
		end; -- make

--------------------------------------------------------------------------------
		
	type : TYPE is 
	-- sebug: should be once (SE bug)
		do
			Result := globals.type_string; 
		end; -- type

--------------------------------------------------------------------------------

	validity_of_constant_attribute (fi: FEATURE_INTERFACE) is
		do
			if fi.type = Void or else not fi.type.is_string then
				fi.position.error(msg.vqmc5);
			end;
		end;  -- validity	_of_constant_attribute	

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	need_local_no_exp (code: ROUTINE_CODE; l_type: LOCAL_TYPE) : LOCAL_VAR is 
	-- load this value into a local variable
		local
			read_mem_cmd: READ_MEM_COMMAND;
			str_id: INTEGER;
			cc: CLASS_CODE;
		do
			cc := code.class_code;
			Result := recycle.new_local(code,l_type);
			cc.const_strings.add(value);
			read_mem_cmd := recycle.new_read_mem_cmd;
			str_id := const_string_name(cc.actual_class.name,cc.const_strings.count);
			read_mem_cmd.make_read_global(Result,str_id);
			code.add_cmd(read_mem_cmd);
		end; -- need_local_no_exp

--------------------------------------------------------------------------------

	load_address (code: ROUTINE_CODE) : LOCAL_VAR is 
	-- load address of this value into a local variable
		local
			locl: LOCAL_VAR;
		do
			locl := need_local(code,globals.local_reference);
			Result := recycle.new_local(code,globals.local_pointer);
			code.add_cmd(recycle.new_load_adr_cmd(Result,locl));
		end; -- load_address

--------------------------------------------------------------------------------
						
end -- STRING_CONSTANT
