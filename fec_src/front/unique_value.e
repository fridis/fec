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

class UNIQUE_VALUE 

inherit
	SCANNER_SYMBOLS;
	FEATURE_VALUE
		redefine
			is_attribute,
			is_constant_attribute,
			is_unique,
			constant_value
		end;
	COMPILE_READ_ATTRIBUTE;
	
creation
	parse
	
creation { FEATURE_DECLARATION }
	make

--------------------------------------------------------------------------------
	
feature { ANY }

	value: INTEGER; 

	position: POSITION;

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Unique = "unique".
		require
			s.current_symbol.type = s_unique
		do
			make(s.current_symbol.position,s.parse_class);
			s.next_symbol;
		end; -- parse

	make (pos: POSITION; pc: PARSE_CLASS) is
		do
			position := pos; 
			pc.increment_unique_value;
			value := pc.unique_value;
		end; -- make

--------------------------------------------------------------------------------

	is_attribute: BOOLEAN is
		do
			Result := true
		end; -- is_attribute

	is_constant_attribute: BOOLEAN is
		-- true for constant attribute
		do
			Result := true
		end; -- is_constant_attribute

	is_unique: BOOLEAN is
		do
			Result := true
		end; -- is_unique
		
--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE) is
		do
			if fi.type = Void or else not fi.type.is_integer then
				position.error(msg.vqui1); 
			end;
		end; -- validity

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	constant_value : VALUE is
	-- von Clients dieses Attributes aufgerufen
		do
memstats(391);
			!INTEGER_CONSTANT!Result.make(value)
		end; 
		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
	-- create routine that returns the value of this constant attribute
		do
			compile_attribute_access_routine(code,constant_value);
		end; -- compile
			
--------------------------------------------------------------------------------
		
end -- UNIQUE_VALUE
