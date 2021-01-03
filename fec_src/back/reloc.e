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

class RELOC

-- Relocation to a Symbol in an object file.

creation
	clear

--------------------------------------------------------------------------------

feature { MACHINE_CODE }

	offset: INTEGER;            -- where this relocation is to be applied.

	referenced_symbol: SYMBOL;  -- relocate relative to this symbol
	
	type: INTEGER;              -- relocation type, r_sparc_* as defined below
	
	addend: INTEGER;
	
-- sparc relocation types:

	r_sparc_32     : INTEGER is 3;
	r_sparc_wdisp30: INTEGER is 7;
	r_sparc_hi22   : INTEGER is 9;
	r_sparc_lo10   : INTEGER is 12;
	r_sparc_13     : INTEGER is 11;

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is
		do
			offset := 0;
			referenced_symbol := Void;
			type := 0;
			addend := 0;
		end; -- clear

--------------------------------------------------------------------------------

feature { MACHINE_CODE }

	make_wdisp30 (new_offset: INTEGER; to: SYMBOL) is
		do
			offset := new_offset;
			referenced_symbol := to;
			type := r_sparc_wdisp30;
			addend := 0;
		end; -- make_wdisp30
		
	make_hi22 (new_offset: INTEGER; to: SYMBOL; new_addend: INTEGER) is
		do
			offset := new_offset;
			referenced_symbol := to;
			type := r_sparc_hi22;
			addend := new_addend;
		end; -- make_hi22
		
	make_lo10 (new_offset: INTEGER; to: SYMBOL; new_addend: INTEGER) is
		do
			offset := new_offset;
			referenced_symbol := to;
			type := r_sparc_lo10;
			addend := new_addend;
		end; -- make_lo10
		
	make_13 (new_offset: INTEGER; to: SYMBOL) is
		do
			offset := new_offset;
			referenced_symbol := to;
			type := r_sparc_13;
			addend := 0;
		end; -- make_13
		
	make_32 (new_offset: INTEGER; to: SYMBOL; new_addend: INTEGER) is
		do
			offset := new_offset;
			referenced_symbol := to;
			type := r_sparc_32;
			addend := new_addend;
		end; -- make_32

--------------------------------------------------------------------------------

end -- RELOC
