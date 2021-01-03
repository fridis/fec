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

class FEATURE_LIST

inherit
	SCANNER_SYMBOLS;
	LIST[FEATURE_NAME]
	rename
		make as list_make
	end;

creation
	parse, clear
	
feature { ANY }

--------------------------------------------------------------------------------

feature { ANY }

	parse (s: SCANNER) is
	-- Feature_list = {Feature_name "," ...}.	 
		local
			feature_name: FEATURE_NAME;
		do
			list_make;
			if s.first_of_feature_name then				
				from
memstats(95);
					!!feature_name.parse(s);
					add(feature_name)
				until
					s.current_symbol.type /= s_comma
				loop
					s.next_symbol;
memstats(96);
					!!feature_name.parse(s);
					add(feature_name)
				end;
			end;
		end; -- parse

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

	has_feat (name: INTEGER) : BOOLEAN is
	-- sucht nach dem Feature name
		require
			name /= 0
		local
			i: INTEGER; 
		do
			from
				i := 1;
			until
				i > count or else
				item(i).name = name
			loop
				i := i + 1
			end;
			Result := i <= count;
		end; -- has_feat

	has_and_used (name: INTEGER): BOOLEAN is
	-- sucht nach dem Feature name und setzt used fŸr gefundenen Eintrag.
		require
			name /= 0
		local
			i: INTEGER; 
		do
			from
				i := 1;
			until
				i > count or else
				item(i).name = name
			loop
				i := i + 1
			end;
			Result := i <= count;
			if Result then
				item(i).set_used
			end;
		end; -- has_and_used

	error_at (name: INTEGER; msg_num: INTEGER) is
	-- sucht nach dem feature name und setzt used fŸr dieses Feature
		require
			has_feat(name)
		local
			i: INTEGER;
		do
			from
				i := 1;
			until
				item(i).name = name
			loop
				i := i + 1;
			end;
			item(i).position.error(msg_num);
		end; -- error_at
			
	check_all_used (msg_num: INTEGER) is 
		local
			i: INTEGER;
		do
			from
				i := 1;
			until
				i > count
			loop
				if not item(i).used then
					item(i).position.error(msg_num);
				end;
				i := i + 1
			end;
		end; -- check_all_used
		
--------------------------------------------------------------------------------

end -- FEATURE_LIST
