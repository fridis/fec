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

class MIDDLE_LOCAL_TYPE

-- Types used in intermediate representation

creation -- creation not allowed
	
feature { ANY }

	is_reference: BOOLEAN;
	is_pointer: BOOLEAN;
	is_integer: BOOLEAN;
	is_character: BOOLEAN;
	is_boolean: BOOLEAN;
	is_real: BOOLEAN;
	is_double: BOOLEAN;
	is_expanded: BOOLEAN;
	is_bit: BOOLEAN;
	
	expanded_class: ACTUAL_CLASS;

	num_bits: INTEGER;

	is_word: BOOLEAN is
	-- is this integer, reference or pointer?
		do
			Result := is_reference or is_pointer or is_integer;
		end; -- is_word

	is_word_or_byte: BOOLEAN is
	-- is this integer, reference, pointer, character or boolean
		do
			Result := is_reference or is_pointer or is_integer or is_character or is_boolean;
		end; -- is_word_or_byte

	is_real_or_double: BOOLEAN is
		do
			Result := is_real or is_double
		end; -- is_real_or_double

feature { NONE }
	
	make_reference is
		do
			is_reference := true
		end; -- make_reference
	
	make_pointer is
		do
			is_pointer := true
		end; -- make_pointer
	
	make_integer is
		do
			is_integer := true
		end; -- make_integer
	
	make_character is
		do
			is_character := true
		end; -- make_character
	
	make_boolean is
		do
			is_boolean := true
		end; -- make_boolean
	
	make_real is
		do
			is_real := true
		end; -- make_real
	
	make_double is
		do
			is_double := true
		end; -- make_double
	
	make_expanded(actual: ACTUAL_CLASS) is
		require
			actual /= Void;
		do
			is_expanded := true;
			expanded_class := actual;
		ensure
			is_expanded
		end; -- make_expanded
	
	make_bit(n: INTEGER) is
		require
			n>=0;
		do
			is_expanded := true;
			is_bit := true;
			num_bits := n;
		ensure
			is_expanded;
			is_bit;
		end; -- make_bit

invariant

	(is_expanded and not is_bit) = (expanded_class /= Void)
	
end -- MIDDLE_LOCAL_TYPE
