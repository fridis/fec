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

class CREATION_LIST

inherit
	SCANNER_SYMBOLS;
	LIST[CREATION_ITEM]
	rename
		make as list_make
	end;

creation
	parse, clear

--------------------------------------------------------------------------------
	
feature { ANY }

	position: POSITION;

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Creators = "creation" {Creation_clause "creation" ...}+.
	-- Creation_clause = [Clients] [Header_comment] {Creation_item "," ...}.	 
	-- Creation_item = Feature_name.
		require
			s.current_symbol.type = s_creation
		local
			creation_clause: CREATION_ITEM; 
			clients: CLIENTS;
		do	
			position := s.current_symbol.position;
			from
				list_make;
			until
				s.current_symbol.type /= s_creation				
			loop
				s.next_symbol;
				IF s.current_symbol.type = s_left_brace then	
memstats(77);
					!!clients.parse(s);
				else
					clients := Void;
				end;
				if s.first_of_feature_name then				
					from
memstats(78);
						!!creation_clause.parse(s,clients);
						add(creation_clause)
					until
						s.current_symbol.type /= s_comma
					loop
						s.next_symbol;
memstats(79);
						!!creation_clause.parse(s,clients);
						add(creation_clause)
					end;
				end;
			end;	
			if s.current_symbol.type = s_semicolon then
				s.current_symbol.position.error(msg.crlist_no_semi);
				s.next_symbol;
			end;
		end; -- parse

	clear is
	-- create an empty list
		do
			list_make;
		end;  -- clear
			
--------------------------------------------------------------------------------

	find (name: INTEGER) : CREATION_ITEM is
	-- sucht nach dem Eintrag name
		require
			name /= 0
		local
			i : INTEGER; 
		do
			from
				i := 1;
			until
				i > count or else
				item(i).name = name
			loop
				i := i + 1
			end;
			if i <= count then
				Result := item(i);
			end;
		end; -- find

--------------------------------------------------------------------------------
	
	set_creation_items (interface: CLASS_INTERFACE) is
	-- calls fi.set_creation_item for all creators in interface.feature_list
		local
			i: INTEGER;
			fi: FEATURE_INTERFACE; 
		do
			from
				i := 1
			until
				i > count
			loop
				fi := interface.feature_list.find(item(i).name);
				if fi/=Void then
					fi.set_creation_item(item(i));
				end;
				i := i + 1;
			end;
		end; -- set_creation_items

--------------------------------------------------------------------------------
	
	validity (interface: CLASS_INTERFACE) is
		local
			i,j: INTEGER; 
		do
			if interface.parse_class.is_deferred then
				position.error(msg.vgcp4); 
			elseif interface.parse_class.is_expanded and count > 1 then
				position.error(msg.vgcp5);
			else
				from
					i := 1
				until
					i > count
				loop
					item(i).validity(interface);
					from
						j := i + 1
					until
						j > count
					loop
						if item(i).name = item(j).name then
							item(i).position.error(msg.vgcp6);
						end; 
						j := j + 1;
					end;
					i := i + 1;
				end;
			end;
		end; -- validity

--------------------------------------------------------------------------------

end -- CREATION_LIST
