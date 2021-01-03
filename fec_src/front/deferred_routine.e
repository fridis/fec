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

class DEFERRED_ROUTINE

inherit
	ROUTINE_BODY
		redefine
			is_deferred
		end;
	SCANNER_SYMBOLS;
	
creation
	parse
	
feature { ANY }

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Deferred = "deferred".
		require
			s.current_symbol.type = s_deferred
		do
			s.next_symbol;
		end; -- parse

--------------------------------------------------------------------------------

	is_deferred: BOOLEAN is
		do 
			Result := true
		end; -- is_deferred

--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE) is
		do
		end; -- validity

--------------------------------------------------------------------------------
		
end -- DEFERRED_ROUTINE	
