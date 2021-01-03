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

	description: "Objects may be compared according to a %
	             %total order relation";
	
	note: "The basic operation is '<' (less than); others are %
	      %defined in terms of this operation and 'is_equal'."

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
deferred class COMPARABLE

inherit
	ANY
		redefine
			is_equal
		end;

feature -- Comparison

	infix "<" (other: COMPARABLE): BOOLEAN is
	-- Is current object less than other?
		require
			other_exists: other /= Void
		deferred
		ensure
			asymmetric: Result implies not (other < Current)
		end; -- infix "<"
		
	infix "<=" (other: COMPARABLE): BOOLEAN is
	-- Is current object less than or equal to other?
		require
			other_exists: other /= Void
		do
			Result := Current < other or is_equal(other)
		ensure
			definition: Result = (Current < other or is_equal(other))
		end; -- infix "<="
		
	infix ">=" (other: COMPARABLE): BOOLEAN is
	-- Is current object greater than or equal to other?
		require
			other_exists: other /= Void
		do
			Result := other <= Current
		ensure
			definition: Result = (other <= Current)
		end; -- infix ">="
			
	infix ">" (other: COMPARABLE): BOOLEAN is
	-- Is current object greater than other?
		require
			other_exists: other /= Void
		do
			Result := other < Current
		ensure
			definition: Result = (other < Current)
		end; -- infix ">"

	is_equal (other: like Current): BOOLEAN is
	-- Is other attached to an object considered equal to current object?
		do
			Result := not (Current < other) and not (other < Current)
		end; -- is_equal
		
	max (other: COMPARABLE): COMPARABLE is
	-- The greater of current object and other
		require
			other_exists: other /= Void
		do
			if Current >= other then
				Result := Current
			else
				Result := other
			end; 
		ensure
			current_if_not_smaller: (Current >= other) implies (Result = Current)
			other_if_smaller: (Current < other) implies (Result = other)
		end; -- max
			
	min (other: COMPARABLE): COMPARABLE is
	-- The smaller of current object and other
		require
			other_exists: other /= Void
		do
			if Current <= other then
				Result := Current
			else
				Result := other
			end; 
		ensure
			current_if_not_greater: (Current <= other) implies (Result = Current)
			other_if_greater: (Current > other) implies (Result = other)
		end; -- min

	three_way_comparison (other: COMPARABLE): INTEGER is
	-- If current object equal to other, 0; if smaller, -1; if greater, 1.
		require
			other_exists: other /= Void
		do
			if Current < other then
				Result := -1
			elseif other < Current then
				Result := 1
			end;
		ensure
			equal_zero: (Result = 0) = is_equal(other);
			smaller_negative: (Result = -1) = (Current < other);
			greater_positive: (Result = 1) = (Current > other)
		end; -- three_way_comparison
		
invariant

	irreflexive_comparison: not (Current < Current)
	
end -- COMPARABLE
