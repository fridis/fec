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

indexing

	description: "Reference class for POINTER"

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
class POINTER_REF

inherit
	HASHABLE
		redefine
			out
		end;

feature -- Access

	item: POINTER;
	
	hash_code: INTEGER is
	-- Hash_code value
		do
			Result := item.to_integer.hash_code;
		end; -- hash_code

feature -- Element change

	set_item (p: POINTER) is
	-- Make b the associated boolean value.
		do
			item := p;
		ensure
			item_set: item = p
		end; -- set_item
		
feature -- Output

	out: STRING is
	-- Printable representation of pointer
		do
			Result := "POINTER(" | item.out | ")";
		end; -- out
		
end -- POINTER_REF
