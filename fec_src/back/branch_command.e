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

class BRANCH_COMMAND

-- The SPARC-Instructions FBcc and Bcc.

inherit
	SPARC_COMMAND;
	
creation { RECYCLE_OBJECTS }
	clear

--------------------------------------------------------------------------------
	
feature { NONE }
	
	is_fbranch: BOOLEAN;  -- true for FBcc, false for Bcc
	
	condition: INTEGER;  -- icc_* from SPARC_CONSTANTS
	
	branch_destination: BASIC_BLOCK; 
	
--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }
	
	clear is
		do
			next := Void;
			prev := Void;
			is_fbranch := false;
			condition := 0;
			branch_destination := Void;
		end; -- clear
	
--------------------------------------------------------------------------------

feature { COMMAND, BLOCK_SUCCESSORS, RECYCLE_OBJECTS }

	make (new_is_fbranch: BOOLEAN; 
	      new_condition: INTEGER; 
	      new_branch_destination: BASIC_BLOCK) is
	-- new_is_fbranch is true for a FBcc, false for Bcc.
		do
			is_fbranch := new_is_fbranch;
			condition := new_condition;
			branch_destination := new_branch_destination;
		end; -- make
	
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			if branch_destination.address < 0 then
				mc.branch_fixups.add(Current);
				fixup_pc := mc.pc;
				mc.asm_bcc_forward(is_fbranch,condition,false);
			else
				mc.asm_bcc(is_fbranch,condition,false,branch_destination.address);
			end;
		end; -- create_machine_code

--------------------------------------------------------------------------------

feature { MACHINE_CODE }

	fixup_pc: INTEGER;
	
	fixup_destination: INTEGER is
		do
			Result := branch_destination.address;
		end; -- fixup

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			write_string("%Tbranch%N"); 
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- BRANCH_COMMAND
