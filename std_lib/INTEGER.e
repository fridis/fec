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

	description: "Integer values";

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
expanded class INTEGER

inherit
	INTEGER_REF
		redefine
			one,
			zero,
			divisible,
			exponentiable,
			infix "+",
			infix "-",
			infix "*",
			infix "//",
			infix "^",
			prefix "+",
			prefix "-",
			infix "<",
			infix "<=",
			infix ">",
			infix ">=",
			min,
			max,
			three_way_comparison
		end;

feature -- Access

	one: INTEGER is
	-- Neutral element for "*" and "/"
		do
			Result := 1
		end; -- one
		
	zero: INTEGER is
	-- Neutral element for "+" and "-"
		do
			Result := 0
		end; -- zero
	
	sign: INTEGER is 
	-- Sign value (0, -1 or 1)
		do
			if Current < 0 then
				Result := -1
			elseif Current > 0 then
				Result := 1
			end;
		ensure
			three_way: Result = three_way_comparison(zero)
		end; -- sign
		
feature -- Status report

	divisible (other: INTEGER): BOOLEAN is
	-- May current object be divided by other?
		do
			Result := other /= 0
		end; -- divisible	
		
	exponentiable (other: INTEGER): BOOLEAN is
	-- May current object be elevated to the power of other?
		do
			Result := other >= 0;
		end; -- exponentiable
		
feature -- Basic operations

	abs: INTEGER is
	-- Absolute value
		do
			if Current < 0 then
				Result := -item
			else
				Result := item
			end;
		ensure
			non_negative: Result >= 0;
			same_absolute_value: (Result = Current) or (Result = - Current);
		end; -- abs

	infix "+" (other: INTEGER): INTEGER is
	-- Sum with other (commutative).
		do
			Result := item + other.item;
		end; -- infix "+"
		
	infix "-" (other: INTEGER): INTEGER is
	-- Result of subtracting other.
		do
			Result := item - other.item;
		end; -- infix "-"
				
	infix "*" (other: INTEGER): INTEGER is
	-- Product by other.
		do
			Result := item * other.item;
		end; -- infix "*"
				
	infix "/" (other: INTEGER): DOUBLE is
	-- Division by other.
		local
			d1,d2: DOUBLE;
		do
			d1 := item;
			d2 := other.item;
			Result := d1 / d2;
		end; -- infix "/"

	infix "//" (other: INTEGER): INTEGER is
	-- Integer division of Current by other
	-- (from infix "/" in NUMERIC)
		do
			Result := item // other;
		end; -- infix "//"
		
	infix "\\" (other: INTEGER): INTEGER is
	-- Remainder of the integer division of Current by other
		require
			good_divisor: divisible(other);
		do
			Result := item \\ other.item;
		end; -- infix "\\"
					
	infix "^" (other: INTEGER): INTEGER is
	-- Current object to the power other
		local
			m,o: INTEGER;
		do
			from
				Result := 1;
				m := item;
				o := other;
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
		
	prefix "+" : INTEGER is
	-- Unary plus
		do
			Result := item;
		end; -- prefix "+"
		
	prefix "-" : INTEGER is
	-- Unary minus
		do
			Result := - item;
		end; -- prefix "-"

feature -- Comparison

	infix "<" (other: INTEGER): BOOLEAN is
		do
			Result := item < other.item;
		end; -- infix "<";

	infix "<=" (other: INTEGER): BOOLEAN is
		do
			Result := item <= other.item;
		end; -- infix "<=";

	infix ">" (other: INTEGER): BOOLEAN is
		do
			Result := item > other.item;
		end; -- infix ">";

	infix ">=" (other: INTEGER): BOOLEAN is
		do
			Result := item >= other.item;
		end; -- infix ">=";
		
	max (other: INTEGER): INTEGER is
	-- The greater of current object and other
		do
			if item >= other.item then
				Result := item
			else
				Result := other.item
			end; 
		end; -- max
			
	min (other: INTEGER): INTEGER is
	-- The greater of current object and other
		do
			if item <= other.item then
				Result := item
			else
				Result := other.item
			end; 
		end; -- min

	three_way_comparison (other: INTEGER): INTEGER is
	-- If current object equal to other, 0; if smaller, -1; if greater, 1.
		do
			if item < other then
				Result := -1
			elseif other < item then
				Result := 1
			end;
		end; -- three_way_comparison

feature -- Conversion

	to_character: CHARACTER is
	-- Returns the character whose ASCII code is Current
		require
			valid_character_code: 0 <= Current and Current <= 255
		do
			Result := item.to_character
		end; -- to_character
		
	to_pointer: POINTER is
		do
			Result := item.to_pointer
		end; -- to_pointer
		
end -- INTEGER
