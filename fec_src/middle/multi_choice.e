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

class MULTI_CHOICE

-- this describes one of the choices of a MULTI_SUCCESSORS object

inherit
	SORTABLE[INTEGER];

creation
	make
	
--------------------------------------------------------------------------------

feature

-- key: INTEGER;            -- geerbt, lower value
	
	lower: INTEGER is do Result := key end; 
	
	upper: INTEGER; 
	
	then_part: BASIC_BLOCK;

--------------------------------------------------------------------------------

	make (new_lower,new_upper: INTEGER; new_then_part: BASIC_BLOCK) is
		do
			key := new_lower;
			upper := new_upper;
			then_part := new_then_part;
		end; -- make

--------------------------------------------------------------------------------

end -- MULTI_CHOICE
