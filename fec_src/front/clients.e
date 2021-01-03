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

class CLIENTS

inherit
	LIST[INTEGER]
	rename
		make as list_make
	end;
	SCANNER_SYMBOLS;
	FRIDISYS;
	CLASSES;
	
creation
	parse
	
--------------------------------------------------------------------------------

feature { ANY }

	is_available_to_any: BOOLEAN;  -- true, wenn ANY in CLIENT-Liste

--------------------------------------------------------------------------------

feature { NONE }

	add_client (s: SCANNER) is
		local
			name: INTEGER;
		do
			s.check_and_get_identifier(msg.id_cnc_expected);	 
			name := s.last_identifier;
			if name /= globals.string_none then
				add(name);
				if name = globals.string_any then	
					is_available_to_any := true
				end;
			end;
		end; -- add_client

--------------------------------------------------------------------------------
	
feature { ANY }

	parse (s: SCANNER) is
	-- Clients = "{" Class_list "}".
	-- Class_list = {Class_name "," ...}.
	-- Class_name = Identifier.
		do 
			list_make;
			IF s.current_symbol.type /= s_left_brace then
				s.current_symbol.position.error(msg.lbrace_expected); 
			else
				s.next_symbol; 
				if s.current_symbol.type = s_identifier then				
					from
						add_client(s);
					until
						s.current_symbol.type /= s_comma
					loop
						s.next_symbol;
						add_client(s);
					end;
				end;
				if s.current_symbol.type /= s_right_brace then
					s.current_symbol.position.error(msg.rbrace_expected);
				else
					s.next_symbol;
				end;
			end;
		end; -- parse
		
--------------------------------------------------------------------------------

	is_available_to(potential_client: CLASS_INTERFACE): BOOLEAN is
	-- true wenn potential_client Nachfolger einer der Klassen in Client-Liste ist
		local
			i: INTEGER;
			al: SORTED_ARRAY[ANCESTOR_NAME,ANCESTOR]; 
		do
			if is_available_to_any then
				Result := true
			else
				al := potential_client.ancestor_list;
				from
					i := 1
				until
					Result or i > count
				loop
					Result := has_ancestor(al, item(i))
					i := i + 1;
				end;
			end;
		end -- is_available_to

feature { NONE }

	has_ancestor(al: SORTED_ARRAY[ANCESTOR_NAME,ANCESTOR]; find: INTEGER): BOOLEAN is
		-- true, wenn al Ancestor mit key.name=find enthŠlt.
		-- Aufwand: O(ln(up-low+1)), ln(up-low+1)+1 Vergleiche
		local
			min,max,mid,cmp, mid_name: INTEGER 
			i: INTEGER;
		do
			from 
				i := al.lower
			until
				i > al.upper or else (al @ i).key.name = find
			loop
				i := i + 1;
			end;
			Result := i <= al.upper;
			-- nyi: wieso funktioniert binŠre Suche nicht?
--			from 
--				min := al.lower;
--				max := al.upper;
--				cmp := -1;
--			invariant  
--				min > al.lower implies find >= al.item(min - 1).key.name
--				max < al.upper implies find <= al.item(max + 1).key.name	 
--			variant 
--				max-min	 
--			until  
--				min>max 
--			loop 
--				mid := (min+max) // 2;
--				mid_name := al.item(mid).key.name;
--				if find <= mid_name then max := mid-1 end 
--				if find >= mid_name then min := mid+1 end 
--			end 
--			Result := cmp=0;
		end; -- has_ancestor

--------------------------------------------------------------------------------

feature { ANY }

	is_available_to_all (clients: CLIENTS): BOOLEAN is
	-- prŸft, ob clients eine Untermenge dieser Clients ist, dies wird zur
	-- †berprŸfung von VAPE benštigt.
		local 
			i: INTEGER;
		do
			if clients = Void then
				Result := is_available_to_any
			else	
				Result := true		
				from
					i := 1
				until
					i > clients.count or not Result
				loop
					Result := is_available_to(get_class(clients @ i));
					i := i + 1;
				end;
			end;
		end; -- is_available_to_all

end -- CLIENTS
