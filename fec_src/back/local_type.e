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

class LOCAL_TYPE

-- Type in intermediate code. 

inherit
	MIDDLE_LOCAL_TYPE;
	DATATYPE_SIZES;

creation
	make_reference,
	make_pointer,
	make_integer,
	make_character,
	make_boolean,
	make_real,
	make_double,
	make_expanded,
	make_bit
	
feature { ANY }

	is_storable_in_gp_register: BOOLEAN is
		do
			Result := is_reference or 
			          is_pointer or
			          is_integer or
			          is_character or
			          is_boolean;
		end; -- is_storable_in_gp_register 
		
	byte_size : INTEGER is
		do
			if     is_reference then Result := reference_size;
			elseif is_pointer   then Result := reference_size;
			elseif is_integer   then Result := integer_size;
			elseif is_character then Result := character_size
			elseif is_boolean   then Result := boolean_size;
			elseif is_real      then Result := real_size;
			elseif is_double    then Result := double_size;
			elseif is_bit then
				Result := (num_bits // 8 + 3) // 4 * 4;
			else
				Result := expanded_class.size;
			end; 
		end; -- byte_size

end -- LOCAL_TYPE
