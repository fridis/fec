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

class FCMPE_COMMAND

-- The SPARC-Instruction FCMPE.

inherit
	SPARC_COMMAND;
	SPARC_CONSTANTS;
	
creation { RECYCLE_OBJECTS }
	clear

--------------------------------------------------------------------------------
	
feature { NONE }

	is_real: BOOLEAN;  -- false for double precision comparison
	
	src1_reg,src2_reg: INTEGER; -- numbers of fp-registers to be compared
	
--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }
	
	clear is
		do
			next := Void;
			prev := Void;
			is_real := false;
			src1_reg := 0;
			src2_reg := 0;
		end; -- clear
	
--------------------------------------------------------------------------------

feature { COMMAND, BLOCK_SUCCESSORS }

	make (new_is_real: BOOLEAN; new_src1_reg,new_src2_reg: INTEGER) is
		require
			new_src1_reg >= f0;
			new_src1_reg <= f0+31;
			new_src2_reg >= f0;
			new_src2_reg <= f0+31;
			not new_is_real implies 
				new_src1_reg \\ 2 = 0 and
				new_src2_reg \\ 2 = 0;
		do
			is_real := new_is_real;
			src1_reg := new_src1_reg;
			src2_reg := new_src2_reg;
		end; -- make
	
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		local
			opf_v: INTEGER;
		do
			if is_real then
				opf_v := opf_fcmpes
			else
				opf_v := opf_fcmped
			end;
			mc.asm_fcmp(opf_v,src1_reg,src2_reg);
		end; -- create_machine_code

--------------------------------------------------------------------------------

	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			if is_real then
				write_string("%Tfcmpes  fp");
			else 
				write_string("%Tfcmped  fp"); 
			end;
			write_integer(src1_reg); write_string(",fp");
			write_integer(src2_reg);
			write_string("%N");
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- FCMPE_COMMAND
