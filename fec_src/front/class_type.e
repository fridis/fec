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

class CLASS_TYPE 
-- this handles Class_type, Class_type_expanded und Formal_generic_name

inherit
	TYPE
		redefine
			is_any,
			is_none, 
			is_integer,
			is_boolean,
			is_character,
			is_real,
			is_double,
			is_pointer,
			is_string,
			is_same_generic_with_conforming_arguments, 
			get_formal_generic_type,
			get_anchors_to_formal_arguments,
			is_array,
			array_element_type,
			substitute
		end;
	SCANNER_SYMBOLS;
	ACTUAL_CLASSES;
	FRIDISYS;
	
creation
	parse, 
	parse_expanded,
	make_any,
	make_standard,
	make_bit,
	make_like_current, 
	make_current, 
	make_reference,
	make_class_type,
	make_new_actuals,
	make_array_of_any

--------------------------------------------------------------------------------
	
feature { ANY }

	name: INTEGER;                       -- der Class-Name in Großbuchstaben

	is_explicitly_expanded: BOOLEAN;    -- für "expanded CT"
	
	is_explicitly_reference: BOOLEAN;   -- für "like Current" 

	actual_generics : TYPE_LIST;

--	position: POSITION;    -- (geerbt:) Position des Typs im Quelltext

feature { NONE }

	empty_actual_generics : TYPE_LIST is
		once
memstats(54);
			!!Result.clear;
		ensure
			Result /= Void		
		end; -- empty_actual_generics

--------------------------------------------------------------------------------

feature { ANY }

	parse (s: SCANNER; may_be_anchored: BOOLEAN) is 
	-- Class_type = Class_Name [Actual_generics].
	-- Actual_generics = "[" Type_list "]".
		do
			is_explicitly_expanded := false;
			is_explicitly_reference := false;
			position := s.current_symbol.position;
			s.check_and_get_identifier(msg.id_cls_expected);	 
			name := s.last_identifier;
			if s.current_symbol.type = s_left_bracket then
				s.next_symbol;
memstats(55);
				!!actual_generics.parse(s,may_be_anchored);
				s.check_right_bracket(msg.rbk_ag_expected); 
			else
				actual_generics := empty_actual_generics;				
			end;
		ensure
			not is_explicitly_expanded;
			not is_explicitly_reference;
			name /= 0;
			actual_generics /= Void
		end; -- parse

	parse_expanded (s: SCANNER; may_be_anchored: BOOLEAN) is
	-- Class_type_expanded = "expanded" Class_type;
		require
			s.current_symbol.type = s_expanded
		do
			s.next_symbol;
			parse(s,may_be_anchored);
			is_explicitly_expanded := true;
		ensure 
			is_explicitly_expanded;
			not is_explicitly_reference;
			name /= 0;
			actual_generics /= Void
		end; 	
		
	make_any is 
		do
			name := globals.string_any
			is_explicitly_expanded := false;
			is_explicitly_reference := false;
			actual_generics := empty_actual_generics;				
		ensure
			actual_generics /= Void		
		end; -- make_any
		
	make_standard(new_name: INTEGER) is 
	-- für BOOLEAN, INTEGER, etc.
		do
			name := new_name;
			is_explicitly_expanded := false;
			is_explicitly_reference := false;
			actual_generics := empty_actual_generics;	
		ensure
			actual_generics /= Void		
		end; -- make_standard
		
	make_bit is 
		do
			name := globals.string_bit_n;
			is_explicitly_expanded := false;
			is_explicitly_reference := false;
			actual_generics := empty_actual_generics;				
		ensure
			actual_generics /= Void		
		end; -- make_any

	make_like_current (interface: CLASS_INTERFACE) is
	-- Referenztyp für "like Current".
		do
			name := interface.key;
			is_explicitly_expanded := false;
			is_explicitly_reference := interface.parse_class.is_expanded;
			if interface.parse_class.formal_generics.is_empty then
				actual_generics := empty_actual_generics;
			else
memstats(56);
				!!actual_generics.make_from_formal_generics(interface.parse_class.formal_generics);
			end;
		ensure
			actual_generics /= Void		
		end; -- make_like_current

	make_current (interface: CLASS_INTERFACE) is
	-- der Typ des Bezeichners "Current"
		do
			name := interface.key;
			is_explicitly_expanded := false;
			is_explicitly_reference := false;
			if interface.parse_class.formal_generics.is_empty then
				actual_generics := empty_actual_generics
			else
memstats(57);
				!!actual_generics.make_from_formal_generics(interface.parse_class.formal_generics);
			end;
		ensure
			actual_generics /= Void		
		end; -- make_current

	make_reference (src: CLASS_TYPE) is
	-- erzeugt einen Referenztyp aus src
		do 
			name := src.name;
			is_explicitly_expanded := false;
			if name = globals.string_none then
				is_explicitly_reference := false
			else
				is_explicitly_reference := get_class(name).parse_class.is_expanded;
			end;
			actual_generics := src.actual_generics;
		ensure
			actual_generics /= Void		
		end;

	make_class_type (new_name: INTEGER; new_actual_generics: TYPE_LIST) is
	-- erzeugt einen CLASS_TYPE name[actuals]
		do 
			name := new_name;
			is_explicitly_expanded := false;
			is_explicitly_reference := false;
			actual_generics := new_actual_generics;
		ensure
			actual_generics /= Void		
		end;
		
	make_new_actuals (src: CLASS_TYPE; new_actual_generics: TYPE_LIST) is
	-- erzeugt den gleichen CLASS_TYPE mit neuen aktuellen generischen Parametern
		do
			name                  := src.name;
			is_explicitly_expanded  := src.is_explicitly_expanded;
			is_explicitly_reference := src.is_explicitly_reference;
			actual_generics       := new_actual_generics;
		ensure
			actual_generics /= Void		
		end; -- make_new_actuals
		
	make_array_of_any is 
		do
			name := globals.string_array;
			is_explicitly_expanded := false;
			is_explicitly_reference := false;
memstats(58);
			!!actual_generics.clear;
			actual_generics.add(globals.type_any);				
		ensure
			actual_generics /= Void		
		end; -- make_arry_of_any

--------------------------------------------------------------------------------
		
feature { TYPE }

	base_type (fi: FEATURE_INTERFACE) : CLASS_TYPE is
		do
			Result := Current;
		end; -- base_type

--------------------------------------------------------------------------------
-- VALIDITY ÜBERPRÜFUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	is_identical (fi: FEATURE_INTERFACE; 
	              other: TYPE) : BOOLEAN is
	-- testet, ob Current und other identisch sind.
		local
			other_class_type : CLASS_TYPE;
			i: INTEGER;
		do
			other_class_type ?= other;
			if other_class_type /= Void and then
			   name = other_class_type.name 
			then
				if is_explicitly_expanded  = other_class_type.is_explicitly_expanded and
				   is_explicitly_reference = other_class_type.is_explicitly_reference and
				   actual_generics.count   = other_class_type.actual_generics.count
				then
					from 
						i := 1
					until
						i > actual_generics.count or else
						not (actual_generics @ i).is_identical(fi,other_class_type.actual_generics @ i)
					loop
						i := i + 1
					end; 
					Result := i > actual_generics.count;
				end;
			end;
		end; -- is_identical
		
	is_identical_disregarding_ref_and_expanded (
		fi: FEATURE_INTERFACE; 
	    other: TYPE) : BOOLEAN is
	-- testet, ob Current und other identisch sind bis auf, daß sie Referenz bzw. Expanded sind
		local
			other_class_type : CLASS_TYPE;
			i: INTEGER;
		do
			other_class_type ?= other;
			if other_class_type /= Void and then
				name = other_class_type.name and then
			   actual_generics.count   = other_class_type.actual_generics.count
			then
				from 
					i := 1
				until
					i > actual_generics.count or else
					not (actual_generics @ i).is_identical(fi,other_class_type.actual_generics @ i)
				loop
					i := i + 1
				end; 
				Result := i > actual_generics.count;
			end;
		end; -- is_identical_disregarding_ref_and_expanded

--------------------------------------------------------------------------------
		
	conforms_directly_to(fi: FEATURE_INTERFACE; 
	                     other: TYPE): BOOLEAN is
	-- testet, ob Current direkt other entspricht.
		local
			other_ct: CLASS_TYPE;
 		do
 			other_ct ?= other; 
 			if other_ct /= Void then
	 			if vncn_and_vncg(fi,other_ct) or else
 				   vnce         (fi,other_ct)
 				then
 					Result := true;
 				end;
 			end;
		end; -- conforms_directly_to

	vnce (fi: FEATURE_INTERFACE; 
	      other: CLASS_TYPE): BOOLEAN is
	-- testet conformance nach vnce
		do
			if is_identical_disregarding_ref_and_expanded(fi,other) then
 			-- vnce 1
 				Result := true
 			else
 			-- vnce 2
 				if is_integer then
 					Result := other.is_real or else
 					          other.is_double;
 				elseif is_real then
 					Result := other.is_double; 
 				end;
 			end;
 		end -- vnce	
 
 	vncn_and_vncg(fi: FEATURE_INTERFACE; 
	              other: CLASS_TYPE): BOOLEAN is
	-- testet conformance nach vncn und vncg
		local
			i,j: INTEGER;
 			pc: PARSE_CLASS;
 			p: PARENT;
 			sub: TYPE;
		do
 			-- vncn & vncg:
 			if other.is_reference(fi) then
 				if is_none then
 					Result := true
 				else
	 				pc := get_class(name).parse_class; 
		 			from
		 				i := 1
		 			until
		 				Result or else
		 				i > pc.parents.count
		 			loop
		 				p := pc.parents @ i;
		 				if other.name = p.class_type.name and then
		 				   other.actual_generics.count = p.class_type.actual_generics.count
		 				then
		 					Result := true;
		 					from
		 						j := 1
		 					until 
		 						j > p.class_type.actual_generics.count
		 					loop
		 						sub := (p.class_type.actual_generics @ j).substitute(actual_generics);
		 						if not sub.is_identical(fi,other.actual_generics @ j) then
		 							Result := false
		 						end;
		 						j := j + 1;
		 					end;
		 				end;
		 				i := i + 1;
		 			end;
		 		end;
		 	end;
		end; -- vncn_and_vncg

--------------------------------------------------------------------------------

	conforms_recursively(fi: FEATURE_INTERFACE;
	                     other: TYPE): BOOLEAN is
	-- testet VNCC: 5, ob ein U existiert so, daß Current U entspricht und U
	-- other entspricht
		local
			other_ct: CLASS_TYPE;
 		do
 			other_ct ?= other; 
 			if other_ct /= Void then
 	 			if vncn_and_vncg_recursive(fi,other_ct) or else
 				   vnce_recursive         (fi,other_ct)
 				then
 					Result := true;
 				end;
 			end;
		end; -- conforms_recursively

	vnce_recursive (fi: FEATURE_INTERFACE; 
	      other: CLASS_TYPE): BOOLEAN is
	-- testet conformance nach vnce
		local
			ref: CLASS_TYPE;
		do
			if is_explicitly_expanded then
memstats(59);
				!!ref.make_reference(Current); 
				Result := ref.is_conforming_to(fi,other);
			end;
 		end -- vnce	
 
 	vncn_and_vncg_recursive(fi: FEATURE_INTERFACE; 
	              other: CLASS_TYPE): BOOLEAN is
	-- testet conformance nach vncn und vncg
		local
			i,j: INTEGER;
 			pc: PARSE_CLASS;
 			p: PARENT;
 			parent_ci: CLASS_INTERFACE;
 			sub: TYPE;
 			new_actuals: TYPE_LIST;
 			new_ct: CLASS_TYPE;
		do
 			-- vncn & vncg:
			if other.is_reference(fi) then
 				pc := get_class(name).parse_class; 
	 			from
	 				i := 1
	 			until
	 				Result or else
	 				i > pc.parents.count
	 			loop
	 				p := pc.parents @ i;
	 				parent_ci := p.class_type.base_class(fi);
	 				if p.class_type.actual_generics.count = 0 then
	 					new_actuals := empty_actual_generics
	 				else
	 					from
 							j := 1;
memstats(60);
							!!new_actuals.clear
 						until 
 							j > p.class_type.actual_generics.count
 						loop
 							sub := (p.class_type.actual_generics @ j).substitute(actual_generics);
 							new_actuals.add_tail(sub);
 							j := j + 1;
 						end;
 					end;
memstats(61);
 					!!new_ct.make_class_type(p.class_type.name,new_actuals);
-- write_string("vncn: old = "); print_type; write_string(" new = "); new_ct.print_type; write_string(" parent = "); write_string(p.class_type.name); write_string("%N"); 
 					Result := new_ct.is_conforming_to(fi,other);
--if Result then
-- 	write_string("Success!%N"); 
-- else
-- 	write_string("No success!%N");
-- end; 
	 				i := i + 1;
	 			end;
	 		end;
		end; -- vncn_and_vncg

feature { CLASS_TYPE }

	substitute (actual: TYPE_LIST): TYPE is
		local
			i: INTEGER;
			new_actuals: TYPE_LIST;
		do
			if actual_generics.count = 0 then
				Result := Current
			else
				from
					i := 1;
memstats(62);
					!!new_actuals.clear;
				until
					i > actual_generics.count
				loop
					new_actuals.add((actual_generics @ i).substitute(actual));
					i := i + 1;
				end;
memstats(63);
				!CLASS_TYPE!Result.make_new_actuals(Current,new_actuals);
			end; 
		end; -- substitute

--------------------------------------------------------------------------------
		
feature { ANY }

	is_any : BOOLEAN is
		do
			Result := not is_explicitly_expanded and name = globals.string_any;
		end -- is_any;

	is_none : BOOLEAN is
		do
			Result := name = globals.string_none;
		end -- is_none;

	is_integer: BOOLEAN is
		do
			Result := not is_explicitly_reference and name = globals.string_integer;
		end; -- is_integer; 

	is_boolean: BOOLEAN is
		do
			Result := not is_explicitly_reference and name = globals.string_boolean;
		end; -- is_boolean;	

	is_character: BOOLEAN is
		do
			Result := not is_explicitly_reference and name = globals.string_character;
		end; -- is_character;
	
	is_real: BOOLEAN is
		do
			Result := not is_explicitly_reference and name = globals.string_real;
		end; 
		
	is_double: BOOLEAN is
		do
			Result := not is_explicitly_reference and name = globals.string_double;
		end; -- is_double
		
	is_pointer: BOOLEAN is
		do
			Result := not is_explicitly_reference and name = globals.string_pointer;
		end; -- is_pointer
		
	is_string: BOOLEAN is
		do
			Result := not is_explicitly_expanded and name = globals.string_string;
		end; -- is_string

--------------------------------------------------------------------------------
		
	is_reference (fi: FEATURE_INTERFACE): BOOLEAN is
		do
			if is_explicitly_expanded then
				Result := false
			elseif is_explicitly_reference then
				Result := true
			elseif name = globals.string_none then
				Result := true
			else
				Result := not get_class(name).parse_class.is_expanded
			end;
		end; -- is_reference
		
	is_expanded (fi: FEATURE_INTERFACE): BOOLEAN is
		do
			Result := not is_reference(fi)
		end; -- is_expanded

	is_same_generic_with_conforming_arguments(fi: FEATURE_INTERFACE;
	                                          other: TYPE): BOOLEAN is
	-- testet VNCC: 4. Current = B[..Yi..] und other = B[..Xi..] und jedes
	-- Yi entspricht Xi.
		local
			other_class_type: CLASS_TYPE;
			generic: ACTUAL_CLASS_NAME;
			i: INTEGER;
		do
			other_class_type ?= other; 
			if other_class_type /= Void then
				if not is_expanded(fi) and then 
					not other_class_type.is_expanded(fi) and then
					name = other_class_type.name 
				then
					from 
						i := 1
					until
						i > actual_generics.count or else
						not (actual_generics @ i).is_conforming_to(fi,other_class_type.actual_generics @ i)
					loop
						i := i + 1
					end; 
					Result := i > actual_generics.count;
				end;
			end;
		end -- is_same_generic_with_conforming_arguments

--------------------------------------------------------------------------------

	is_array : BOOLEAN is
		do
			Result := name = globals.string_array;
		end; -- is_array
		
	array_element_type : TYPE is
		do
			if actual_generics.count > 0 then
				Result := actual_generics @ 1
			else
				Result := Current
			end; 
		end; -- array_element_type

--------------------------------------------------------------------------------

feature { ANY }

	ancestor_name (interface: CLASS_INTERFACE): ANCESTOR_NAME is
	-- Der Ancestor_name dieses Typs. 
		local
			generics: LIST[ANCESTOR_NAME];
			i: INTEGER;
		do
			if not actual_generics.is_empty then
memstats(321);
				!!generics.make;
				from
					i := 1
				until
					i > actual_generics.count
				loop
					generics.add((actual_generics @ i).ancestor_name(interface));
					i := i + 1;
				end;
			end;
memstats(322);
			!!Result.make_class_type(name,generics);
		end; -- ancestor_name

--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		local
			btc: CLASS_INTERFACE; 
		do
			btc := base_class(fi);
			vtct(fi,btc);
			vtec(fi,btc);
			vtuc_vtcg(fi,btc);
		end; -- validity

	vtct (fi: FEATURE_INTERFACE; btc: CLASS_INTERFACE) is
		do
			if btc.is_dummy then
				position.error(msg.vtct1);
			end;
		end; -- vtct
		
	vtec (fi: FEATURE_INTERFACE; btc: CLASS_INTERFACE) is
		local
			creators: LIST[CREATION_ITEM]
			ci: CREATION_ITEM;
			btc_fi: FEATURE_INTERFACE;
		do
			if is_expanded(fi) then
				if btc.parse_class.is_deferred then
					position.error(msg.vtec1);
				end;
				creators := btc.parse_class.creators;
				if creators /= Void then
					if creators.count > 1 then
						position.error(msg.vtec2);
					elseif creators.count = 1 then
						ci := creators @ 1;
						if ci.clients /= Void and then ci.clients.is_available_to(fi.interface) then
							position.error(msg.vtec3);
						else
							btc_fi := btc.feature_list.find(ci.name);
							if btc_fi /= Void then
								if not btc_fi.formal_arguments.is_empty then
									position.error(msg.vtec4);
								end;
							end;
						end;
					end;
				end;
			end;
		end; -- vtec

	vtuc_vtcg (fi: FEATURE_INTERFACE; btc: CLASS_INTERFACE) is
		local
			i: INTEGER;
			pos: POSITION; -- sebug: Nur wegen BUG in SE
			constr: TYPE;
			formal_generics: LIST[FORMAL_GENERIC];
		do
			formal_generics := btc.parse_class.formal_generics;
			if formal_generics.count /= actual_generics.count then
				if formal_generics.count = 0 then 
					position.error(msg.vtug1);
				elseif actual_generics.count = 0 then
					position.error(msg.vtug2);
				else
					position.error(msg.vtug3);
				end;
			else
				from
					i := 1; 
				until
					i > actual_generics.count
				loop
					(actual_generics @ i).validity(fi);
					constr := (formal_generics @ i).constraint.view_constraint(fi,Current);
					if not (actual_generics @ i).is_conforming_to(fi,constr) then
--write_string("actual = "); (actual_generics @ i).print_type;
--write_string(" constr = "); constr.print_type; 
--write_string(" constr was = "); (formal_generics @ i).constraint.print_type; 
--write_string("%N");
						pos := (actual_generics @ i).position;
						pos.error(msg.vtcg1);
					end;
					i := i + 1
				end;
			end;
		end; -- vtuc_vtcg

--------------------------------------------------------------------------------

	view(parent: PARENT): TYPE is
	-- bestimmt die Sicht auf diesen Typ, wie er beim Erben von parent sich in
	-- der Tochterklasse ergibt. 
	-- Bsp: inherit STACK[INTEGER], wobei die Vaterklasse STACK[G] so ist
	-- "ARRAY[G]".view(interface,stack_parent) = "ARRAY[INTEGER]".
	-- entsprechend wird bei Anchored Types der Anchor verändert, wenn er
	-- umbenannt wurde.
		local
			i,j: INTEGER;
			new_actuals: TYPE_LIST;
			actual,new_actual: TYPE;
		do
			if actual_generics.is_empty then
				Result := Current
			else
			-- eine neue actual_generics List wird nur dann erzeugt, wenn
			-- mindestens eines der actuals sich durch view ändert.
				from
					i := 1;
					new_actuals := Void;
				until 
					i > actual_generics.count
				loop
					actual := (actual_generics @ i);
					new_actual := actual.view(parent);
					if new_actual /= actual and new_actuals = Void then
memstats(64);
						!!new_actuals.clear;
						from 
							j := 1
						until
							j = i
						loop
							new_actuals.add_tail(actual_generics @ j);
							j := j + 1;
						end;
					end;
					if new_actuals /= Void then
						new_actuals.add_tail(new_actual);
					end;						
					i := i + 1;
				end;
				if new_actuals /= Void then
memstats(65);
					!CLASS_TYPE!Result.make_new_actuals(Current,new_actuals);
				else
					Result := Current
				end;
			end; 
		end; -- view

	view_client (fi: FEATURE_INTERFACE; 
	             target: EXPRESSION; 
	             target_type: TYPE;
	             original: CLASS_INTERFACE): TYPE is
	-- bestimmt die Sicht auf diesen Typ, der aus der Klasse original stammt, 
	-- wie sie sich ergibt wenn die Klasse als actual_type verwendet wird.
		local
			i,j: INTEGER; 
			new_actuals: TYPE_LIST;
			actual, new_actual: TYPE;
		do
			if actual_generics.is_empty then
				Result := Current
			else
			-- eine neue actual_generics List wird nur dann erzeugt, wenn
			-- mindestens eines der actuals sich durch view ändert.
				from
					i := 1;
					new_actuals := Void;
				until 
					i > actual_generics.count
				loop
					actual := (actual_generics @ i);
					new_actual := actual.view_client(fi,target,target_type,original);
					if new_actual /= actual and new_actuals = Void then
memstats(66);
						!!new_actuals.clear;
						from 
							j := 1
						until
							j = i
						loop
							new_actuals.add_tail(actual_generics @ j);
							j := j + 1;
						end;
					end;
					if new_actuals /= Void then
						new_actuals.add_tail(new_actual);
					end;						
					i := i + 1;
				end;
				if new_actuals /= Void then
memstats(67);
					!CLASS_TYPE!Result.make_new_actuals(Current,new_actuals);
				else
					Result := Current
				end;
			end;
		end; -- view_client

	view_constraint (fi: FEATURE_INTERFACE; 
	                 new_type: CLASS_TYPE): TYPE is
	-- bestimmt die Sicht auf diesen Constraint eines formal generics im
	-- Typ new_type.
		local
			i,j: INTEGER; 
			new_actuals: TYPE_LIST;
			actual, new_actual: TYPE;
		do
			if actual_generics.is_empty then
				Result := Current
			else
			-- eine neue actual_generics List wird nur dann erzeugt, wenn
			-- mindestens eines der actuals sich durch view ändert.
				from
					i := 1;
					new_actuals := Void;
				until 
					i > actual_generics.count
				loop
					actual := (actual_generics @ i);
					new_actual := actual.view_constraint(fi,new_type);
					if new_actual /= actual and new_actuals = Void then
memstats(68);
						!!new_actuals.clear;
						from 
							j := 1
						until
							j = i
						loop
							new_actuals.add_tail(actual_generics @ j);
							j := j + 1;
						end;
					end;
					if new_actuals /= Void then
						new_actuals.add_tail(new_actual);
					end;						
					i := i + 1;
				end;
				if new_actuals /= Void then
memstats(69);
					!CLASS_TYPE!Result.make_new_actuals(Current,new_actuals);
				else
					Result := Current
				end;
			end;
		end; -- view_constraint
			
--------------------------------------------------------------------------------

feature { CLASS_TYPE }
	
	get_fg_type(formal_generics: FORMAL_GENERIC_LIST;
	            must_not_be: INTEGER;
	            first: BOOLEAN): TYPE is
	-- Dies wird aufgerufen für die Typen die in den Formal_generics vorkommen
	-- und auf generische Parameter verweisen können, die noch nicht geparst
	-- wurden. Das Ergebnis ist der gleiche Typ, wobei jedoch alle
	-- Class_types, die formal_generics sind, durch FORMAL_GENERIC_NAME ersetzt
	-- wurden
	-- Ist first true, dann werden nur die actual_generics betrachtet. 
		local
			i: INTEGER;
			ct: CLASS_TYPE;
		do
			Result := Current;
			if not is_explicitly_expanded and then
			   actual_generics.is_empty
			then
				from
					i := 1;
				until
					i > formal_generics.count or else
					name = (formal_generics @ i).name
				loop
					i := i + 1;
				end;
				if first and (i < formal_generics.count) or else 
				   name = must_not_be then
					position.error(msg.rec_generic);
memstats(70);
					!CLASS_TYPE!Result.make_any;
				else
					if 	i <= formal_generics.count then
memstats(71);
						!FORMAL_GENERIC_NAME!Result.make(i,formal_generics @ i,position);
					end;
				end;
			else
				from 
					i := 1
				until
					i > actual_generics.count
				loop
					ct ?= actual_generics @ i; 
					if ct /= Void then
						actual_generics.replace(ct.get_fg_type(formal_generics,must_not_be,false),i);
					end;
					i := i + 1
				end;
			end;
		ensure
			first implies Result = Current
		end; -- get_fg_type

feature { FORMAL_GENERIC }
	
	get_formal_generic_type(formal_generics: FORMAL_GENERIC_LIST;
	                        must_not_be: INTEGER): CLASS_TYPE is
	-- Dies wird aufgerufen für die Typen die in den Formal_generics vorkommen
	-- und auf generische Parameter verweisen können, die noch nicht geparst
	-- wurden. Das Ergebnis ist der gleiche Typ, wobei jedoch alle
	-- Class_types, die formal_generics sind, durch FORMAL_GENERIC_NAME ersetzt
	-- wurden
	-- must_not_be kann Void sein, 
		do
			Result ?= get_fg_type(formal_generics,must_not_be,true);
		end; -- get_formal_generic_type

--------------------------------------------------------------------------------

feature { FEATURE_DECLARATION, TYPE }

	get_anchors_to_formal_arguments (formals: ENTITY_DECLARATION_LIST) is
	-- Sucht nach Anchored Types für formale Argumente und trägt für sie die
	-- ACHORED.argument_number ein
		local
			i: INTEGER; 
		do
			from
				i := 1
			until
				i > actual_generics.count
			loop
				(actual_generics @ i).get_anchors_to_formal_arguments(formals); 
				i := i + 1
			end; 
		end; -- get_anchors_to_formal_arguments

--------------------------------------------------------------------------------
	
feature { ANY }
	
	print_type is
	-- for debugging only
		local
			i: INTEGER;
		do	
			if is_explicitly_expanded then write_string("expanded ") end; 
			if is_explicitly_reference then write_string("reference ") end; 
			write_string(strings @ name); 
			if not actual_generics.is_empty then
				write_string("["); 
				from
					(actual_generics @ 1).print_type; 
					i := 2
				until
					i > actual_generics.count
				loop
					write_string(","); 
					(actual_generics @ i).print_type; 
					i := i + 1
				end;
				write_string("]"); 
			end; 
		end; 

--------------------------------------------------------------------------------

feature { ANY }

	add_to_uses (fi: FEATURE_INTERFACE) is
	-- Fügt diesen Typ fi.interface.uses_types zu. Falls Current 
	-- Anchored ist, so wird der Typ des Ankers verwendet. 
	-- Dies muß Aufgerufen werden für alle Typen, für die Objekte
	-- alloziert werden, und für expandierte lokale Bezeichner.
		local
			i: INTEGER; 
		do
			if not is_none then
				fi.interface.uses_types.add(Current);
			end;
			from
				i := 1
			until
				i > actual_generics.count
			loop
				(actual_generics @ i).add_to_uses(fi);
				i := i + 1;
			end;
		end -- add_to_uses

--------------------------------------------------------------------------------

	actual_class_name (actual: ACTUAL_CLASS_NAME): ACTUAL_CLASS_NAME is
	-- Der aktuelle Name des Typs in der aktuellen Klasse actual
		local
			list: LIST[ACTUAL_CLASS_NAME];
			i: INTEGER; 
		do
			if previous_actual/=actual then
				if not actual_generics.is_empty then
memstats(72);
					!!list.make;
					from
						i := 1
					until
						i > actual_generics.count
					loop
						list.add_tail((actual_generics @ i).actual_class_name(actual));
						i := i + 1;
					end;
				end;
memstats(73);
				!!previous_actual_class_name.make(name,is_explicitly_expanded,is_explicitly_reference,list);
				previous_actual := actual;
			end;
			Result := previous_actual_class_name;
		end; -- actual_class_name

	actual_is_reference (code: ROUTINE_CODE): BOOLEAN is
	-- Ist der aktuelle Typ Referenztyp?
		do
			Result := is_explicitly_reference or else
			          not is_explicitly_expanded and then 
			          not get_class(name).parse_class.is_expanded;
		end; -- actual_is_reference

feature { NONE }

	previous_actual_class_name: ACTUAL_CLASS_NAME; 
	previous_actual: ACTUAL_CLASS_NAME;

--------------------------------------------------------------------------------

	true_class_name (tcn: TRUE_CLASS_NAME; fi: FEATURE_INTERFACE): TRUE_CLASS_NAME is
	-- Get true_class_name of this type that is used within fi as seen in
	-- class tcn (tcn is the true class of fi.ancestor).
		local
			list: LIST[TRUE_CLASS_NAME];
			i: INTEGER; 
		do
			if not actual_generics.is_empty then
memstats(472);
				!!list.make;
				from
					i := 1
				until
					i > actual_generics.count
				loop
					list.add_tail((actual_generics @ i).true_class_name(tcn,fi));
					i := i + 1;
				end;
			end;
memstats(473);
			!!Result.make(name,is_explicitly_expanded,is_explicitly_reference,list);
		end; -- true_class_name

	true_class_name_code_parent (code: ROUTINE_CODE; no_parent: BOOLEAN): TRUE_CLASS_NAME is
	-- This tries to get the true_class_name of this type during compilation of
	-- a routine. NOTE: This might fail and return Void if the name can't be
	-- determined before system creation.
		local
			tcn: TRUE_CLASS_NAME;
			list: LIST[TRUE_CLASS_NAME];
			i: INTEGER; 
			ok: BOOLEAN;
		do
			ok := true
			if not actual_generics.is_empty then
memstats(495);
				!!list.make;
				from
					i := 1
				until
					i > actual_generics.count or (i > 1) and (tcn = Void)
				loop
					tcn := (actual_generics @ i).true_class_name_code_parent(code,no_parent);
					list.add_tail(tcn);
					if tcn=Void then
						ok := false
					end;
					i := i + 1;
				end;
			end;
			if ok then
memstats(496);
				!!Result.make(name,is_explicitly_expanded,is_explicitly_reference,list);
			end;
		end; -- true_class_name_code

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }

	local_type(code: ROUTINE_CODE): LOCAL_TYPE is
		local
			ci: CLASS_INTERFACE;
		do
			if     Current=globals.type_integer   then Result := globals.local_integer
			elseif Current=globals.type_character then Result := globals.local_character
			elseif Current=globals.type_boolean   then Result := globals.local_boolean
			elseif Current=globals.type_real      then Result := globals.local_real
			elseif Current=globals.type_double    then Result := globals.local_double
			elseif Current=globals.type_pointer   then Result := globals.local_pointer
			elseif is_explicitly_reference        then Result := globals.local_reference
			elseif is_explicitly_expanded or else 
			       get_class(name).parse_class.is_expanded 
			then
				!!Result.make_expanded(actual_classes.find(actual_class_name(code.class_code.actual_class.key)));
			else
				Result := globals.local_reference
			end;
		end; -- local_type

--------------------------------------------------------------------------------

end -- CLASS_TYPE
