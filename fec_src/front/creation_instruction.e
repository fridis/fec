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

class CREATION_INSTRUCTION

inherit
	CALL
	rename
		type         as call_result_type,
		validity     as call_validity,
		parse        as parse_call,
		called_class as creation_class
	end;
	INSTRUCTION
		select 
			validity,
			compile
		end;
	SCANNER_SYMBOLS;
	PARSE_TYPE;
	WRITEABLE
		rename
			type         as writeable_type,
			is_attribute as create_attribute,
			is_local     as create_local,
			is_result    as create_result
		end;
	INIT_EXPANDED;
	DATATYPE_SIZES;
	
creation
	parse
	
--------------------------------------------------------------------------------

feature { ANY }

-- type : TYPE;        -- (geerbt) der Typ oder Void

--	writeable: INTEGER;  -- (geerbt) Das Ziel in Kleinbuchstaben
	
-- position: POSITION; -- (geerbt)
	
--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Creation = "!" [Type] "!" Writeable [Creation_call]
	-- Creation_call = "." Unqualified_call
		require
			s.current_symbol.type = s_exclamation_mark
		do
			position := s.current_symbol.position;
			s.next_symbol;
			if s.current_symbol.type /= s_exclamation_mark then
				parse_type(s);
			else
				type := Void;
			end;
			if s.current_symbol.type /= s_exclamation_mark then
				s.current_symbol.position.error(msg.excl_expected);
			else
				s.next_symbol;
			end; 	
			parse_writeable(s);
			if s.current_symbol.type = s_dot then
				s.next_symbol;
				parse_unqualified_call(s,Void,false);
			end;
		end; -- parse
		
--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	creation_type : TYPE;
	
--	creation_class: CLASS_INTERFACE;  -- (geerbt)

	validity (fi: FEATURE_INTERFACE) is
		do
			validity_of_writeable(fi);
			if type = Void then
				creation_type := writeable_type
			else
				creation_type := type
			end;
			creation_type.add_to_uses(fi); 
			if creation_type.is_formal_generic then
				position.error(msg.vgcc1);
			end;
			creation_class := creation_type.base_class(fi);
			if creation_class.parse_class.is_deferred then
				position.error(msg.vgcc2);
			end;
			if type /= Void then
				if not type.is_conforming_to(fi,writeable_type) then
					position.error(msg.vgcc3);
				elseif not type.is_reference(fi) then
					position.error(msg.vgcc4);
				end;
			end;
			if creation_class.parse_class.creators = Void then
				if feature_name /= 0 then
					position.error(msg.vgcc5);
				end
			else
				check_creation_call(fi);
			end;
		end; -- validity

	check_creation_call (fi: FEATURE_INTERFACE) is
		local
			ci: CREATION_ITEM;
		do
			if feature_name = 0 then
				position.error(msg.vgcc6);
			else
				called_feature := creation_class.feature_list.find(feature_name);	
				if called_feature = Void or else
					called_feature.creation_item = Void or else
					called_feature.creation_item.clients /= Void and then 
					not called_feature.creation_item.clients.is_available_to(fi.interface)
				then
					position.error(msg.vgcc7);
				else
					if called_feature.type = Void and
						called_feature.feature_value.is_routine and
						not called_feature.feature_value.is_once
					then
						check_arguments(fi,creation_type);
					else
						position.error(msg.vgcc8);
					end;
				end;
			end;
		end; -- check_creation_call
				
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
		local
			new_type, new_object: LOCAL_VAR;
			call_cmd: CALL_COMMAND;
			args: LIST[LOCAL_VAR];
		do
			if creation_type.actual_is_reference(code) then
				new_type := clone_and_copy.compile_get_type_descriptor(code,creation_type,false);
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
				init_expanded(code,new_object,creation_type,false);
				if called_feature /= Void then
					args := compile_arguments(code,new_object);
					call_cmd := recycle.new_call_cmd;
					call_cmd.make_static(code,
					                     called_feature.get_static_name(creation_type.actual_class_code(code)),
					                     args,
					                     Void);
					code.add_cmd(call_cmd);
				end;
				compile_assignment(code,new_object,creation_type);
			else
				clear_and_init_expanded(code, address_of_writeable(code),creation_type);
			end;
		end; -- compile

--------------------------------------------------------------------------------

end -- CREATION_INSTRUCTION
