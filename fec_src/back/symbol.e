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

class SYMBOL

-- A linker Symbol.

inherit
	SORTABLE[INTEGER];
	
creation
	clear
	
--------------------------------------------------------------------------------

feature { ANY }

--	key: INTEGER;     -- inherited name of this symbol

feature { MACHINE_CODE }

	type: INTEGER;   -- type of this symbol

	value: INTEGER;  -- value of this symbol

	section: INTEGER;  -- section header index

--------------------------------------------------------------------------------

-- symbol types:

	stt_notype : INTEGER is 0; 
	stt_object : INTEGER is 1; 
	stt_func   : INTEGER is 2; 
	stt_section: INTEGER is 3; 
	stt_file   : INTEGER is 4; 
	
-- section header index:

	shn_abs : INTEGER is -15;
	shn_undef : INTEGER is 0;
	code_section: INTEGER is 2;
	data_section: INTEGER is 3;
	bss_section: INTEGER is 4;

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is
		do
			key := 0;
			type := 0;
			value := 0;
			section := 0;
			number := -1;
		end; -- clear

--------------------------------------------------------------------------------

feature { MACHINE_CODE }

	make_function (new_name: INTEGER; new_value: INTEGER) is
		do
			key := new_name;
			type := stt_func;
			value := new_value;
			section := code_section;
		end; -- make_function;
	
	make_object (new_name: INTEGER; new_value: INTEGER) is
		do
			key := new_name;
			type := stt_object;
			value := new_value;
			section := data_section;
		end; -- make_object
	
	make_bss (new_name: INTEGER; new_value: INTEGER) is
		do
			key := new_name;
			type := stt_object;
			value := new_value;
			section := bss_section;
		end; -- make_bss;
		
	make_abs (new_name: INTEGER; new_value: INTEGER) is
		do
			key := new_name;
			type := stt_object;
			value := new_value;
			section := shn_abs;
		end; -- make_abs
		
	make_undefined (new_name: INTEGER) is
	-- used to reference external symbols
		do
			key := new_name;
			type := stt_notype;
			value := 0;
			section := shn_undef;
		end; -- make_undefined
		
--------------------------------------------------------------------------------

feature { MACHINE_CODE }

	number: INTEGER;  -- this holds the index of this symbol in the symbol table
	                  -- of the object file.
	
	set_number(to: INTEGER) is
		do 
			number := to; 
		end; -- set_number

--------------------------------------------------------------------------------

end -- SYMBOL
