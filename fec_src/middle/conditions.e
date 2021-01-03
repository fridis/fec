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

class CONDITIONS

-- Condition-codes used in the intermediate code.
--
-- Inherit this class to use the constants.

feature

-- comparison between two values;
	c_equal,
 	c_not_equal, 
 	c_less, 
 	c_less_or_equal, 
 	c_greater_or_equal, 
 	c_greater: INTEGER is UNIQUE; 
 
	invert_condition (cond: INTEGER): INTEGER is
	-- Bestimmt die Umkehrung der angegebenden Bedingung
		do
			inspect cond
			when c_equal                 then Result := c_not_equal
			when c_not_equal             then Result := c_equal
			when c_less                  then Result := c_greater_or_equal
			when c_less_or_equal         then Result := c_greater
			when c_greater_or_equal      then Result := c_less
			when c_greater               then Result := c_less_or_equal
			end
		ensure
		--	cond = negate(Result)
		end -- invert_condition
		
end -- CONDITIONS
