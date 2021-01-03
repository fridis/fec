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

class NEW_EXPORT_ITEM_LIST

inherit
	SCANNER_SYMBOLS;
	LIST[NEW_EXPORT_ITEM]
	rename
		make as list_make
	end;

creation
	parse, clear
	
feature { ANY }

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- New_export_list = {New_export_item ";" ...}.
		local
			new_export_item: NEW_EXPORT_ITEM;
		do
			list_make;
			from
			until 
				s.current_symbol.type /= s_left_brace -- ie. not in FIRST(New_Export_Item)
			loop
memstats(140);
				!!new_export_item.parse(s);
				add_tail(new_export_item);
				s.remove_redundant_semicolon;
			end	
		end; -- parse

	clear is
	-- create an empty list
		do
			list_make;
		end;  -- clear

--------------------------------------------------------------------------------

	clear_all_used is
	-- lšscht used in allen Feature_lists der New_exports
		local
			i: INTEGER; 
		do
			from
				i := 1;
			until
				i > count
			loop
				if item(i).all_features then
				else
					item(i).features.clear_all_used
				end;
				i := i + 1 
			end;
		end; -- clear_all_used

	get_clients (name: INTEGER; old_clients: CLIENTS): CLIENTS is
	-- sucht nach Eintrag fŸr name in New_exports. Wird dieser gefunden, so
	-- wird er als benutzt markiert und Result auf die neuen Clients gesetzt. 
	-- ansonsten wird Result auf old_clients gesetzt.
		require
			name /= 0
		local
			i: INTEGER; 
			found: BOOLEAN;
		do
			Result := old_clients;
			from
				i := 1;
				found := false;
			until
				found or else i > count
			loop
				if item(i).all_features then
					Result := item(i).clients;
				elseif item(i).features.has_and_used(name) then
					Result := item(i).clients;
					found := true;
				end;
				i := i + 1 
			end;
		end; -- get_clients
	
	check_all_used is 
		local
			i: INTEGER;
			all_found: BOOLEAN;
		do
			from
				i := 1;
				all_found := false;
			until
				i > count
			loop
				if item(i).all_features then
					if all_found then
						item(i).position.error(msg.vlel1); 
					end;
					all_found := true;
				else 
					item(i).features.check_all_used(msg.vlel2);
				end;
				i := i + 1
			end;
		end; -- check_all_used
			
--------------------------------------------------------------------------------

end -- NEW_EXPORT_ITEM_LIST
