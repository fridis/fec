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

	description: "Sequences of characters, accessible through integer %
	             %indices in a contiguous range."
	
	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
class STRING

inherit
	COMPARABLE
		redefine
			is_equal, 
			copy,
			out
		end;

creation
	make, 
	make_from_string
		
feature -- Initialization

	from_c (c_string: POINTER) is
	-- Reset contents of string from contents of c_string,
	-- a string created by some external C function.
		local
			len: INTEGER;
			low_level: LOW_LEVEL;
		do
			from
				len := 0
			until
				low_level.get_byte(c_string,len) = '%U'
			loop
				len := len + 1
			end;
			reallocate(len);
			low_level.memcpy(storage,c_string,len);
			count := len;
		end; -- from_c
		
	frozen make (n: INTEGER) is
	-- Allocate space for at least n characters.
		require
			non_negative_size: n >= 0;
		local
			low_level: LOW_LEVEL;
		do
			if n>0 then
				storage := low_level.malloc(n)
			end;
			capacity :=  n;
			count := 0;
		ensure
			empty_string: count = 0;
		end; -- remake
					
	make_from_string (s: STRING) is
	-- Initialize from the characters of s.
	-- (Useful in proper descendants of class STRING,
	-- to initialize a string-like object from a manifest string.)
		require
			string_existst: s /= Void
		local
			i: INTEGER;
		do
			make(s.count);
			count := s.count;
			from
				i := 1
			until
				i > count
			loop
				put(s @ i,i);
				i := i + 1;
			end; 
		end; -- make_from_string

feature -- Access

	hash_code: INTEGER is
	-- Hash code value
		local
			i: INTEGER;
		do
			from
				i := 1;
				Result := 231;
			until
				i > count
			loop
				Result := 32*Result + item(i).code;
				if Result >= 2097152 then
					Result := (Result // 2097152 + Result) \\ 2097152;
				end;
			end;
		end; -- hash_code
		
	index_of (c: CHARACTER; start:INTEGER): INTEGER is
	-- Position of first occurrence of c at or after start;
	-- 0 if none
		require
			start_large_enough: start >= 1;
			start_small_enough: start <= count;
		do
			from
				Result := start
			until
				Result > count or else item(Result) = c
			loop
				Result := Result + 1;
			end;
			if Result > count then
				Result := 0
			end;
		ensure
			non_negative_result: Result >= 0;
			at_this_position: Result > 0 implies item(Result) = c;
			-- none_before: For every i in start..Result-1: item(i) /= c
			-- zero_iff_absent: (Result = 0) = For every i in start..count: item(i) /= c
		end; -- index_of
	
	item, infix "@" (i: INTEGER): CHARACTER is
	-- Character at position i
		require
			good_key: valid_index(i)
		local
			low_level: LOW_LEVEL;
		do
			Result := low_level.get_byte(storage,i-1);
		end; -- item
		
	substring_index (other: STRING; start: INTEGER): INTEGER is
	-- Position of first occurrence of other at or after start; 
	-- 0 if none.
		require
			start_large_enough: start >= 1;
			start_small_enough: start <= count;
			string_existst: other /= Void
		local
			i,s: INTEGER;
		do
			from
				s := start;
			until
				Result /= 0 or (s + other.count - 1) > count
			loop
				from
					i := 1
				until
					i > other.count or else
					item(s + i - 1) /= other @ i
				loop
					i := i + 1;
				end;
				if i > other.count then
					Result := s;
				else
					s := s + 1
				end;
			end; 
		end; -- substring_index
		
feature -- Measurement

	count: INTEGER;
	-- Actual number of characters making up the string
	
	occurrences(c: CHARACTER): INTEGER is
	-- Number of times c appears in the string
		local
			i: INTEGER;
		do
			from
				i := 1;
			until
				i > count
			loop
				if item(i) = c then
					Result := Result + 1;
				end; 
				i := i + 1;
			end; 
		ensure
			non_negative_occurrences: Result >= 0
		end; -- occurrences
		
feature -- Comparison

	is_equal (other: like Current): BOOLEAN is
	-- Is string made of same character sequence as other?
		local
			i: INTEGER;
		do
			if count = other.count then
				from
					i := 1
				until
					i > count or else item(i) /= other.item(i)
				loop
					i := i + 1;
				end;
				Result := i > count
			end;
		end; -- is_equal
		
	infix "<" (other: STRING): BOOLEAN is
	-- is string lexicographically lower than other?
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > count or else
				i > other.count or else
				item(i) /= other.item(i)
			loop
				i := i + 1;
			end; 
			if i > count then
				Result := count < other.count
			elseif i > other.count then
				Result := false
			else
				Result := item(i) < other.item(i);
			end;
		end; -- infix "<"			
			
feature -- Status report

	empty: BOOLEAN is
	-- Is string empty?
		do
			Result := count = 0;
		end; -- empty	
			
	valid_index (i: INTEGER): BOOLEAN is
	-- Is i within the bounds of the string?
		do
			Result := i >= 1 and i <= count;
		end; -- valid_index
			
feature -- Element change

	append_boolean (b: BOOLEAN) is
	-- Append the string representation of b at end.
		do
			if b then
				append("true");
			else
				append("false");
			end;
		end; -- append_boolean
		
	append_character (c: CHARACTER) is
	-- Append c at end.
		do
			if count=capacity then
				if count<5 then -- nyi: use max
					reallocate(10)
				else
					reallocate(2*count)
				end;
			end;
			count := count + 1;
			put(c,count);
		ensure
			item_inserted: item(count) = c
			one_more_occurrence: Occurrences (c) = old occurrences (c) + 1
		end; -- append_character
		
	append_double (d: DOUBLE) is
	-- Append the string representation of d at end.
		local
			r: DOUBLE;
			i: INTEGER;
		do
			r := d;
			if r<0 then
				append_character('-');
				r := -r;
			end;
			from
				i := 1
			until
				r < 10
			loop
				r := r / 10;
				i := i + 1;
			end;
			from
			until
				i <= -8 or else (r=0 and i <= 0)
			loop
				if i=0 then 
					append_character('.');
				end;
				append_character("0123456789" @ (r.floor+1));
				r := (r - r.truncated_to_integer) * 10;
				i := i - 1;
			end;
		end; -- append_double

	append_real (r: REAL) is
	-- Append the string representation of r at end.
		do
			append_double(r);
		end; -- append_real

	append_integer (i: INTEGER) is
	-- Append the string representation of i at end.
		do
			if i<0 then
				if i<-2_147_483_647 then -- nyi: use Minimum_integer
					append_string("-2147483648")
				else
					append_character('-'); 
					append_integer(-i);
				end;
			else
				if i>=10 then
					append_integer(i // 10);
				end;
				append_character((('0').to_integer + i \\ 10).to_character);
			end;
		end; -- append_integer

	append, append_string (s: STRING) is
	-- Append a copy of s, if not void, at end.
		require
			string_exists: s /= Void;
		local
			i, old_count: INTEGER;
		do
			if capacity < count + s.count then
				reallocate(count + s.count);
			end; 
			from
				i := s.count;
				old_count := count;
				count := count + s.count;
			until
				i < 1
			loop
				put(s @ i,old_count + i);
				i := i - 1;
			end; 
		ensure 
			count = old count + s.count;
			-- appended: for every i in 1..s.count,
			--   item(old count + i) = s.item(i)
		end -- append_string
	
	fill (c: CHARACTER) is
	-- Replace every character with c.
		local
			i: INTEGER;
		do
			from
				i := 1
			until
				i > count
			loop
				put(c,i);
				i := i + 1;
			end; 
		ensure
			-- allblank: For every i in 1..count, item(i) = c
		end; -- fill
		
	head (n: INTEGER) is
	-- Remove all characters except for the first n; 
	-- do nothing if n >= count.
		require
			non_negative_argument: n >= 0
		do
			if n < count then
				count := n;
			end;
		ensure
			new_count: count = n.min(old count);
			-- first_kept: For every i in 1..count: item(i) = old item(i);
		end; -- head
		
	insert (s: STRING; i: INTEGER) is
	-- Add s to the left of position i.
		require
			string_exists: s /= Void;
			index_small_enough: i <= count;
			index_large_enough: i > 0;
		local
			j: INTEGER;
		do
			if capacity < count + s.count then
				reallocate(count + s.count);
			end; 
			count := count + s.count;
			from
				j := count
			until
				j < i
			loop
				put(item(j),j+s.count);
				j := j - 1;
			end;
			from 
				j := 1
			until
				j > s.count
			loop
				put(s @ j,i + j - 1);
				j := j + 1;
			end;
		ensure
			new_count: count = old count + s.count;
		end; -- insert

	insert_character (c: CHARACTER; i: INTEGER) is
	-- Add c to the left of position i.
		local
			j: INTEGER;
		do
			if count = capacity then
				if count < 5 then -- nyi: use max
					reallocate(10);
				else
					reallocate(2*count)
				end;
			end;
			count := count + 1;
			from
				j := count
			until
				j < i
			loop
				put(item(j),j+1);
				j := j - 1;
			end;
			put(c,i);
		end; -- insert_character

	left_adjust is
	-- Remove leading white space.
		local
			i: INTEGER;
		do
			from 
				i := 1
			until
				i > count or else item(i) /= ' '
			loop
				i := i + 1;
			end;
			tail(count-i+1);
		ensure
			new_count: (count /= 0) implies (item(1) /= ' ');
		end; -- left_adjust
		
	put (c: CHARACTER; i: INTEGER) is
	-- Replace character at position i by c.
		require
			good_key: valid_index(i);
		local
			low_level: LOW_LEVEL;
		do
			low_level.put_byte(storage,i-1,c);
		ensure
			insertion_done: item(i) = c;
		end; -- put
		
	put_substring (s: STRING; start_pos, end_pos: INTEGER) is
	-- Copy the characters of s to positions start_pos .. end_pos
		do
			-- nyi: (so einen Quatsch implementier ich nicht)
		end; -- put_substring
		
	right_adjust is
	-- remove trailing white space.
		do
			from
			until
				count = 0 or else item(count) /= ' '
			loop
				count := count - 1;
			end;
		ensure
			new_count: (count /= 0) implies (item(count) /= ' ');
		end; -- right_adjust
		
	tail (n: INTEGER) is
	-- Remove all characters except for the last n; 
	-- do nothing if n >= count
		require
			non_negative_argument: n >= 0;
		local
			i: INTEGER;
		do
			if n < count then
				from
					i := 1
				until
					i > n
				loop
					put(item(i+(count-n)),i);
					i := i + 1;
				end;
				count := n;
			end;
		ensure
			new_count: count = n.min(old count);
		end; -- tail

feature -- Removal

	remove (i: INTEGER) is
	-- Remove the i-th character.
		require
			index_small_enough: i <= count;
			index_large_enough: i > 0;
		local
			j: INTEGER;
		do
			from
				j := i
			until
				j = count
			loop
				put(item(j+1),j);
				j := j + 1;
			end; 
			count := count - 1;
		ensure
			new_count: count = old count - 1 
		end; -- remove
		
	wipe_out is
	-- Remove all characters
		do 
			count := 0;
		ensure
			empty_string: count = 0; 
			weiped_out: empty;
		end; -- wipe_out
		
feature -- Resizing

	resize (newsize: INTEGER) is
	-- Rearrange string so that it can accommodate at least newsize characters.
	-- Do not lose any previously entered character.
		require
			new_size_non_negative: newsize >= 0;
		do
			if newsize > capacity then
				reallocate(newsize);
			end;
		end; -- resize
		
feature -- Conversion

	to_boolean: BOOLEAN is
		do
			Result := is_equal("true") or is_equal("TRUE");
		end; -- to_boolean
		
-- nyi: to_double: DOUBLE
-- nyi: to_real: REAL

	to_integer: INTEGER is
		local
			i: INTEGER;
			neg: BOOLEAN;
		do 
			Result := 0;
			inspect item(1)
			when '+' then neg := false; i := 2
			when '-' then neg := true;  i := 2
			else
				neg := false
				i := 1;
			end;
			from
				i := 1
			until
				i > count
			loop
				inspect item(i)
				when '0'..'9' then
					Result := 10*Result + item(i).code - ('0').code
				else
				end;
				i := i + 1;
			end;
			if neg then 
				Result := - Result
			end;
		end; -- to_integer
		
	to_lower is
	-- Convert to lower case.
		local
			i: INTEGER;
			c: CHARACTER;
		do
			from
				i := 1
			until
				i > count
			loop
				c := item(i);
				if c>='A' and then c<='Z' then
					put((c.code + 32).to_character,i);
				end;
				i := i + 1;
			end;
		end; -- to_lower
		
	to_upper is
	-- Convert to upper case.
		local
			i: INTEGER;
			c: CHARACTER;
		do
			from
				i := 1
			until
				i > count
			loop
				c := item(i);
				if c>='a' and then c<='z' then
					put((c.code - 32).to_character,i);
				end;
				i := i + 1;
			end;
		end; -- to_upper
		
	to_external: POINTER is
		local
			low_level: LOW_LEVEL;
		do
			Result := low_level.malloc(count+1);
			low_level.memset(Result,'%U',count+1);
			low_level.memcpy(Result,storage,count);
		end;

feature -- Duplication

	copy (other: like Current) is
	-- Reinitialize by copying the characters of other. 
	-- (This is also used by clone.)
		do
			make_from_string(other);
		ensure then
			new_result_count: count = other.count;
			-- same_characters: For every i in 1..count,
			--   item(i) = other.item(i);
		end; -- copy
		
	substring (n1,n2: INTEGER): STRING is
	-- Copy of substring containing all characters at indices
	-- between n1 and n2
		require
			meaningful_origin: 1 <= n1;
			meaningful_interfal: n1 <= n2;
			maningful_end: n2 <= count;
		local
			i: INTEGER;
		do
			!!Result.make(n2-n1+1);
			from
				i := n1
			until
				i > n2
			loop
				Result.append_character(item(i));
				i := i + 1;
			end; 
		ensure
			new_result_count: Result.count = n2 - n1 + 1;
			-- original_characters: For every i in 1..n2-n1+1, 
			--   Result.item(i) = item(n1+i-1);
		end; -- substring
		
feature -- Output

	out: STRING is
	-- Printable representation
		do
			Result := Current;
		end; -- out

feature -- Convenient non-standard routines

	infix "|", concat (other: STRING): STRING is
	-- concatenate Current and other
	-- ex: file_name := "STRING" | ".e"
		do
			!!Result.make(count+other.count);
			Result.copy(Current);
			Result.append(other);
		end; -- infix "|"
		
	infix "^" (n: INTEGER): STRING is
	-- concatenate Current n times with itself
	-- ex: to get 100 blanks,  use (" ")^100.
		require
			n >= 0;
		local
			i,j: INTEGER;
		do
			!!Result.make(n*count);
			from
				i := 1
			until
				i > n
			loop
				Result.append(Current);
				i := i + 1;
			end;
		end; -- infix "^"
			
feature { NONE } 

	storage: POINTER;
	
	capacity: INTEGER;
	
	reallocate (new_capacity: INTEGER) is
		local
			mem: LOW_LEVEL;
		do
			if capacity < new_capacity then
				storage := mem.realloc(storage,new_capacity);
				capacity := new_capacity;
			end;
		end; -- reallocate

	make_from_mem(adr: POINTER; len: INTEGER) is
	-- this is called automatically by the compiler
		local
			low_level: LOW_LEVEL;
		do
			capacity := len;
			count := len;
			if len>0 then
				storage := low_level.malloc(len);
				low_level.memcpy(storage,adr,len);
			end;
		end; -- make_from_mem

end -- STRING
