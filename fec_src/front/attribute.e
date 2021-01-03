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

class ATTRIBUTE

inherit
	SCANNER_SYMBOLS;
	FEATURE_VALUE
		redefine
			is_variable_attribute,
			is_attribute
		end;
	COMPILE_READ_ATTRIBUTE;
	
creation
	make

--------------------------------------------------------------------------------
	
feature { ANY }
	
--------------------------------------------------------------------------------

	make is
		do
		end; -- make
		
--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	is_variable_attribute : BOOLEAN is
		do
			Result := true;
		end; -- is_attribute

	is_attribute : BOOLEAN is
		do
			Result := true;
		end; -- is_attribute
	
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE) is
		do 
		end; -- validity

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
	-- create routine that returns this variable attribute
		local
			src_offset: INTEGER; 
			src: OFFSET_INDIRECT_VALUE;
		do
			src_offset := code.class_code.actual_class.attribute_offsets @ code.fi.number;
			src := recycle.new_off_ind;
			src.make(src_offset,code.current_local);
			compile_attribute_access_routine(code,src);
		end; -- compile

--------------------------------------------------------------------------------
	
end -- ATTRIBUTE
