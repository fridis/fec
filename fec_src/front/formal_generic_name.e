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

class FORMAL_GENERIC_NAME
-- this handles Class_type, Class_type_expanded und Formal_generic_name

inherit
	TYPE
		redefine
			is_formal_generic,
			substitute,
			local_type_no_parent
		end;
	SCANNER_SYMBOLS;
	ACTUAL_CLASSES;
	
creation
	make
	
--------------------------------------------------------------------------------
	
feature { ANY }

	index: INTEGER;       -- Index in parse_class.formal_generic dieses Typs  

	formal_generic: FORMAL_GENERIC;  -- parse_class.formalge_generics @ index

--	position: POSITION;    -- (geerbt:) Position des Typs im Quelltext

--------------------------------------------------------------------------------

	make (new_index: INTEGER; new_formal_generic: FORMAL_GENERIC; new_position: POSITION) is 
	-- Formal_generic_name = Identifier.
		do
			index          := new_index;
			formal_generic := new_formal_generic;
			position       := new_position;
		end; -- parse

--------------------------------------------------------------------------------

feature { TYPE }

	base_type (fi: FEATURE_INTERFACE) : CLASS_TYPE is
		do
			Result := formal_generic.constraint.base_type(fi);
		end; -- base_type
		
--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	is_identical (fi: FEATURE_INTERFACE; 
	              other: TYPE) : BOOLEAN is
	-- testet, ob Current und other identisch sind.
		local
			other_formal_generic_name : FORMAL_GENERIC_NAME;
			i: INTEGER;
		do
			other_formal_generic_name ?= other;
			if other_formal_generic_name /= Void and then
			   index = other_formal_generic_name.index
			then
				Result := true
			end;
		end; -- is_identical
		
--------------------------------------------------------------------------------
		
	conforms_directly_to(fi: FEATURE_INTERFACE; 
	                     other: TYPE): BOOLEAN is
	-- testet, ob Current direkt other entspricht.
 		do
 		-- vncf:
 			if formal_generic.constraint.is_identical(fi,other) then
 				Result := true
 			end
 		end; -- conforms_directly_to

--------------------------------------------------------------------------------

	conforms_recursively(fi: FEATURE_INTERFACE;
	                     other: TYPE): BOOLEAN is
	-- testet VNCC: 5, ob ein U existiert so, da§ Current U entspricht und U
	-- other entspricht
 		do
 		-- vncf:
 			if formal_generic.constraint.is_conforming_to(fi,other) then
 				Result := true
 			end;
		end; -- conforms_recursively
		
feature { ANY }

	is_reference (fi: FEATURE_INTERFACE): BOOLEAN is
		do
			Result := false
		end; -- is_reference
		
	is_expanded (fi: FEATURE_INTERFACE): BOOLEAN is
		do
			Result := false
		end; -- is_expanded
		
	is_formal_generic : BOOLEAN is
		do
			Result := true
		end; -- is_formal_generic

--------------------------------------------------------------------------------

feature { CLASS_TYPE }

	substitute (actual: TYPE_LIST): TYPE is
		do
			if index <= actual.count then
				Result := actual @ index; 
			else
				Result := globals.type_any;
			end;
		end; -- substitute

--------------------------------------------------------------------------------

feature { ANY }

	ancestor_name (interface: CLASS_INTERFACE): ANCESTOR_NAME is
	-- Der Ancestor_name dieses Typs. 
		do
memstats(347);
			!!Result.make_formal_generic(index);
		end; -- ancestor_name

--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		local
			btc: CLASS_INTERFACE;
		do
			btc := base_class(fi);
		end; -- validity

--------------------------------------------------------------------------------

	view(parent: PARENT): TYPE is
	-- bestimmt die Sicht auf diesen Typ, wie er beim Erben von parent sich in
	-- der Tochterklasse ergibt. 
	-- Bsp: inherit STACK[INTEGER], wobei die Vaterklasse STACK[G] so ist
	-- "ARRAY[G]".view(interface,stack_parent) = "ARRAY[INTEGER]".
	-- entsprechend wird bei Anchored Types der Anchor verŠndert, wenn er
	-- umbenannt wurde.
		do
			if index <= parent.class_type.actual_generics.count then
				Result := parent.class_type.actual_generics @ index;
			else
				Result := Current
			end;
		end; -- view

	view_client (fi: FEATURE_INTERFACE; 
	             target: EXPRESSION; 
	             target_type: TYPE;
	             original: CLASS_INTERFACE): TYPE is
	-- bestimmt die Sicht auf diesen Typ, der aus der Klasse original stammt, 
	-- wie sie sich ergibt wenn die Klasse als actual_type verwendet wird.
		local
			ab: CLASS_TYPE;
		do
			if target_type /= Void then
				ab := target_type.base_type(fi); 
				if index <= ab.actual_generics.count then
					Result := ab.actual_generics @ index;
				else
					Result := globals.type_any;
				end
			else
				Result := Current
			end; 
		end; -- view_client

	view_constraint (fi: FEATURE_INTERFACE; 
	                 new_type: CLASS_TYPE): TYPE is
	-- bestimmt die Sicht auf diesen Constraint eines formal generics im
	-- Typ new_type.
		do
			if index <= new_type.actual_generics.count then
				Result := new_type.actual_generics @ index
			else
				Result := globals.type_any;
			end;
		end; -- view_constraint

--------------------------------------------------------------------------------

feature { ANY }

	add_to_uses (fi: FEATURE_INTERFACE) is
	-- FŸgt diesen Typ fi.interface.uses_types zu. Falls Current 
	-- Anchored ist, so wird der Typ des Ankers verwendet. 
	-- Dies mu§ Aufgerufen werden fŸr alle Typen, fŸr die Objekte
	-- alloziert werden, und fŸr expandierte lokale Bezeichner.
		do
			-- dies tut nichts, denn der generic steht nur fŸr eine aktuelle
			-- Klasse
		end -- add_to_uses

--------------------------------------------------------------------------------

	actual_class_name (actual: ACTUAL_CLASS_NAME): ACTUAL_CLASS_NAME is
	-- Der aktuelle Name des Typs in der aktuellen Klasse actual
		do
-- nyi: This may return "_ref" even if the real type is required, as for the actual generics of an expanded generic type!
--print("FGN.acn: "); actual.print_name; print(" @ "); print(index); print("%N");
			Result := actual.actual_generics @ index;
		end; -- actual_class_name

	actual_is_reference (code: ROUTINE_CODE): BOOLEAN is
	-- Ist der aktuelle Typ Referenztyp?
		local
			an,ag: ACTUAL_CLASS_NAME;
		do
			an := code.class_code.actual_class.key;
			if code.fi.parent_clause = Void then
				ag := an.actual_generics @ index;
			else
				ag := code.fi.ancestor.key.actual_class_name_of_generic(index,an)
			end;
			Result := not ag.actual_is_expanded;
		end; -- actual_is_reference

--------------------------------------------------------------------------------

	true_class_name (tcn: TRUE_CLASS_NAME; fi: FEATURE_INTERFACE): TRUE_CLASS_NAME is
	-- Get true_class_name of this type that is used within fi as seen in
	-- class tcn (tcn is the true class of fi.ancestor).
		do
			Result := tcn.actual_generics @ index;
		end; -- true_class_name

	true_class_name_code_parent (code: ROUTINE_CODE; no_parent: BOOLEAN): TRUE_CLASS_NAME is
	-- This tries to get the true_class_name of this type during compilation of
	-- a routine. NOTE: This might fail and return Void if the name can't be
	-- determined before system creation.
		local
			an: ACTUAL_CLASS_NAME;
		do
			an := code.class_code.actual_class.key;
			if not no_parent and then code.fi.parent_clause /= Void then
				an := code.fi.ancestor.key.actual_class_name(an);
			end;
			an := an.actual_generics @ index;
			if not an.has_refs_in_code_name then
				Result := an.true_class_name;
			end;
		end; -- true_class_name_code_parent

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	local_type(code: ROUTINE_CODE): LOCAL_TYPE is
	-- get local_type of this type as seen by routine code (code may be 
	-- inherited and Curren in this case is the type in the class of origin.
		do
			Result := actual_class_name_code(code).local_type;
		end; -- local_type

	local_type_no_parent(code: ROUTINE_CODE): LOCAL_TYPE is
	-- like local_type, but here Current is a type as seen in the class 
	-- currently compiled, even if the routine compile currenlt (code) is
	-- inherited.
	-- this routine is needed to implement unqualified calls to 
	-- standard_copy (which are inlined by the compiler)
		do
			Result := actual_class_name(code.class_code.actual_class.key).local_type;
		end; -- local_type_no_parent

--------------------------------------------------------------------------------
	
	print_type is
	-- for debugging only
		do	
			write_string(strings @ formal_generic.name); 
		end; 

end -- FORMAL_GENERIC_NAME
