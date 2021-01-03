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

class MY_STRING

-- This class is used by MY_STRINGS to store string in an PS_ARRAY. 

inherit
	SORTABLE[STRING];

creation { MY_STRINGS }
	make

--------------------------------------------------------------------------------
	
feature { MY_STRINGS }

--	key: STRING;   -- inherited: characters of this string

	id: INTEGER;   -- unambiguous id for this string
	
--------------------------------------------------------------------------------

feature { NONE }

	make (new_string: STRING; new_id: INTEGER) is 
		do
			key := new_string;
			id := new_id;
		end; -- make

--------------------------------------------------------------------------------
	
end -- MY_STRING
