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

	description: "Reference class for INTEGER";

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
class INTEGER_REF

inherit
	NUMERIC
		rename
			infix "/" as infix "//"
		undefine
			is_equal,
			out
		end;
	HASHABLE
		undefine
			is_equal,
			out
		end;
	COMPARABLE
		redefine
			infix "<=",
			infix ">",
			infix ">=",
			out
		end;

feature -- Access

	item: INTEGER;

	hash_code: INTEGER is 
	-- Hash code value
		local
			platform: expanded PLATFORM;
		do
			if item <= platform.Minimum_integer then
				Result := item.abs;
			end;
		end; -- hash_code

	one: INTEGER_REF is
	-- Neutral element for "*" and "/"
		do
			Result := 1
		end; -- one
		
	zero: INTEGER_REF is
	-- Neutral element for "+" and "-"
		do
			Result := 0
		end; -- zero
	
feature -- Status report

	divisible (other: INTEGER_REF): BOOLEAN is
	-- May current object be divided by other?
		do
			Result := other.item /= 0
		end; -- divisible	
		
	exponentiable (other: INTEGER_REF): BOOLEAN is
	-- May current object be elevated to the power of other?
		do
			Result := other.item >= 0;
		end; -- exponentiable
		
feature -- Basic operations

	infix "+" (other: INTEGER_REF): INTEGER_REF is
	-- Sum with other (commutative).
		do
			Result := item + other.item;
		end; -- infix "+"
		
	infix "-" (other: INTEGER_REF): INTEGER_REF is
	-- Result of subtracting other.
		do
			Result := item - other.item;
		end; -- infix "-"
				
	infix "*" (other: INTEGER_REF): INTEGER_REF is
	-- Product by other.
		do
			Result := item * other.item;
		end; -- infix "*"
				
	infix "//" (other: INTEGER_REF): INTEGER_REF is
	-- Integer division of Current by other
	-- (from infix "/" in NUMERIC)
		do
			Result := item // other.item;
		end; -- infix "//"
					
	infix "^" (other: INTEGER_REF): INTEGER_REF is
	-- Current object to the power other
		local
			m,o: INTEGER;
		do
			from
				Result := 1;
				m := item;
				o := other.item;
			until
				o = 0
			loop
				if o \\ 2 /= 0 then
					Result := Result * m
				end;
				o := o // 2;
				m := m * m;
			end;
		end; -- infix "^"		
		
	prefix "+" : INTEGER_REF is
	-- Unary plus
		do
			Result := item;
		end; -- prefix "+"
		
	prefix "-" : INTEGER_REF is
	-- Unary minus
		do
			Result := - item;
		end; -- prefix "-"

feature -- Comparison

	infix "<" (other: INTEGER_REF): BOOLEAN is
		do
			Result := item < other.item;
		end; -- infix "<";

	infix "<=" (other: INTEGER_REF): BOOLEAN is
		do
			Result := item <= other.item;
		end; -- infix "<=";

	infix ">" (other: INTEGER_REF): BOOLEAN is
		do
			Result := item > other.item;
		end; -- infix ">";

	infix ">=" (other: INTEGER_REF): BOOLEAN is
		do
			Result := item >= other.item;
		end; -- infix ">=";
			
feature -- Output

	out: STRING is
		do			
			!!Result.make(11);
			Result.append_integer(item);
		end; -- out
		
end -- INTEGER_REF
