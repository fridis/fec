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

class COMMANDS

-- Constants used to represent operators supported by ARITHMETIC_COMMAND.
--
-- Inherit this class to use these constants.

feature

-- ARITHMETIC_COMMAND
	b_add,
	b_sub,
	b_subf,  -- subtract from: a subf b = b - a
	b_mul,
	b_div,
	b_mod,
	b_and,
	b_nand,
	b_or,
	b_nor,
	b_xor,
	b_eqv,
	b_implies,
	b_nimplies,
	b_shift_left,
	b_shift_right,             -- für "local1 := local2 <op> local3"
	u_neg,
	u_abs: INTEGER is UNIQUE;  -- für "local1 := <op> local2"

end -- COMMANDS
