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

deferred class MIDDLE_CLASS_CODE

-- The code created for one class.
	
--------------------------------------------------------------------------------

feature { ANY }

	actual_class: ACTUAL_CLASS;

	machine_code: MACHINE_CODE;

	const_strings: LIST[INTEGER];  -- Ids of constant strings of this class
	const_bits: LIST[INTEGER];     -- Ids of bit constants of this class

	const_reals: LIST[REAL];       -- real and double constants of this class
	const_doubles: LIST[DOUBLE];

	add_pos_and_tag(pos: POSITION; tag: INTEGER) is
	-- Positions and Tags used for runtime messages
		do
			const_positions.add(pos);
			const_tags.add(tag);
		end; -- add_pos_and_tag
	
	const_pos_and_tag_offset: INTEGER is 
	-- offset of next pos_and_tag added, relative to const_pos_and_tags
		deferred
		end; -- const_pos_and_tag_offset

	const_pos_and_tags: INTEGER; -- Label at start of pos_and_tags entries.

feature { NONE } 

	const_positions: LIST[POSITION]; -- Positions and Tags used for runtime messages
	const_tags: LIST[INTEGER];

--------------------------------------------------------------------------------

feature { NONE }

	middle_make (new_actual_class: ACTUAL_CLASS) is 
		do
			actual_class := new_actual_class;
memstats(432);
			!!machine_code.make(new_actual_class.name);
memstats(410);
			!!const_strings.make;
memstats(411);
			!!const_bits.make;
memstats(498);
			!!const_reals.make;
memstats(499);
			!!const_doubles.make;
			!!const_positions.make;
			!!const_tags.make;
		end; -- middle_make

--------------------------------------------------------------------------------

feature { ANY }

	add_c_string(str: INTEGER) is
	-- add str as a C-string and set c_string_label and c_string_offset
	-- to point to this string.
		deferred
		end; 

	c_string_label: INTEGER;
	c_string_offset: INTEGER;

--------------------------------------------------------------------------------

end -- MIDDLE_CLASS_CODE
