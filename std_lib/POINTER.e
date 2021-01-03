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

indexing

	description: "References to objects meant to be exchanged with %
	             %non-Eiffel software."
	
	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";

expanded class POINTER

inherit
	POINTER_REF;

feature -- Conversion

	to_integer: INTEGER is
	-- Low-level conversion to the corresponding Integer-value
		do
			Result := item.to_integer;
		end; -- to_integer

	is_void: BOOLEAN is
	-- true if this is a null pointer
		do
			Result := item.to_integer = 0
		end; -- is_void

	is_not_void: BOOLEAN is
	-- true if this is not a null pointer
		do
			Result := item.to_integer /= 0
		end; -- is_not_void

end -- POINTER
