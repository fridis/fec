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

class LOCAL_VAR

-- Backend class specific for SUN/SPARC 
--
-- Abstract register.

inherit
	MIDDLE_LOCAL_VAR;
	SPARC_CONSTANTS;

creation { RECYCLE_OBJECTS }
	clear

creation { ROUTINE_CODE }
	make_gpr,
	make_gpr_character,
	make_fpr,
	make_dfpr
	
--------------------------------------------------------------------------------

feature { ROUTINE_CODE, COMMAND, BLOCK_SUCCESSORS }

	gp_register: INTEGER;  -- number of GPR for this local or -1
	
	fp_register: INTEGER;  -- number of FP for this local or -1
	
	stack_position: INTEGER;  -- position in stackframe of this local
	
	sp_or_fp: INTEGER;        -- this is either sp or fp. if stack_position is /= 0
	                          -- this gives the register to which the local is
	                          -- relative.
	                          
--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is
		do
			key := 0;
			type := Void;
			number := 0;
			is_argument := false;
			must_not_be_register := false;
			gp_register := -1;
			fp_register := -1;
			stack_position := 0;
			sp_or_fp := -1;
			if preferred_synonyms=Void then
				!!preferred_synonyms.make
			else
				preferred_synonyms.make
			end;
		end; -- clear
		
--------------------------------------------------------------------------------

feature { ANY }

	make_local (code: ROUTINE_CODE; new_type: LOCAL_TYPE) is
		do
			type := new_type;
			is_argument := false;
			must_not_be_register := new_type.is_expanded;
			code.locals.add(Current);
			number := code.locals.count;
			gp_register := -1;
			fp_register := -1;
			stack_position := 0;
		end; -- make

	add_to_arguments (code: ROUTINE_CODE) is
		do
			is_argument := true;
			code.arguments.add(Current);
		end; -- add_to_arguments

--------------------------------------------------------------------------------

feature { NONE }

	make_gpr (new_gp_register: INTEGER) is
	-- create local_var for given gp register, use integer as type
		do
			clear;
			type := globals.local_integer;
			number := -1;
			gp_register := new_gp_register;
		end; -- make_gpr

	make_gpr_character (new_gp_register: INTEGER) is
	-- same as make_gpr, but uses character as type
		do
			clear;
			type := globals.local_character;
			number := -1;
			gp_register := new_gp_register;
		end; -- make_gpr_character

	make_fpr (new_fp_register: INTEGER) is
		do
			clear;
			type := globals.local_real;
			number := -1;
			fp_register := new_fp_register;
		end; -- make_fpr

	make_dfpr (new_fp_register: INTEGER) is
		do
			clear;
			type := globals.local_double;
			number := -1;
			fp_register := new_fp_register;
		end; -- make_dfpr

--------------------------------------------------------------------------------

feature { ROUTINE_CODE }

	set_gpr (new_gp_register: INTEGER) is
		do
			gp_register := new_gp_register;
		end; -- set_gpr

	set_fpr (new_fp_register: INTEGER) is
		do
			fp_register := new_fp_register;
		end; -- set_fpr

	set_stack_pos (new_stack_position: INTEGER; new_sp_or_fp: INTEGER) is
		require
			new_stack_position /= 0;
			new_sp_or_fp = sp or new_sp_or_fp = fp;
		do
			stack_position := new_stack_position;
			sp_or_fp := new_sp_or_fp;
		end; -- set_stack_pos
		
	add_to_locals (locals: LIST[LOCAL_VAR]) is
	-- used to add %o0..%o5 to locals and let them take part in determining the
	-- conflict matrix if they are used to pass arguments.
		do
			locals.add(Current);
			number := locals.count;
		end; -- add_to_locals

--------------------------------------------------------------------------------

feature { ANY }

	print_local is
		do
			inspect gp_register
			when 0..7      then write_string("%%g"); write_integer(gp_register); 
			when 8..13,15  then write_string("%%o"); write_integer(gp_register-8);
			when 14        then write_string("%%sp"); 
			when 16..23    then write_string("%%l"); write_integer(gp_register-16); 
			when 24..29,31 then write_string("%%i"); write_integer(gp_register-24);
			when 30        then write_string("%%fp");
			else
				if fp_register >= 0 then
					write_string("%%f"); write_integer(fp_register-f0);
				else
					write_string("local"); 
					write_integer(number);
				end;
			end;
		end; -- print_local

--------------------------------------------------------------------------------

end -- LOCAL_VAR
