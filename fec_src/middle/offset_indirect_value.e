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

class OFFSET_INDIRECT_VALUE 

-- für die Addressierung "offset(local)"

inherit
	VALUE; 
	COMMANDS;
	
creation { RECYCLE_OBJECTS }
	clear
	
--------------------------------------------------------------------------------

feature { NONE }

	offset: INTEGER;  -- der Offset

	symbol: INTEGER;     -- Das Symbol, das zum Offset addiert werden muss, oder Void
	
	locl: LOCAL_VAR;     -- die Lokale Variable

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS } 
	
	clear is
		do
			offset := 0;
			symbol := 0;
			locl := Void;
		end; -- clear

--------------------------------------------------------------------------------

feature { ANY } 

	make (new_offset: INTEGER; new_locl: LOCAL_VAR) is
		do
			offset := new_offset;
			symbol := 0;
			locl := new_locl;
		end; -- make
		
	make_symbol (new_offset: INTEGER; 
	             new_symbol: INTEGER; 
	             new_locl: LOCAL_VAR) is
		do
			offset := new_offset;
			symbol := new_symbol;
			locl := new_locl;
		end; -- make_symbol

--------------------------------------------------------------------------------

feature { ANY }

	need_local_no_exp (code: ROUTINE_CODE; type: LOCAL_TYPE) : LOCAL_VAR is 
	-- load this value into a local variable
		local
			read_mem_cmd: READ_MEM_COMMAND;
		do
			Result := recycle.new_local(code,type);
			read_mem_cmd := recycle.new_read_mem_cmd;
			read_mem_cmd.make_read_offset(Result,offset,symbol,locl);
			code.add_cmd(read_mem_cmd);
		end; -- need_local_no_exp

--------------------------------------------------------------------------------

	load_address (code: ROUTINE_CODE) : LOCAL_VAR is 
	-- load address of this value into a local variable
		local
			ari_cmd: ARITHMETIC_COMMAND;
		do
			if symbol /= 0 then
			-- nyi: Diesen Fall implementieren oder zeigen, dass er nicht auftreten kann!
write_string("Compilerfehler: OFFSET_INDIRECT_VALUE.load_address#1%N");
			end;
			if offset = 0 then
				Result := locl;
			else
				Result := recycle.new_local(code,globals.local_pointer);
				ari_cmd := recycle.new_ari_cmd;
				ari_cmd.make_binary_const(b_add,Result,locl,offset);
				code.add_cmd(ari_cmd);
			end;
		end; -- load_address

--------------------------------------------------------------------------------

end -- OFFSET_INDIRECT_VALUE
