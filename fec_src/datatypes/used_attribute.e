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

class USED_ATTRIBUTE

-- This class implements a single single boolean attributes 'used' and
-- features to set and use it. Inherit this class to have this attribute.
--
-- The main purpose of this attribute is to check validity constraints
-- that require all elements of feature- or rename-lists to be used and
-- not to be used twice.

--------------------------------------------------------------------------------

feature { ANY }

	used: BOOLEAN; -- wurde dieser Clause auch verwendet
	
	set_used is 
		do
			used := true;
		end; -- set_used
	
	clear_used is 
		do
			used := false;
		end; -- clear_used
		
--------------------------------------------------------------------------------

end -- USED_ATTRIBUTE
