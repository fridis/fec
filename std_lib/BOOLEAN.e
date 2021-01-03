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

	description: "Truth values, with the boolean operations"

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
expanded class BOOLEAN

inherit
	BOOLEAN_REF;

feature -- Basic operations

	infix "and" (other: BOOLEAN): BOOLEAN is
	-- Boolean conjunction with other
		do
			if item then
				Result := true
			else
				Result := other
			end;
		ensure
			de_morgan: Result = not (not Current or not other); 
			commutative: Result = (other and Current);
			consistent_with_semi_strict: Result implies (Current and then other)
		end; -- infix "and"

	infix "and then" (other: BOOLEAN): BOOLEAN is
	-- Boolean semi-strict conjunction with other
		do
			if item then
				Result := true
			else
				Result := other
			end;
		ensure
			de_morgan: Result = not (not Current or else not other); 
		end; -- infix "and then"
		
	infix "implies" (other: BOOLEAN): BOOLEAN is
	-- Boolean implication of other (semi-strict)
		do
			if item then
				Result := other
			else
				Result := true
			end; 
		ensure
			definition: Result = not Current or else other
		end; -- infix "implies"
		
	prefix "not": BOOLEAN is
	-- Negation.
		do
			if item then
				Result := false
			else
				Result := true
			end; 
		end; -- prefix "not"

	infix "or" (other: BOOLEAN): BOOLEAN is
	-- Boolean disjunction with other
		do
			if item then
				Result := true
			else
				Result := other
			end; 
		ensure
			de_morgan: Result = not (not Current and not other);
			commutative: Result = other or Current; 
			consistent_with_semi_strict: Result = (Current or else other); 
		end; -- infix "or"
		
	infix "or else" (other: BOOLEAN): BOOLEAN is
	-- Boolean semi-strict disjunction with other
		do
			if item then
				Result := true
			else
				Result := other
			end; 
		ensure
			de_morgan: Result = not (not Current and then not other)
		end; -- infix "or else"
		
	infix "xor" (other: BOOLEAN): BOOLEAN is
	-- Boolean exclusive or with other
		do
			if item then
				Result := not other
			else
				Result := other
			end; 
		ensure
			definition: Result = ((Current or other) and not (Current and other))
		end; -- infix "xor"
				
invariant
	
	involutive_negation: is_equal(not not Current); 
	non_contradiction: not(Current and not Current);
	completeness: Current or not Current

end -- BOOLEAN
