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

class SAVE_COMMAND

-- The SPARC-Instruction SAVE.

inherit
	SPARC_COMMAND;
	
creation { RECYCLE_OBJECTS }
	clear

--------------------------------------------------------------------------------
	
feature { RECYCLE_OBJECTS }

	stack_frame_size : INTEGER;
	
--------------------------------------------------------------------------------
	
	clear is
		do
			next := Void;
			prev := Void;
			stack_frame_size := 0;
		end; -- clear
	
--------------------------------------------------------------------------------

feature { ROUTINE_CODE }

	make (stackfr_size: INTEGER) is
		do
			stack_frame_size := stackfr_size;
		end; -- make
	
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			mc.asm_save(stack_frame_size);
		end; -- create_machine_code

--------------------------------------------------------------------------------

	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			write_string("%Tsave    %%sp,-x,%%sp%N");
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- SAVE_COMMAND
