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

class SORTABLE [KEY -> COMPARABLE]

-- Classes that represent objects that are sortable, ie. that have
-- a compareable key that allows to build a total order of the
-- objects, should inherit this class. Rename the attribute key
-- to be meaningful in the heir's context.
--
-- SORTABLE is similar to COMPARABLE, but it often appears more 
-- accurate to write eg. "x.name < y.name" instead of "x<y". 

feature
	
	key: KEY;
	
end -- SORTABLE		
