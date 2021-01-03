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

class FEATURE_DECLARATION_LIST

inherit
	SCANNER_SYMBOLS;
	LIST[FEATURE_DECLARATION]
	rename
		make as list_make
	end;

creation
	parse, clear
	
feature { ANY }

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Features = ["feature" {Feature_clause "feature" ...}+].
		require
			s.current_symbol.type = s_feature
		do	
			list_make;
			from
			until
				s.current_symbol.type /= s_feature
			loop
				s.next_symbol;
				parse_feature_clause(s);
			end;
		end; -- parse

	clear is
	-- create an empty list
		do
			list_make;
		end;  -- clear

--------------------------------------------------------------------------------

	parse_feature_clause (s: SCANNER) is
	-- Feature_clause = [Clients] [Header_comment] Feature_declaration_list.
	-- Feature_declaration_list = {Feature_declaration ";" ...}.
	-- Header_comment = Comment.
		local
			clients: CLIENTS;
			feature_declaration: FEATURE_DECLARATION;
		do
			if s.current_symbol.type = s_left_brace then 
memstats(91);
				!!clients.parse(s);
			else
				clients := Void;
			end;
			from
			until 
				not s.first_of_feature_declaration
			loop
memstats(92);
				!!feature_declaration.parse(s,clients,Current);
				s.remove_redundant_semicolon;
			end;
		end; -- parse_feature_clause
			
--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	get_immediate (interface: CLASS_INTERFACE) is
	-- holt alle in dieser Klasse eingefŸhrten Features
		local
			i: INTEGER;
		do
			from
				i := 1
			until
				i > count
			loop
				item(i).get_immediate(interface);
				i := i + 1;
			end;
		end; -- get_immediate

--------------------------------------------------------------------------------

end -- FEATURE_DECLARATION_LIST
