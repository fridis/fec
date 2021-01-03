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

class MY_STRINGS

-- this implements a bijective function STRING <--> INTEGER. This saves memory,
-- since double strings are stored only once, and it allows fast comparison 
-- of strings using "=", "<=",... with integer operands.

creation
	make

--------------------------------------------------------------------------------

feature { NONE }

	string_list: LIST[MY_STRING];
	
	string_array: PS_ARRAY[STRING,MY_STRING];

	first_string: INTEGER is -1_000_000_000; -- this is added to the index of
	                                         -- a string in string_list to catch the
	                                         -- case of an "@" with illegal index
	                                         -- NOTE: This does not work for more
	                                         -- than 999_999_999 strings!
	 
--------------------------------------------------------------------------------

	make is 
		do
			!!string_list.make;
			!!string_array.make;
		end; -- make
		
--------------------------------------------------------------------------------

feature { ANY }

	get_id, infix "#" (of: STRING): INTEGER is
	-- get id of this string. The result is never 0, so 0 can be used to represent
	-- the Void string.
		local
			my_string: MY_STRING;
			new_string: STRING;
		do
			if of /= Void then
				my_string := string_array.find(of);
				if my_string=Void then
memstats(452);
					!!new_string.make_from_string(of);
memstats(453);
					!!my_string.make(new_string,string_list.count + 1 + first_string);
					string_list.add(my_string);
					string_array.add(my_string);
				end;
				Result := my_string.id;
			end;
		ensure
			(of = Void) = (Result = 0);
			of /= Void implies Result < 0 and of.is_equal(string(Result));
		end -- of
	
	string, infix "@" (id: INTEGER): STRING is
	-- get string with this number
		require
			is_valid_id(id) or id = 0;
		do
			if id /= 0 then
				Result := (string_list @ (id - first_string)).key;
			end;
		ensure
			(id = 0) = (Result = Void)
		end; -- infix "@"

	is_valid_id (id: INTEGER): BOOLEAN is
		do
			Result := id > first_string and (id - first_string) <= string_list.count;
		end; -- is_valid_id

--------------------------------------------------------------------------------

end -- MY_STRINGS
