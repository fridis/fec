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
	
	description: "Real values, single precision"

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
expanded class REAL

inherit
	REAL_REF
		redefine
			one,
			zero,
			divisible,
			exponentiable,
			infix "+",
			infix "-",
			infix "*",
			infix "/",
			infix "^",
			prefix "+",
			prefix "-",
			infix "<",
			infix "<=",
			infix ">",
			infix ">="
		end;

feature -- Access

	one: REAL is
	-- Neutral element for "*" and "/"
		do
			Result := 1
		end; -- one
		
	zero: REAL is
	-- Neutral element for "+" and "-"
		do
			Result := 0
		end; -- zero

feature -- Status report

	divisible (other: REAL): BOOLEAN is
	-- May current object be divided by other?
		do
			Result := other /= 0.0;
		end; -- divisible
		
	exponentiable (other: REAL): BOOLEAN is
	-- May current object be elevated to the power of other?
		do
			Result := other >= 0.0
		end; -- exponentiable
		
feature -- Basic operations

	abs: REAL is
	-- Absolute value
		do
			if Current < 0 then
				Result := -item
			else
				Result := item
			end;
		ensure
			non_negative: Result >= 0;
			same_absolute_value: (Result = Current) or (Result = -Current);
		end; -- abs
	
	sign: INTEGER is
	-- sign value: -1, 0 or 1
		do
			if item < 0 then
				Result := -1
			elseif item > 0 then
				Result := 1
			end;
		end; -- sign
	
	infix "+" (other: REAL): REAL is
	-- Sum with other.
		do
			Result := item + other.item;
		end; -- infix "+"
		
	infix "-" (other: REAL): REAL is
	-- Result of subtracting other.
		do
			Result := item - other.item;
		end; -- infix "-"
		
	infix "*" (other: REAL): REAL is
	-- Product by other
		do
			Result := item * other.item;
		end; -- infix "*"
		
	infix "/" (other: REAL): REAL is
	-- Division by other
		do
			Result := item / other.item;
		end; -- infix "/"
	
	infix "^" (other: REAL): REAL is
	-- Current real to the power other
		do -- nyi
		end; -- infix "^"
		
	prefix "+" : REAL is
	-- Unary plus
		do
			Result := item;
		end; -- prefix "+"
		
	prefix "-" : REAL is
	-- Unary minus
		do
			Result := - item;
		end; -- prefix "-"
		
feature -- Comparison

	infix "<" (other: REAL): BOOLEAN is
		do
			Result := item < other.item;
		end; -- infix "<"

	infix "<=" (other: REAL): BOOLEAN is
		do
			Result := item <= other.item;
		end; -- infix "<=";

	infix ">" (other: REAL): BOOLEAN is
		do
			Result := item > other.item;
		end; -- infix ">";

	infix ">=" (other: REAL): BOOLEAN is
		do
			Result := item >= other.item;
		end; -- infix ">=";
	
feature -- Conversion

	ceiling: INTEGER is
	-- Smallest integral value not smaller than current object
		do 
			if item < 0 then
				Result := item.truncated_to_integer
			else
				Result := -(-item).truncated_to_integer;
			end;
		ensure 
		--nyi	result_not_smaller: Result >= Current;
		--nyi	close_enough: Result - Current < one;
		end; -- ceiling
		
	floor: INTEGER is
	-- Greatest integral value no greater than current object
		do 
			if item >= 0 then
				Result := item.truncated_to_integer
			else
				Result := -(-item).truncated_to_integer;
			end;
		ensure
		-- nyi	result_no_greater: Result <= Current;
		-- nyi	close_enough: Current - Result < one;
		end; -- floor

	rounded: INTEGER is
	-- Rounded integral value
		do
			Result := sign * ((abs+0.5).floor);
		ensure
			definition: Result = sign * ((abs+0.5).floor);
		end; -- rounded
		
	truncated_to_integer: INTEGER is
	-- Integer part (same sign, largest absolute value
	-- no greater than current object's)
		do
			Result := item.truncated_to_integer;
		end; -- truncated_to_integer

	to_double: DOUBLE is
	-- Convert this value to a DOUBLE
		do
			Result := item.to_double;
		end; -- to_double
		
end -- REAL
