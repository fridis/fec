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

deferred class TYPE

-- Ancestor to all Types.

inherit
	ACTUAL_CLASSES;

--------------------------------------------------------------------------------

feature { ANY }

	position: POSITION; -- Position des Typs im Quelltext

feature { TYPE, CLONE_AND_COPY, CALL, RUNTIME_CHECKS }

	base_type (fi: FEATURE_INTERFACE) : CLASS_TYPE is
		deferred
		end; -- base_type

feature { ANY }

	base_class (fi: FEATURE_INTERFACE): CLASS_INTERFACE is
		do
			Result := get_class(base_type(fi).name);
		end; -- base_class
	
--------------------------------------------------------------------------------

feature { ANY }

	ancestor_name (interface: CLASS_INTERFACE): ANCESTOR_NAME is
	-- Der Ancestor_name dieses Typs. Der Typ darf nicht ANCHORED sein.
		deferred
		end; -- ancestor_name

--------------------------------------------------------------------------------

feature { ANY }

	is_conforming_to(fi: FEATURE_INTERFACE; 
	            other: TYPE) : BOOLEAN is
	-- testet ob dieser Typ other entspricht. Ist dies der Fall, so ist das
	-- Ergebnis true
		do
			if Current = other or else
				other.is_any or else
			   is_identical(fi,other) or else
			   conforms_directly_to(fi,other) or else
			   is_none and other.is_reference(fi) or else
			   is_same_generic_with_conforming_arguments(fi,other) or else
			   other.is_reference(fi) and then conforms_recursively(fi,other) or else
			   other.is_fake_anchored and then is_conforming_to(fi,other.unfake_anchored(fi))
			then
				Result := true
			end;
		ensure
			-- Current conforms to other implies Result = Void
		end; -- is_conforming_to

	is_identical (fi: FEATURE_INTERFACE; 
	              other: TYPE) : BOOLEAN is
	-- testet, ob Current und other identisch sind.
		deferred
		end; -- is_identical

	conforms_directly_to(fi: FEATURE_INTERFACE; 
	                     other: TYPE): BOOLEAN is
	-- testet, ob Current direkt other entspricht.
		deferred
		end; -- conforms_directly_to

	is_any : BOOLEAN is
		do 
			Result := false
		end; -- is_any

	is_none : BOOLEAN is
	-- true wenn dieser type NONE ist.
		do
			Result := false;
		end; -- is_none
		
	is_integer: BOOLEAN is
		do
			Result := false;
		end; -- is_integer; 

	is_boolean: BOOLEAN is
		do
			Result := false;
		end; -- is_boolean;

	is_character: BOOLEAN is
		do
			Result := false;
		end; -- is_character;
	
	is_real: BOOLEAN is
		do
			Result := false
		end; 
		
	is_double: BOOLEAN is
		do
			Result := false
		end; -- is_double
		
	is_pointer: BOOLEAN is
		do
			Result := false
		end; -- is_pointer
		
	is_string: BOOLEAN is
		do
			Result := false
		end; -- is_string
		
	is_bit_type: BOOLEAN is
		do
			Result := false
		end; -- is_bit_type 

	is_reference (fi: FEATURE_INTERFACE): BOOLEAN is
	-- ACHTUNG: Für Formal_generic gilt: not is_reference and not is_expanded!
		deferred
		end; -- is_reference

	is_expanded (fi: FEATURE_INTERFACE): BOOLEAN is
		deferred
		end; -- is_expanded
		
feature { NONE }
		
	is_same_generic_with_conforming_arguments(fi: FEATURE_INTERFACE; 
	                                          other: TYPE): BOOLEAN is
	-- testet VNCC: 4. Current = B[..Yi..] und other = B[..Xi..] und jedes
	-- Yi entspricht Xi.
		do
			Result := false
		end -- is_same_generic_with_conforming_arguments

	conforms_recursively(fi: FEATURE_INTERFACE; other: TYPE): BOOLEAN is
	-- testet VNCC: 5, ob ein U existiert so, daß Current U entspricht und U
	-- other entspricht
		require
			other.is_reference(fi)
		deferred
		end; -- conforms_recursively

--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		deferred
		end; -- validity
			
--------------------------------------------------------------------------------
		
	is_formal_generic : BOOLEAN is
		do
			Result := false
		end; -- is_formal_generic
		
	is_anchored : BOOLEAN is
		do 
			Result := false
		end; -- is_anchored

	is_like_current : BOOLEAN is
		do
			Result := false
		end; -- is_like_current

	is_array : BOOLEAN is
	-- true für ARRAY[X]
		do
			Result := false
		end; -- is_array
		
	array_element_type : TYPE is
	-- X für ARRAY[X]
		require
			is_array
		do	
		end; -- array_element_type

--------------------------------------------------------------------------------

feature { TYPE }

	is_fake_anchored : BOOLEAN is
		do
			Result := false
		end; -- is_fake_anchored

	unfake_anchored (fi: FEATURE_INTERFACE) : TYPE is
		require
			is_fake_anchored
		do
		end; -- unfake_anchored

--------------------------------------------------------------------------------

feature { CLASS_TYPE }

	substitute (actual: TYPE_LIST): TYPE is
	-- beim Prüfen von VNCG verwendet um formale generische Parameter durch 
	-- aktuelle zu ersetzen.
		do
			Result := Current
		end; -- substitute
		
--------------------------------------------------------------------------------

feature { ANY }

	view(parent: PARENT): TYPE is
	-- bestimmt die Sicht auf diesen Typ, wie er beim Erben von parent sich in
	-- der Tochterklasse ergibt. 
	-- Bsp: inherit STACK[INTEGER], wobei die Vaterklasse STACK[G] so ist
	-- "ARRAY[G]".view(interface,stack_parent) = "ARRAY[INTEGER]".
	-- entsprechend wird bei Anchored Types der Anchor verändert, wenn er
	-- umbenannt wurde.
		deferred
		end; -- view

	view_client (fi: FEATURE_INTERFACE; 
	             target: EXPRESSION; 
	             target_type: TYPE;
	             original: CLASS_INTERFACE): TYPE is
	-- bestimmt die Sicht auf diesen Typ, der aus der Klasse original stammt, 
	-- wie sie sich bei einem Aufruf mit target als Ziel ergibt. target,
	-- target_type und original können alle auch Void sein. 
		deferred
		end; -- view_client

	view_constraint (fi: FEATURE_INTERFACE; 
	                 new_type: CLASS_TYPE): TYPE is
	-- bestimmt die Sicht auf diesen Constraint eines formal generics im
	-- Typ new_type.
		deferred
		end; -- view_constraint

--------------------------------------------------------------------------------

feature { FORMAL_GENERIC }

	get_formal_generic_type(formal_generics: FORMAL_GENERIC_LIST; 
	                        must_not_be: INTEGER): TYPE is
	-- Dies wird aufgerufen für die Typen die in den Formal_generics vorkommen
	-- und auf generische Parameter verweisen können, die noch nicht geparst
	-- wurden. Das Ergebnis ist der gleiche Typ, wobei jedoch alle
	-- Class_types, die formal_generics sind, durch FORMAL_GENERIC_NAME ersetzt
	-- wurden
		do
			Result := Current; 
		end; -- get_formal_generic_type

--------------------------------------------------------------------------------

feature { FEATURE_DECLARATION, TYPE }

	get_anchors_to_formal_arguments (formals: ENTITY_DECLARATION_LIST) is
	-- Sucht nach Anchored Types für formale Argumente und trägt für sie die
	-- ACHORED.argument_number ein
		do
		end; -- get_anchors_to_formal_arguments

--------------------------------------------------------------------------------

feature { ANY }

	add_to_uses (fi: FEATURE_INTERFACE) is
	-- Fügt diesen Typ fi.interface.uses_types zu. Falls Current 
	-- Anchored ist, so wird der Typ des Ankers verwendet. 
	-- Dies muß Aufgerufen werden für alle Typen, für die Objekte
	-- alloziert werden, und für expandierte lokale Bezeichner.
		deferred
-- do something like: fi.interface.uses_types.add(Current);
		end -- add_to_uses

--------------------------------------------------------------------------------

feature { ANY }

	actual_class_name (actual: ACTUAL_CLASS_NAME): ACTUAL_CLASS_NAME is
	-- Der aktuelle Name des Typs in der aktuellen Klasse actual
		require
			not is_anchored
		deferred
		end; -- actual_class_name

	actual_class_name_code (code: ROUTINE_CODE): ACTUAL_CLASS_NAME is
	-- Abbreviation for actual_class_name(code.class_code.actual_class.key), 
	-- but also works while duplicating inherited feature.
	-- May also be used for anchored types.
		local
			an: ACTUAL_CLASS_NAME;
		do
			an := code.class_code.actual_class.key;
			if code.fi.parent_clause /= Void then
				an := code.fi.ancestor.key.actual_class_name(an);
			end;
			Result := actual_class_name(an);
		end; -- actual_class_name_code

	actual_class_name_code_no_parent (code: ROUTINE_CODE): ACTUAL_CLASS_NAME is
	-- like actual_class_name_code, but Current is a type as seen within the actual_class
	-- of code, not its class of origin.
	-- This is only needed to implement standard_copy and for a static call to 
	-- a precondition routine in an unqualified call within a duplicated routine.
		do
			Result := actual_class_name(code.class_code.actual_class.key);
		end; -- actual_class_name_code

	actual_is_reference (code: ROUTINE_CODE): BOOLEAN is
	-- Ist der aktuelle Typ Referenztyp?
		deferred
		end; -- actual_is_reference

	actual_class_code (code: ROUTINE_CODE): ACTUAL_CLASS is
	-- like actual_class_name_code, directly returns the actual_class.
		do
			Result := actual_classes.find(actual_class_name_code(code));
if Result = Void then 
	print("%N**** "); print_type; print(" in "); code.class_code.actual_class.key.print_name; print("%N");
	check false end;
end;
		end; -- actual_class_code

	actual_class_code_no_parent (code: ROUTINE_CODE): ACTUAL_CLASS is
	-- like actual_class_name_code_no_parent, directly returns the actual_class.
		do
			Result := actual_classes.find(actual_class_name_code_no_parent(code));
		end; -- actual_class_code

	actual_class (actual: ACTUAL_CLASS_NAME): ACTUAL_CLASS is
	-- like actual_class_name, directly returns the actual_class.
		do
			Result := actual_classes.find(actual_class_name(actual));
		end; -- actual_class

--------------------------------------------------------------------------------

	true_class_name (tcn: TRUE_CLASS_NAME; fi: FEATURE_INTERFACE): TRUE_CLASS_NAME is
	-- Get true_class_name of this type that is used within fi as seen in
	-- class tcn (tcn is the true class of fi.ancestor).
		deferred
		end; -- true_class_name

	true_class_name_code (code: ROUTINE_CODE): TRUE_CLASS_NAME is
	-- This tries to get the true_class_name of this type during compilation of
	-- a routine. NOTE: This might fail and return Void if the name can't be
	-- determined before system creation.
		do
			Result := true_class_name_code_parent(code,false);
		end; -- true_class_name_code

	true_class_name_code_parent (code: ROUTINE_CODE; no_parent: BOOLEAN): TRUE_CLASS_NAME is
	-- like true_class_name_code, but here Current is a type as seen in the class 
	-- currently compiled, even if the routine compiled currently (code) is
	-- inherited.
	-- this routine is needed to implement unqualified calls to 
	-- standard_copy (which are inlined by the compiler)
		deferred
		end; -- true_class_name_code
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	local_type(code: ROUTINE_CODE): LOCAL_TYPE is
	-- get local_type of this type as seen by routine code (code may be 
	-- inherited and Current in this case is the type in the class of origin.
		deferred
		end; -- local_type

	local_type_no_parent(code: ROUTINE_CODE): LOCAL_TYPE is
	-- like local_type, but here Current is a type as seen in the class 
	-- currently compiled, even if the routine compiled currently (code) is
	-- inherited.
	-- this routine is needed to implement unqualified calls to 
	-- standard_copy (which are inlined by the compiler)
		do
			Result := local_type(code);
		end; -- local_type_no_parent

--------------------------------------------------------------------------------

feature { ANY }
	
	print_type is
	-- for debugging only
		deferred
		end; 
	
end -- TYPE
