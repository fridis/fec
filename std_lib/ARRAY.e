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

	description: "Sequences of values, all of the same type or of a %
	             %conforming one, accessible through indices in a %
	             %contiguous interval."
	
	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
	note: "The Eiffel compiler assumes that this class has the % 
	      %features put, item, infix %"@%", element_size and % 
	      %storage exactly as they are specified here. If they %
	      %are changed or removed the compiler will fail.";

class ARRAY[G]

inherit
	ANY
		redefine
			is_equal,
			copy
		end;

creation
	make, 
	make_from_array
	
feature -- Initialization

	make (minindex, maxindex: INTEGER) is
	-- Allocate array; set index interval to
	-- minindex..maxindex; set all values to default.
	-- (Make array empty if minindex > maxindex.)
		local
			c, array_size: INTEGER;
			new_storage: POINTER;
			low_level: LOW_LEVEL;
		do
			upper := maxindex; 
			lower := minindex; 
			c := count;
			if c>0 then
				array_size := c * element_size;
				new_storage := low_level.malloc(array_size);
				low_level.memset(new_storage,'%U',array_size);
				new_storage := (new_storage.to_integer - (lower * element_size)).to_pointer;
			end;
			storage := new_storage;
		ensure
			no_count: (minindex > maxindex) implies (count = 0);
			count_constraint: (minindex <= maxindex) implies (count = maxindex - minindex + 1);
		end; -- make

	make_from_array (a: ARRAY[G]) is
	-- Initialize from the items of a. 
	-- (Useful in proper descendants of class ARRAY,
	-- to initialize an array-like object from a manifest array.)
		local
			i: INTEGER;
		do
			make(a.lower,a.upper);
			from 
				i := lower
			until
				i = upper
			loop
				put(a @ i,i);
				i := i + 1;
			end;
		end; -- make_from_array

feature -- Access

	entry (i: INTEGER): G is
	-- Entry at index i, if in index interval
	-- (Redefineable synonym for item and infix "@")
		require
			good_key: valid_index(i);
		do
			Result := item(i);
		end; -- entry
		
	frozen infix "@", item (i: INTEGER): G is
	-- Entry at index i, if in index interval
		require
			good_key: valid_index(i);
		do -- this is implemented automatically by the compiler
		end; -- infix "@", item

feature -- Measurement

	count: INTEGER is
	-- Number of available indices
		do
			if lower <= upper then
				Result := upper - lower + 1
			end;
		end; -- count

	lower: INTEGER; -- Minimum index
	
	upper: INTEGER; -- Maximum index

feature -- Comparison

	is_equal (other: like Current): BOOLEAN is
		local
			i: INTEGER;
		do
			if lower = other.lower and upper = other.upper then
				from
					i := lower
				until
					i > upper or 
					not item(i).is_equal(other @ i)
				loop
					i := i + 1;
				end;
				Result := i > upper
			end;
		end; -- is_equal

feature -- Status report

	valid_index (i: INTEGER): BOOLEAN is
	-- Is i within the bounds of the array?
		do
			Result := i >= lower and i <= upper;
		end; -- valid_index

feature -- Element change

	enter (v: G; i: INTEGER) is
	-- Replace i-th entry, if in index interval, by v.
	-- (Redefinable synonym for put.)
		require
			good_key: valid_index(i);
		do
			put(v,i);
		ensure
			inserted: item(i) = v
		end; -- enter

	force (v: G; i: INTEGER) is
	-- Assign item v to i-th entry.
	-- Always applicable: resize the array if i falls out of
	-- currently defined bounds; preserve existing items.
		do
			resize(i.min(lower),i.max(upper));
			put(v,i);
		ensure
			inserted: item(i) = v;
			higher_count: count >= old count;
		end; -- force
	
	frozen put (v: G; i: INTEGER) is
	-- Replace i-th entry, if in index interval, by v.
		require
			good_key: valid_index(i);
		do -- this is implemented automatically by the compiler
		ensure
			inserted: item(i) = v
		end; -- put
		
feature -- Resizing

	resize (minindex, maxindex: INTEGER) is
	-- Rearrange array so that it can accommodate
	-- indices down to minindex and up to maxindex.
	-- Do not lose any previously entered item.
		require
			good_indices: minindex <= maxindex;
		local
			old_lower, old_upper, old_count: INTEGER;
			old_storage, new_storage: POINTER;
			array_size, old_array_size: INTEGER;
			low_level: LOW_LEVEL;
		do
			old_lower := lower;
			old_upper := upper; 
			old_count := count;
			lower := minindex.min(old_lower); 
			upper := maxindex.max(old_upper); 
			if count > old_count then
				array_size := count * element_size;
				old_array_size := old_count * element_size;
				old_storage := (storage.to_integer + old_lower * element_size).to_pointer;
				if lower = old_lower then
					new_storage := low_level.realloc(old_storage,array_size);
					low_level.memset((new_storage.to_integer + old_array_size).to_pointer,
					                 '%U',
					                 array_size - old_array_size);
				else
					new_storage := low_level.malloc(array_size);
					low_level.memset(new_storage,'%U',array_size);
					low_level.memcpy((new_storage.to_integer + (old_lower - lower) * element_size).to_pointer,
					                 old_storage,
					                 old_array_size);
				end;
				storage := (new_storage.to_integer - lower * element_size).to_pointer;
			end;
		ensure
			no_low_lost : lower = minindex.min(old lower);
			no_high_lost: upper = maxindex.max(old upper);
		end; -- resize

feature -- Conversion

	to_c: POINTER is
	-- Address of actual sequence of values, 
	-- for passing to external (non_eiffel) routines.
		do
			Result := (storage.to_integer + lower * element_size).to_pointer;
		end; -- to_c

feature -- Duplication

	copy (other: like Current) is
	-- Reinitialize by copying all the items of other.
		local
			i: INTEGER;
		do
			make(other.lower,other.upper);
			from 
				i := lower
			until
				i > upper
			loop
				put(other @ i,i);
				i := i + 1
			end;
		end -- copy

feature { NONE }

	storage: POINTER; -- pointer to array element with index 0 (even if 0 is out of bounds)

	frozen element_size: INTEGER is
		do 
			-- NOTE: unqualified calls to element_size (i.e. to any feature whose seed is element_size
			--       and whose origin is ARRAY) are inlined by the compiler, so this can easily be
			--       implemented by an unqualified call to itself. So a qualified call to element_size,
			--       that is allowed if a heir of ARRAY changes the export status of element_size,
			--       works correctly.
			Result := element_size;
		end; -- element_size

end -- ARRAY
