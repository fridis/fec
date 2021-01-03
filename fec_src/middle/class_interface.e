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

class CLASS_INTERFACE

-- A representation of a class after the inherited features have been added and
-- joined or shared.
			
inherit
	SORTABLE[INTEGER];
	ACTUAL_CLASSES;
	CLASSES;
	FRIDISYS;
			
creation
	make, make_dummy, make_none

--------------------------------------------------------------------------------
	
feature { NONE }

--------------------------------------------------------------------------------
	
feature { ANY }

--	key: INTEGER;           -- geerbt: id des Namens 

	parse_class: PARSE_CLASS;

	is_dummy: BOOLEAN;      -- parse_class.is_dummy: true, wenn diese Klasse im Universum 
	                        -- nicht gefunden wurde und daher ein Dummy erzeugt wurde.

	feature_list: SORTED_ARRAY[INTEGER,FEATURE_INTERFACE];  -- die sortierten Features nach dem Erben

	ancestor_list: SORTED_ARRAY[ANCESTOR_NAME,ANCESTOR]; -- die Vorgängerklassen nach dem Erben

	this_class : ANCESTOR;  -- der Eintrag in ancestors für diese Klasse.

	no_feature: FEATURE_INTERFACE;  -- Dies wird den Conformance-Routinen übergeben bei Typen, 
	                                -- die außerhalb eines Features verwendet werden

	like_current: TYPE;         -- The type of 'like Current' seen within this class

feature { TYPE, CLASSES }

	uses_types: LIST[TYPE];     -- Nicht-Referenztypen, die diese Klasse als Attribute oder Locals 
	                            -- benutzt 

feature { PARENT, PARENT_LIST, FEATURE_DECLARATION }

	features: PS_ARRAY[INTEGER,FEATURE_INTERFACE];
	ancestors : PS_ARRAY[ANCESTOR_NAME,ANCESTOR];  -- alle Vorgängerklassen

feature { CLASSES }

	getting_inherited: BOOLEAN;  -- Hiermit kann zyklische Vererbung erkannt werden: wenn
	                             -- eine Klasse in der class_list gefunden wurde, dann darf
	                             -- sie nicht verwendet werden, solange getting_inherited
	                             -- true ist.

--------------------------------------------------------------------------------

feature { ANY }

	make (pc: PARSE_CLASS; 
	      class_lst: PS_ARRAY[INTEGER,CLASS_INTERFACE]) is
		do
			parse_class          := pc;
			key                  := pc.key;
			is_dummy             := pc.is_dummy;
memstats(39);
			!!features.make;
memstats(40);
			!!ancestors.make;
memstats(41);
			!!this_class.make_this_class(Current);
memstats(42);
			!!no_feature.make_no_feature(Current);
			ancestors.add(this_class);
memstats(43);
			!!uses_types.make;
			getting_inherited := true; 
			class_lst.add(Current);
			pc.parents.get_inherited(Current);
			pc.feature_declarations.get_immediate(Current);
			feature_list := features.get_sorted;
			if pc.creators/=Void then
				pc.creators.set_creation_items(Current);
			end;
			get_feature_numbers;
			vdrs4_and_vcch2;
			this_class.set_features(feature_list,num_dynamic_features);
			pc.parents.get_ancestors_features(Current);
			ancestor_list := ancestors.get_sorted;
			check_selects;
			get_pre_and_postconditions;
			getting_inherited := false; 
memstats(495);
			!CLASS_TYPE!like_current.make_like_current(Current);
--			print_ancestors;
		end; -- make

--------------------------------------------------------------------------------
		
feature { NONE }
		
	get_pre_and_postconditions is
	-- determines the combined pre- and postconditions of redefined routines. 
		local
			i: INTEGER;
			fi: FEATURE_INTERFACE; 
		do
			from
				i := 1
			until
				i > feature_list.count
			loop
				fi := feature_list @ i;
				(feature_list @ i).get_pre_and_postconditions;
				i := i + 1;
			end; 
		end; -- get_pre_and_postconditions

--------------------------------------------------------------------------------

	forget_joined_and_shared is
	-- Die Feature_interface von wiederholt geerbten features verbrauchen sehr viel 
	-- Platz (300 Features in Any, bei 3 Parent_clauses also 600 unnütz, jeweils
	-- 80 Bytes also 42K und bei 100 solchen Klassen 4MB!).
		local
			i: INTEGER; 
			fi: FEATURE_INTERFACE;
		do
			from
				i := 1
			until
				i > feature_list.upper
			loop
				fi := feature_list @ i;
				if fi.joined /= Void then
					recycle.forget_features(fi.joined);
					fi.set_joined(Void);
				end;
				if fi.shared /= Void then
					recycle.forget_features(fi.shared);
					fi.set_shared(Void);
				end;
				i := i + 1;
			end; 
		end; -- forget_joined_and_shared
		
--------------------------------------------------------------------------------

feature { ANY }

	make_dummy (name: INTEGER) is
		do
memstats(44);
			!!parse_class.make_dummy(strings # "_DUMMY_");
			key                  := name;
			is_dummy             := true;
memstats(45);
			!!features.make;
memstats(46);
			!!ancestors.make; 
memstats(47);
			!!this_class.make_this_class(Current);
memstats(48);
			!!no_feature.make_no_feature(Current);
			ancestors.add(this_class);
memstats(49);
			!!uses_types.make;
memstats(50);
			!!feature_list.make(1,0);
memstats(51);
			!!ancestor_list.make(1,0);
memstats(494);
			!CLASS_TYPE!like_current.make_like_current(Current);
		end; -- make_dummy

	make_none is
		do
			make_dummy(globals.string_none);
			is_dummy := false;
		end; -- make_none

--------------------------------------------------------------------------------

	num_dynamic_features: INTEGER; 

	get_feature_numbers is
		local
			i: INTEGER;
			fi: FEATURE_INTERFACE; 
		do
			from 
				i := feature_list.lower
				num_dynamic_features := 0;
			until
				i > feature_list.upper
			loop
				fi := (feature_list @ i);
				if fi.feature_value.is_variable_attribute or
					fi.feature_value.is_deferred or
					fi.feature_value.is_internal_routine  
				-- frozen features also get a number since they may be duplicated and therefore have
				-- to be bound dynamically
				then
					num_dynamic_features := num_dynamic_features + 1;
					fi.set_number(num_dynamic_features);
				else
					fi.set_number(-1)
				end;
				i := i + 1;
			end; 
		end; -- get_feature_numbers

--------------------------------------------------------------------------------
		
	check_selects is
		local
			i: INTEGER;
		do
			from
				i := ancestor_list.lower;
			until
				i > ancestor_list.upper
			loop
				(ancestor_list @ i).check_selects;				
				i := i + 1;
			end;
			parse_class.parents.check_selects;			
		end; -- check_ancestors
		
	print_ancestors is 
		local
			i,j: INTEGER;
			a: ANCESTOR;
		do
			write_string("ancestors of <<"); write_string(strings @ key); write_string(">>%N");
			from
				i := ancestor_list.lower;
			until
				i > ancestor_list.upper
			loop
				a := ancestor_list @ i;
				write_string(" - "); a.key.print_name(Current); write_string("%N");	
				from
					j := a.features.lower
				until
					j > a.features.upper
				loop
					write_string("      ["); write_integer(j); write_string("] "); write_string(strings @ (a.features @ j).key); write_string("%N");
					j := j + 1;
				end;		
				i := i + 1;
			end;
		end; -- print_ancestor

--------------------------------------------------------------------------------
-- VALIDITY CHECKING:                                                         --		
--------------------------------------------------------------------------------

	validity is
		do
			!!current_type.make_current(Current); 
			parse_class.formal_generics.validity(Current);
			parse_class.parents.validity(Current);
			if parse_class.creators /= Void then 
				parse_class.creators.validity(Current)
			end;
			vdrd2; 
			forget_joined_and_shared; -- Dies sollte eigentlich der GC tun.
			feature_validity;
			parse_class.invariant_assertion.validity(no_feature);
		end; -- validity

	current_type: CLASS_TYPE;  -- Type of 'Current' within this class, set when validity 
	                           -- is checked.

--------------------------------------------------------------------------------

feature { NONE }

	vdrs4_and_vcch2 is
		-- VDRS 4: Alle geerbten Features mit redefine=true müssen redefiniert werden
		-- VCCH 2: Deferred class gdw. deferred Features vorhanden
		local
			index: INTEGER; 
			feat,joined,shared: FEATURE_INTERFACE;
			has_deferred: FEATURE_INTERFACE;
		do
			from
				index := feature_list.lower
				has_deferred := Void;
			until
				index > feature_list.upper
			loop
				feat := feature_list @ index;
				if feat.is_deferred then 
					has_deferred := feat
				end;
				if feat.parent_clause /= Void then 
					from  joined := feat
					until joined = Void
					loop  
						from  shared := joined; -- this is correct
						until shared = Void
						loop
							if shared.is_redefined then 
								shared.parent_clause.redefines.error_at(shared.key,msg.vdrs3);
							end;
							shared := shared.shared;
						end;
						joined := joined.joined;
					end;
				end;
				index := index + 1;
			end;
			if has_deferred = Void then
				if parse_class.is_deferred then
					parse_class.name_position.error(msg.vcch1);
				end;
			else
				if not parse_class.is_deferred then
					parse_class.name_position.error_m(<<"VCCH: Dies muß eine deferred class sein, sie enthält das deferred Feature <<",strings @ has_deferred.key,">>.">>);
				end; 
			end;
		end; -- vdrs4_and_vcch2

--------------------------------------------------------------------------------

	vdrd2 is
		local
			i: INTEGER; 
			fi,joined: FEATURE_INTERFACE;
		do
			from
				i := 1
			until
				i > feature_list.count
			loop
				fi := feature_list @ i;
				if fi.parent_clause = Void then -- redeclaration
					from
						joined := fi.joined
					until
						joined = Void or else
						not fi.signature_conforms_to(joined)
					loop
						joined := joined.joined;
					end
					if joined /= Void then
						fi.position.error(msg.vdrd1);
					end;
				else -- joining
					from
						joined := fi.joined
					until
						joined = Void or else
						not fi.signature_is_identical(joined)
					loop
						joined := joined.joined;
					end
					if joined /= Void then
						fi.position.error(msg.vdjr1);
					end;
				end;
				i := i + 1;
			end;
		end; -- vdrd2
		
	feature_validity is
		local
			i: INTEGER;
			fi: FEATURE_INTERFACE; 
		do
			from
				i := 1
			until
				i > feature_list.count
			loop
				fi := feature_list @ i;
				if fi.parent_clause = Void then  -- Nur immediate Features müssen geprüft werden
					(feature_list @ i).validity;
				end;
				i := i + 1;
			end; 
		end; -- feature_validity
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }

	get_inherited_feature (ancestor: ANCESTOR_NAME; old_name: INTEGER): FEATURE_INTERFACE is
	-- this finds the feature in Current that was inherited from ancestor with
	-- the original name old_name.
	-- This only works for dynamic features, ie. internal routines and
	-- variable attributes.
		local
			an: ANCESTOR;
			ci: CLASS_INTERFACE;
			fi: FEATURE_INTERFACE;
		do
			an := ancestor_list.find(ancestor);
			ci := get_class(ancestor.name);
			fi := ci.feature_list.find(old_name);
			Result := an.features @ fi.number;
		end; -- get_inherited_feature

--------------------------------------------------------------------------------

feature { ACTUAL_CLASS }

	get_duplicated_features(ac: ACTUAL_CLASS) is
		local
			changed: BOOLEAN;
			i: INTEGER;
			fi: FEATURE_INTERFACE;
		do
		-- nyi: Duplication due to anchored types: "!!x" with "x: like y" or "x: like Current"
			if ac.is_expanded then
				duplicate_all(ac)
			else
				if parse_class.is_deferred then
					find_cant_be_compiled(ac);
				end;
				duplication_due_to_attr_or_array(ac);
				duplication_due_to_routine_call(ac);
			end;
		end; -- get_duplicated_features

feature { NONE }

	find_cant_be_compiled (ac: ACTUAL_CLASS) is
	-- set cant_be_compiled for all internal effective routines that call
	-- a deferred routine
		local
			changed: BOOLEAN;
			i: INTEGER;
			fi: FEATURE_INTERFACE;
		do
			from
				changed := true
			until
				not changed
			loop
				changed := false;
				from
					i := 1
				until
					i > feature_list.count
				loop
					fi := feature_list @ i;
					if fi.feature_value.is_internal_routine then 
						if not (ac.cant_be_compiled @ fi.number) then
							if not compilation_possible(ac,fi) then
								changed := true;
								ac.set_cant_be_compiled(fi.number);
							end;
						end;
					end;
					i := i + 1;
				end;
			end;
		end; -- find_cant_be_compiled

	compilation_possible(ac: ACTUAL_CLASS; fi: FEATURE_INTERFACE): BOOLEAN is
		local
			j: INTEGER;
			rout: ROUTINE;
			calls: ARRAY[BOOLEAN];
			origin_this_class: ANCESTOR;
			old_called,new_called: FEATURE_INTERFACE;
		do
			Result := true;
			if fi.feature_value.is_internal_routine then
				rout ?= fi.feature_value;
				calls := rout.routine_body.calls_currents_features;
				origin_this_class := get_class(fi.origin.name).this_class;
				from
					j := calls.lower;
				until
					j > calls.upper
				loop
					if calls @ j then
						old_called := origin_this_class.features @ j;
						new_called := fi.get_new_feature(old_called.key);
						if new_called.is_deferred or else
						   new_called.number >= 0 and then
						   ac.cant_be_compiled @ new_called.number
						then
							Result := false;
						end;
					end;
					j := j + 1;
				end;
			end;
		end; -- compilation_possible
		
--------------------------------------------------------------------------------

	duplicate_all(ac: ACTUAL_CLASS) is
	-- mark all internal routines to be duplicated
		local
			i: INTEGER;
			fi: FEATURE_INTERFACE;
		do
			from
				i := 1
			until
				i > feature_list.count
			loop
				fi := feature_list @ i; 
				if fi.feature_value.is_internal_routine and then fi.parent_clause /= Void then
					ac.set_must_be_duplicated(fi.number);
				end;
				i := i + 1;
			end;
		end; -- duplicate_all

	duplication_due_to_attr_or_array(ac: ACTUAL_CLASS) is
	-- this finds all features that have to be duplicated because they access attributes
	-- that have moved or because their seed is one of put, item or infix "@" and their
	-- origin is ARRAY.
	-- This also finds all features whose seed is a generic class and that use a true_class
	-- that depends on actual generic arguments that are references (these true_classes are
	-- stored int he type descriptor, so duplicating these features is necessary to get the
	-- true_classes in the td_true_types list of the new actual_class). 
		local
			i: INTEGER;
			fi: FEATURE_INTERFACE;
			origin,seed: INTEGER;
		do
			from
				i := 1
			until
				i > feature_list.count
			loop
				fi := feature_list @ i; 
				if fi.feature_value.is_internal_routine then 
					origin := fi.origin.name;
					seed := fi.seed.key;
					if not fi.origin.generics.is_empty then
						-- NOTE: This duplicates all features inherited from a generic class. 
						-- This is not necessary, since only those that use types that depend
						-- on the actual generics that are references have to be duplicated.
						ac.set_must_be_duplicated(fi.number);
					elseif origin = globals.string_array and then 
						(seed = globals.string_put      or else
						 seed = globals.string_infix_at or else
						 seed = globals.string_item             ) or else
						origin = globals.string_general and then
						(seed = globals.string_clone             or else
						 seed = globals.string_standard_clone    or else
						 seed = globals.string_standard_copy     or else
						 seed = globals.string_standard_is_equal )
					then
						ac.set_must_be_duplicated(fi.number);
					elseif fi.parent_clause /= Void then
						if check_dupl_due_to_attribute_access(ac,fi) then
							ac.set_must_be_duplicated(fi.number)
						end;
					end;
				end;
				i := i + 1;
			end;
		end; -- duplication_due_to_attr_or_array

	check_dupl_due_to_attribute_access (ac: ACTUAL_CLASS; fi: FEATURE_INTERFACE): BOOLEAN is
		local
			j: INTEGER;
			ancestor,parent_ancestor: ANCESTOR;
			parent_class: ACTUAL_CLASS;
			rout: ROUTINE;
			calls: ARRAY[BOOLEAN];
			origin_this_class: ANCESTOR;
			old_called,new_called: FEATURE_INTERFACE;
		do
			if fi.feature_value.is_internal_routine then
				rout ?= fi.feature_value;
				calls := rout.routine_body.calls_currents_features;
				ancestor := ancestor_list.find(fi.origin);
				parent_class := actual_classes.find(fi.parent_clause.class_type.actual_class_name(ac.key));
				parent_ancestor := parent_class.base_class.ancestor_list.find(fi.origin);
				origin_this_class := get_class(fi.origin.name).this_class;
				from
					j := calls.lower;
				until
					j > calls.upper
				loop
					if calls @ j then
						old_called := origin_this_class.features @ j;
						new_called := fi.get_new_feature(old_called.key);
						if new_called.feature_value.is_variable_attribute then
							if ac          .attribute_offsets @ new_called.number /= 
								parent_class.attribute_offsets @ old_called.number 
							then
								Result := true
							end;
						end;
					end;
					j := j + 1;
				end;
			end;
		end; -- check_dupl_due_to_attribute_access

	duplication_due_to_routine_call (ac: ACTUAL_CLASS) is
		local
			changed: BOOLEAN;
			i: INTEGER;
			fi: FEATURE_INTERFACE;
		do
			from -- this is an iterative loop that is executed until we have a stable situation. 
				changed := true
			until
				not changed
			loop
				changed := false;
				from
					i := 1
				until
					i > feature_list.count
				loop
					fi := feature_list @ i;
					if fi.feature_value.is_internal_routine and then fi.parent_clause /= Void then
						if not (ac.must_be_duplicated @ fi.number) then
							if check_need_for_duplication(ac,fi) then
								changed := true;
								ac.set_must_be_duplicated(fi.number);
							end;
						end;
					end;
					i := i + 1;
				end;
			end;
		end; -- duplication_due_to_routine_call
		
	check_need_for_duplication(ac: ACTUAL_CLASS; fi: FEATURE_INTERFACE): BOOLEAN is
		local
			j: INTEGER;
			rout: ROUTINE;
			calls: ARRAY[BOOLEAN];
			origin_this_class: ANCESTOR;
			old_called,new_called: FEATURE_INTERFACE;
		do
			rout ?= fi.feature_value;
			calls := rout.routine_body.calls_currents_features;
			origin_this_class := get_class(fi.origin.name).this_class;
			from
				j := calls.lower;
			until
				j > calls.upper
			loop
				if calls @ j then
					old_called := origin_this_class.features @ j;
					new_called := fi.get_new_feature(old_called.key);
					if new_called.parent_clause = Void or else 
						new_called.number >= 0 and then
						ac.must_be_duplicated @ new_called.number
					then
						Result := true;
					end;
				end;
				j := j + 1;
			end;
		end; -- check_need_for_duplication
		
--------------------------------------------------------------------------------

feature { ACTUAL_CLASS }

	compile(ac: ACTUAL_CLASS) is
		do
			compile_routines(ac);
			if not parse_class.is_deferred then
				create_feature_descriptors(ac);
			end;
		end -- compile

--------------------------------------------------------------------------------

feature { NONE }

	compile_routines(ac: ACTUAL_CLASS) is
		local
			i: INTEGER;
		do
			from
				i := 1
			until
				i > feature_list.count
			loop
				(feature_list @ i).compile(ac);
				i := i + 1
			end;
		end -- compile_routines

--------------------------------------------------------------------------------

	create_feature_descriptors(ac: ACTUAL_CLASS) is
		local
			i: INTEGER
		do
			from
				i := 1
			until
				i > ancestor_list.count
			loop
				(ancestor_list @ i).create_feature_descriptor(ac);
				i := i + 1;
			end;
		end; -- create_feature_descriptor
	
--------------------------------------------------------------------------------

end -- CLASS_INTERFACE
