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

class ROUTINE 

inherit
	SCANNER_SYMBOLS;
	FEATURE_VALUE
		redefine
			is_deferred,
			has_require_else_and_ensure_then,
			is_routine,
			is_once,
			is_external,
			is_internal_routine,
			add_locals,
			alloc_locals,
			set_calls
		end;
	FRIDISYS;
	CONDITIONS;
	COMPILE_ASSIGN;
	
creation
	parse

--------------------------------------------------------------------------------
	
feature { ANY }

	obsolete_msg : INTEGER;             -- obsolete-message or Void
	
	precondition : ASSERTION;         
	postcondition : ASSERTION; 
	
	is_require_present : BOOLEAN;      -- keyword "require" found?
	is_require_else_present : BOOLEAN; -- keywords "require else" found ?	

	is_ensure_present : BOOLEAN;       -- keyword "ensure" found?
	is_ensure_then_present : BOOLEAN;  -- keywords "ensure_then" found ?	
	
	locals: ENTITY_DECLARATION_LIST;   -- lokale Variablen oder Void

	routine_body : ROUTINE_BODY; 
	
	rescue_compound : COMPOUND;         
	
	position: POSITION; 
	
--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Routine = Obsolete
	--           [Header_comment]
	--           Precondition
	--           Local_declarations
	--           Routine_body
	--           Postcondition
	--           Rescue
	--           "end" ["--" Feature_name]
		do
			position := s.current_symbol.position;
			parse_obsolete(s);
			parse_precondition(s);
			parse_local_declarations(s);
			parse_routine_body(s);
			parse_postcondition(s);
			parse_rescue(s);
			s.check_keyword(s_end); 
		end; -- parse

--------------------------------------------------------------------------------

	parse_obsolete (s: SCANNER) is
	-- Obsolete = ["obsolete" Message].
	-- Message = Manifest_string.
		do
			if s.current_symbol.type = s_obsolete then
				s.next_symbol;
				s.check_and_get_string(msg.obs_expected);
				obsolete_msg := s.last_string;
			else
				obsolete_msg := 0;
			end;
		end; -- parse_obsolete

--------------------------------------------------------------------------------

	parse_precondition (s: SCANNER) is
	-- Precondition = ["require" ["else"] Assertion].
		do
			if s.current_symbol.type = s_require then
				s.next_symbol;
				is_require_present := true; 
				if s.current_symbol.type = s_else then 
					s.next_symbol;
					is_require_else_present := true;
				end;
memstats(220);
				!!precondition.parse(s); 
			else
				is_require_present := false;
				is_require_else_present := false; 
				precondition := empty_assertion;
			end;
		ensure
			is_require_else_present implies is_require_present;
			precondition /= Void;
		end; -- parse_precondition

--------------------------------------------------------------------------------

	parse_postcondition (s: SCANNER) is
	-- Postcondition = ["ensure" ["then"] Assertion].
		do
			if s.current_symbol.type = s_ensure then
				s.next_symbol;
				is_ensure_present := true; 
				if s.current_symbol.type = s_then then 
					s.next_symbol;
					is_ensure_then_present := true;
				end;
memstats(221);
				!!postcondition.parse(s); 
			else
				is_ensure_present := false;
				is_ensure_then_present := false; 
				postcondition := empty_assertion;
			end;
		ensure
			is_ensure_then_present implies is_ensure_present;
			postcondition /= Void;
		end; -- parse_postcondition

--------------------------------------------------------------------------------

	parse_local_declarations (s: SCANNER) is
	-- Local_declarations = ["local" Entity_declaration_list].
		do
			if s.current_symbol.type = s_local then
				s.next_symbol;
memstats(222);
				!!locals.parse(s,false);
			end;
		end; -- parse_local_declaration_list
		
--------------------------------------------------------------------------------

	parse_routine_body (s: SCANNER) is
	-- Routine_body = Effective | Deferred.
	-- Effective = Internal | External.
		do
			inspect s.current_symbol.type
			when s_deferred then
memstats(223);
				!DEFERRED_ROUTINE!routine_body.parse(s);
			when s_external then
memstats(224);
				!EXTERNAL_ROUTINE!routine_body.parse(s);
			else
memstats(225);
				!INTERNAL_ROUTINE!routine_body.parse(s);
			end;
		end; -- parse_routine_body
		
--------------------------------------------------------------------------------

	parse_rescue (s: SCANNER) is
	-- Rescue = ["rescue" Compound].
		do
			if s.current_symbol.type = s_rescue then
				s.next_symbol;
memstats(226);
				!!rescue_compound.parse(s);
			end;
		end; -- parse_rescue
		
--------------------------------------------------------------------------------

	empty_assertion : ASSERTION is
		once
			!!Result.clear
		end; -- empty_assertion

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	is_deferred: BOOLEAN is
		do
			Result := routine_body.is_deferred;
		end; -- is_deferred

	has_require_else_and_ensure_then: BOOLEAN is
		do
			Result := (is_require_present implies is_require_else_present) and
			          (is_ensure_present  implies is_ensure_then_present)
		end; -- has_require_else_and_ensure_then

	is_routine : BOOLEAN is
		do
			Result := true
		end; -- is_routine
		
	is_once : BOOLEAN is
		do
			Result := routine_body.is_once;
		end; -- is_once

	is_external : BOOLEAN is
		do
			Result := routine_body.is_external;
		end; -- is_external

	is_internal_routine : BOOLEAN is
		do
			Result := routine_body.is_internal;
		end; -- is_external

	add_locals (fi: FEATURE_INTERFACE) is
	-- falls dies eine interne Routine ist, so werden die bezeichner
	-- der lokalen Variablen fi.local_identifiers hinzugefŸgt.
		local
			i: INTEGER;
			existing,new: LOCAL_OR_ARGUMENT;
			f: FEATURE_INTERFACE; 
		do
			if locals /= Void then
				from 
					i := 1
				until
					i > locals.count
				loop
					new := locals @ i;
					f := fi.interface.feature_list.find(new.key); 
					if f /= Void then
						new.position.error(msg.vrle1);
					end;
					existing := fi.local_identifiers.find(new.key)
					if existing /= Void then
						if existing.is_argument then
							new.position.error(msg.vrle2);
						else
							new.position.error(msg.vreg1);
						end;
					else
						fi.local_identifiers.add(new);
					end;
					i := i + 1;
				end;
			end;
		end; -- add_locals;

--------------------------------------------------------------------------------

feature { CALL }

	set_calls (n: INTEGER) is
		do
			routine_body.set_calls(n);
		end; -- set_calls

--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		do
			if locals /= Void then
				locals.validity(fi);
			end;
			if routine_body.is_deferred or routine_body.is_external then
				if locals /= Void or rescue_compound /= Void then
					position.error(msg.vrrr1);
				end;
			end;
			fi.start_precondition; precondition.validity(fi); fi.stop_precondition;
			routine_body.validity(fi);
			fi.start_postcondition; postcondition.validity(fi); fi.stop_postcondition;
			if rescue_compound /= Void then
				if not routine_body.is_internal then
					position.error(msg.vxrc1); 
				else
					fi.start_rescue;
						rescue_compound.validity(fi);
					fi.stop_rescue;
				end;
			end;
		end; -- validity

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
		require else
			is_internal_routine
		do
			routine_body.compile(code);
		end -- compile

--------------------------------------------------------------------------------

	compile_precondition(code: ROUTINE_CODE) is
		local
			basic: BASIC_BLOCK;
			last_block,next_block: BASIC_BLOCK;
			i: INTEGER;
			j: FEATURE_INTERFACE;
			args: LIST[LOCAL_VAR];
			call_cmd: CALL_COMMAND;
			joined_condition: LOCAL_VAR;
			boolval: BOOLEAN_VALUE;
			ass_cmd: ASSIGN_COMMAND;
			last_succ: ONE_SUCCESSOR;
		do
			-- prolog
			basic := recycle.new_block(basic.weight_normal);
			code.set_first_block(basic);
			code.fi.alloc_arguments(code);
			if not code.class_code.actual_class.key.actual_generics.is_empty and then
				not code.class_code.actual_class.is_expanded
			then
			-- add an extra argument for the static type of Current in case of a
			-- precondition within a generic reference class. This is needed for some 
			-- dynamically bound calls to features of Current.
				recycle.new_local(code,globals.local_pointer).add_to_arguments(code);
			end;
			-- body
			last_block := recycle.new_block(basic.weight_normal);
			last_succ := recycle.new_one_succ(last_block);
--			if not precondition.is_empty then
--				next_block := recycle.new_block(basic.weight_normal);
--				precondition.compile(code,0,next_block);
--				code.finish_block(last_succ,next_block);
--			end;
			from
				i := 1
			until
				i > code.fi.ored_preconditions.count
			loop
				next_block := recycle.new_block(basic.weight_normal);
				(code.fi.ored_preconditions @ i).compile(code,0,next_block);
				code.result_local.assign_initial_value(code);
				code.finish_block(last_succ,next_block);
				i := i + 1;
--				j := code.fi.joined_preconditions @ i;		
--				r ?= j.
--				args := adapt_arguments_for_redeclared_precondition(code,j);
--				call_cmd := recycle.new_call_cmd;
--				call_cmd.make_static(code,
--				                     j.get_static_precondition_name(code.class_code.actual_class),
--			                    	   args,
--			                        globals.local_pointer);
--				code.add_cmd(call_cmd);
--				code.add_cmd(recycle.new_ass_cmd(code.result_local,call_cmd.result_local));
--				boolval := recycle.new_boolval;
--				boolval.make(code.result_local,Void,0,c_equal);				
--				next_block := recycle.new_block(basic.weight_normal);
--				boolval.fix_boolean(code,last_block,next_block,next_block);
--				i := i + 1;
			end;
			code.finish_block(last_succ,last_block);
			-- epilog
			code.finish_block(no_successor,Void);
		end -- compile_precondition

feature { NONE }

	adapt_arguments_for_redeclared_precondition(code: ROUTINE_CODE; 
	                                            j: FEATURE_INTERFACE): LIST[LOCAL_VAR] is
	-- this adapts the arguments for a call to a joined preconditions. 
	-- This handles the case in which a reference argument was redeclared as
	-- an expanded type. Additionally, it adds the extra argument of the static
	-- type of Current in a generic reference class.
		local
			arg: INTEGER;
			jfa,ffa: LIST[LOCAL_OR_ARGUMENT];
			jfaat: TYPE;
			ffaa: LOCAL_OR_ARGUMENT;
			static_type: TYPE;
			td: LOCAL_VAR;
		do
			Result := recycle.new_args_list;
			Result.add(code.current_local);
			from
				arg := 1;
				jfa := j.formal_arguments;
				ffa := code.fi.formal_arguments;
			until
				arg > jfa.count
			loop
				jfaat := (jfa @ arg).type;
				ffaa  := (ffa @ arg);
				compile_assign.clone_or_copy_no_dst(code,
				                                    jfaat,
				                                    ffaa.type,
				                                    ffaa.local_var);
				Result.add(compile_assign.cloned_or_copied.need_local(code,jfaat.local_type(code)));
				arg := arg + 1;
			end;
			if not j.parent_clause.class_type.actual_generics.is_empty and then
				not code.class_code.actual_class.is_expanded 
			then
			-- add an extra argument for the static type of Current in case of a
			-- precondition within a generic reference class. This is needed for some 
			-- dynamically bound calls to features of Current.
				static_type := j.get_static_precondition_type;
				td := compile_assign.clone_and_copy.compile_get_type_descriptor(code,static_type,false);
				Result.add(td);
			end;
		end; -- adapt_arguments_for_redeclared_precondition

--------------------------------------------------------------------------------

feature { ANY }

	alloc_locals (code: ROUTINE_CODE) is
		local
			i: INTEGER;
		do
			if locals /= Void then
				from 
					i := 1
				until
					i > locals.count
				loop
					(locals @ i).alloc_local(code);
					i := i + 1;
				end;
			end;
		end; -- add_locals;

--------------------------------------------------------------------------------

feature { NONE }

	no_successor: NO_SUCCESSOR is
		once
			!!Result.make
		end -- no_successor
	
end -- ROUTINE
