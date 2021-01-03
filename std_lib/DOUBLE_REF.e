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
	
	description: "Reference class for DOUBLE"

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
class DOUBLE_REF

inherit
	NUMERIC
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

	item: DOUBLE;
	
	hash_code: INTEGER is
	-- Hash code value
		local
			d: DOUBLE;
			platform: expanded PLATFORM;
		do
			d := item;
			if d < 0 then
				d := - d
			end;
			from
			until
				d <= platform.Maximum_integer 
			loop
				d := d / platform.Maximum_integer;
			end;
			Result := d.truncated_to_integer;
		end; -- hash_code
		
	one: DOUBLE_REF is
	-- Neutral element for "*" and "/"
		local
			d: DOUBLE;
		do
			d := 1;
			Result := d;
		end; -- one
		
	zero: DOUBLE_REF is
	-- Neutral element for "+" and "-"
		local
			d: DOUBLE;
		do
			d := 0;
			Result := d;
		end; -- zero

feature -- Status report

	divisible (other: DOUBLE_REF): BOOLEAN is
	-- May current object be divided by other?
		do
			Result := other.item /= 0.0;
		end; -- divisible
		
	exponentiable (other: DOUBLE_REF): BOOLEAN is
	-- May current object be elevated to the power of other?
		do
			Result := other.item >= 0.0
		end; -- exponentiable
		
feature -- Basic operations
		
	infix "+" (other: DOUBLE_REF): DOUBLE_REF is
	-- Sum with other.
		do
			Result := item + other.item;
		end; -- infix "+"
		
	infix "-" (other: DOUBLE_REF): DOUBLE_REF is
	-- Result of subtracting other.
		do
			Result := item - other.item;
		end; -- infix "-"
		
	infix "*" (other: DOUBLE_REF): DOUBLE_REF is
	-- Product by other
		do
			Result := item * other.item;
		end; -- infix "*"
		
	infix "/" (other: DOUBLE_REF): DOUBLE_REF is
	-- Division by other
		do
			Result := item / other.item;
		end; -- infix "/"
	
	infix "^" (other: DOUBLE_REF): DOUBLE_REF is
	-- Current real to the power other
		do -- nyi
		end; -- infix "^"
		
	prefix "+" : DOUBLE_REF is
	-- Unary plus
		do
			Result := item;
		end; -- prefix "+"
		
	prefix "-" : DOUBLE_REF is
	-- Unary minus
		do
			Result := - item;
		end; -- prefix "-"
		
feature -- Comparison

	infix "<" (other: DOUBLE_REF): BOOLEAN is
		do
			Result := item < other.item;
		end; -- infix "<"

	infix "<=" (other: DOUBLE_REF): BOOLEAN is
		do
			Result := item <= other.item;
		end; -- infix "<=";

	infix ">" (other: DOUBLE_REF): BOOLEAN is
		do
			Result := item > other.item;
		end; -- infix ">";

	infix ">=" (other: DOUBLE_REF): BOOLEAN is
		do
			Result := item >= other.item;
		end; -- infix ">=";
	
feature -- Output
		
	out: STRING is	
		do
			!!Result.make(20);
			Result.append_double(item);
		end; -- out
		
end -- DOUBLE_REF
