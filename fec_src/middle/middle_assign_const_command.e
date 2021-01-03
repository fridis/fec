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

deferred class MIDDLE_ASSIGN_CONST_COMMAND

-- An assignment of a constant value

inherit
	COMMAND;
	
--------------------------------------------------------------------------------

feature { NONE }
	
	dst: LOCAL_VAR;      -- the destination local

	const: INTEGER;      -- constant to be assign to non-real dst
	
	symbol: INTEGER;     -- optional symbol. if not 0, this symbols address
	                     -- plus the offset value const is stored in dst 
	
	const_real: DOUBLE;  -- constant to be assign if op.type.is_real/double

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is
		do
			next := Void;
			prev := Void;
			dst := Void;
			const := 0;
			const_real := 0;
			symbol := 0;
		end; -- clear

--------------------------------------------------------------------------------

feature { ANY }

	make_assign_const_int (dest: LOCAL_VAR; src: INTEGER) is
	-- dest := src
		require
			dest.type.is_word or
			dest.type.is_real or
			dest.type.is_double
		do
			if dest.type.is_real_or_double then
				const_real := src;
			else
				const := src;
			end;
			dst := dest;
		end; -- make_assign_const_int

	make_assign_const_symbol (dest: LOCAL_VAR; symbl: INTEGER; offset: INTEGER) is
	-- dest := "strings @ symbol" 
		require
			symbl /= 0;
			dest.type.is_word
		do
			const := offset;
			symbol := symbl;
			dst := dest;
		end; -- make_assign_const_int

	make_assign_const_char (dest: LOCAL_VAR; src: CHARACTER) is
	-- dest := src
		require
			dest.type.is_character
		do
			const := src.code;
			dst := dest;
		end; -- make_assign_const_char
		
	make_assign_const_bool (dest: LOCAL_VAR; src: BOOLEAN) is
	-- dest := src
		require
			dest.type.is_boolean
		do
			if src then
				const := 1
			else
				const := 0
			end;
			dst := dest;
		end; -- make_assign_const_bool
		
	make_assign_const_real (dest: LOCAL_VAR; src: DOUBLE) is
	-- dest := src
		require
			dest.type.is_real
		do
			const_real := src;
			dst := dest;
		end; -- make_assign_const_real
		
	make_assign_const_double (dest: LOCAL_VAR; src: DOUBLE) is
	-- dest := src
		require
			dest.type.is_double
		do
			const_real := src;
			dst := dest;
		end; -- make_assign_const_double
		
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	get_alive (alive: SET) is
	-- löscht jede von diesem Befehl geschriebene Variable aus alive und
	-- fügt jede gelesene Variable in alive ein.
	-- alive := (alive \ written variables) U read variables.
		do
	   	alive.exclude(dst.number);
		end; -- get_alive
		
	get_conflict_matrix (code: ROUTINE_CODE; alive: SET; weight: INTEGER) is
	-- Bestimmt alive und trägt alle im Konflikt stehenden Variablen in 
	-- code.conflict_matrix ein. Die bijektive Hülle des Konfliktgrafen wird
	-- danach noch bestimmt, so dass es reicht wenn ein Konflikt nur einmal
	-- (d.h. bei der Zuweisung an eine Variable) eingetragen wird. 
	-- Zusätzlich wird alive wie bei get_alive bestimmt und must_not_be_volatile
	-- gesetzt für diejenigen locals, die während eines Aufrufs leben.
		do
		   code.add_conflict(dst,alive);			
			dst.inc_use_count(weight);
			get_alive(alive);
		end; -- get_conflict_matrix

--------------------------------------------------------------------------------

feature { ANY }

	print_cmd is 
		do
			dst.print_local; write_string(" := "); 
			if dst.type.is_real or dst.type.is_double then
				write_string("const real");
			else
				write_integer(const); 
			end;
			write_string("%N"); 
		end; -- print_cmd 

end -- MIDDLE_ASSIGN_CONST_COMMAND
