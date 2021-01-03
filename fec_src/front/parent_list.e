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

class PARENT_LIST

inherit
	LIST[PARENT]
	rename 
		make as list_make
	end;
	SCANNER_SYMBOLS;
	
creation
	parse, clear, make_dummy
	
feature { ANY }

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Index_list = {Index_clause ";" ...}.
	-- Parent_list = {Parent ";" ...}.
		local
			parent: PARENT;
		do
			list_make;
			from
			until 
				s.current_symbol.type /= s_identifier -- ie. not in FIRST(parent)
			loop
memstats(163);
				!!parent.parse(s);
				add_tail(parent);
				s.remove_redundant_semicolon;
			end	
			if is_empty then
				clear(s)
			end;
		end; -- parse_inheritance

	clear(s: SCANNER) is
	-- create an empty list
		local
			parent: PARENT;
		do
			list_make;
			if s.parse_class.key /= globals.string_any     and 
				s.parse_class.key /= globals.string_general
			then
memstats(164);
				!!parent.make_any(s.parse_class.name_position);
				add_tail(parent);
			end;
		end;  --  clear
	
	make_dummy is
		do
			list_make
		end; -- make_dummy
		
--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	get_inherited (interface: CLASS_INTERFACE) is
	-- holt alle geerbten Features, wie in ETL, S. 187, beschrieben
		local
			inherited: ARRAY[FEATURE_INTERFACE];
			i: INTEGER;
		do	
--print("gi:%N");
			from
				i := 1
			until
				i > count
			loop
--print("item.gi:%N");
				item(i).get_inherited(interface);
--print("item.gi done%N");
				i := i + 1;
			end;
--print("get_sorted:%N");
			inherited := interface.features.get_sorted;
--print("get_sorted done%N");
			from 
				i := 1;
			until
				i > inherited.upper
			loop
--print("replace:%N");
				interface.features.replace((inherited @ i).join_or_share);
--print("replace done%N");
				i := i + 1;
			end;
--print("gi done.%N");
		end; -- get_inherited

	get_ancestors_features (interface: CLASS_INTERFACE) is
		-- ruft ancestor.set fŸr jedes geerbte Feature auf.
		local
			i: INTEGER; 
		do 
			from
				i := 1
			until
				i > count
			loop
				item(i).get_ancestors_features(interface);
				i := i + 1;
			end;
		end; -- get_ancestors_features

	check_selects is
		-- ruft check_selects fŸr jeden parent-clause auf.
		local
			i: INTEGER; 
		do 
			from
				i := 1
			until
				i > count
			loop
				item(i).selects.check_all_used(msg.vmss2);
				i := i + 1;
			end;
		end; -- check_selects
		
--------------------------------------------------------------------------------

	validity (interface: CLASS_INTERFACE) is
		local
			i: INTEGER; 
		do
			from
				i := 1
			until
				i > count
			loop
				item(i).class_type.validity(interface.no_feature);
				item(i).class_type.add_to_uses(interface.no_feature);
				i := i + 1
			end;
		end; -- validity

--------------------------------------------------------------------------------

end -- PARENT_LIST

	
