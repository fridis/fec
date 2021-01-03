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

class MIDDLE_LOCAL_VAR

-- An abstract register.

inherit
	VALUE
		redefine
			need_local
		end;
	CONDITIONS;
	FRIDISYS;
	SORTABLE[INTEGER];   -- sortable by number of uses

creation   -- no objects of this class may be created.
		
--------------------------------------------------------------------------------

feature { ANY }

	type: LOCAL_TYPE;  -- the type

	number: INTEGER;     -- Nummer dieses Lokals, < 0 für direktes Arbreiten mit Registern
	
	is_argument: BOOLEAN; -- true für Argument, false für Local/Temp
	
	must_not_be_register: BOOLEAN;  -- undefined if is_argument=true

--	key: INTEGER;    -- number of uses of this local
		
--------------------------------------------------------------------------------

feature { COMMAND }

	set_must_not_be_register is
		do
			must_not_be_register := true
		end; -- set_must_not_be_register

--------------------------------------------------------------------------------

feature { ANY }

	need_local_no_exp (code: ROUTINE_CODE; l_type: LOCAL_TYPE) : LOCAL_VAR is 
	-- load this value into a local variable
		do
			Result ?= Current;
		end; -- need_local_no_exp

	need_local (code: ROUTINE_CODE; l_type: LOCAL_TYPE) : LOCAL_VAR is 
	-- load this value into a local variable
		do
			Result ?= Current;
		end; -- need_local

--------------------------------------------------------------------------------

	load_address (code: ROUTINE_CODE) : LOCAL_VAR is 
	-- load address of this value into a local variable
		local
			cur: LOCAL_VAR;
		do
			Result := recycle.new_local(code,globals.local_pointer);
			cur ?= Current;
			code.add_cmd(recycle.new_load_adr_cmd(Result,cur));
		end; -- load_address

--------------------------------------------------------------------------------

	assign_initial_value (code: ROUTINE_CODE) is
	-- create code that initializes this variable with its default value, 
	-- ie. 0, Void, false, 0.0, etc.
		require
			not type.is_expanded
		local
			ass_const_cmd: ASSIGN_CONST_COMMAND; 
			cur: LOCAL_VAR;
		do
			cur ?= Current;
			ass_const_cmd := recycle.new_ass_const_cmd;
			if     type.is_word      then ass_const_cmd.make_assign_const_int(cur,0);
			elseif type.is_character then ass_const_cmd.make_assign_const_char(cur,'%U');
			elseif type.is_boolean   then ass_const_cmd.make_assign_const_bool(cur,false);
			elseif type.is_real      then ass_const_cmd.make_assign_const_real(cur,0);
			elseif type.is_double    then ass_const_cmd.make_assign_const_double(cur,0);
			end;
			code.add_cmd(ass_const_cmd);
		end; -- assign_initial_value
		
--------------------------------------------------------------------------------

feature { ROUTINE_CODE }

	preferred_synonyms: LIST[LOCAL_VAR]; 
			-- register allocation tries to allocate the same register to locals
			-- in one synonym list
			
feature { MIDDLE_ASSIGN_COMMAND }

	add_preferred_synonym (synonym: LOCAL_VAR) is
		do
			if not preferred_synonyms.has(synonym) then
				preferred_synonyms.add(synonym)
			end;
		end; -- add_preferred_synonym

feature { COMMAND, BLOCK_SUCCESSORS }

	inc_use_count(by: INTEGER) is 
		do
			key := key + by
		end;  -- inc_use_count
		
feature { ROUTINE_CODE }		

	use_count: INTEGER is  -- sebug: better: "rename key as use_count"
		do
			Result := key;
		end; -- use_count

--------------------------------------------------------------------------------

end -- MIDDLE_LOCAL_VAR
