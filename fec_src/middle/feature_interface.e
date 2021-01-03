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

class FEATURE_INTERFACE

-- The representation of an a (possibly inherited) feature in a class_interface.

inherit
	SORTABLE[INTEGER];
	DATATYPE_SIZES;
	FRIDISYS;
	ACTUAL_CLASSES;

creation
	clear, make, make_from, make_no_feature

--------------------------------------------------------------------------------
	
feature

--	key: INTEGER;  -- (geerbt:) Name des Features
	
	clients: CLIENTS;          -- wer darf dieses Feature benutzen?
	
	creation_item: CREATION_ITEM; -- Falls für dieses Feature Creation_item 
	                              -- existiert, sonst Void
	
	interface: CLASS_INTERFACE; -- die Klasse, die dieses Feature enthält.
	
	position: POSITION;  -- Position des Namens des seeds dieses Features
	
	formal_arguments: ENTITY_DECLARATION_LIST;

	type: TYPE;
	
	feature_value: FEATURE_VALUE;
	
	is_frozen: BOOLEAN;
	
	is_deferred: BOOLEAN; 
	is_selected: BOOLEAN; 
	is_redefined: BOOLEAN;
	
	is_attribute_that_was_routine: BOOLEAN; -- gesetzt, wenn dies ein Attribut ist, das eine Routine redefiniert

	parent_clause: PARENT;  -- Void oder der Parent_clause, durch den feature geerbt wurde
	original: FEATURE_INTERFACE;  -- gesetzt wenn parent_clause/=Void: Das Feature in der Vaterklasse

	seed: FEATURE_INTERFACE;
	origin: ANCESTOR_NAME;

	class_of_origin: CLASS_INTERFACE is
		do
			if parent_clause = Void then
				Result := interface
			else
				Result := original.class_of_origin
			end;
		end; 

	type_of_class_of_origin: TYPE is
		do
			if parent_clause = Void then
				Result := interface.current_type
			else
				Result := original.type_of_class_of_origin.view(parent_clause);
			end;
		end;

feature { ANY }

	number: INTEGER;           -- Nummer dieses Features im Feature_Deskriptor und Index
	                           -- in CLASS_INTERFACE.feature_list.

	is_no_feature : BOOLEAN;   -- Nur für dummy-Feature zur Übergabe an die Conformance-
	                           -- Routinen für Typen außerhalb von features gedacht.

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }
	
	clear is
	-- Dies ist nur da, solange es keinen guten GC gibt. Es wird von
	-- recycle.new_feature_interface zum recyceln von Objekten benutzt. 
		do
			key := 0;
			clients := Void;
			creation_item := Void;
			interface := Void;
			-- position := NO_POSITION
			formal_arguments := Void;
			type := Void;
			feature_value := Void;
			is_frozen := false;
			is_deferred := false; 
			is_selected := false;
			is_redefined := false;
			is_attribute_that_was_routine := false;
			parent_clause:= Void;  
			original := Void;
			seed := Void; 
			origin := Void;
			number := 0; 
			is_no_feature := false;
			same_name := Void;
			shared := Void;
			joined := Void;
			local_identifiers := Void;
			doing_rescue := false;
			doing_precondition := false;
			doing_postcondition:= false;
			ored_preconditions := Void;
		end -- clear

feature { ANY }

	make (new_interface: CLASS_INTERFACE;
	      new_name: FEATURE_NAME;
	      new_clients: CLIENTS;
	      new_is_frozen: BOOLEAN;
	      new_formal_arguments: ENTITY_DECLARATION_LIST;
	      new_type: TYPE;
	      new_feature_value: FEATURE_VALUE;
	      new_origin: ANCESTOR_NAME) is
	    -- Initialisierung mit den angegebenen Werten für ein neues (immediate)
	    -- feature. seed wird auf Current gesetzt, origin auf new_origin.
		do
			is_no_feature := false;
			-- attributes describing this feature
			interface        := new_interface;
			key              := new_name.name;
			clients          := new_clients;
			creation_item    := Void;
			position         := new_name.position;
			is_frozen        := new_is_frozen;
			is_deferred      := new_feature_value.is_deferred;
			formal_arguments := new_formal_arguments;
			type             := new_type;
			feature_value    := new_feature_value;
			parent_clause    := Void;
			
			-- seed and origin:
			seed   := Current;
			origin := new_origin;
			
			-- other values
			is_selected  := false;
			is_redefined := false; 
			is_attribute_that_was_routine := false;
			shared := Void;
			joined := Void;
		end; -- make
		
	make_from (src: FEATURE_INTERFACE; 
	           new_interface: CLASS_INTERFACE;
	           new_name: INTEGER;
	           new_clients: CLIENTS;
	           new_parent_clause: PARENT) is
		-- dupliziert ein geerbtes Feature_interface von src und renamet es als
		-- new_name und setzt parent auf new_parent.
		-- NOTE: This does not adopt calls_currents_features.
		do
			is_no_feature := false;
			-- set attributes:
			clients          := new_clients;
			creation_item    := Void;
			interface        := new_interface;
			key              := new_name;
			position         := src.position;
			is_frozen        := src.is_frozen;
			is_deferred      := src.is_deferred;
			is_attribute_that_was_routine := src.is_attribute_that_was_routine;
			formal_arguments := src.formal_arguments.view(new_parent_clause); 
			if src.type = Void then
				type := Void
			else
				type := src.type.view(new_parent_clause);
			end;
			feature_value    := src.feature_value;
			parent_clause    := new_parent_clause;
			original         := src;
			
			-- seed and origin inherited
			seed := src.seed;
			origin := src.origin.get_heirs_view(interface,parent_clause.class_type);
			
			-- other values;
			is_selected   := false;
			is_redefined  := false;
			shared  := Void;
			joined  := Void;
		end; -- make_from

feature { CREATION_LIST }

	set_creation_item(to: CREATION_ITEM) is
		do
			creation_item := to;
		end; -- set_creation_item

feature { NONE }

	empty_formal_args: ENTITY_DECLARATION_LIST is
		once
			!!Result.clear
		end; -- empty_formal_args;
	
feature { ANY }
	
	make_no_feature (new_interface: CLASS_INTERFACE) is
		do
			interface := new_interface;
			local_identifiers := empty_local_identifiers;
			is_no_feature := true; 
		end; -- make_no_feature

--------------------------------------------------------------------------------
	
feature { ANY }

	set_deferred is 
		do
			is_deferred := true
		end; -- set_deferred
		
	set_redefined is 
		do
			is_redefined := true
		end; -- set_redefined
		
	set_selected is 
		do
			is_selected := true
		end; -- set_selected

--------------------------------------------------------------------------------

feature { CLASS_INTERFACE }

	set_number (to: INTEGER) is
		do
			number := to
		end; -- set_number

--------------------------------------------------------------------------------

feature { PARENT, FEATURE_INTERFACE }

	same_name: FEATURE_INTERFACE;  -- Features mit gleichem Bezeichner vor join_or_share.
	                               -- Danach undefiniert!
	
	add_same_name (other: FEATURE_INTERFACE) is
		-- fügt feature mit gleichem Namen diesem hinzu. Dieses feature muß dann
		-- mittels join oder share mit diesem verschmolzen werden.
		require
			other.key = key;
			other.same_name = Void
		do
			if same_name = Void then
				same_name := other
			else
				other.set_same_name(same_name);
				same_name := other; 
			end; 
		ensure
			same_name = other; 
			other.same_name = old same_name
		end; -- add_same_name

feature { FEATURE_INTERFACE }

	set_same_name (to: FEATURE_INTERFACE) is
		require
			same_name = Void
		do
			same_name := to
		end; -- set_same_name

	remove_next_same_name is
		-- entfernt das Feature same_name wieder aber nur dieses
		require
			same_name /= Void
		do
			same_name := same_name.same_name;
		ensure
			same_name = old same_name.same_name;
		end; -- remove_next_same_name 

--------------------------------------------------------------------------------

feature { PARENT_LIST }

	join_or_share: FEATURE_INTERFACE is
		-- die über same_name verbundene Liste an geerbten Features mit gleichem
		-- Namen wird mittels join oder share wie in ETL, S. 187 1. bis 4., auf das 
		-- eine Element Result reduziert.
		do
			-- 1. Sharing
			share;
			-- 2. Undefine wurde bereits von PARENT.get_inherited erledigt
			-- 3. Join deferred features
			join;
			-- 4. Effecting von geerbten deferred Features durch geerbte effektive Features
			Result := effect_inherited;
		end; -- join or share

feature { FEATURE_INTERFACE }

	share is
		-- alle geerbten Features, die denselben seed haben, werden zu einem
		-- zusammengefügt, wie ETL S. 187 1.
		local
			next,prev: FEATURE_INTERFACE;
		do
			if not is_deferred then -- für deferred features reicht joining.
				from
					prev := Current;
				until
					prev.same_name = Void 
				loop
					next := prev.same_name;
					if seed   = next.seed and 
					   origin = next.origin and
					   not next.is_deferred and
					   (parent_clause.class_type.actual_generics.is_empty or else
					   signature_conforms_to(next))
					then
						prev.remove_next_same_name;
						next.set_shared(shared);
						shared := next;
					else
						prev := prev.same_name;
					end;
				end;
			end;
			if same_name /= Void then 
				same_name.share
			end;
		end; -- share

	join is
		-- deferred Features zusammenfügen, wie in ETL S. 187, 3.
		local
			cur,next,prev: FEATURE_INTERFACE;
		do
			from -- finde erstes deferred feature
				cur := Current
			until
				cur = Void or else cur.is_deferred
			loop
				cur := cur.same_name
			end; 
			if cur/=Void then
				from  -- joine erstes mit allen anderen deferred features
					prev := cur;
				until
					prev.same_name = Void 
				loop
					next := prev.same_name;
					if next.is_deferred then
						prev.remove_next_same_name;
						next.set_joined(joined);
						joined := next;
					else
						prev := prev.same_name;
					end;
				end;
			end;
		end; -- join

	effect_inherited : FEATURE_INTERFACE is
		-- deferred Features durch geerbtes effektives Feature ersetzen
		local
			effective: FEATURE_INTERFACE;
		do
			-- alle deferred features wurden durch join zu einem einzigen zusammen
			-- gefügt. die Liste besteht also nur mehr aus einem deferred Feature und
			-- möglicherweise mehreren effektiven, wobei mehr als eines einen
			-- Fehler darstellt.
			if same_name = Void then
				Result := Current;
			else
				if is_deferred then
					Result := same_name;
					same_name := Void;
					if Result.same_name /= Void then
						parent_clause.position.error_m(<<msg @ msg.vmfn2,strings @ key>>);
					end;
					Result.set_joined(Current);
				else
					Result := current;
					if not same_name.is_deferred or
						same_name.same_name /= Void 
					then
						parent_clause.position.error_m(<<msg @ msg.vmfn2,strings @ key>>);
					end;
					if same_name.is_deferred then
						joined := same_name;
					end;
				end;	
			end
		end; --effect_inherited

--------------------------------------------------------------------------------

feature { NONE }

	check_redeclaration (inherited: FEATURE_INTERFACE): BOOLEAN is 
		local
			ifeature_value: FEATURE_VALUE;
		do
			if inherited.is_frozen then 
				position.error(msg.vdrs4);
			else
				ifeature_value := inherited.feature_value;
				if inherited.is_attribute_that_was_routine or else 
	 				     feature_value.is_attribute and then
					not ifeature_value.is_attribute
				then
					is_attribute_that_was_routine := true;
				end;
				if ifeature_value.is_attribute then
					if not  feature_value.is_variable_attribute or
					   not ifeature_value.is_variable_attribute or
					   (inherited.type /= Void and type /= Void) and then
					   (inherited.type.is_expanded(inherited) xor type.is_expanded(Current))
					then
						position.error(msg.vdrd2);
					end;
				end;
				if not feature_value.has_require_else_and_ensure_then then
					position.error(msg.vdrd3);
				end;
				if ifeature_value.is_external xor feature_value.is_external	then
-- nyi: Die SE-Klassen verstoßen gegen diese Regel:
--					position.error(msg.vdrd4); 
				end;
				if inherited.is_redefined then
					if not inherited.is_deferred and is_deferred then
						position.error(msg.vdrd5);
					elseif inherited.is_deferred and not is_deferred then
						position.error(msg.vdrs5);
					else
						Result := true
					end;
				else
					if not is_deferred and inherited.is_deferred then
						Result := true
					else
						position.error(msg.vdrd6);
					end; 
				end;
				if Result and inherited.joined /= Void then
					Result := check_redeclaration(inherited.joined);
				end;
			end;
		end; -- check_redeclaration

feature { ANY }

	redeclares (inherited: FEATURE_INTERFACE) is
	-- Von Feature_declaration.get_immediate aufgerufen, wenn gleichnamiges
	-- Feature geerbt wird.
		do
			if check_redeclaration(inherited) then
				set_joined(inherited);
			end;
		end; -- redeclares

--------------------------------------------------------------------------------

feature { FEATURE_INTERFACE, CLASS_INTERFACE, RECYCLE_OBJECTS }
	
	shared: FEATURE_INTERFACE; -- Liste der Features, die mit diesem geshared wurden
	joined: FEATURE_INTERFACE; -- Liste der Features, die mit diesem gejoint wurden

	set_shared (to: FEATURE_INTERFACE) is
		do
			shared := to;
		end; -- set_shared

	set_joined (to: FEATURE_INTERFACE) is
		do
			joined := to;
		end; -- set_joined
		
--------------------------------------------------------------------------------
-- VALIDITY †BERPRÜFUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	signature_conforms_to(other: FEATURE_INTERFACE): BOOLEAN is
		local
			i: INTEGER;
		do
			if type = Void xor other.type = Void or else
				formal_arguments.count /= other.formal_arguments.count 
			then
				Result := false
			else
				Result := (type /= Void) implies type.is_conforming_to(Current,other.type);
				from 
					i := 1
				until
					not Result or else
					i > formal_arguments.count
				loop
					Result := (formal_arguments @ i).type.is_conforming_to(Current,(other.formal_arguments @ i).type);
					i := i + 1;
				end;
			end;
		end; -- signature_conforms_to
		
	signature_is_identical(other: FEATURE_INTERFACE): BOOLEAN is
		local
			i: INTEGER;
		do
			if (type = Void xor other.type = Void) or else
				formal_arguments.count /= other.formal_arguments.count 
			then
				Result := false
			else
				Result := (type /= Void) implies type.is_identical(Current,other.type);
				from 
					i := 1
				until
					not Result or else
					i > formal_arguments.count
				loop
					Result := (formal_arguments @ i).type.is_identical(Current,(other.formal_arguments @ i).type);
					i := i + 1;
				end;
			end;
		end; -- signature_is_identical

--------------------------------------------------------------------------------

feature { ANY }

	local_identifiers: SORTABLE_LIST[INTEGER, LOCAL_OR_ARGUMENT];

feature { NONE }

	get_locals is 
		local
			i: INTEGER;
			new,ole: LOCAL_OR_ARGUMENT;
			rout: ROUTINE;
		do
			rout ?= feature_value;
			if rout /= Void then 
				if not formal_arguments.is_empty or 
				   rout.locals /= Void
				then 
memstats(93);
					!!local_identifiers.make;
					from 
						i := 1
					until
						i > formal_arguments.count
					loop
						new := formal_arguments @ i;
						if interface.feature_list.find(new.key) /= Void then 
							new.position.error(msg.vrfa1);
						end;
						local_identifiers.add(new);
						i := i + 1;
					end;
					feature_value.add_locals(Current);
					local_identifiers.sort;
					from
						i := 1;
						ole := Void;
					until
						i > local_identifiers.count
					loop
						new := local_identifiers @ i;
						new.type.validity(Current);
						if ole /= Void and then ole.key = new.key then
							if ole.is_argument xor new.is_argument then
								new.position.error(msg.vrle2);
							else
								new.position.error(msg.vreg1);
							end;
						end;
						i := i + 1;
						ole := new;
					end;
				else
					local_identifiers := empty_local_identifiers;
				end;
			end;
		end; -- get_locals;

	empty_local_identifiers: SORTABLE_LIST[INTEGER,LOCAL_OR_ARGUMENT] is
		once
			!!Result.make
		end; -- empty_local_identifiers

feature { ANY }

	validity is
		local
			i: INTEGER; 
		do	
-- interface.key.print_name; write_string("."); write_string(strings @ key); write_string("%N"); 
			formal_arguments.validity(Current);
			get_locals;
			if type /= Void then
				type.validity(Current);
				type.add_to_uses(Current);
			end;
			feature_value.validity(Current);
			start_precondition;
				from
					i := 1
				until
					i > ored_preconditions.count
				loop
					(ored_preconditions @ i).validity(Current);
					i := i + 1;
				end;
			stop_precondition;
		end; -- validity

--------------------------------------------------------------------------------

	doing_rescue: BOOLEAN;
	doing_precondition: BOOLEAN;
	doing_postcondition: BOOLEAN;

feature { ROUTINE }

	start_rescue is
		do
			doing_rescue := true
		end; -- start_rescue

	stop_rescue is
		do
			doing_rescue := false
		end; -- stop_rescue

	start_postcondition is
		do
			doing_postcondition := true
		end; -- start_postcondition

	stop_postcondition is
		do
			doing_postcondition := false
		end; -- stop_postcondition
		
	start_precondition is
		do
			doing_precondition := true
		end; -- start_precondition

	stop_precondition is
		do
			doing_precondition := false
		end; -- stop_precondition
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { CALL, TYPE, SYSTEM, TRUE_CLASS }

	ancestor: ANCESTOR; -- ancestor this inherited feature comes from or interface.this_class

--------------------------------------------------------------------------------

feature { CLASS_INTERFACE }

	compile(ac: ACTUAL_CLASS) is
		local
			current_type: LOCAL_TYPE;
			r: ROUTINE;
		do
			if feature_value.is_routine then
				r ?= feature_value;
				if globals.create_require_check and then
				   has_precondition and then
				   (ac.is_expanded or else seed = Current)
				then
					compile_precondition(r,ac);
				end;
				if feature_value.is_internal_routine then
					if (parent_clause=Void or ac.must_be_duplicated @ number) and 
					   not(interface.parse_class.is_deferred and then ac.cant_be_compiled @ number)
					then
						compile_internal_routine_or_read_attribute(ac); 
					end;
				end;
			elseif is_attribute_that_was_routine then
				compile_internal_routine_or_read_attribute(ac);
			end;
		end -- compile
	
	compile_precondition(routine: ROUTINE; ac: ACTUAL_CLASS) is
	-- create routine to check precondition of this routine. 
	-- Note: Preconditions are statically bound and not duplicated. So unqualified
	-- calls to routines or attributes of Current must use dynamic dispatching
	-- as well!
		local
			current_type: LOCAL_TYPE;
		do
			ancestor := interface.this_class;
--print("compiling precondition: "); ancestor.key.print_name(interface); print("."); print(strings @ key); print("%N");
			if ac.is_expanded then
				current_type := globals.local_pointer;
			else
				current_type := globals.local_reference;
			end;
			start_precondition;
				routine_code.init(true,
				                  ac.class_code,
				                  Current,
				                  current_type,
				                  globals.type_pointer);
				routine.compile_precondition(routine_code);
				routine_code.create_code;
			stop_precondition;
			globals.routine_stats(routine_code.locals.count,false);
			recycle.forget_commands;
		end -- compile_precondition

	compile_internal_routine_or_read_attribute(ac: ACTUAL_CLASS) is
	-- create code corresponding to a routine. For a variable or constant
	-- attribute this creates a routine returning the attributes value.
		local
			current_type: LOCAL_TYPE;
		do
			if parent_clause /= Void then
--print("duplicating: ");
				ancestor := interface.ancestor_list.find(origin);
			else
--print("compiling: ");
				ancestor := interface.this_class;
			end;
--ancestor.key.print_name(interface); write_string("."); write_string(strings @ key); write_string("%N");
			if ac.is_expanded then
				current_type := globals.local_pointer;
			else
				current_type := globals.local_reference;
			end;
			routine_code.init(false,
			                  ac.class_code,
			                  Current,
			                  current_type,
			                  seed.type);
			feature_value.compile(routine_code);
			routine_code.create_code;
			globals.routine_stats(routine_code.locals.count,parent_clause/=Void);
			recycle.forget_commands;
		end -- compile_internal_routine_or_read_attribute

feature { NONE }

	routine_code: ROUTINE_CODE is
		once
			!!Result.make
		end; -- routine_code

--------------------------------------------------------------------------------

feature { CLASS_INTERFACE, FEATURE_INTERFACE }

	get_pre_and_postconditions is
	-- determine pre- and postcondition for this feature, combining inherited 
	-- conditions if present.
	-- This must be called after this routine was called for all the features 
	-- of every true ancestor of this feature's class.
		local
			j,jorig: FEATURE_INTERFACE;
			i: INTEGER;
			r: ROUTINE;
		do
			if ored_preconditions = Void and then
			   globals.create_require_check and then 
			   feature_value.is_routine 
			then
				if parent_clause = Void then
-- nyi: duplicate preconditions if parent_clause /= Void, they must be used for expanded classes
					r ?= feature_value;
					ored_preconditions := Void;
					if not r.precondition.is_empty then
						!!ored_preconditions.make;
						ored_preconditions.add(r.precondition);
					end;
					from
						j := joined;
					until
						j = Void
					loop
						if j.ored_preconditions = Void then
							j.get_pre_and_postconditions;
						end;
						if j.parent_clause = Void then
							from
								i := 1
							until
								i > j.ored_preconditions.count
							loop
								if ored_preconditions = Void then
									!!ored_preconditions.make;
								end;
								ored_preconditions.add(j.ored_preconditions @ i); 
								i := i + 1;
							end;
						else
							jorig := j.original;
							from
								i := 1
							until
								i > jorig.ored_preconditions.count
							loop
								if ored_preconditions = Void then
									!!ored_preconditions.make;
								end;
								ored_preconditions.add((jorig.ored_preconditions @ i).view(j.parent_clause,j.formal_arguments,formal_arguments));
								i := i + 1;
							end;
						end;
						j := j.joined;
					end;
				end;
			end;
			if ored_preconditions = Void then
				ored_preconditions := empty_ored_preconditions
			end;
		end; 

feature { ROUTINE, FEATURE_INTERFACE }

	ored_preconditions: LIST[ASSERTION];  -- nyi: needed?

feature { NONE }

	empty_ored_preconditions: LIST[ASSERTION] is
		once
			!!Result.make;
		end; -- empty_ored_preconditions
		
feature { RUNTIME_CHECKS, FEATURE_INTERFACE }

	has_precondition: BOOLEAN is
	-- if this is true, precondition for this routine must be checked before it
	-- is called. This also implies that a precondition routine is created when 
	-- this feature is compiled.
		do
			if feature_value.is_routine then
				if parent_clause = Void then
					Result := not ored_preconditions.is_empty;
				else
					Result := original.has_precondition;
				end;
			end; 
		end; -- has_precondition

--------------------------------------------------------------------------------

feature { ANY }

	get_static_name (ac: ACTUAL_CLASS): INTEGER is
	-- when statically calling this feature (as in an unqualified call with Current
	-- as target or with expanded target), find this feature's static name. That is
	-- the name of this feature's origin or of its youngest duplication.
		require
			-- nyi: wg debugging aus:
			-- feature_value.is_internal_routine or 
			-- is_attribute_that_was_routine
		do
if not feature_value.is_internal_routine and
	not is_attribute_that_was_routine then
	write_string("**** get_static_name of: "); 
	write_string(strings @ interface.key); 
	write_string("-punkt-");
	write_string(strings @ key);
	write_string(" in ");
	write_string(strings @ ac.name);
	write_string("%N");
end;
			if feature_value.is_internal_routine and then
				parent_clause /= Void and then not(ac.must_be_duplicated @ number)
			then
				Result := original.get_static_name(parent_clause.class_type.actual_class(ac.key));
			else
				Result := get_symbol_name(ac.key.code_name,key)
			end;
		end -- get_static_name

	get_static_precondition_name (ac: ACTUAL_CLASS): INTEGER is
	-- precondition calls are always static. This routine determines the feature's
	-- precondition's static name. That is the name of the precondtion of this 
	-- feature's origin.
		require
			feature_value.is_routine or 
			is_attribute_that_was_routine
		local
			parent_acn: ACTUAL_CLASS_NAME;
			parent_ac: ACTUAL_CLASS;
		do
			if parent_clause /= Void then
				parent_acn := parent_clause.class_type.actual_class_name(ac.key).clone_x_or_ref(ac.is_expanded);
				parent_ac := actual_classes.find(parent_acn);
				Result := original.get_static_precondition_name(parent_ac);
			else
				Result := get_precondition_name(ac.key.code_name,key);
			end;
		end -- get_static_precondition_name

	get_static_precondition_type: TYPE is
	-- precondition calls are always static. This routine determines the static
	-- type expected by this feature's precondition.
	-- That is the type of this feature's origin.
		require
			feature_value.is_routine or 
			is_attribute_that_was_routine
		do
			if parent_clause /= Void then
				Result := original.get_static_precondition_type.view(parent_clause);
			else
				Result := interface.like_current;
			end;
		end -- get_static_precondition_type
		
--------------------------------------------------------------------------------

feature { ROUTINE, INTERNAL_ROUTINE }

	alloc_arguments (code: ROUTINE_CODE) is 
		local
			i: INTEGER;
		do
			from 
				i := 1
			until
				i > formal_arguments.count
			loop
				(seed.formal_arguments @ i).alloc_local(code);
				i := i + 1;
			end;
		end; -- alloc_arguments;

--------------------------------------------------------------------------------

feature { ANY }

	get_new_feature(old_name: INTEGER): FEATURE_INTERFACE is
	-- determine the feature in this class of the feature that was called
	-- old_name in this feature's class of origin
		do
			Result := interface.feature_list.find(get_new_name(old_name));
		end; -- get_new_feature

feature { FEATURE_INTERFACE }
		
	get_new_name(old_name: INTEGER): INTEGER is
	-- Determine the name in this class of the feature that was called old_name 
	-- in this feature's class of origin.
		local
			name: INTEGER;
		do
			if parent_clause = Void then
				Result := old_name
			else
				name := original.get_new_name(old_name);
				Result := parent_clause.renames.get_rename(name);
			end;
		end; -- get_new_name

--------------------------------------------------------------------------------
		
end  -- FEATURE_INTERFACE
