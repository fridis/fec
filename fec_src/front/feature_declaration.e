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

class FEATURE_DECLARATION

inherit
	SCANNER_SYMBOLS;
	PARSE_TYPE;
	PARSE_FEATURE_VALUE; 
	FRIDISYS;
	
creation
	parse

creation { FEATURE_DECLARATION }
	make_clone
		
feature { ANY }

--------------------------------------------------------------------------------

	new_feature: NEW_FEATURE;

	formal_arguments: ENTITY_DECLARATION_LIST;  -- Die Argumente	
	
--	type : TYPE;                     -- geerbt: das Ergebnis oder Void

--	feature_value : FEATURE_VALUE;   -- geerbt: Attribute, Manifest_Constant, Unique oder Routine 

	position: POSITION;

	clients: CLIENTS;

--------------------------------------------------------------------------------

	parse (s: SCANNER; new_clients: CLIENTS; fdl: FEATURE_DECLARATION_LIST) is
	-- Feature_declaration = New_feature_list Declaration_body.
	-- Declaration_body = Formal_arguments 
	--                    [":" Type]
	--                    [Constant_or_routine].
	-- Formal_arguments = ["(" Entity_declaration_list ")" ].
	-- Constant_or_Routine = "is" Feature_value.
	-- New_Feature_list = {New_Feature "," ...}+.	 
		local
			other_names: LIST[NEW_FEATURE];
			other_name: NEW_FEATURE;
			i: INTEGER;
			other: FEATURE_DECLARATION; 
		do
			clients := new_clients;
			position := s.current_symbol.position;
memstats(84);
			!!new_feature.parse(s);
			if s.current_symbol.type = s_comma then
				from
memstats(85);
					!!other_names.make;
				until
					s.current_symbol.type /= s_comma
				loop
					s.next_symbol;
memstats(86);
					!!other_name.parse(s);
					other_names.add(other_name);
				end;
			end;
			if s.current_symbol.type = s_left_parenthesis then
				s.next_symbol;
memstats(87);
				!!formal_arguments.parse(s,true);
				s.check_right_parenthesis(msg.rpr_fa_expected);
			else
				formal_arguments := empty_formal_arguments;
			end;			
			if s.current_symbol.type = s_colon then
				s.next_symbol; 
				parse_type(s); 
			end;
			get_anchors_to_formal_arguments; 
			if s.current_symbol.type = s_is then
				s.next_symbol;
				parse_feature_value(s); 
			else
memstats(88);
				!ATTRIBUTE!feature_value.make;
			end;
			fdl.add(Current);
			if other_names /= Void then
				from
					i := 1
				until
					i > other_names.count
				loop
memstats(89);
					!!other.make_clone(s,other_names @ i,Current);
					fdl.add(other);
					i := i + 1;
				end;
			end; 
		ensure
			new_feature /= Void;
			formal_arguments /= Void;
			feature_value /= Void
		end; -- parse

--------------------------------------------------------------------------------		

feature { NONE }

	make_clone (s: SCANNER; 
	            nf: NEW_FEATURE; 
	            original: FEATURE_DECLARATION) is
		local
			uv: UNIQUE_VALUE;
		do
			new_feature := nf;
			formal_arguments := original.formal_arguments;
			type := original.type;
			if original.feature_value.is_unique then
				uv ?= original.feature_value;
memstats(90);
				!UNIQUE_VALUE!feature_value.make(uv.position,s.parse_class);
			else
				feature_value := original.feature_value;
			end;
			position := original.position;
			clients := original.clients;
		end; 

--------------------------------------------------------------------------------		

	empty_formal_arguments : ENTITY_DECLARATION_LIST is
		once
			!!Result.clear;
		end; -- empty_formal_arguments
		
--------------------------------------------------------------------------------		

	get_anchors_to_formal_arguments is
	-- Sucht nach Anchored Types für formale Argumente und trägt für sie die
	-- ACHORED.argument_number ein
		local
			i: INTEGER; 
		do
			if not formal_arguments.is_empty then
				from
					i := 1
				until
					i > formal_arguments.count
				loop
					(formal_arguments @ i).type.get_anchors_to_formal_arguments(formal_arguments); 
					i := i + 1
				end; 
				if type /= Void then
					type.get_anchors_to_formal_arguments(formal_arguments); 
				end; 
			end; 
		end; -- get_anchors_to_formal_arguments

feature { ANY }

--------------------------------------------------------------------------------
-- VALIDITY ÜBERPRÜFUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	get_immediate (interface: CLASS_INTERFACE) is
	-- fügt dieses Feature unter allen seinen Namen dem Interface zu
		local
			new_fi,redeclares: FEATURE_INTERFACE;
			name: FEATURE_NAME;
		do
			validity;
			name := new_feature.name;
			new_fi := recycle.new_feature_interface;
			new_fi.make(interface,
			            name,
			            clients,
			            new_feature.is_frozen,
			            formal_arguments,
				         type,
				         feature_value,
				         interface.this_class.key)
			redeclares := interface.features.find(name.name);
			if redeclares /= Void then
				if redeclares.parent_clause = Void then
					-- immediate feature!
					name.position.error(msg.vmfn1);
				else
					new_fi.redeclares(redeclares);
					interface.features.replace(new_fi);
				end;
			else
				interface.features.add(new_fi);
			end;
		end; -- get_immediate

--------------------------------------------------------------------------------

	validity is
		local
			name: FEATURE_NAME;
		do
			-- test VFFD 1:
			if not( feature_value.is_routine or             -- Routine
			        formal_arguments.is_empty and then      -- oder Attribut? 
			        type /= Void and then
			        feature_value.is_attribute)
			then
				position.error(msg.vffd1); 
			end;
			if feature_value.is_once and then 
			   type /= Void and then 
			   (type.is_formal_generic or type.is_anchored) then
			   position.error(msg.vffd2);
			end;
			if new_feature.is_frozen and then feature_value.is_deferred then
				new_feature.name.position.error(msg.vffd3);
			end; 
			name := new_feature.name;
			if strings @ name.name @ 1 = '+' and then (not formal_arguments.is_empty or type = Void) then
				new_feature.name.position.error(msg.vffd4);
			end;
			if strings @ name.name @ 1 = '*' and then (formal_arguments.count /= 1 or type = Void) then
				new_feature.name.position.error(msg.vffd5);
			end;
		end; -- vffd

--------------------------------------------------------------------------------
						
end -- FEATURE_DECLARATION			
