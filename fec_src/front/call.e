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

class CALL

-- The 'heart' of the compiler, this class creates the intermediate 
-- representation of all call expressions and instructions. It transforms those
-- calls that are implemented by the compiler (like most features of INTEGER and
-- BOOLEAN) directly into the corresponding intermediate code.
--
-- CREATION_INSTRUCTION inherits this class to implement the creation call.

inherit
	EXPRESSION
		rename
			compile as expression_compile
		redefine
			is_entity, 
			get_entity_or_feature, 
			is_current, 
			is_unqualified_call
		end;
	INSTRUCTION
		rename
			validity as instruction_validity,
			compile as instruction_compile
		end;
	LIST[ACTUAL]  -- nyi: make this an attribute
		rename
			make as list_make
		export { CALL }
			data   -- used by make_from
		end;
	SCANNER_SYMBOLS;
	PARSE_EXPRESSION;
	ACTUAL_CLASSES;
	DATATYPE_SIZES;
	CONDITIONS;
	COMMANDS;
	COMPILE_ASSIGN;
	RUNTIME_CHECKS;

creation
	parse, 
	parse_call_chain, 
	make_unary, 
	make_binary

creation { CALL }
	make_from, new_view
	
--------------------------------------------------------------------------------

feature { ANY }

	target : EXPRESSION;   -- Ziel des call oder Void

	feature_name : INTEGER; -- id des aufgerufenen features, in Kleinbuchstaben
	                        -- Unary und Binary wie in FEATURE_NAME umgewandelt.

	is_expression: BOOLEAN; -- true, wenn dies als Teil eines Ausdrucks geparst wurde.

--	position: POSITION;     -- geerbt.

--------------------------------------------------------------------------------

feature { NONE }

	parse (s: SCANNER; new_is_expression: BOOLEAN) is
	-- Call = [Parenthesized_qualifier] Call_chain.
	-- Parenthesized_qualifier = "(" Expression ")" ".".
		local
			new_target: EXPRESSION;
		do
			position := s.current_symbol.position;
			is_expression := new_is_expression;
			list_make;
			if s.current_symbol.type = s_left_parenthesis then
				s.next_symbol;
				parse_expression(s);
				new_target := expression;
				s.check_right_parenthesis(msg.rpr_pq_expected);
				s.check_dot(msg.dot_pe_expected);
			else
				new_target := Void;
			end;
			parse_call_chain(s,new_target,new_is_expression);
		end; -- parse

--------------------------------------------------------------------------------

	parse_call_chain(s: SCANNER; call_target: EXPRESSION; new_is_expression: BOOLEAN) is
	-- Call_chain = Unqualified_call ["." Call_chain].
	-- Unqualified_call = Entity [Actuals].
		local
			new_target: CALL;
		do
			from
				parse_unqualified_call(s,call_target,new_is_expression);
			until 
				s.current_symbol.type /= s_dot
			loop
				s.next_symbol;
				is_expression := true;
memstats(446);
				!!new_target.make_from(Current);
				count := 0; 
				data := Void;
				parse_unqualified_call(s,new_target,new_is_expression);
			end;
		end; -- parse_call_chain;

--------------------------------------------------------------------------------

	parse_unqualified_call (s: SCANNER; call_target: EXPRESSION; new_is_expression: BOOLEAN) is
	-- Unqualified_call = Entity [Actuals].
	-- Entity = Identifier.
	-- Actuals = "(" Actual_list ")".
	-- Actual_list = {Actual "," ...}.
		local 
			actual: ACTUAL;
		do
			position := s.current_symbol.position;
			is_expression := new_is_expression; 
			list_make;
			target := call_target;
			s.check_and_get_identifier(msg.id_cll_expected);
			feature_name := s.last_identifier;
			if s.current_symbol.type = s_left_parenthesis then
				s.next_symbol;
				if s.first_of_actual then
					from
memstats(17);
						!!actual.parse(s);
						add_tail(actual);
					until
						s.current_symbol.type /= s_comma
					loop
						s.next_symbol;
memstats(18);
						!!actual.parse(s);
						add_tail(actual);
					end;
				end; 
				s.check_right_parenthesis(msg.rpr_pr_expected);
			end; 
		end; -- parse_unqualified_call
	
--------------------------------------------------------------------------------

	make_binary (call_target: EXPRESSION;
	             operator: INTEGER;
	             right: EXPRESSION;
	             new_pos: POSITION) is
	-- Erzeuge Call aus einem binären Ausdruck. call_target ist die linke Seite,
	-- operator der Operator und right die rechte Seite des Ausdrucks.
		local
			actual: ACTUAL;
		do
			position := new_pos;
			is_expression := true;
			list_make;
			target := call_target;
			feature_name := operator;
memstats(19);
			!!actual.make_from_expression(right);
			add_tail(actual);
		end; -- make_binary

--------------------------------------------------------------------------------

	make_unary (call_target: EXPRESSION;
	            operator: INTEGER;
	            new_pos: POSITION) is
	-- Erzeuge Call aus einem unären Ausdruck. call_target ist das Argument,
	-- und operator der Operator Ausdrucks.
		do
			position := new_pos;
			is_expression := true;
			list_make;
			target := call_target;
			feature_name := operator;
		end; -- make_unary

--------------------------------------------------------------------------------

	make_from (other: CALL) is
	-- clones other. NOTE: ensures data = other.data, so other must no more
	-- modify its argument list.
		do
			target        := other.target;
			feature_name  := other.feature_name;			
			is_expression := other.is_expression;
			position      := other.position;
			data          := other.data;
			count         := other.count;
		end; -- make_from
			
--------------------------------------------------------------------------------

feature { NONE }

	called_class: CLASS_INTERFACE;	
	called_feature: FEATURE_INTERFACE;
	
	called_local: LOCAL_OR_ARGUMENT; 

	is_result: BOOLEAN;
	is_current: BOOLEAN;
	is_equality: BOOLEAN;
	is_unequality: BOOLEAN;

feature { ANY }

	instruction_validity (fi: FEATURE_INTERFACE) is 
		do
			validity(fi,Void)
		end; -- instruction_validity

	validity (fi: FEATURE_INTERFACE; expected_type: TYPE) is
		do
			if target = Void then
				if feature_name = globals.string_result then
					is_result := true;
					if fi.type /= Void then
						type := fi.type
						if fi.is_no_feature or fi.doing_precondition then
							position.error(msg.veen1); 
						end; 
					else
						position.error(msg.veen2); 
					end; 
					check_no_arguments;
				elseif feature_name = globals.string_current then
					is_current := true;
					type := fi.interface.current_type;
					check_no_arguments;
				else
					check_unqualified_call(fi);
				end; 
			else
				target.validity(fi,Void);
				is_equality := feature_name = globals.string_infix_equal;
				is_unequality := feature_name = globals.string_infix_not_equal;
				if is_equality or is_unequality then 
					item(1).validity_in_equality(fi);
					if target            .is_conforming_to(fi,item(1).type) or else
					   item(1).expression.is_conforming_to(fi,target .type) 
					then
						-- dies ist der eigentlich einzige in ETL erlaubte Fall
					elseif target            .type.is_formal_generic and then item(1).type.is_none or else
						    item(1).expression.type.is_formal_generic and then target .type.is_none
					then
						-- NYI: Vergleich von Void und formal generic ist in ETL verboten, ich erlaube es
						-- jedoch (wie SE) dennoch!
					elseif item(1).type.is_none or else target .type.is_none
					then
						-- NYI: Ich erlaube sogar beliebige vergleiche mit Void, dieser Fall tritt auf in
						-- geerbten precondtitions, deren validity eigentlich nicht mehr geprŸft werden 
						-- muss (aber dennoch wird, um z.B. expression.type zu setzen): 
					else
						position.error(msg.vweq1);
					end;
					type := globals.type_boolean;
				else
					check_qualified_call(fi);
				end;
			end;
			if is_expression then
				if type = Void then
					position.error(msg.vkcn1);
					type := globals.type_any;
				end;
-- write_string("call: "); write_string(strings @ feature_name); write_string(" result is: "); type.print_type; write_string("%N"); 
			else
				if type /= Void then
					position.error(msg.vkcn2);
				end; 
			end;
		end; -- validity

feature { NONE }

	check_unqualified_call (fi: FEATURE_INTERFACE) is
		do
			called_class := fi.interface;
			called_local := fi.local_identifiers.find(feature_name); 
			if called_local /= Void then
				if fi.doing_precondition and then not called_local.is_argument then
					position.error(msg.vape1);
				end;
				type := called_local.type;
				check_no_arguments;
			else
				called_feature := called_class.feature_list.find(feature_name); 
				if called_feature /= Void then
					check_vape(fi);
					check_arguments(fi,Void);
					if not fi.is_no_feature and
						not fi.doing_precondition and 
					   not fi.doing_postcondition and 
					   not fi.doing_rescue
					then
						fi.feature_value.set_calls(called_feature.number);
					end;
				else
					if fi.is_no_feature then
						position.error(msg.vwid1);
					else
						position.error(msg.vwid2)
					end;
				end;
			end;
		end; -- check_unqualified_call
		
	check_qualified_call (fi: FEATURE_INTERFACE) is
		do	
			called_class := target.type.base_class(fi);
			called_feature := called_class.feature_list.find(feature_name);
			if called_feature = Void then
				position.error(msg.vuex1);
			else
				check_availability(fi);
				check_arguments(fi,Void);
			end;
		end; -- check_qualified_call

	check_vape (fi: FEATURE_INTERFACE) is
		require
			called_feature /= Void
		local
			ci: CREATION_ITEM;
		do
			if fi.doing_precondition then
				if called_feature.clients /= Void then
					if not called_feature.clients.is_available_to_all(fi.clients) then
						position.error(msg.vape2);
					end;
					if fi.creation_item /= Void then
						if not called_feature.clients.is_available_to_all(fi.creation_item.clients) then
							position.error(msg.vape2);
						end;
					end
				end;
			end;
		end; -- check_vape

	check_availability (fi: FEATURE_INTERFACE) is
		require
			called_feature /= Void
		do
			if 	called_feature.clients /= Void then
				if not called_feature.clients.is_available_to(fi.interface) then
					position.error(msg.vuex2);
				end;
			end;
			check_vape(fi);
		end; -- check_availability

	check_arguments (fi: FEATURE_INTERFACE; creation_type: TYPE) is
	-- creation_type /= Void, wenn dies ein Creation-call ist. Dann ist
	-- dies der Typ des erzeugten Objekts.
		require
			called_feature /= Void
		local
			i: INTEGER;
		do
			if called_feature.formal_arguments.count /= count then
				if count = 0 then
					position.error(msg.vuar6);
				elseif called_feature.formal_arguments.count = 0 then
					position.error(msg.vuar7);
				else
					position.error(msg.vuar8);
				end; 
				type := called_feature.type;
			else
				from  i := 1
				until i > count
				loop
					check_argument_no_anchor(i,fi,creation_type);
					i := i + 1
				end;
				from  i := 1
				until i > count
				loop
					check_argument_anchor(i,fi);
					i := i + 1
				end;
				type := get_view_of(fi,called_feature.type);
			end;
		end; -- check_arguments

	check_argument_no_anchor (i: INTEGER; fi: FEATURE_INTERFACE; creation_type: TYPE) is
		local
			declared_type,formal_type: TYPE;
			formal_anchor: ANCHORED;
		do
			declared_type := (called_feature.formal_arguments @ i).type;
			formal_type := declared_type;
			if target /= Void then
				if formal_type.is_like_current then
					if not target.is_current then
						formal_type := target.type
-- write_string("check_arg: "); write_string(strings @ feature_name); write_string(" arg is_like_current: "); formal_type.print_type; write_string("%N"); 
					end;
				else
					formal_type := declared_type.view_client(fi,target,target.type,called_class);
				end;
			elseif creation_type /= Void then
				if formal_type.is_like_current then
					formal_type := creation_type
				else
					formal_type := formal_type.view_client(fi,Void,creation_type,called_class);
				end;
			elseif formal_type.is_like_current then
				formal_type := fi.interface.current_type;
			end;
			formal_anchor ?= declared_type;
			if formal_anchor = Void or else formal_anchor.argument_number = 0 then
-- write_string("chkargs: "); write_string(strings @ feature_name); write_string("%N");
				item(i).validity(fi,called_feature,formal_type,target);
-- write_string("done chkargs: "); write_string(strings @ feature_name); write_string("%N");
			end;
		end; -- check_argument_no_anchor

	check_argument_anchor (i: INTEGER; fi: FEATURE_INTERFACE) is
		local
			formal_anchor: ANCHORED;
		do
			formal_anchor ?= (called_feature.formal_arguments @ i).type;
			if formal_anchor /= Void and then formal_anchor.argument_number /= 0 then
-- write_string("chkfargs: "); write_string(strings @ feature_name); write_string("%N");
				item(i).validity(fi,called_feature,item(formal_anchor.argument_number).type,target);
-- write_string("done chkfargs: "); write_string(strings @ feature_name); write_string("%N");
			end;
		end; -- check_argument_anchor

--------------------------------------------------------------------------------

	get_view_of(fi: FEATURE_INTERFACE; original: TYPE): TYPE is
		local
			formal_anchor: ANCHORED;
			anchored_name: INTEGER;
		do
			if original /= Void then
				formal_anchor ?= original;
				if formal_anchor /= Void and then formal_anchor.argument_number /= 0 then
					if item(formal_anchor.argument_number).expression /= Void then
						anchored_name := item(formal_anchor.argument_number).expression.get_entity_or_feature(fi);
					end;
					if anchored_name /= 0 then
memstats(22);
						!ANCHORED!Result.make_fake(anchored_name,position);
					else
						Result := item(formal_anchor.argument_number).type
					end;
				elseif original.is_like_current then
					if target /= Void then
						if target.is_current then
							Result := original
						else
							anchored_name := target.get_entity_or_feature(fi);
							if anchored_name /= 0 then
memstats(23);
								!ANCHORED!Result.make_fake(anchored_name,position);
							else
								Result := target.type
							end;
						end;
					else
						Result := original;
					end;
				else
					if target = Void then
						Result := original;
					else
						Result:= original.view_client(fi,target,target.type,called_class);
					end;
				end;
			end;
		end; -- get_view_of
		
--------------------------------------------------------------------------------
	
	check_no_arguments is
	-- Überprüft, das count = 0, sonst Fehlermeldung 
		do
			if count /= 0 then
				position.error(msg.vuar7);
			end; 
		end; -- check_no_arguments

feature { ANY }

--------------------------------------------------------------------------------

	is_entity (v: INTEGER; fi: FEATURE_INTERFACE): BOOLEAN is
		local
			l: LOCAL_OR_ARGUMENT;
		do
			if target = Void and not fi.is_no_feature then
			   l := fi.local_identifiers.find(feature_name);
			   if l /= Void then
					if v =feature_name then
						Result := true
					end;
				end;
			end;
		end; -- is_entity
	
	is_unqualified_call : INTEGER is
		do
			if target=Void then
				Result := feature_name
			end; 
		end; -- is_unqualified_call
	
--------------------------------------------------------------------------------
	
	get_entity_or_feature (fi: FEATURE_INTERFACE): INTEGER is
	-- Result ist der Name der Entität oder des Features dieser Klasse, falls
	-- der Ausdruck eines von beidem ist, sonst Void.
		local
			entity: LOCAL_OR_ARGUMENT;
			feat: FEATURE_INTERFACE;
		do
			if not fi.is_no_feature then
				entity := fi.local_identifiers.find(feature_name); 
			end
			if entity /= Void then
				Result := entity.key
			else
				feat := fi.interface.feature_list.find(feature_name)
				if feat /= Void then
					Result := feat.key
				end;
			end;
		end; -- get_entity_or_feature

--------------------------------------------------------------------------------

feature { ASSERTION }

	view (pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST): CALL is
	-- get the view of this call inherited through the specified
	-- parent_clause. 
		do
			!!Result.new_view(Current,pc,old_args,new_args);
		end; -- view

feature { NONE }

	new_view (original: CALL; pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST) is
		local
			i: INTEGER;
			arg_num: INTEGER;
		do
			list_make;
			from 
				i := 1
			until
				i > original.count
			loop
				add((original @ i).view(pc,old_args,new_args));
				i := i + 1;
			end; 
			if original.target = Void then
				target := Void
				arg_num := old_args.find(original.feature_name); 
				if arg_num = 0 then
					feature_name := pc.renames.get_rename(original.feature_name);
				else
					feature_name := (new_args @ arg_num).key;
				end;
			else
				target := original.target.view(pc,old_args,new_args);
				feature_name := original.feature_name;
			end;
			is_expression := original.is_expression;
			position := original.position;
		end; -- new_view
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }

	compile_call(code: ROUTINE_CODE) is
		do
			if target = Void then
				compile_unqualified_call(code);
			else -- target /= Void:
				compile_qualified_call(code);
			end;
		end; -- compile_call

feature { NONE }

	compile_unqualified_call (code: ROUTINE_CODE) is
		do
			if     is_result                                          then compile_read_result (code);
			elseif is_current                                         then compile_read_current(code);
			elseif called_local /= Void                               then compile_read_local  (code);
			elseif called_feature.feature_value.is_constant_attribute then result_value := called_feature.feature_value.constant_value;
			elseif called_feature.feature_value.is_variable_attribute then compile_unqualified_read_variable_attribute(code)
			elseif called_feature.feature_value.is_external           then compile_external_call(code);
			else -- call internal routine:
				compile_unqualified_routine_call(code);
			end;
		end; -- compile_unqualified_call

	compile_qualified_call(code: ROUTINE_CODE) is
		do
			if     is_equality or is_unequality                       then compile_equality(code);
			elseif called_feature.feature_value.is_constant_attribute then result_value := called_feature.feature_value.constant_value;
			elseif called_feature.feature_value.is_variable_attribute then compile_qualified_read_variable_attribute(code);
			elseif called_feature.feature_value.is_external           then compile_external_call(code);
			else -- internal feature, möglicherweise mit is_frozen
				compile_qualified_routine_call(code);
			end;
		end; -- compile_qualified_call

--------------------------------------------------------------------------------

feature { NONE }

	compile_read_result(code: ROUTINE_CODE) is
		local
			off_ind: OFFSET_INDIRECT_VALUE;
			once_result_global: INTEGER;
			src: LOCAL_VAR;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
		do
			if code.fi.feature_value.is_once then
				once_result_global := once_result_name(code.fi);
				src := recycle.new_local(code,globals.local_pointer);
				ass_const_cmd := recycle.new_ass_const_cmd;
				ass_const_cmd.make_assign_const_symbol(src,once_result_global,0);
				code.add_cmd(ass_const_cmd);
				off_ind := recycle.new_off_ind;
				off_ind.make(0,src);
				result_value := off_ind;
			elseif code.expanded_result then
				off_ind := recycle.new_off_ind;
				off_ind.make(0,code.result_local);
				result_value := off_ind;
			else
				result_value := code.result_local;
			end; 
		end; -- compile_read_result

	compile_read_current(code: ROUTINE_CODE) is
		local
			off_ind: OFFSET_INDIRECT_VALUE;
		do
			if code.class_code.actual_class.key.actual_is_expanded then
				off_ind := recycle.new_off_ind;
				off_ind.make(0,code.current_local);
				result_value := off_ind;
			else
				result_value := code.current_local;
			end;
		end; -- compile_read_current

	compile_read_local(code: ROUTINE_CODE) is
		local
			off_ind: OFFSET_INDIRECT_VALUE;
		do
			if called_local.is_argument and then
				type.local_type(code).is_expanded
			then
				off_ind := recycle.new_off_ind;
				off_ind.make(0,called_local.local_var);
				result_value := off_ind;
			else
				result_value := called_local.local_var;
			end;
		end; -- compile_read_local

	compile_unqualified_read_variable_attribute(code: ROUTINE_CODE) is
		local
			attribute: FEATURE_INTERFACE; 
		do
			attribute := code.fi.get_new_feature(feature_name);
			if code.fi.doing_precondition then
				if code.class_code.actual_class.key.actual_is_expanded then
					compile_unqualified_read_this_variable_attribute(code,attribute);
				else
					compile_dynamic_read_variable_attribute(code,attribute,code.current_local,code.fi.interface.current_type);
				end;
			else
				compile_unqualified_read_this_variable_attribute(code,attribute);
			end;
		end; -- compile_unqualified_read_variable_attribute

	compile_unqualified_read_this_variable_attribute(code: ROUTINE_CODE; attribute: FEATURE_INTERFACE) is
		local
			offset: INTEGER;
			off_ind: OFFSET_INDIRECT_VALUE;
		do
			offset := code.class_code.actual_class.attribute_offsets @ attribute.number;
			off_ind := recycle.new_off_ind;
			off_ind.make(offset,code.current_local);
			result_value := off_ind;
		end; -- compile_unqualified_read_this_variable_attribute

	compile_dynamic_read_variable_attribute(code: ROUTINE_CODE;
	                                        attribute: FEATURE_INTERFACE;
	                                        target_local: LOCAL_VAR;
	                                        target_type: TYPE) is
	-- read attribute using dynamic dispatching on heap object 
	-- referenced to by target_local.
	-- this does not check target_local for Void.
		local
			feat_descr,temp: LOCAL_VAR;
			read_mem_cmd: READ_MEM_COMMAND;
			indexed: INDEXED_VALUE;
		do
			feat_descr := clone_and_copy.compile_read_feature_descr(code,target_local,target_type,false);
			temp := recycle.new_local(code,globals.local_integer);
			read_mem_cmd := recycle.new_read_mem_cmd;
			read_mem_cmd.make_read_offset(temp,
			                              fd_feature_array+reference_size*(attribute.number-1),
			                              0,
			                              feat_descr);
			code.add_cmd(read_mem_cmd);
			indexed := recycle.new_indexed;
			indexed.make(target_local,temp);
			result_value := indexed;
		end; -- compile_dynamic_read_variable_attribute

	compile_unqualified_routine_call(code: ROUTINE_CODE) is
		local
			call_cmd: CALL_COMMAND;
			args: LIST[LOCAL_VAR];
			really_called: FEATURE_INTERFACE; -- name of actual feature called by immediate or inherited routine
			local_type: LOCAL_TYPE;
		do
			if code.fi.doing_precondition and then
				not code.class_code.actual_class.key.actual_is_expanded 
			then
			-- while checking precondition on a reference object, even
			-- unqualified calls must be dynamic:
				args := compile_arguments(code,code.current_local);
				check_precondition(code,
				                   code.fi.class_of_origin.like_current,
				                   code.fi.class_of_origin,
				                   called_feature,
				                   args,
				                   position,
				                   true);
				clone_and_copy.compile_dynamic_call(code,
				                                    code.current_local,
				                                    code.fi.interface.like_current,
				                                    called_feature.number,
				                                    args,
				                                    type);
				result_value := clone_and_copy.dynamic_call_result;
			else
				really_called := code.fi.get_new_feature(feature_name);
				if really_called.origin.name = globals.string_array and then 
				   really_called.seed.key = globals.string_element_size
				then
					compile_std_array(code);
				elseif really_called.origin.name = globals.string_general and then
				   (really_called.seed.key = globals.string_clone             or else
				    really_called.seed.key = globals.string_standard_clone    or else
				    really_called.seed.key = globals.string_standard_copy     or else
				    really_called.seed.key = globals.string_void                     )
				then
					compile_std_general(code,really_called.seed.key);
				else
					if     really_called.feature_value.is_constant_attribute then result_value := really_called.feature_value.constant_value;
					elseif really_called.feature_value.is_variable_attribute then compile_unqualified_read_this_variable_attribute(code,really_called);
					elseif really_called.feature_value.is_external           then 
					  -- nyi: this is done by SE, but redefinition between internal and external is not allowed in ETL, so this case can be removed
					else
						args := compile_arguments(code,code.current_local);
						check_precondition(code,
						                   really_called.type_of_class_of_origin,
						                   really_called.class_of_origin,
						                   really_called.seed,
						                   args,
						                   position,
						                   true);
						if type/=Void then
							local_type := type.local_type(code)
						else
							local_type := Void
						end;
						call_cmd := recycle.new_call_cmd;
						call_cmd.make_static(code,
						                     really_called.get_static_name(code.class_code.actual_class),
						                     args,
						                     local_type);
						result_value := call_cmd.result_local;
						code.add_cmd(call_cmd);
					end;
				end;
			end;
		end; -- compile_unqualified_routine_call

--------------------------------------------------------------------------------

	compile_std_array (code: ROUTINE_CODE) is
	-- This traps the unqualified call to element_size within class ARRAY
		local
			element_type: ACTUAL_CLASS_NAME;
			element_size: INTEGER;
		do
			-- get array element size:
			element_type := code.fi.origin.actual_class_name(code.class_code.actual_class.key).actual_generics @ 1;
			if element_type.actual_is_expanded then
				element_size := actual_classes.find(element_type).size;
			else
				element_size := reference_size;
			end;
			!INTEGER_CONSTANT!result_value.make(element_size);
		end; -- compile_std_array
	
--------------------------------------------------------------------------------

	compile_std_general (code: ROUTINE_CODE; seed_of_called_routine: INTEGER) is
		local
			arg: VALUE;
			t: TYPE;
		do
			if seed_of_called_routine = globals.string_void then
				result_value := void_constant;
			else
				arg := item(1).compile(code);
				t := item(1).type;
				if seed_of_called_routine = globals.string_standard_copy  then
					clone_and_copy.compile_standard_copy(code,arg,t);
				elseif seed_of_called_routine = globals.string_standard_clone then
					clone_and_copy.compile_standard_clone(code,arg,t);
					result_value := clone_and_copy.cloned_object;			
				elseif seed_of_called_routine = globals.string_clone then
					clone_and_copy.compile_clone(code,arg,t);
					result_value := clone_and_copy.cloned_object;
				end;
			end;
		end; -- compile_std_general

	clone_and_copy: CLONE_AND_COPY is 
		once
			!!Result
		end; -- clone_and_copy
		
	void_constant: VOID_CONSTANT is
		once
			!!Result.make;
		end; -- void_constant

--------------------------------------------------------------------------------

	compile_equality (code: ROUTINE_CODE) is
		local
			left_type  ,rite_type  : TYPE;
			left_l_type,rite_l_type: LOCAL_TYPE;
			left_value ,rite_value : VALUE;
		do
			left_type := target.type;
			rite_type := item(1).type;
			left_l_type := left_type.local_type(code);
			rite_l_type := rite_type.local_type(code);
			left_value := target .compile(code);
			rite_value := item(1).compile(code);
			if (left_l_type.is_reference xor rite_l_type.is_reference) or
				left_l_type.is_expanded 
			then
				compile_equality_using_equal(code,
				                             left_type  ,rite_type,
				                             left_value ,rite_value);
			else -- compare references or standard types
				compile_equality_for_refs_or_standard(code,
				                             left_l_type,rite_l_type,
				                             left_value ,rite_value);
			end;
		end; -- compile_equality

	compile_equality_using_equal (code: ROUTINE_CODE;
	                              left_type  ,rite_type: TYPE;
	                              left_value ,rite_value: VALUE) is
	-- compile "=" or "/=" for expanded objects. This calls GENERAL.equal()
		local
			call_cmd: CALL_COMMAND;
			args: LIST[LOCAL_VAR];
			equal_routine: FEATURE_INTERFACE;
		do
			args := recycle.new_args_list;
			args.add(code.current_local);
			compile_assign.clone_or_copy_no_dst(code,
			                                    globals.type_general,
			                                    left_type,
			                                    left_value);
			args.add(compile_assign.cloned_or_copied.need_local(code,globals.local_reference));
			compile_assign.clone_or_copy_no_dst(code,
			                                    globals.type_general,
			                                    rite_type,
			                                    rite_value);
			args.add(compile_assign.cloned_or_copied.need_local(code,globals.local_reference));
			
			equal_routine := code.fi.interface.get_inherited_feature(globals.general_ancestor_name,globals.string_equal);
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,
			                     equal_routine.get_static_name(code.class_code.actual_class),
			                     args,
			                     globals.local_boolean);
			code.add_cmd(call_cmd);
			if is_equality then
				result_value := call_cmd.result_local;
			else
				result_value := call_cmd.result_local.invert_boolean(code);
			end;
		end; -- compile_equality_using_equal

	compile_equality_for_refs_or_standard (code: ROUTINE_CODE; 
	                                       left_type, rite_type: LOCAL_TYPE;
	                                       left_value,rite_value: VALUE) is
	-- compile "=" or "/=" for references or standard types
		local
			condition: INTEGER; -- the condition
			left_local,rite_local,new_left_local,new_rite_local: LOCAL_VAR;
			real_type: LOCAL_TYPE;
			boolval: BOOLEAN_VALUE;
			is_const_target,is_const_arg: BOOLEAN;
			const_target,const_arg: INTEGER;
		do
			if is_equality then condition := c_equal
			               else condition := c_not_equal
			end;

			if left_type .is_real_or_double or
				rite_type.is_real_or_double
			then
				left_local := left_value.need_local(code,left_type);
				rite_local := rite_value.need_local(code,rite_type);
				if left_type.is_double or rite_type.is_double then
					real_type := globals.local_double;
				else
					real_type := globals.local_real;
				end;
				if real_type /= left_type then
					new_left_local := recycle.new_local(code,real_type);
					code.add_cmd(recycle.new_ass_cmd(new_left_local,left_local));
					left_local := new_left_local;
				end;
				if real_type /= rite_type then
					new_rite_local := recycle.new_local(code,real_type);
					code.add_cmd(recycle.new_ass_cmd(new_rite_local,rite_local));
					rite_local := new_rite_local;
				end;
				is_const_target := false;
				is_const_arg := false;
			else

				check_const_ibcr(left_value,target.type);
				is_const_target := is_const_ibcr;
				const_target := const_ibcr_value;
				if not is_const_target then
					left_local := left_value.need_local(code,left_type);
				end;
			
				check_const_ibcr(rite_value,item(1).type);
				is_const_arg := is_const_ibcr;
				const_arg := const_ibcr_value;
				if not is_const_arg then
					rite_local := rite_value.need_local(code,left_type);
				end;
			end;
							
			if is_const_target and is_const_arg then
				!BOOLEAN_CONSTANT!result_value.make(is_equality = (const_target = const_arg));
			else
				boolval := recycle.new_boolval;
				if is_const_target then
					boolval.make(rite_local,Void,const_target,condition);
				elseif is_const_arg then
					boolval.make(left_local,Void,const_arg,condition);
				else
					boolval.make(left_local,rite_local,0,condition);
				end;
				result_value := boolval;
			end;
		end; -- compile_equality_for_refs_or_standard


	is_const_ibcr: BOOLEAN;
	const_ibcr_value: INTEGER;

	check_const_ibcr (val: VALUE; val_type: TYPE) is
	-- if val with type is constant integer, boolean, char or attribute set is_const_ibcr 
	-- to true and store the value in const_ibcr_value.
		local
			c_int: INTEGER_CONSTANT;
			c_bool: BOOLEAN_CONSTANT;
			c_char: CHARACTER_CONSTANT;
		do
			is_const_ibcr := false;
			if val_type.is_none then
				is_const_ibcr := true;
				const_ibcr_value := 0;
			else
				c_int ?= val;
				c_bool ?= val;
				c_char ?= val;
				if c_int /= Void then
					is_const_ibcr := true;
					const_ibcr_value := c_int.value;
				elseif c_bool /= Void then
					is_const_ibcr := true;
					if c_bool.value then
						const_ibcr_value := 1;
					else
						const_ibcr_value := 0;
					end;
				elseif c_char /= Void then
					is_const_ibcr := true;
					const_ibcr_value := c_char.value.code;
				end;
			end;
		end; -- check_const_ibcr

--------------------------------------------------------------------------------

	compile_qualified_read_variable_attribute (code: ROUTINE_CODE) is
		local
			target_local,feat_descr,temp: LOCAL_VAR;
			read_mem_cmd: READ_MEM_COMMAND;
			offset,color: INTEGER;
			off_ind: OFFSET_INDIRECT_VALUE;
			indexed: INDEXED_VALUE;
		do
			if target.type.actual_is_reference(code) then
				target_local := target.compile(code).need_local(code,globals.local_reference);
				check_void(code,target_local,position);
				compile_dynamic_read_variable_attribute(code,called_feature,target_local,target.type);
			else
				temp := target.compile(code).load_address(code);
				offset := target.type.actual_class_code(code).attribute_offsets @ called_feature.number
				off_ind := recycle.new_off_ind;
				off_ind.make(offset,temp);
				result_value := off_ind;
			end;
		end; -- compile_qualified_read_variable_attribute

	compile_qualified_routine_call (code: ROUTINE_CODE) is
		local
			target_local: LOCAL_VAR;
			target_l_type: LOCAL_TYPE;
			target_base_type: TYPE;
		do
			if target.type.actual_is_reference(code) then
				target_local := target.compile(code).need_local(code,globals.local_reference);
				compile_qualified_routine_call_with_ref_target(code,target_local,target.type);
			else
				target_l_type := target.type.local_type(code);
				if target_l_type.is_boolean and then
					(feature_name = globals.string_prefix_not     or else
					 feature_name = globals.string_infix_and_then or else
					 feature_name = globals.string_infix_or_else  or else
					 feature_name = globals.string_infix_and      or else
					 feature_name = globals.string_infix_or       or else
					 feature_name = globals.string_infix_implies)
				then
					compile_std_boolean(code);
				elseif target_l_type.is_integer and then
					(feature_name = globals.string_prefix_plus            or else
					 feature_name = globals.string_prefix_minus           or else
					 feature_name = globals.string_infix_plus             or else
					 feature_name = globals.string_infix_minus            or else
					 feature_name = globals.string_infix_times            or else
					 feature_name = globals.string_infix_div              or else
					 feature_name = globals.string_infix_mod              or else
					 feature_name = globals.string_infix_less             or else
					 feature_name = globals.string_infix_less_or_equal    or else
					 feature_name = globals.string_infix_greater          or else
					 feature_name = globals.string_infix_greater_or_equal or else
					 feature_name = globals.string_three_way_comparison   or else
					 -- nyi: min, max
					 feature_name = globals.string_to_character           or else
					 feature_name = globals.string_to_pointer) 
				then
					compile_std_integer(code);
				elseif (target_l_type.is_real  or else 
				        target_l_type.is_double         ) and then
					(feature_name = globals.string_prefix_plus            or else
					 feature_name = globals.string_prefix_minus           or else
					 feature_name = globals.string_infix_plus             or else
					 feature_name = globals.string_infix_minus            or else
					 feature_name = globals.string_infix_times            or else
					 feature_name = globals.string_infix_divide           or else
					 feature_name = globals.string_infix_less             or else
					 feature_name = globals.string_infix_less_or_equal    or else
					 feature_name = globals.string_infix_greater          or else
					 feature_name = globals.string_infix_greater_or_equal or else
					 -- nyi: min, max, 3-way-comparison
					 feature_name = globals.string_truncated_to_integer   or else
					 feature_name = globals.string_to_real   and then target_l_type.is_double or else
					 feature_name = globals.string_to_double and then target_l_type.is_real  )
				then
					compile_std_real(code);
				elseif target_l_type.is_character and then
					(feature_name = globals.string_code                   or else
					 feature_name = globals.string_to_integer             or else
					 feature_name = globals.string_infix_less             or else
					 feature_name = globals.string_infix_less_or_equal    or else
					 feature_name = globals.string_infix_greater          or else
					 feature_name = globals.string_infix_greater_or_equal) 
					 -- nyi: min, max, 3-way-comparison
				then
					compile_std_character(code);
				elseif target_l_type.is_pointer and then
					(feature_name = globals.string_to_integer)
				then
					compile_std_pointer(code);
				else
					target_base_type := target.type.base_type(code.fi);
					if target.type.is_formal_generic and then
						target_base_type.actual_is_reference(code)
					then
-- nyi: this strange case occurs when compiling a call to is_equal in array[g].is_equal.
-- print("&: compiling "); print(strings @ code.fi.key); 
-- if code.fi.doing_precondition then print("(precondition)") end;
-- print(" in class "); code.class_code.actual_class.key.print_name;
-- print(" calling "); print(strings @ feature_name); print("%N");
						-- nyi: check if this part is needed
						compile_assign.clone_or_copy_no_dst(code,
						                                    target_base_type,
						                                    target.type,
						                                    target.compile(code));
						target_local := compile_assign.cloned_or_copied.need_local(code,globals.local_reference);
						compile_qualified_routine_call_with_ref_target(code,target_local,target_base_type);
					else
						compile_qualified_routine_call_with_exp_target(code);
					end;
				end;
			end;
		end; -- compile_qualified_routine_call

	compile_qualified_routine_call_with_ref_target(code: ROUTINE_CODE;
	                                               target_local: LOCAL_VAR;
	                                               target_type: TYPE) is
		local
			args: LIST[LOCAL_VAR];
		do
			check_void(code,target_local,position);
			args := compile_arguments(code,target_local);
			check_precondition(code,
			                   -- was: called_feature.type_of_class_of_origin.view_client(code.fi,target,target.type,called_feature.class_of_origin),
			                   target_type,
			                   called_class,
			                   called_feature,
			                   args,
			                   position,
			                   false);
			clone_and_copy.compile_dynamic_call(code,
			                                    target_local,
			                                    target_type,
			                                    called_feature.number,
			                                    args,
			                                    type);
			result_value := clone_and_copy.dynamic_call_result;
		end; -- compile_qualified_routine_call_with_ref_target		

	compile_qualified_routine_call_with_exp_target(code: ROUTINE_CODE) is
		local
			args: LIST[LOCAL_VAR];
			target_local: LOCAL_VAR;
			local_type: LOCAL_TYPE;
			call_cmd: CALL_COMMAND;
		do
			target_local := target.compile(code).load_address(code);
			args := compile_arguments(code,target_local);
			if type/=Void then
				local_type := type.local_type(code)
			else
				local_type := Void
			end;
			check_precondition(code,
			                   target.type,
			                   called_class,
			                   called_feature,
			                   args,
			                   position,
			                   false);
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,
			                     called_feature.get_static_name(target.type.actual_class_code(code)),
			                     args,
			                     local_type);
			result_value := call_cmd.result_local;
			code.add_cmd(call_cmd);
		end; -- compile_qualified_routine_call_with_exp_target

--------------------------------------------------------------------------------

	compile_std_boolean(code: ROUTINE_CODE) is
		local
			arg_block,next_block: BASIC_BLOCK;
			target_value,arg_value: BOOLEAN_VALUE;
			fixups: LIST[BRANCH_FIXUP];
		do
			if feature_name = globals.string_prefix_not then
				result_value := target.compile(code).invert_boolean(code);
			else -- "and then", "or else" or "implies"
				arg_block := recycle.new_block(code.current_weight);
				target_value := target.compile(code).need_boolean(code);
				if feature_name = globals.string_infix_or_else or else	
					feature_name = globals.string_infix_or      
				then -- or: look at 2nd arg if first is false
					target_value.fix_false(code,arg_block); fixups := target_value.true_list;
				else -- and, implies: llok at 2nd arg if first is true
					target_value.fix_true (code,arg_block); fixups := target_value.false_list;
				end;
				compile_assign.clone_or_copy_no_dst(code,
				                                    globals.type_boolean,
				                                    item(1).type,
				                                    item(1).compile(code))
				arg_value := compile_assign.cloned_or_copied.need_boolean(code);
				if feature_name = globals.string_infix_and_then or else
				   feature_name = globals.string_infix_and
				then -- and: result is false if 2nd argument was irrelevant
					arg_value.add_false_fixups(fixups);
				else -- or, implies: result is true if 2nd argument was irrelevant
					arg_value.add_true_fixups(fixups);
				end;
				result_value := arg_value;
			end;
		end; -- compile_std_boolean

--------------------------------------------------------------------------------

	compile_std_integer(code: ROUTINE_CODE) is
		local
			target_value,arg_value: VALUE;
			target_local,arg_local,result_local,new_target_local: LOCAL_VAR;
			arg: ACTUAL;
			arg_type: TYPE;
			ari_cmd: ARITHMETIC_COMMAND;
			boolval: BOOLEAN_VALUE;
			condition, swapped_condition: INTEGER; -- condition and its equivalent with swapped arguments
			const_target,const_arg: INTEGER_CONSTANT;
			c,c1: INTEGER;
			bool: BOOLEAN;
			set_minus1,set_zero,set_plus1,test_equal,next: BASIC_BLOCK;
			one_succ: ONE_SUCCESSOR;
			two_succ: TWO_SUCCESSORS;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
						
		do
			target_value := target.compile(code);
			const_target ?= target_value;

			if feature_name = globals.string_to_character or
				feature_name = globals.string_to_pointer
			then -- type conversion

				target_local := target_value.need_local(code,globals.local_integer);
				if feature_name = globals.string_to_pointer then
					result_local := recycle.new_local(code,globals.local_pointer);
				else 
					result_local := recycle.new_local(code,globals.local_character);
				end; 
				code.add_cmd(recycle.new_ass_cmd(result_local,target_local));
				result_value := result_local;
			
			elseif feature_name = globals.string_prefix_plus or
				    feature_name = globals.string_prefix_minus
			then -- prefix operator:

				if feature_name = globals.string_prefix_plus then
					result_value := target_value
				else -- prefix "-"
					if const_target /= Void then 
						if const_target.value = Minimum_integer then
							position.error(msg.overflow);
							!INTEGER_CONSTANT!result_value.make(0);
						else
							!INTEGER_CONSTANT!result_value.make(-const_target.value);
						end;  
					else
						target_local := target_value.need_local(code,globals.local_integer);
						result_local := recycle.new_local(code,globals.local_integer);
						ari_cmd := recycle.new_ari_cmd;
						ari_cmd.make_binary_const(b_subf,result_local,target_local,0);
						code.add_cmd(ari_cmd);
						result_value := result_local;
					end;
				end;

			else  -- infix operator

				arg := item(1);
				arg_type := arg.type;
				
				-- convert target to double if arg is double:
				if feature_name /= globals.string_infix_div and then
				   feature_name /= globals.string_infix_mod and then 
				   (arg_type.is_real or arg_type.is_double)
				then
					new_target_local := recycle.new_local(code,arg_type.local_type(code));
					target_local := target_value.need_local(code,globals.local_integer);
					code.add_cmd(recycle.new_ass_cmd(new_target_local,target_local));
					compile_infix_real(code,new_target_local);
				else

					compile_assign.clone_or_copy_no_dst(code,
					                                    globals.type_integer,
					                                    item(1).type,
					                                    item(1).compile(code));
					arg_value := compile_assign.cloned_or_copied;
					const_arg ?= arg_value;

					if     feature_name = globals.string_infix_less_or_equal    then condition := c_less_or_equal;    swapped_condition := c_greater_or_equal
					elseif feature_name = globals.string_infix_less             then condition := c_less;             swapped_condition := c_greater
					elseif feature_name = globals.string_infix_greater_or_equal then condition := c_greater_or_equal; swapped_condition := c_less_or_equal
					elseif feature_name = globals.string_infix_greater          then condition := c_greater;          swapped_condition := c_less
					                                                            else condition := -1;
					end;

					if condition >= 0 then -- comparision:
				
						if const_target = Void then 
							target_local := target_value.need_local(code,globals.local_integer);
						end;
						if const_arg = Void then 
							arg_local := arg_value.need_local(code,globals.local_integer)
						end;
				
						if const_target /= Void and const_arg /= Void then
							inspect condition
							when c_less_or_equal    then bool := const_target.value <= const_arg.value  
							when c_less             then bool := const_target.value <  const_arg.value
							when c_greater_or_equal then bool := const_target.value >= const_arg.value
							when c_greater          then bool := const_target.value >  const_arg.value
							end;
							!BOOLEAN_CONSTANT!result_value.make(bool);
						else
							boolval := recycle.new_boolval;
							if const_target /= Void then
								boolval.make(arg_local,Void,const_target.value,swapped_condition);
							elseif const_arg /= Void then
								boolval.make(target_local,Void,const_arg.value,condition);
							else
								boolval.make(target_local,arg_local,0,condition);
							end;
							result_value := boolval;
						end;

					elseif feature_name = globals.string_three_way_comparison then

						target_local := target_value.need_local(code,globals.local_integer);
						arg_local := arg_value.need_local(code,globals.local_integer)
						result_local := recycle.new_local(code,globals.local_integer);
						result_value := result_local;
						
						set_minus1 := recycle.new_block(code.current_weight);
						set_zero   := recycle.new_block(code.current_weight);
						set_plus1  := recycle.new_block(code.current_weight);
						test_equal := recycle.new_block(code.current_weight);
						next       := recycle.new_block(code.current_weight);
						one_succ := recycle.new_one_succ(next);
						two_succ := recycle.new_two_succ;
						two_succ.make(target_local,arg_local,0,c_less,set_minus1,test_equal);						
						code.finish_block(two_succ,set_minus1);
						ass_const_cmd := recycle.new_ass_const_cmd;
						ass_const_cmd.make_assign_const_int(result_local,-1);
						code.add_cmd(ass_const_cmd);
						code.finish_block(one_succ,test_equal);
						two_succ := recycle.new_two_succ;
						two_succ.make(target_local,arg_local,0,c_greater,set_plus1,set_zero);
						code.finish_block(two_succ,set_plus1);
						ass_const_cmd := recycle.new_ass_const_cmd;
						ass_const_cmd.make_assign_const_int(result_local,+1);
						code.add_cmd(ass_const_cmd);
						code.finish_block(one_succ,set_zero);
						ass_const_cmd := recycle.new_ass_const_cmd;
						ass_const_cmd.make_assign_const_int(result_local,0);
						code.add_cmd(ass_const_cmd);
						code.finish_block(one_succ,next);

					else  -- numerical infix operator:
							 
						if const_target /= Void then
							if const_arg /= Void then   -- const <op> const
								c := const_target.value; c1 := const_arg.value;
								-- nyi: check overflow, div 0, ...!
								if     feature_name = globals.string_infix_plus  then c := c + c1;
								elseif feature_name = globals.string_infix_minus then c := c - c1;
								elseif feature_name = globals.string_infix_times then c := c * c1;
								elseif feature_name = globals.string_infix_div   then c := c // c1;
								elseif feature_name = globals.string_infix_mod   then c := c \\ c1;
								end;
								!INTEGER_CONSTANT!result_value.make(c);
							else   --- const <op> local
								c := const_target.value;
								if     feature_name = globals.string_infix_plus  then create_binary_const(code,b_add ,arg_value   ,c);
								elseif feature_name = globals.string_infix_minus then create_binary_const(code,b_subf,arg_value   ,c);
								elseif feature_name = globals.string_infix_times then create_binary_const(code,b_mul ,arg_value   ,c);
								elseif feature_name = globals.string_infix_div   then create_binary      (code,b_div ,target_value,arg_value)
								elseif feature_name = globals.string_infix_mod   then create_binary      (code,b_mod ,target_value,arg_value)
								end;
							end;
						else
							if const_arg /= Void then   -- local <op> const
								c := const_arg.value;
								if     feature_name = globals.string_infix_plus  then create_binary_const(code,b_add ,target_value,c);
								elseif feature_name = globals.string_infix_minus then create_binary_const(code,b_sub ,target_value,c);
								elseif feature_name = globals.string_infix_times then create_binary_const(code,b_mul ,target_value,c);
								elseif feature_name = globals.string_infix_div   then create_binary_const(code,b_div ,target_value,c);
								elseif feature_name = globals.string_infix_mod   then create_binary_const(code,b_mod ,target_value,c);
								end;
							else   -- local <op> local
								if     feature_name = globals.string_infix_plus  then create_binary      (code,b_add ,target_value,arg_value);
								elseif feature_name = globals.string_infix_minus then create_binary      (code,b_sub ,target_value,arg_value);
								elseif feature_name = globals.string_infix_times then create_binary      (code,b_mul ,target_value,arg_value);
								elseif feature_name = globals.string_infix_div   then create_binary      (code,b_div ,target_value,arg_value);
								elseif feature_name = globals.string_infix_mod   then create_binary      (code,b_mod ,target_value,arg_value);
								end;
							end;
						end;
					end;
				end;   -- if infix real operator else 
			end;   -- if feature_name = ...
		end; -- compile_std_integer
					
	create_binary(code: ROUTINE_CODE; operand: INTEGER; src1,src2: VALUE) is
	-- used by compile_std_integer to create arithmetic command with both arguments
	-- in local variables.
	-- result_value is set to the local holding the result.
		local
			result_local: LOCAL_VAR;
			ari_cmd: ARITHMETIC_COMMAND;
		do
			result_local := recycle.new_local(code,globals.local_integer);
			ari_cmd := recycle.new_ari_cmd;
			ari_cmd.make_binary(operand,
									  result_local,
			                    src1.need_local(code,globals.local_integer),
			                    src2.need_local(code,globals.local_integer));
			code.add_cmd(ari_cmd);
			result_value := result_local;
		end; -- create_binary
	
	create_binary_const(code: ROUTINE_CODE; operand: INTEGER; src1: VALUE; src2: INTEGER) is
	-- used by compile_std_integer to create arithmetic command with both arguments
	-- in local variables.
	-- result_value is set to the local holding the result.
		local
			result_local: LOCAL_VAR;
			ari_cmd: ARITHMETIC_COMMAND;
		do
			result_local := recycle.new_local(code,globals.local_integer);
			ari_cmd := recycle.new_ari_cmd;
			ari_cmd.make_binary_const(operand,
									        result_local,
			                          src1.need_local(code,globals.local_integer),
			                          src2);
			code.add_cmd(ari_cmd);
			result_value := result_local;
		end; -- create_binary

--------------------------------------------------------------------------------

	compile_std_real (code: ROUTINE_CODE) is
		local
			is_real: BOOLEAN;
			target_l_type,result_l_type: LOCAL_TYPE;
			target_value: VALUE;
			const_target: REAL_CONSTANT;
			target_local,arg_local,result_local, new_target_local: LOCAL_VAR;
			boolval: BOOLEAN_VALUE;
			condition: INTEGER; 
			ari_cmd: ARITHMETIC_COMMAND;
		do 
			target_l_type := target.type.local_type(code);
			is_real := target_l_type.is_real;
			target_value := target.compile(code);
			const_target ?= target_value;

			if feature_name = globals.string_truncated_to_integer or else
			   feature_name = globals.string_to_real              or else
				feature_name = globals.string_to_double
			then -- type conversion
				target_local := target_value.need_local(code,target_l_type);
				if     feature_name = globals.string_to_real   then result_l_type := globals.local_real;
			   elseif feature_name = globals.string_to_double then result_l_type := globals.local_double;
			                                                  else result_l_type := globals.local_integer;
			   end;
				result_local := recycle.new_local(code,result_l_type);
				code.add_cmd(recycle.new_ass_cmd(result_local,target_local));
				result_value := result_local;
			
			elseif feature_name = globals.string_prefix_plus  or
				    feature_name = globals.string_prefix_minus
			then -- prefix operator:

				if feature_name = globals.string_prefix_plus then
					result_value := target_value
				else -- prefix "-"
					if const_target /= Void then
						!REAL_CONSTANT!result_value.make(-const_target.value);
					else
						target_local := target_value.need_local(code,target_l_type);
						result_local := recycle.new_local(code,target_l_type);
						ari_cmd := recycle.new_ari_cmd;
						ari_cmd.make_unary(u_neg,result_local,target_local);
						code.add_cmd(ari_cmd);
						result_value := result_local;
					end;
				end;

			else  -- infix operator

				target_local := target_value.need_local(code,target_l_type);

				-- convert target to double if arg is double:
				if is_real and then item(1).type.is_double then
					is_real := false;
					target_l_type := globals.local_double;
					new_target_local := recycle.new_local(code,target_l_type);
					code.add_cmd(recycle.new_ass_cmd(new_target_local,target_local));
					target_local := new_target_local;
				end;
				
				compile_infix_real(code,target_local);
				
			end; -- if feature_name = ...
		
		end; -- compile_std_real

	compile_infix_real (code: ROUTINE_CODE; target_local: LOCAL_VAR) is
	-- compile infix operator for reals. target_local is already converted to double if 
	-- item(1).type.is_double.
	-- This is also used by compile_std_integer, if the argument is real or double
		local
			arg_local,result_local: LOCAL_VAR;
			condition: INTEGER;
			boolval: BOOLEAN_VALUE;
			operand: INTEGER;
			ari_cmd: ARITHMETIC_COMMAND;
		do
			compile_assign.clone_or_copy_no_dst(code,
			                                    target.type,
			                                    item(1).type,
			                                    item(1).compile(code));
			arg_local := compile_assign.cloned_or_copied.need_local(code,target_local.type);
				
			if     feature_name = globals.string_infix_less_or_equal    then condition := c_less_or_equal;
			elseif feature_name = globals.string_infix_less             then condition := c_less;
			elseif feature_name = globals.string_infix_greater_or_equal then condition := c_greater_or_equal;
			elseif feature_name = globals.string_infix_greater          then condition := c_greater;
			                                                            else condition := -1;
			end;
			
			if condition >= 0 then -- comparision:
				boolval := recycle.new_boolval;
				boolval.make(target_local,arg_local,0,condition);
				result_value := boolval;
			else  -- numerical infix operator:
				if     feature_name = globals.string_infix_plus   then operand := b_add;
				elseif feature_name = globals.string_infix_minus  then operand := b_sub;
				elseif feature_name = globals.string_infix_times  then operand := b_mul;
				elseif feature_name = globals.string_infix_divide then operand := b_div;
				end;
				result_local := recycle.new_local(code,target_local.type);
				ari_cmd := recycle.new_ari_cmd;
				ari_cmd.make_binary(operand,result_local,target_local,arg_local);
				code.add_cmd(ari_cmd);
				result_value := result_local;
			end;
		end; -- compile_infix_real

		
--------------------------------------------------------------------------------

	compile_std_pointer (code: ROUTINE_CODE) is
		local
			target_local,result_local: LOCAL_VAR;
			
		do -- the only pointer routine implemented by the compiler is to_integer:
		
			target_local := target.compile(code).need_local(code,globals.local_pointer);
			result_local := recycle.new_local(code,globals.local_integer);
			code.add_cmd(recycle.new_ass_cmd(result_local,target_local));
			result_value := result_local;
			
		end; -- compile_std_pointer

--------------------------------------------------------------------------------
					
	compile_std_character(code: ROUTINE_CODE) is
		local
			target_value,arg_value: VALUE;
			target_local,arg_local,result_local: LOCAL_VAR;
			const_target, const_arg: CHARACTER_CONSTANT;
			boolval: BOOLEAN_VALUE;
			condition, swapped_condition: INTEGER;
			bool: BOOLEAN;
		do
			target_value := target.compile(code);
			const_target ?= target_value;
			
			if feature_name = globals.string_code       or else
				feature_name = globals.string_to_integer 

			then -- convert character to integer

				target_local := target_value.need_local(code,globals.local_character);
				result_local := recycle.new_local(code,globals.local_integer); 
				code.add_cmd(recycle.new_ass_cmd(result_local,target_local));
				result_value := result_local;

			else -- character comparison
			
				compile_assign.clone_or_copy_no_dst(code,
				                                    globals.type_character,
				                                    item(1).type,
				                                    item(1).compile(code));
				arg_value := compile_assign.cloned_or_copied;
				const_arg ?= arg_value;

				if     feature_name = globals.string_infix_less_or_equal    then condition := c_less_or_equal;    swapped_condition := c_greater_or_equal
				elseif feature_name = globals.string_infix_less             then condition := c_less;             swapped_condition := c_greater
				elseif feature_name = globals.string_infix_greater_or_equal then condition := c_greater_or_equal; swapped_condition := c_less_or_equal
				elseif feature_name = globals.string_infix_greater          then condition := c_greater;          swapped_condition := c_less
				else
					condition := -1;
				end;

				if const_target = Void then
					target_local := target_value.need_local(code,globals.local_character);
				end;
				if const_arg = Void then
					arg_local := arg_value.need_local(code,globals.local_character);
				end;
				
				if const_target /= Void and const_arg /= Void then
					inspect condition
					when c_less_or_equal    then bool := const_target.value <= const_arg.value  
					when c_less             then bool := const_target.value <  const_arg.value
					when c_greater_or_equal then bool := const_target.value >= const_arg.value
					when c_greater          then bool := const_target.value >  const_arg.value
					end;
					!BOOLEAN_CONSTANT!result_value.make(bool);
				else
					boolval := recycle.new_boolval;
					if const_target /= Void then
						boolval.make(arg_local,Void,const_target.value.code,swapped_condition);
					elseif const_arg /= Void then
						boolval.make(target_local,Void,const_arg.value.code,condition);
					else
						boolval.make(target_local,arg_local,0,condition);
					end;
					result_value := boolval;
				end;
				
			end; -- if feature_name = ...
		
		end; -- compile_std_character

--------------------------------------------------------------------------------
			
	compile_external_call(code: ROUTINE_CODE) is
		local
			args: LIST[LOCAL_VAR];
			rout: ROUTINE;
			er: EXTERNAL_ROUTINE;
			call_cmd: CALL_COMMAND;
			name: INTEGER;
			local_type: LOCAL_TYPE;
		do
			rout ?= called_feature.feature_value;
			er ?= rout.routine_body;
			args := compile_arguments(code,Void);
			if er.external_name /= 0 then
				name := er.external_name
			else
				name := feature_name
			end;
			if type/=Void then
				local_type := type.local_type(code)
			else
				local_type := Void
			end;
			-- nyi: check precondition, add target.compile() or ADR(target.compile) as first argument.
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,
			                     name,
			                     args,
			                     local_type);
			result_value := call_cmd.result_local;
			code.add_cmd(call_cmd);
		end; -- compile_external_call

--------------------------------------------------------------------------------

	compile_arguments(code: ROUTINE_CODE; 
	                  add_current: LOCAL_VAR): LIST[LOCAL_VAR] is
		local
			i: INTEGER; 
			actual: ACTUAL;
			formal_type: TYPE;
			src: VALUE;
		do
			Result := recycle.new_args_list;
			if add_current/=Void then
				Result.add(add_current);
			end;
			from
				i := 1
			until
				i > count
			loop
				actual := item(i);
				formal_type := actual.formal_type;
				compile_assign.clone_or_copy_no_dst(code,
				                                    formal_type,
				                                    actual.type,
				                                    actual.compile(code));
				src := compile_assign.cloned_or_copied;
				Result.add(src.need_local(code,formal_type.local_type(code)));
				i := i + 1;
			end; 
		end -- compile_arguments

	result_value: VALUE;

--------------------------------------------------------------------------------
	
feature { ANY }

	expression_compile(code: ROUTINE_CODE): VALUE is
		do
			compile_call(code); 
			Result := result_value;
		end; -- expression_compile
			
	instruction_compile(code: ROUTINE_CODE) is
		do
			compile_call(code);
		end; -- instruction_compile
											
--------------------------------------------------------------------------------
	
end -- CALL
