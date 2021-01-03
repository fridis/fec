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

class INDEXED_VALUE 

-- für die Addressierung "(local1+local2)"

inherit
	VALUE;
	COMMANDS;
	
creation { RECYCLE_OBJECTS }
	clear
		
--------------------------------------------------------------------------------

feature { ANY }

	local1,local2: LOCAL_VAR;     -- die Lokale Variable

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is
		do
			local1 := Void;
			local2 := Void;
		end; -- clear
		
--------------------------------------------------------------------------------

feature { ANY }

	make (new_local1,new_local2: LOCAL_VAR) is
		do
			local1 := new_local1;
			local2 := new_local2;
		end; -- make

--------------------------------------------------------------------------------

	need_local_no_exp (code: ROUTINE_CODE; type: LOCAL_TYPE) : LOCAL_VAR is 
	-- load this value into a local variable
		local
			read_mem_cmd: READ_MEM_COMMAND;
		do
			Result := recycle.new_local(code,type);
			read_mem_cmd := recycle.new_read_mem_cmd;
			read_mem_cmd.make_read_indexed(Result,local1,local2);
			code.add_cmd(read_mem_cmd);
		end; -- need_local_no_exp

--------------------------------------------------------------------------------

	load_address (code: ROUTINE_CODE) : LOCAL_VAR is 
	-- load address of this value into a local variable
		local
			ari_cmd: ARITHMETIC_COMMAND;
		do
			Result := recycle.new_local(code,globals.local_pointer);
			ari_cmd := recycle.new_ari_cmd;
			ari_cmd.make_binary(b_add,Result,local1,local2);
			code.add_cmd(ari_cmd);
		end; -- load_address

--------------------------------------------------------------------------------

end -- INDEXED_VALUE
