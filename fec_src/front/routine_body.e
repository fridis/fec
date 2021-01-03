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

deferred class ROUTINE_BODY

-- Ancestor of DEFERRED_ROUTINE, INTERNAL_ROUTINE and EXTERNAL_ROUTINE
		
--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	is_deferred : BOOLEAN is 
		do 
			Result := false
		end; -- is_deferred

	is_external : BOOLEAN is 
		do 
			Result := false
		end; -- is_external

	is_internal : BOOLEAN is 
		do 
			Result := false
		end; -- is_external
				
	is_once : BOOLEAN is
		do
			Result := false
		end; -- is_once

--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE) is
		deferred
		end; -- validity

--------------------------------------------------------------------------------

	calls_currents_features: ARRAY[BOOLEAN] is
		require
			is_internal
		do 
			-- redefined in INTERNAL_ROUTINE
		end; -- calls_currents_features
	                                         
	set_calls (n: INTEGER) is
		require
			is_internal
		do 
			-- redefined in INTERNAL_ROUTINE
		end; -- set_calls
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
	-- Dies wird in INTERNAL_ROUTINE redefiniert
		require
			is_internal
		do
		end; -- compile
		
--------------------------------------------------------------------------------

end -- ROUTINE_BODY
