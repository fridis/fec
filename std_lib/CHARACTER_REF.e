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
	
	description: "Referebce class for CHARACTER"

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
class CHARACTER_REF

inherit
	COMPARABLE
		redefine
			infix "<=", 
			infix ">=",
			infix ">",
			is_equal,
			out
		end; 
	HASHABLE
		undefine
			is_equal,
			out
		end;

feature -- Access

	item: CHARACTER;
	
	hash_code: INTEGER is
	-- Hash_code value
		do
			Result := item.code;
		end; -- hash_code

feature -- Comparison

	infix "<" (other: like Current): BOOLEAN is
		do
			Result := item < other.item;
		end; -- infix "<"

	infix "<=" (other: like Current): BOOLEAN is
		do
			Result := item <= other.item;
		end; -- infix "<="

	infix ">=" (other: like Current): BOOLEAN is
		do
			Result := item >= other.item;
		end; -- infix ">="

	infix ">" (other: like Current): BOOLEAN is
		do
			Result := item > other.item;
		end; -- infix ">"

	is_equal (other: like Current): BOOLEAN is
		do
			Result := item = other.item;
		end; -- is_equal

feature -- Output

	out: STRING is
		do
			!!Result.make(1); 
			Result.append_character(item);
		end; -- out
		
end -- CHARACTER_REF
