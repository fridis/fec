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

	description: "Facilities for tuning up the garbage collection %
	             %machanism. This class may be used as ancestor by classes %
	             %needing its facilities."

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
class MEMORY

feature -- Status report

	collecting: BOOLEAN is
	-- Is garbage collection enabled?
		false;

feature -- Status setting

	collection_off is
	-- Disable garbage collection.
		do
		end; -- collection_off
		
	collection_on is
	-- Enable garbage collection.
		do
			-- nyi: no gc mechanism implemented so far
		end; -- collection_on

feature -- Removal

	dispose is
	-- Action to be executed just before garbage collection 
	-- reclaims an object.
	-- Default version does nothng; redefine in descendants
	-- to perfom specific dispose actions. Thos actions
	-- should only take care of freeing external resources;
	-- they should not perform remote calls on other objects
	-- since these may also be dead and recleimed.
		do
		end; -- dispose

	full_collect is
	-- Force a full collection cycle if garbage 
	-- collection is enabled; do nothing otherwise
		do
			-- nyi
		end; -- full_collect
		
end -- MEMORY
