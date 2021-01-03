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

class SET

-- Implements arbritrarily sized Sets of positive integers and their
-- basic operations.

inherit
	ANY
		redefine
			is_equal,
			copy
		end; 

creation 
	make

--------------------------------------------------------------------------------
	
feature { ANY }

	make(new_max: INTEGER) is
		require
			new_max>=0
		do
			max := new_max;
			if bits=Void or else bits.upper<new_max then
memstats(421); 
				!!bits.make(1,new_max)
			else
				clear;
			end;
		ensure
			max=new_max;
			bits.upper >= new_max;
			is_empty;
		end; -- make

feature { SET }

	bits: ARRAY[BOOLEAN];

--------------------------------------------------------------------------------

feature { ANY }

	max: INTEGER;

--------------------------------------------------------------------------------

-- single element modification

	include(i: INTEGER) is
		require
			i>=1; 
			i<=max
		do
			bits.put(true,i);
		ensure
			has(i)
		end; -- include

	exclude(i: INTEGER) is
		require
			i>=1; 
			i<=max
		do
			bits.put(false,i);
		ensure
			not has(i)
		end; -- exclude
		
--------------------------------------------------------------------------------

-- state

	has(i: INTEGER): BOOLEAN is
		require
			i>=1; 
			i<=max
		do
			Result := bits @ i;
		end; -- has

	is_empty: BOOLEAN is
		local
			i: INTEGER; 
		do
			from
				i := 1;
			until
				i > max or else bits @ i
			loop
				i := i + 1
			end;
			Result := i>max;
		ensure
			-- Result = for all i: 1<=i<=max implies not has(i)
		end; -- is_empty

	first: INTEGER is
		do
			from
				Result := 1
			until
				Result > max or else bits @ Result
			loop
				Result := Result + 1;
			end;
			if Result > max then
				Result := - 1
			end;
		ensure
			Result >= 0 implies has(Result); 
			-- for all i: 1<=i<Result implies not has(i);
			Result < 0 implies is_empty 
		end; -- first

	last: INTEGER is
		do
			from
				Result := max
			until
				Result < 1 or else bits @ Result
			loop
				Result := Result - 1;
			end;
			if Result < 1 then
				Result := - 1
			end;
		ensure
			Result >= 0 implies has(Result); 
			-- Result >= 0 implies for all i: Result<i<=max implies not has(i);
			Result < 0 implies is_empty 
		end; -- last

	pop_count : INTEGER is
	-- population count
		local
			i: INTEGER; 
		do
			from
				i := 1
			until
				i > max
			loop
				if bits @ i then
					Result := Result + 1
				end;
				i := i + 1
			end;
		ensure
			-- Result = sum of i=1..max: 1, if has(i); 0, otherwise 
		end; -- pop_count

	is_equal(other: like Current): BOOLEAN is
		local
			i: INTEGER;
		do
			from
				i := 1;
				Result := true;
			until
				i>max or i>other.max or not Result
			loop
				Result := (bits @ i) = (other.bits @ i);
				i := i + 1
			end;
			if Result then
				from
				until
					i>max or not Result
				loop
					Result := not (bits @ i);
					i := i + 1
				end;
				from
				until
					i>other.max or not Result
				loop
					Result := not (other.bits @ i);
					i := i + 1
				end;
			end;
		ensure then
			-- Result = for all i: 1<=i<=max implies (has(i) = other.has(i))
		end; -- is_empty
				
--------------------------------------------------------------------------------
	
-- modify multiple elements
	
	clear is
		local
			i: INTEGER;
		do
			from 
				i := 1
			until
				i > max
			loop
				bits.put(false,i);
				i := i + 1 
			end;
		ensure
			is_empty
		end; -- clear		
		
	copy (other: like Current) is
		local
			i: INTEGER;
		do
			if max<other.max then
				make(other.max)
			end;
			from 
				i := 1
			until
				i > other.max
			loop
				bits.put(other.bits @ i,i);
				i := i + 1 
			end;
			from 
			until
				i > max
			loop
				bits.put(false,i);
				i := i + 1 
			end;
		end; -- copy
	
	union(other: SET) is
		require
			other.max = max
		local
			i: INTEGER;
		do
			from 
				i := 1
			until
				i > max
			loop
				bits.put(bits @ i or else other.bits @ i,i);
				i := i + 1 
			end;
		ensure
			-- for all i: 1<=i<=max implies (has(i) = (has(i) or other.has(i)))
		end; -- union
	
	dissection(other: SET) is
		require
			other.max = max
		local
			i: INTEGER;
		do
			from 
				i := 1
			until
				i > max
			loop
				bits.put(bits @ i and then other.bits @ i,i);
				i := i + 1 
			end; 
		ensure
			-- for all i: 1<=i<=max implies (has(i) = has(i) and other.has(i))
		end; -- dissection
	
	subtraction(other: SET) is
		require
			other.max = max
		local
			i: INTEGER;
		do
			from 
				i := 1
			until
				i > max
			loop
				bits.put(bits @ i and then not (other.bits @ i),i);
				i := i + 1 
			end; 
		ensure
			-- for all i: 1<=i<=max implies (has(i) = has(i) and not other.has(i))
		end; -- subtraction

	complement is
		local
			i: INTEGER;
		do
			from 
				i := 1
			until
				i > max
			loop
				bits.put(not (bits @ i),i);
				i := i + 1 
			end; 
		ensure
			-- for all i: 1<=i<=max implies (has(i) = not has(i))
		end; -- complement
		
--------------------------------------------------------------------------------

-- calculation

	infix "|" (other: SET): SET is
		require
			other.max = max
		local
			i: INTEGER;
		do
			!!Result.make(max);
			from 
				i := 1
			until
				i > max
			loop
				Result.bits.put(bits @ i or else other.bits @ i,i);
				i := i + 1 
			end;
		ensure
			-- for all i: 1<=i<=max implies (Result.has(i) = has(i) or other.has(i))
		end; -- infix "|"
	
	infix "&" (other: SET): SET is
		require
			other.max = max
		local
			i: INTEGER;
		do
			!!Result.make(max);
			from 
				i := 1
			until
				i > max
			loop
				Result.bits.put(bits @ i and then other.bits @ i,i);
				i := i + 1 
			end; 
		ensure
			-- for all i: 1<=i<=max implies (Result.has(i) = has(i) and other.has(i))
		end; -- infix "&"
	
	infix "-" (other: SET): SET is
		require
			other.max = max
		local
			i: INTEGER;
		do
			!!Result.make(max);
			from 
				i := 1
			until
				i > max
			loop
				Result.bits.put(bits @ i and then not (other.bits @ i),i);
				i := i + 1 
			end; 
		ensure
			-- for all i: 1<=i<=max implies (Result.has(i) = has(i) and not other.has(i))
		end; -- infix "-"

	prefix "-": SET is
		local
			i: INTEGER;
		do
			!!Result.make(max);
			from 
				i := 1
			until
				i > max
			loop
				Result.bits.put(not (bits @ i),i);
				i := i + 1 
			end; 
		ensure
			-- for all i: 1<=i<=max implies (Result.has(i) = not has(i))
		end; -- prefix "-"

--------------------------------------------------------------------------------

end -- SET
