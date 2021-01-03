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

class VOID_CONSTANT

-- This is used as the result of GENERAL.Void.

inherit
	INTEGER_CONSTANT
		rename
			make as integer_make
		redefine
			type
		end;
	
creation
	make
		
--------------------------------------------------------------------------------
	
feature { ANY }

--------------------------------------------------------------------------------

	make is 
		do
			integer_make(0);
		end; -- make
				
--------------------------------------------------------------------------------
		
	type : TYPE is 
	-- sebug: dies sollte once-feature sein, das funkt aber mit SE nicht
		do
			Result := globals.type_none; 
		end; -- type

--------------------------------------------------------------------------------
		
end -- VOID_CONSTANT
