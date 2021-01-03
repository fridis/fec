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

class ANCHORED

inherit
	TYPE
		redefine
			is_anchored, 
			is_fake_anchored,
			is_like_current,
			unfake_anchored,
			get_anchors_to_formal_arguments,
			actual_class_name_code,
			actual_class_name_code_no_parent
		end;
	SCANNER_SYMBOLS;
	
creation
	parse, make_fake
	
creation { ANCHORED }
	make

--------------------------------------------------------------------------------
	
feature { ANY }

	anchor : INTEGER;  -- id des Ankers
	
	argument_number: INTEGER; -- falls anchor ein formales argument ist, dann 
	                          -- ist dies dessen index, sonst 0. Der Name in 
	                          -- anchor muß dann ignoriert werden
	
--	position: POSITION;    -- (geerbt:) Position des Typs im Quelltext

	is_fake_anchored: BOOLEAN;
	
--------------------------------------------------------------------------------
	
	parse (s: SCANNER) is 
	-- Anchored = "like" Anchor
		require
			s.current_symbol.type = s.s_like 
		do
			is_fake_anchored := false;
			position := s.current_symbol.position;
			s.next_symbol;
			s.check_and_get_identifier(msg.id_anc_expected);
			anchor := s.last_identifier;
		end; -- parse		

	make (new_anchor: INTEGER; new_position: POSITION) is 
		do
			is_fake_anchored := false;
			anchor := new_anchor; 
			position := new_position;
		end; -- make

	make_fake (new_anchor: INTEGER; new_position: POSITION) is 
	-- gefälschter Anchor: bei "x.y" mit "y: like Current" wird
	-- für das Ergebnis "like x", damit es einem typ "z: like x"
	-- entspricht.
		do
			is_fake_anchored := true;
			anchor := new_anchor; 
			position := new_position;
		end; -- make_fake

--------------------------------------------------------------------------------

	is_anchored : BOOLEAN is
		do 
			Result := true
		end; -- is_anchored
		
	is_like_current : BOOLEAN is
		do
			Result := anchor = globals.string_current; 
		end; -- is_like_current

feature { NONE }

--------------------------------------------------------------------------------

feature { TYPE }

	unfake_anchored (fi: FEATURE_INTERFACE) : TYPE is
		do
			Result := anchors_type_or_any(fi);
		end; -- unfake_anchored
		
--------------------------------------------------------------------------------

feature { FEATURE_DECLARATION, TYPE }

	get_anchors_to_formal_arguments (formals: ENTITY_DECLARATION_LIST) is
	-- Sucht nach Anchored Types für formale Argumente und trägt für sie die
	-- ACHORED.argument_number ein
		local
			i: INTEGER; 
		do
			from
				i := formals.count
			until
				i = 0 or else
				(formals @ i).key = anchor
			loop
				i := i - 1
			end; 
			argument_number := i
		end; -- get_anchors_to_formal_arguments

--------------------------------------------------------------------------------

feature { ANY }

	ancestor_name (interface: CLASS_INTERFACE): ANCESTOR_NAME is
	-- Der Ancestor_name dieses Typs. 
		do
			write_string("Compilerfehler: ANCHORED.ancestor_name #1%N"); 
memstats(254); 
			!!Result.make_class_type(globals.string_any,Void);
		end; -- ancestor_name

feature { ANY }

--------------------------------------------------------------------------------
-- VALIDITY ÜBERPRÜFUNG:                                                      --		
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE) is
		local
			ft: TYPE;
		do
			if recursive_anchor then
				position.error(msg.vtat1);
			else
				ft := anchors_type(fi);
				if ft = Void then
					position.error(msg.vtat2);
				elseif not is_fake_anchored and then ft.is_anchored then
					position.error(msg.vtat3);
				elseif not is_fake_anchored    and then 
					    not ft.is_reference(fi) and then
					    anchor /= globals.string_current
				then
					position.error(msg.vtat4);
				else
					recursive_anchor := true;
					ft.validity(fi);
					recursive_anchor := false;
				end;  
			end;  -- if recursive_anchor
		end; -- validity

feature { NONE }

	recursive_anchor: BOOLEAN;

--------------------------------------------------------------------------------

feature { TYPE }

	base_type (fi: FEATURE_INTERFACE) : CLASS_TYPE is
		local
			at: TYPE;
		do
			if recursive_anchor then
				Result := globals.type_any
			else
				recursive_anchor := true;
				Result := anchors_type_or_any(fi).base_type(fi)
				recursive_anchor := false;
			end;
		end; -- base_type

feature { NONE }

	anchors_type (fi: FEATURE_INTERFACE) : TYPE is
	-- Der Typ, mit dem der Anker deklariert wurde.
	-- Void wenn dieser nicht existiert!
		local
			found_fi: FEATURE_INTERFACE;
			found_arg: LOCAL_OR_ARGUMENT;
		do
			if anchor = globals.string_current then
memstats(9);
				!CLASS_TYPE!Result.make_like_current(fi.interface);
			else
				found_fi := fi.interface.feature_list.find(anchor);
				if found_fi /= Void then
					Result := found_fi.type;
				elseif not fi.is_no_feature then
					found_arg := fi.local_identifiers.find(anchor);
					if found_arg /= Void then
						Result := found_arg.type;
					end;
				end;
			end;  -- if anchor = globals.string_current
		end; -- anchors_type

	anchors_type_or_any (fi: FEATURE_INTERFACE): TYPE is
	-- wie anchors_type, nur globals.type_any statt Void als Result
		do
			Result := anchors_type(fi);
			if Result = Void then
				Result := globals.type_any
			end;
		end; -- anchors_type_or_any

feature { ANY }

--------------------------------------------------------------------------------
-- VALIDITY ÜBERPRÜFUNG:                                                      --		
--------------------------------------------------------------------------------

	is_identical (fi: FEATURE_INTERFACE; 
	              other: TYPE) : BOOLEAN is
	-- testet, ob Current und other identisch sind.
		local
			other_anchor: ANCHORED;
		do
			other_anchor ?= other;
			if other_anchor /= Void then
				if argument_number = 0 then
					Result := anchor = other_anchor.anchor;
				else
					Result := argument_number = other_anchor.argument_number
				end;
			end; 
		end; -- is_identical

	is_reference (fi: FEATURE_INTERFACE): BOOLEAN is
		do
			if is_fake_anchored then
				Result := anchors_type_or_any(fi).is_reference(fi)
			else
				Result := true;
			end;
		end; -- is_reference
		
	is_expanded (fi: FEATURE_INTERFACE): BOOLEAN is
		do
			if is_fake_anchored then
				Result := anchors_type_or_any(fi).is_expanded(fi)
			else
				Result := false;
			end;
		end;

	conforms_directly_to(fi: FEATURE_INTERFACE; 
	                     other: TYPE): BOOLEAN is
	-- testet, ob Current direkt other entspricht.
		local
			at: TYPE;
			act: CLASS_TYPE;
		do
			at := anchors_type_or_any(fi);	
			Result := at.is_identical(fi,other)
			if not Result and then anchor = globals.string_current then
				act ?= at;
				Result := act.is_identical_disregarding_ref_and_expanded(fi,other);
			end;
		end; -- conforms_directly_to

	conforms_recursively(fi: FEATURE_INTERFACE; 
							other: TYPE): BOOLEAN is
	-- testet VNCC: 5, ob ein U existiert so, daß Current U entspricht und U
	-- other entspricht
		do
			if not recursive_anchor then
				recursive_anchor := true;
				Result := anchors_type_or_any(fi).is_conforming_to(fi,other);
				recursive_anchor := false;
			end;
		end; -- conforms_recursively

--------------------------------------------------------------------------------

	view(parent: PARENT): TYPE is
	-- bestimmt die Sicht auf diesen Typ, wie er beim Erben von parent sich in
	-- der Tochterklasse ergibt. 
	-- Bsp: inherit STACK[INTEGER], wobei die Vaterklasse STACK[G] so ist
	-- "ARRAY[G]".view(interface,stack_parent) = "ARRAY[INTEGER]".
	-- entsprechend wird bei Anchored Types der Anchor verändert, wenn er
	-- umbenannt wurde.
		local
			i: INTEGER; 
			pair: RENAME_PAIR;
		do
			from 
				i := 1
				Result := Current;
			until
				i > parent.renames.count
			loop
				pair := parent.renames @ i;
				if pair.original_name.name = anchor then
memstats(10);
					!ANCHORED!Result.make(pair.new_name.name,pair.new_name.position)
				end;
				i := i + 1;
			end; 
		end; -- view

	view_client (fi: FEATURE_INTERFACE; 
	             target: EXPRESSION; 
	             target_type: TYPE;
	             original: CLASS_INTERFACE): TYPE is
	-- bestimmt die Sicht auf diesen Typ, der aus der Klasse original stammt, 
	-- wie sie sich ergibt wenn die Klasse als actual_type verwendet wird.
		local
			anch: INTEGER; 
		do
			if anchor = globals.string_current then
				if target /= Void then
					anch := target.is_unqualified_call; 
				end;
				if anch = 0 or else 
				   not target_type.is_reference(fi) or else 
					target_type.is_anchored or else
				   anch = globals.string_result
				then
					if target_type /= Void then
						Result := target_type;
					else
memstats(11);
						!CLASS_TYPE!Result.make_like_current(original);
						Result := Result.view_client(fi,target,target_type,original);
					end;
				else
memstats(12);
					!ANCHORED!Result.make_fake(anch,position)
				end;
			else			
				if not recursive_anchor then
					recursive_anchor := true;
					Result := anchors_type_or_any(original.no_feature).view_client(fi,target,target_type,original);
					recursive_anchor := false;
				end;
			end;
		end; -- view_client

	view_constraint (fi: FEATURE_INTERFACE; 
	                 new_type: CLASS_TYPE): TYPE is
	-- bestimmt die Sicht auf diesen Constraint eines formal generics im
	-- Typ new_type.
		do
			-- dies darf nie aufgerufen werden, da ein Constraint keinen
			-- anchored enthalten darf.
			Result := globals.type_any;
		end; -- view_constraint

--------------------------------------------------------------------------------

feature { ANY }

	add_to_uses (fi: FEATURE_INTERFACE) is
	-- Fügt diesen Typ fi.interface.uses_types zu. Falls Current 
	-- Anchored ist, so wird der Typ des Ankers verwendet. 
	-- Dies muß Aufgerufen werden für alle Typen, für die Objekte
	-- alloziert werden, und für expandierte lokale Bezeichner.
		local
			at: TYPE;
		do
			if not recursive_anchor then
				recursive_anchor := true
				-- die local_identifiers sind noch nicht alloziert, also gaukeln wir
				-- anchors_type vor, es gäbe kein feature:
				at := anchors_type(fi.interface.no_feature);
				if at /= Void then
				-- ist at=Void so liegt entweder ein Fehler vor, der von validity 
				-- gefunden wird, oder at ist ein formales Argument und dessen Typ
				-- wird sowieso hinzugefügt  
					at.add_to_uses(fi);
				end;
				recursive_anchor := false
			end;
		end -- add_to_uses

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }

	actual_class_name (actual: ACTUAL_CLASS_NAME): ACTUAL_CLASS_NAME is
	-- Der aktuelle Name des Typs in der aktuellen Klasse actual
		do
write_string("Compilerfehler: ANCHORED.actual_class_name#1 <<");
write_string(strings @ anchor);
write_string(">>%N");
memstats(255); 
			!!Result.make(globals.string_any,false,false,Void);
		end; -- actual_class_name

	actual_class_name_code (code: ROUTINE_CODE): ACTUAL_CLASS_NAME is
	-- Der aktuelle Name des Typs in der aktuellen Klasse actual
		do
			Result := anchors_type(code.fi.seed).actual_class_name_code(code)
		end; -- actual_class_name_code

	actual_class_name_code_no_parent (code: ROUTINE_CODE): ACTUAL_CLASS_NAME is
	-- Der aktuelle Name des Typs in der aktuellen Klasse actual
		do
			Result := anchors_type(code.fi).actual_class_name_code_no_parent(code)
		end; -- actual_class_name_code_no_parent

	actual_is_reference (code: ROUTINE_CODE): BOOLEAN is
	-- Ist der aktuelle Typ Referenztyp?
		do
			if is_fake_anchored then
				Result := anchors_type_or_any(code.fi.seed).actual_is_reference(code)
			else
				Result := true;
			end;
		end; -- actual_is_reference

--------------------------------------------------------------------------------

	true_class_name (tcn: TRUE_CLASS_NAME; fi: FEATURE_INTERFACE): TRUE_CLASS_NAME is
	-- Get true_class_name of this type that is used within fi as seen in
	-- class tcn (tcn is the true class of fi.ancestor).
		do
			Result := anchors_type(fi.seed).true_class_name(tcn,fi);
		end; -- true_class_name

	true_class_name_code_parent (code: ROUTINE_CODE; no_parent: BOOLEAN): TRUE_CLASS_NAME is
	-- This tries to get the true_class_name of this type during compilation of
	-- a routine. NOTE: This might fail and return Void if the name can't be
	-- determined before system creation.
		do
			Result := anchors_type(code.fi.seed).true_class_name_code_parent(code,no_parent);
		end; -- true_class_name_code

--------------------------------------------------------------------------------

	local_type(code: ROUTINE_CODE): LOCAL_TYPE is
	-- get local_type of this type as seen by routine code (code may be 
	-- inherited and Curren in this case is the type in the class of origin.
		do
			if is_fake_anchored then
				Result := anchors_type_or_any(code.fi.seed).local_type(code);
			else
				Result := globals.local_reference
			end;
		end; -- local_type

--------------------------------------------------------------------------------
	
	print_type is
	-- for debugging only
		do	
			if is_fake_anchored then 
				write_string("fake "); 
			end;
			write_string("like "); 
			write_string(strings @ anchor); 
		end; 

invariant
	anchor /= 0;
end -- ANCHORED
