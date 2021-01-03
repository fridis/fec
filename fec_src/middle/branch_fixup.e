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

class BRANCH_FIXUP

-- A list of objects of this class is stored in every basic block. Each 
-- of these objects represents a branch to the basic block whose machine code
-- was created before the address of the destination block was known.
-- 
-- (this should be a expanded class to save some mem). 

creation
	make

--------------------------------------------------------------------------------

feature

	fix_block: TWO_SUCCESSORS;    -- der Block, der die Verzweigung enthält.

	fix_true: BOOLEAN;            -- Soll der true oder false-Nachfolger gesetzt werden?
	
--------------------------------------------------------------------------------

	make (new_fix_block: TWO_SUCCESSORS; new_fix_true: BOOLEAN) is
		do
			fix_block := new_fix_block;
			fix_true := new_fix_true;
		end; -- make
		
--------------------------------------------------------------------------------

	fix (to: BASIC_BLOCK) is
		do
			if fix_true then
				fix_block.set_true(to)
			else
				fix_block.set_false(to)
			end;
		end; -- fix

--------------------------------------------------------------------------------

end -- BRANCH_FIXUP
