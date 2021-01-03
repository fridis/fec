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

deferred class FEATURE_VALUE

feature { ANY }

	is_deferred: BOOLEAN is
		do
			Result := false
		end; -- is_deferred

	is_variable_attribute: BOOLEAN is
		-- true for variable attribute
		do
			Result := false
		end; -- is_attribute

	is_attribute: BOOLEAN is
		-- true for attribute or constant attribute
		do
			Result := false
		end; -- is_attribute

	is_constant_attribute: BOOLEAN is
		-- true for constant attribute
		do
			Result := false
		end; -- is_constant_attribute
		
	has_require_else_and_ensure_then: BOOLEAN is
		do
			Result := true
		end; -- has_require_else_and_ensure_then

	validity (fi: FEATURE_INTERFACE) is
		deferred
		end; -- validity

	is_routine : BOOLEAN is
		do
			Result := false
		end; -- is_routine

	is_once : BOOLEAN is
		do
			Result := false
		end; -- is_once
		
	is_external : BOOLEAN is
		do
			Result := false
		end; -- is_external
		
	is_internal_routine : BOOLEAN is
		do
			Result := false
		end; -- is_internal_routine
		
	is_unique : BOOLEAN is
		do
			Result := false
		end; -- is_unique

	add_locals (fi: FEATURE_INTERFACE) is
	-- falls dies eine interne Routine ist, so werden die bezeichner
	-- der lokalen Variablen local_identifiers hinzugefügt.
		do
		end; -- add_locals;

feature { ANY }

	set_calls (n: INTEGER) is
		require
			is_internal_routine
		do
		end; -- set_calls

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }

	compile(code: ROUTINE_CODE) is
	-- create code for this internal routine or create a routine that
	-- returns this attribute's value.
		require
			is_internal_routine or is_attribute; 
			code /= Void
		deferred
		end -- compile

--------------------------------------------------------------------------------

	alloc_locals (code: ROUTINE_CODE) is
	-- Alloziert die Platz für die lokalen Variablen im Zwischencode
		require
			is_internal_routine
		do
		end; -- alloc_locals

--------------------------------------------------------------------------------

	constant_value : VALUE is
	-- von Clients dieses Attributes aufgerufen
		require
			is_constant_attribute
		do
			-- redefined in MANIFEST_CONSTANT_VALUE und UNIQUE_VALUE
		end; 
			
--------------------------------------------------------------------------------

end -- FEATURE_VALUE
