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

class ACTUAL

inherit
	SCANNER_SYMBOLS;
	PARSE_EXPRESSION;
	FRIDISYS;
	
creation
	parse, make_from_expression

creation { ACTUAL }
	new_view

--------------------------------------------------------------------------------
	
feature { ANY }

	address_of : INTEGER;  -- ist dies ein Address-ACTUAL, der id des Bezeichners
	                       -- in Kleinbuchstaben, sonst 0
	                       
-- expression : EXPRESSION;  -- ist dies ein normaler ACTUAL-Parameter, der Ausdruck
                             -- der diesen berechnet.

	position: POSITION; 

--------------------------------------------------------------------------------
	
	parse (s: SCANNER) is
	-- Actual = Expression | Address.
	-- Address = "$" Identifier.
		do
			position := s.current_symbol.position;
			if s.current_symbol.type = s_dollar_sign then 
				s.next_symbol;
				s.check_and_get_identifier(msg.id_adr_expected);
				address_of := s.last_identifier;
				expression := Void;
			else
				parse_expression(s); 
				address_of := 0;
			end;	
		ensure
			address_of = 0 xor expression = Void;
		end; -- parse

--------------------------------------------------------------------------------

	make_from_expression (expr: EXPRESSION) is	
	-- Erzeuge ACTUAL, der diesen Ausdruck enthölt. Dies wird bei binären
	-- Operatoren verwendet, um aus der rechten Seite einen aktuellen Parameter
	-- zu machen
		do
			expression := expr; 
			address_of := 0;
			position := expr.position;
		end; -- make_from_expression

--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE; 
	          called_feature: FEATURE_INTERFACE; 
	          new_formal_type: TYPE; 
	          target: EXPRESSION) is 
	-- target kann Void sein für unqualified call
		require
			-- formal_type darf nicht Anchor zu formalem Argument sein
		local
			formal_anchor,actual_anchor: ANCHORED;
		do
			formal_type := new_formal_type;
			if address_of /= 0 then
				if not called_feature.feature_value.is_external then
					position.error(msg.vuar1);
				end;
				address_of_feature := fi.interface.feature_list.find(address_of); 
				if address_of_feature = Void then
					position.error(msg.vuar2);
				elseif fi.feature_value.is_constant_attribute then
					position.error(msg.vuar3);
				end;
			else
				expression.validity(fi,formal_type);
				formal_anchor ?= formal_type;
				actual_anchor ?= expression.type;
				if target /= Void and then 
				   formal_anchor /= Void and then formal_anchor.anchor = globals.string_current and then 
				   (expression.is_conforming_to(fi,target.type) or else
					actual_anchor /= Void and then target.is_entity(actual_anchor.anchor,fi)) 
				then
					-- ok:  Aufruf a.f(b) von f(x: like Current) mit b vom Typ "like a" oder b conforming to a.type 
				else
					if not expression.is_conforming_to(fi,formal_type) then
-- write_string("left = <<"); formal_type.print_type; write_string(">>  right = <<"); expression.type.print_type; write_string(">>%N");
						position.error(msg.vuar4);
					end;
				end;
			end;
		end; -- validity

	address_of_feature: FEATURE_INTERFACE; -- the attribute, if this is an address-actual.

--------------------------------------------------------------------------------

	validity_in_equality (fi: FEATURE_INTERFACE) is
	-- wird für den rechten Ausdruck in "x = y" oder "x /= y" aufgerufen
		do
			expression.validity(fi,Void);
		end; -- validity_in_equality

--------------------------------------------------------------------------------

	type: TYPE is 
	-- Typ des aktuellen Parameters
		do
			if expression /= Void then
				Result := expression.type
			else
				Result := globals.type_pointer; 
			end; 
		end; -- type

	formal_type: TYPE; -- Formaler Typ der Aufgerufenen Routine

--------------------------------------------------------------------------------

feature { CALL }

	view (pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST): ACTUAL is
	-- get the view of this actual inherited through the specified
	-- parent_clause. 
		do
			!!Result.new_view(Current,pc,old_args,new_args);
		end; -- view

feature { NONE }

	new_view (original: ACTUAL; pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST) is
		do
			if original.address_of = 0 then
				address_of := 0;
				expression := original.expression.view(pc,old_args,new_args);
			else
				address_of := pc.renames.get_rename(original.address_of);
				expression := Void;
			end;
			position := original.position; 
		end; -- new_view
		
--------------------------------------------------------------------------------

feature { CALL }

	compile(code: ROUTINE_CODE): VALUE is
		local
			fv: FEATURE_VALUE;
		do
			if expression /= Void then
				Result := expression.compile(code);
			else -- address operator "$"
				fv := address_of_feature.feature_value;
				if     fv.is_variable_attribute then Result := compile_adr_of_attribute(code);
				elseif fv.is_external           then Result := compile_adr_of_external (code);
				                                else Result := compile_adr_of_routine  (code);
				end;
			end;
		end; -- compile

--------------------------------------------------------------------------------

feature { NONE }

	compile_adr_of_attribute (code: ROUTINE_CODE): VALUE is
		local
			attribute: FEATURE_INTERFACE; 
			offset: INTEGER;
			off_ind: OFFSET_INDIRECT_VALUE;
		do
			attribute := code.fi.get_new_feature(address_of);
			offset := code.class_code.actual_class.attribute_offsets @ attribute.number;
			off_ind := recycle.new_off_ind;
			off_ind.make(offset,code.current_local);
			Result := off_ind.load_address(code);
		end; -- compile_adr_of_attribute

	compile_adr_of_external (code: ROUTINE_CODE): VALUE is
		local
			rout: ROUTINE;
			er: EXTERNAL_ROUTINE;
			name: INTEGER;
		do
			rout ?= address_of_feature.feature_value;
			er ?= rout.routine_body;
			if er.external_name /= 0 then
				name := er.external_name
			else
				name := address_of_feature.key
			end;
			Result := compile_adr_of_symbol(code,name);
		end; -- compile_adr_of_external

	compile_adr_of_routine (code: ROUTINE_CODE): VALUE is
		local
			really_called: FEATURE_INTERFACE; -- name of actual feature called by immediate or inherited routine
			local_type: LOCAL_TYPE;
		do
			really_called := code.fi.get_new_feature(address_of);
			if     really_called.feature_value.is_constant_attribute then 
				position.error(msg.vuar5);
				Result := recycle.new_local(code,globals.local_pointer);
			elseif really_called.feature_value.is_variable_attribute then 
				Result := compile_adr_of_attribute(code);
			elseif really_called.feature_value.is_external           then 
				Result := recycle.new_local(code,globals.local_pointer);
			  -- nyi: this is done by SE, but redefinition between internal and external is not allowed in ETL, so this case can be removed
			else
				Result := compile_adr_of_symbol(code,really_called.get_static_name(code.class_code.actual_class));
			end;
		end; -- compile_adr_of_routine

	compile_adr_of_symbol (code: ROUTINE_CODE; symbol_name: INTEGER): VALUE is
		local
			ass_const_cmd: ASSIGN_CONST_COMMAND;
			adr: LOCAL_VAR;
		do
			adr := recycle.new_local(code,globals.local_pointer);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_symbol(adr,symbol_name,0);
			code.add_cmd(ass_const_cmd);
			Result := adr;
		end; -- compile_adr_of_symbol

--------------------------------------------------------------------------------

end -- ACTUAL
