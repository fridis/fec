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

class BIT_CONSTANT

inherit
	MANIFEST_CONSTANT;
	DATATYPE_SIZES;
		
creation
	make

--------------------------------------------------------------------------------
	
feature { ANY }
	
	value: INTEGER;   -- id des Wertes dieser Konstanten

--------------------------------------------------------------------------------

	make (initial_value: INTEGER) is 
		do
			value := initial_value;
		ensure
			value = initial_value
		end; -- make

--------------------------------------------------------------------------------
		
	type : TYPE is 
		do
			if the_type = Void then
memstats(15);
				!!the_type.make((strings @ value).count)
			end;
			Result := the_type;
		end; -- type
		
feature { NONE }

	the_type : BIT_TYPE;
	
feature { ANY }
		
--------------------------------------------------------------------------------

	validity_of_constant_attribute (fi: FEATURE_INTERFACE) is
		do
			if fi.type = Void or else not fi.type.is_bit_type then
				fi.position.error(msg.vqmc6);
			end;
		end;  -- validity_of_constant_attribute

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	need_local_no_exp (code: ROUTINE_CODE; l_type: LOCAL_TYPE) : LOCAL_VAR is 
	-- load this value into a local variable
		local
			read_mem_cmd: READ_MEM_COMMAND;
			bit_name: STRING;
			bit_id: INTEGER;
		do
			-- nyi: dies sollte schšner gehen
			Result := recycle.new_local(code,l_type);
			code.class_code.const_bits.add(value);
memstats(302);
			!!bit_name.make(40);
			bit_name.append(const_bit_suffix);
			bit_name.append_integer(code.class_code.const_bits.count);
			bit_id := get_symbol_name(code.class_code.actual_class.name,strings # bit_name);
			read_mem_cmd := recycle.new_read_mem_cmd;
			read_mem_cmd.make_read_global(Result,bit_id);
			code.add_cmd(read_mem_cmd);
		end; -- need_local_no_exp

--------------------------------------------------------------------------------

	load_address (code: ROUTINE_CODE) : LOCAL_VAR is 
	-- load address of this value into a local variable
		local
			locl: LOCAL_VAR;
		do
			locl := need_local(code,type.local_type(code));
			Result := recycle.new_local(code,globals.local_pointer);
			code.add_cmd(recycle.new_load_adr_cmd(Result,locl));
		end; -- load_address

--------------------------------------------------------------------------------
		
end -- BIT_CONSTANT
