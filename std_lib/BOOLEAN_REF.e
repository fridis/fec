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

	description: "Reference class for BOOLEAN"

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
class BOOLEAN_REF

inherit
	HASHABLE
		redefine
			out
		end;

feature -- Access

	item: BOOLEAN;
	
	hash_code: INTEGER is
	-- Hash_code value
		do
			if item then
				Result := 1
			end;
		end; -- hash_code

feature -- Element change

	set_item (b: BOOLEAN) is
	-- Make b the associated boolean value.
		do
			item := b;
		ensure
			item_set: item = b
		end; -- set_item
		
feature -- Output

	out: STRING is
	-- Printable representation of boolean
		do
			if item then
				Result := "true"
			else
				Result := "false"
			end; 
		end; -- out
		
end -- BOOLEAN_REF
