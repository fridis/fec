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

class SETHI_COMMAND

-- The SPARC-Instruction SETHI

inherit
	SPARC_COMMAND;
	SPARC_CONSTANTS;
	
creation { RECYCLE_OBJECTS }
	clear

--------------------------------------------------------------------------------
	
feature { NONE }

	const: INTEGER; -- the 22 bits (0..2^22-1)
	
	dst_reg: INTEGER;

	symbol: INTEGER;  -- id of symbol for relocation or 0
	
	addend: INTEGER;
	
--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }
	
	clear is
		do
			next := Void;
			prev := Void;
			const := 0;
			dst_reg := 0;
			symbol := 0;
			addend := 0;
		end; -- clear
	
--------------------------------------------------------------------------------

feature { COMMAND, BLOCK_SUCCESSORS, ROUTINE_CODE }

	make (constant: INTEGER; dest_reg: INTEGER) is
		require
			constant >= 0;
			constant <= b22;
			dest_reg < 32;
			dest_reg >= 0;
		do
			const := constant;
			dst_reg := dest_reg;
			symbol := 0;
		end; -- make

	make_reloc (sym: INTEGER; dest_reg: INTEGER; new_addend: INTEGER) is
		require
			dest_reg < 32;
			dest_reg >= 0;
		do
			const := 0;
			dst_reg := dest_reg;
			symbol := sym;
			addend := new_addend;
		end; -- make_reloc
	
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			if symbol /= 0 then
				mc.reloc_hi22(mc.pc,symbol,addend)
			end;
			mc.asm_sethi(const,dst_reg);
		end; -- create_machine_code

--------------------------------------------------------------------------------

	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			write_string("%Tsethi   "); write_integer(const) write_string(","); write_integer(dst_reg);
			write_string("%N");
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- SETHI_COMMAND
