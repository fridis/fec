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

class LOCAL_OR_ARGUMENT 

inherit
	SORTABLE[INTEGER];
	SCANNER_SYMBOLS;
	INIT_EXPANDED;

creation
	parse, make

--------------------------------------------------------------------------------

feature { ANY }

--	key: INTEGER;  -- (geerbt) id des Namens des Arguments
	
	type: TYPE;    -- Typ des Arguments

	position: POSITION; 

	is_argument: BOOLEAN; -- true für formal argument, false für local declaration

--------------------------------------------------------------------------------
	
	parse (s: SCANNER; new_is_argument: BOOLEAN) is
	-- Entity = Identifier.
		do
			is_argument := new_is_argument;
			position := s.current_symbol.position;
			s.check_and_get_identifier(msg.id_far_expected);
			key := s.last_identifier;
		ensure
			key /= 0
		end; -- parse

	make (new_key: INTEGER; 
	      new_type: TYPE; 
	      new_position: POSITION; 
	      new_is_argument: BOOLEAN) is
		do
			key := new_key;
			type := new_type;
			position := new_position;
			is_argument := new_is_argument;
		end; -- make

--------------------------------------------------------------------------------

feature { ENTITY_DECLARATION_LIST }
	
	set_type (new_type: TYPE) is
		do
			type := new_type;
		end; -- set_type

--------------------------------------------------------------------------------

	view (parent: PARENT): LOCAL_OR_ARGUMENT is 
	-- bestimmt die Sicht auf die Liste beim Erben von parent, d.h. die formalen
	-- Argumente werden durch die in parent angegebenen aktuellen erstetzt.
		local
			new_type: TYPE;
		do
			new_type := type.view(parent);
			if type /= new_type then
memstats(124);
				!!Result.make(key,new_type,position,is_argument)
			else
				Result := Current
			end;
		end; -- view

--------------------------------------------------------------------------------
-- VALIDITY ÜBERPRÜFUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		do
			type.add_to_uses(fi);
		end; -- validity	

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }

	local_var: LOCAL_VAR; -- Diese Variable im Zwischencode
	
	alloc_local(code: ROUTINE_CODE) is
	-- allocate local_var.
	-- if new_type/=Void it provides the view of the type of this local in
	-- the actual class. This view is necessary when duplicating an
	-- inherited feature.
		local
			l_type: LOCAL_TYPE;
		do
			l_type := type.local_type(code);
			if is_argument then
				if l_type.is_expanded then
					l_type := globals.local_reference
				end;
				local_var := recycle.new_local(code,l_type);
				local_var.add_to_arguments(code);
			else
				local_var := recycle.new_local(code,l_type);
				if local_var.type.is_expanded then
					clear_and_init_expanded(code,local_var.load_address(code),type);
				else
					local_var.assign_initial_value(code);
				end;
			end;
		end; -- alloc_local

--------------------------------------------------------------------------------

end -- LOCAL_OR_ARGUMENT 
			
