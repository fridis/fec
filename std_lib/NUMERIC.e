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

	description: "Objects to which numerical operations are applicable";
	
	note: "The model is that of a commutative ring."

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
deferred class NUMERIC

feature -- Access

	one: NUMERIC is
	-- Neutral element for "*" and "/"
		deferred
		ensure
			Result_exists: Result /= Void
		end; -- one
		
	zero: NUMERIC is
	-- Neutral element for "+" and "-"
		deferred
		ensure
			Result_exists: Result /= Void
		end; -- zero
		
feature -- Status report

	divisible (other: NUMERIC): BOOLEAN is
	-- May current object be divided by other?
		require
			other_exists: other /= Void
		deferred
		end; -- divisible	
		
	exponentiable (other: NUMERIC): BOOLEAN is
	-- May current object be elevated to the power of other?
		require
			other_exists: other /= Void
		deferred
		end; -- exponentiable
		
feature -- Basic operations

	infix "+" (other: NUMERIC): NUMERIC is
	-- Sum with other (commutative).
		require
			other_exists: other /= Void
		deferred
		ensure
			result_exists: Result /= Void;
		-- nyi:	commutative: equal(Result,other + Current)
		end; -- infix "+"
		

	infix "-" (other: NUMERIC): NUMERIC is
	-- Result of subtracting other.
		require
			other_exists: other /= Void
		deferred
		ensure
			result_exists: Result /= Void;
		end; -- infix "-"

	infix "*" (other: NUMERIC): NUMERIC is
	-- Product by other.
		require
			other_exists: other /= Void
		deferred
		ensure
			result_exists: Result /= Void;
		end; -- infix "*"
				
	infix "/" (other: NUMERIC): NUMERIC is
	-- Division by other.
		require
			other_exists: other /= Void;
			good_divisor: divisible(other)
		deferred
		ensure
			result_exists: Result /= Void;
		-- nyi:	commutative: equal(Result,other + Current)
		end; -- infix "/"
				
	infix "^" (other: NUMERIC): NUMERIC is
	-- Current object to the power other
		require	
			other_exists: other /= Void;
			good_exponent: exponentiable(other)
		deferred
		ensure
			result_exists: Result /= Void;
		end; -- infix "^"		
		
	prefix "+" : NUMERIC is
	-- Unary plus
		deferred
		ensure
			result_exists: Result /= Void;
		end; -- prefix "+"
		
	prefix "-" : NUMERIC is
	-- Unary minus
		deferred
		ensure
			result_exists: Result /= Void;
		end; -- prefix "-"

invariant
	
-- nyi:	neutral_addition: equal(Current + zero, Current);
-- nyi:	self_subtraction: equal(Current - Current, zero);
	
-- nyi:	neutral_multiplication: equal(Current * one, Current);
-- nyi:	self_division: divisible(Current) implies equal(Current / Current, one); 

end -- NUMERIC
