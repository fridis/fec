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

class PARENT

inherit
	SCANNER_SYMBOLS;
	CLASSES;

creation
	parse, make_any
	
feature { ANY }

	class_type: CLASS_TYPE;     -- the parent class' type
	renames: RENAME_LIST;       -- list of RENAME_PAIR
	new_exports: NEW_EXPORT_ITEM_LIST;  -- list of NEW_EXPORT_ITEM
	undefines: FEATURE_LIST;    -- list of FEATURE_NAME
	redefines: FEATURE_LIST;    -- list of FEATURE_NAME
	selects: FEATURE_LIST;      -- list of FEATURE_NAME

	position : POSITION;        -- Position des Namens der Vaterklasse.

	got_unneccessary_end: BOOLEAN; -- Dies ist nur fŸr den Parser, wenn fŸr
	                            -- dieses Parent leer ist, dann wurde 
	                            -- mšglicherweise bereits das end der Klasse
	                            -- Ÿberlesen.

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Parent = Class_type [Feature_adaptation].
	-- Feature_adaptation = Rename
	--                      New_exports
	--                      Undefine
	--                      Redefine
	--                      Select
	--                      "end".
		do
			position := s.current_symbol.position;
memstats(142);
			!!class_type.parse(s,false);
			inspect s.current_symbol.type
			when 
				s_rename, 
				s_export, 
				s_undefine, 
				s_redefine, 
				s_select
			then
				parse_rename(s);
				parse_new_exports(s);
				parse_undefine(s);
				parse_redefine(s);
				parse_select(s);
				s.check_keyword(s_end);				
			else
memstats(143);
memstats(144);
memstats(145);
memstats(146);
memstats(147);
				!!renames.clear;
				!!new_exports.clear;
				!!undefines.clear;
				!!redefines.clear;
				!!selects.clear;
				if s.current_symbol.type = s_end then
					got_unneccessary_end := true;
					s.next_symbol;
				end;
			end;
		end; -- parse

	make_any (class_name_position: POSITION) is
	-- erzeugt ein Parent-element fŸr ANY ohne Extras.
		do
			position := class_name_position;
			class_type := globals.type_any;
memstats(148);
memstats(149);
memstats(150);
memstats(151);
memstats(152);
			!!renames.clear;
			!!new_exports.clear;
			!!undefines.clear;
			!!redefines.clear;
			!!selects.clear;
		end; -- make_any
		
--------------------------------------------------------------------------------
		
feature { NONE }	
		
	parse_rename (s: SCANNER) is
	-- Rename = ["rename" Rename_list].
		local
			rename_pair: RENAME_PAIR; 
		do	
			if s.current_symbol.type = s_rename then
				s.next_symbol;
memstats(153);
				!!renames.parse(s);
			else
memstats(154);
				!!renames.clear;
			end;
		end; -- parse_rename	
		
--------------------------------------------------------------------------------		

	parse_new_exports (s: SCANNER) is
	-- New_exports = ["export" New_export_list].
		do
			if s.current_symbol.type = s_export then
				s.next_symbol
memstats(155);
				!!new_exports.parse(s)
			else
memstats(156);
				!!new_exports.clear;
			end;
		end; -- parse_new_exports

--------------------------------------------------------------------------------

	parse_undefine (s: SCANNER) is
	-- Undefine = ["undefine" Feature_list]
		do
			if s.current_symbol.type = s_undefine then
				s.next_symbol;
memstats(157);
				!!undefines.parse(s)
			else
memstats(157);
				!!undefines.clear;
			end;
		end; -- parse_undefine

--------------------------------------------------------------------------------

	parse_redefine (s: SCANNER) is
	-- Redefine = ["redefine" Feature_list]
		do
			if s.current_symbol.type = s_redefine then
				s.next_symbol;
memstats(158);
				!!redefines.parse(s)
			else
memstats(159);
				!!redefines.clear;
			end;
		end; -- parse_redefine

--------------------------------------------------------------------------------

	parse_select (s: SCANNER) is
	-- Undefine = ["select" Feature_list]
		do
			if s.current_symbol.type = s_select then
				s.next_symbol;
memstats(160);
				!!selects.parse(s)
			else
memstats(161);
				!!selects.clear;
			end;
		end; -- parse_select
		
--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	get_inherited (interface: CLASS_INTERFACE) is
	-- fŸgt die geerbten Features dem Interface dieses Nachfolgers zu
		local
			parent_interface : CLASS_INTERFACE;
		do
--print("get_inherited:%N");
			parent_interface := class_type.base_class(interface.no_feature);	
--print("join_anc:%N");
			join_ancestors(interface,parent_interface);
--print("feature_adapt:%N");
			feature_adaption(interface,parent_interface);
--print("get_inherited done.%N");
		end; -- get_inherited

--------------------------------------------------------------------------------

feature { NONE }

	join_ancestors (interface,parent_interface: CLASS_INTERFACE) is
		-- fŸgt alle VorgŠngerklassen von parent_interface denen von interface hinzu.
		local
			parent_ancestors: ARRAY[ANCESTOR];
			parent_ancestor,new_ancestor: ANCESTOR;
			new_view: ANCESTOR_NAME;
			i: INTEGER;
		do
			parent_ancestors := parent_interface.ancestor_list;
			from
				i := 1
			until
				i > parent_ancestors.upper
			loop
				parent_ancestor := parent_ancestors @ i;
				new_view := parent_ancestor.key.get_heirs_view(interface,class_type);
				if interface.ancestors.find(new_view) = Void then
memstats(162);
					!!new_ancestor.make_parent(new_view,position);
					new_ancestor.allocate_features(parent_ancestor.features.upper);
					interface.ancestors.add(new_ancestor);
				end;
				i := i+1;
			end;
		end; -- join_ancestors

	feature_adaption (interface,parent_interface: CLASS_INTERFACE)	is
		local
			i: INTEGER; 
		do
			new_exports.clear_all_used;
			renames.clear_all_used;
			undefines.clear_all_used;
			redefines.clear_all_used;
			selects.clear_all_used;
			from 
				i := parent_interface.feature_list.lower
			until
				i > parent_interface.feature_list.upper
			loop
				adapt_feature(interface,parent_interface.feature_list @ i);
				i := i + 1;
			end;
			renames.check_all_used;
			undefines.check_all_used(msg.vdus1); 
			redefines.check_all_used(msg.vdrs1);
			selects  .check_all_used(msg.vmss1);
			selects  .clear_all_used;
			new_exports.check_all_used;
		end; -- feature_adaption

	adapt_feature(interface: CLASS_INTERFACE; fi: FEATURE_INTERFACE) is
		local
			new_fi,same_name_fi: FEATURE_INTERFACE;
			new_name: INTEGER;
			clients: CLIENTS;
		do
			new_name := renames.get_rename(fi.key);
			clients := new_exports.get_clients(new_name,fi.clients);
			new_fi := recycle.new_feature_interface;
			new_fi.make_from(fi,interface,new_name,clients,Current);
			if undefines.has_and_used(new_fi.key) then 
				if new_fi.is_frozen or new_fi.feature_value.is_attribute then
					undefines.error_at(new_fi.key,msg.vdus2);
				elseif new_fi.is_deferred then
					undefines.error_at(new_fi.key,msg.vdus3);
				else
					new_fi.set_deferred  
				end;
			end;
			if redefines.has_and_used(new_fi.key) then 
				if new_fi.is_frozen or new_fi.feature_value.is_constant_attribute then
					redefines.error_at(new_fi.key,msg.vdrs2);
				else
					new_fi.set_redefined 
				end;
			end;
			if selects.has_and_used(new_fi.key) then 
				new_fi.set_selected
			end;
			-- add new_fi to feature list:
			same_name_fi := interface.features.find(new_fi.key); 
			if same_name_fi/=Void then
				same_name_fi.add_same_name(new_fi)
			else
				interface.features.add(new_fi);
			end;
		end; -- adapt_feature

--------------------------------------------------------------------------------

feature { ANY }
		
	get_ancestors_features (interface: CLASS_INTERFACE) is
	-- setzt die Features in die VorgŠnger dieser Vaterklasse und aller ihrer VorgŠnger
		local
			parent_interface: CLASS_INTERFACE;
			parent_ancestor: ANCESTOR;
			i: INTEGER; 
			this_ancestor: ANCESTOR;
			fi: FEATURE_INTERFACE;
			new_name: INTEGER;
		do	
			parent_interface := class_type.base_class(interface.no_feature);	
			parent_ancestor := parent_interface.this_class;	
			this_ancestor := interface.ancestors.find(class_type.ancestor_name(interface));
if this_ancestor = Void then
	print("%N"); class_type.ancestor_name(interface).print_name(interface);
	print("%N"); class_type.print_type;
end;
			from 			
				i := parent_ancestor.features.lower
			until
				i > parent_ancestor.features.upper
			loop
				new_name := renames.get_rename((parent_ancestor.features @ i).key);
				fi := interface.feature_list.find(new_name);
				this_ancestor.set(i,fi,selects);
				i := i + 1;
			end;
			get_ancestors_ancestors_features(interface,parent_interface,this_ancestor);
		end;  -- get_ancestors_features
		
feature { NONE }

	get_ancestors_ancestors_features (interface, parent_interface: CLASS_INTERFACE; this_ancestor: ANCESTOR) is
	-- setzt die Features der echten VorgŠnger dieser Vaterklasse
		local
			parents_ancestor : ANCESTOR;       -- VorgŠnger der Vaterklasse in der Vaterklasse
			this_ancestors_ancestor: ANCESTOR; -- VorgŠnger der Vaterklasse in dieser Klasse 
			i: INTEGER;                        -- Index in parent_interface.ancestor_list
			j: INTEGER;                        -- Index in parents_ancestors.features
			parent_number: INTEGER;            -- Nummer des Features in der Vaterklasse
			fi: FEATURE_INTERFACE;             -- Das dem Feature entsprechende Feature in dieser Klasse
		do
			-- fŸr alle echten VorgŠnger dieser Vaterklasse
			from 
				i := parent_interface.ancestor_list.lower
			until
				i > parent_interface.ancestor_list.upper
			loop
				parents_ancestor := parent_interface.ancestor_list @ i;
				if parents_ancestor /= parent_interface.this_class then  -- nur echte VorgŠnger betrachten:
				
					this_ancestors_ancestor := interface.ancestors.find(parents_ancestor.key.get_heirs_view(interface,class_type));
					
					-- fŸr alle Features des echten VorgŠngers this_ancestors_ancestor der Vaterklasse setzen
					from 
						j := parents_ancestor.features.lower
					until
						j > parents_ancestor.features.upper
					loop
						parent_number := (parents_ancestor.features @ j).number;  
						if parent_number >= 0 then
							fi := this_ancestor.features @ parent_number;     -- das Feature in der neuen Klasse
 							this_ancestors_ancestor.set(j,fi,selects);
 						end;
						j := j + 1;
					end;
					
				end;
				
				i := i + 1;
			end; 
		end; -- get_ancestors_ancestors_features

--------------------------------------------------------------------------------

invariant
	renames /= Void; 
	new_exports /= Void;
	undefines /= Void;
	redefines /= Void;
	selects /= Void;
end -- PARENT
