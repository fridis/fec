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

class MANIFEST_CONSTANT_VALUE

inherit
	FEATURE_VALUE
		redefine
			is_attribute,
			is_constant_attribute,
			constant_value
		end;
	PARSE_MANIFEST_CONSTANT;
	COMPILE_READ_ATTRIBUTE;

creation
	parse

--------------------------------------------------------------------------------
	
feature { ANY }

-- constant : MANIFEST_CONSTANT;   -- geerbt: die Konstante

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- parst MANIFEST_CONSTANT
		do
			parse_manifest_constant(s);
		end; -- parse

--------------------------------------------------------------------------------

	is_attribute: BOOLEAN is
		-- true for attribute or constant attribute
		do
			Result := true
		end; -- is_attribute

	is_constant_attribute: BOOLEAN is
		-- true for constant attribute
		do
			Result := true
		end; -- is_constant_attribute
		
--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE) is
		do
			constant.validity_of_constant_attribute(fi); 
		end; -- validity

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	constant_value : VALUE is
	-- von Clients dieses Attributes aufgerufen
		do
			Result := constant
		end; 

--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
	-- create routine that returns the value of this constant attribute
		do
			compile_attribute_access_routine(code,constant);
		end; -- compile

--------------------------------------------------------------------------------

end -- MANIFEST_CONSTANT_VALUE
