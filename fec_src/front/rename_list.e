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

class RENAME_LIST

inherit
	SCANNER_SYMBOLS;
	LIST[RENAME_PAIR]
	rename
		make as list_make
	end;

creation
	parse, clear
	
feature { ANY }

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Rename_list = {Rename_pair "," ...}.
	-- Rename_pair = Feature_name "as" Feature_name
		local
			rename_pair: RENAME_PAIR; 
		do	
			list_make;
			if s.first_of_feature_name then
				from
memstats(216);
					!!rename_pair.parse(s);
					add(rename_pair);
				until
					s.current_symbol.type /= s_comma
				loop
					s.next_symbol;
memstats(217);
					!!rename_pair.parse(s);
					add(rename_pair);
				end;	
			end;
		end; -- parse_rename	

	clear is
	-- create an empty list
		do
			list_make;
		end;  -- clear
			
--------------------------------------------------------------------------------

	clear_all_used is
		local
			i: INTEGER; 
		do
			from
				i := 1;
			until
				i > count
			loop
				item(i).clear_used;
				i := i + 1
			end;
		end; -- clear_all_used

	get_rename (name: INTEGER): INTEGER is
	-- sucht nach Eintrag in Rename-Liste fŸr name. Wird dieser gefunden, so
	-- wird er als benutzt markiert und Result auf den neuen Namen gesetzt. 
	-- ansonsten wird Result auf name gesetzt.
		require
			name /= 0
		local
			i: INTEGER; 
		do
			from
				i := 1;
			until
				i > count or else
				item(i).original_name.name = name
			loop
				i := i + 1 
			end;
			if i > count then
				Result := name
			else
				Result := item(i).new_name.name;
				item(i).set_used;
			end;
		end; -- get_rename	 
	
	check_all_used is 
		local
			i: INTEGER;
		do
			from
				i := 1;
			until
				i > count
			loop
				if not item(i).used then
					item(i).position.error(msg.vhrc1);
				end;
				i := i + 1
			end;
		end; -- check_all_used
		
--------------------------------------------------------------------------------

end -- RENAME_LIST
