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

	description: "Access to arguments%
	             %Inherit ARGUMENTS to use these features."
	
	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
class ARGUMENTS

feature 

	argument_count: INTEGER is
		local
			low_level: LOW_LEVEL;
		do
			Result := low_level.argc-1;
		end; -- argument_count
	
	argument (num: INTEGER): STRING is
		require
			num >= 0;
			num <= argument_count;
		local
			low_level: LOW_LEVEL;
		do
			!!Result.make(0);
			Result.from_c(low_level.eiffel_get_arg(num));
		end; -- argument
	
	command_name: STRING is
		do
			Result := argument(0);
		ensure
			definition: Result.is_equal(argument(0))
		end; -- command_name
	
end -- ARGUMENTS
