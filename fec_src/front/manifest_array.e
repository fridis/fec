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

class MANIFEST_ARRAY

inherit
	EXPRESSION;
	SCANNER_SYMBOLS;
	LIST[EXPRESSION]
	rename
		make as list_make
	end;
	PARSE_EXPRESSION;
	COMPILE_ASSIGN;
	DATATYPE_SIZES;
	FRIDISYS;
	
creation
	parse

creation { MANIFEST_ARRAY }
	new_view
	
--------------------------------------------------------------------------------	
	
feature { ANY }
	
-- position: POSITION; -- geerbt.

--------------------------------------------------------------------------------	

	parse (s: SCANNER) is
	-- Manifest_array = "<<" Expression_list ">>".
	-- Expression_list = { Expression "," ... }.
		require
			s.current_symbol.type = s_left_angle_bracket;
		do
			position := s.current_symbol.position;
			list_make;
			s.next_symbol;
			from
				parse_expression(s);
				add_tail(expression);
			until
				s.current_symbol.type /= s_comma
			loop
				s.next_symbol;
				parse_expression(s);
				add_tail(expression);
			end; 	
			if s.current_symbol.type /= s_right_angle_bracket then
				s.current_symbol.position.error(msg.rangle_expected);
			else
				s.next_symbol;
			end;
		end; -- parse

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE; expected_type: TYPE) is
		local
			i: INTEGER;
		do
			if expected_type /= Void and then 
			   expected_type.is_array 
			then
				element_type := expected_type.array_element_type;
			end; 
			from
				i := 1
			until
				i > count
			loop
				item(i).validity(fi,element_type);
				if element_type /= Void then
					if not item(i).type.is_conforming_to(fi,element_type) then 
						if element_type.is_conforming_to(fi,item(i).type) then
							element_type := item(i).type
						else
							element_type := Void;
						end;
					end;
				elseif i = 1 then
					element_type := item(1).type;
				end;
				i := i + 1;
			end;
			if element_type = Void or expected_type = Void then
memstats(131);
				!CLASS_TYPE!type.make_array_of_any;
				element_type := globals.type_any;
			else
				type := expected_type
			end;
		end; -- validity

feature { NONE }

	element_type: TYPE;

--------------------------------------------------------------------------------

feature { ASSERTION }

	view (pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST): MANIFEST_ARRAY is
	-- get the view of this call inherited through the specified
	-- parent_clause. 
		do
			!!Result.new_view(Current,pc,old_args,new_args);
		end; -- view

feature { NONE }

	new_view (original: MANIFEST_ARRAY; pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST) is
		local
			i: INTEGER;
		do
			position := original.position;
			list_make;
			from
				i := 1;
			until
				i > original.count
			loop
				add((original @ i).view(pc,old_args,new_args));
				i := i + 1;
			end; 	
		end; -- new_view

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }

	compile(code: ROUTINE_CODE): VALUE is
		local
			new_type, new_object, lower, upper, item_local, item_num: LOCAL_VAR;
			item_value: VALUE;
			call_cmd: CALL_COMMAND;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
			args: LIST[LOCAL_VAR];
			i: INTEGER;
			array_code_name,put_symbol_name: INTEGER;
		do
			new_type := compile_assign.clone_and_copy.compile_get_type_descriptor(code,type,false);
			args := recycle.new_args_list; 
			args.add(new_type);
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,
			                     globals.string_allocate_object,
			                     args,
			                     globals.local_pointer);
			-- NOTE: the Result type.is_pointer although it actually is a reference. But
			-- allocate_object is not an Eiffel routine, so the result is treated like a normal
			-- reference, but immediately assigned to a is_reference variable.
			code.add_cmd(call_cmd);
			new_object := recycle.new_local(code,globals.local_reference);
			code.add_cmd(recycle.new_ass_cmd(new_object,call_cmd.result_local));
			lower := recycle.new_local(code,globals.local_integer);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_int(lower,1);
			code.add_cmd(ass_const_cmd);			
			upper := recycle.new_local(code,globals.local_integer);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_int(upper,count);
			code.add_cmd(ass_const_cmd);			
			array_code_name := type.actual_class_name(code.class_code.actual_class.key).code_name;
			args := recycle.new_args_list;
			args.add(new_object);
			args.add(lower);
			args.add(upper);
			call_cmd := recycle.new_call_cmd;
			call_cmd.make_static(code,
										get_symbol_name(array_code_name,globals.string_make),
			                     args,
			                     Void);
			code.add_cmd(call_cmd);
			put_symbol_name := get_symbol_name(array_code_name,globals.string_put);
			from
				i := 1
			until
				i > count
			loop
				item_value := item(i).compile(code);
				compile_assign.clone_or_copy_no_dst(code,element_type,item(i).type,item_value);
				item_value := compile_assign.cloned_or_copied;
				item_num := recycle.new_local(code,globals.local_integer);
				ass_const_cmd := recycle.new_ass_const_cmd;
				ass_const_cmd.make_assign_const_int(item_num,i);
				code.add_cmd(ass_const_cmd);			
				args := recycle.new_args_list;
				args.add(new_object);
				args.add(item_value.need_local(code,element_type.local_type(code)));
				args.add(item_num);
				call_cmd := recycle.new_call_cmd;
				call_cmd.make_static(code,
				                     put_symbol_name,
				                     args,
				                     Void);
				code.add_cmd(call_cmd);
				i := i + 1;
			end; 
			Result := new_object;
		end; -- compile
						
--------------------------------------------------------------------------------

end -- MANIFEST_ARRAY
			
