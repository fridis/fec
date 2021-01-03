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

deferred class MIDDLE_LOAD_ADR_COMMAND

inherit
	COMMAND;
	
--------------------------------------------------------------------------------

feature { NONE }

	dst,src: LOCAL_VAR; -- dst := adr(src)

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is
		do
			next := Void;
			prev := Void;
			dst := Void;
			src := Void;
		end; -- clear

--------------------------------------------------------------------------------

feature { ANY }

	make_load_address (dest,source: LOCAL_VAR) is
	-- dest := ADR(source)
		require
			dest.type.is_word;
		do
			dst := dest;
			src := source;
		end; -- make_load_address
		
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	get_alive (alive: SET) is
	-- löscht jede von diesem Befehl geschriebene Variable aus alive und
	-- fügt jede gelesene Variable in alive ein.
	-- alive := (alive \ written variables) U read variables.
		do
			alive.exclude(dst.number);
			alive.include(src.number);
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

			src.set_must_not_be_register;
			
			dst.inc_use_count(weight);
			-- src's use_count remains unchanged since the loading the address is no real
			-- use of the local_var

			get_alive(alive);
			
		end; -- get_conflict_matrix

--------------------------------------------------------------------------------

feature { ANY }

	print_cmd is 
		do
			dst.print_local; write_string(" := ADR("); src.print_local; write_string(")%N"); 
		end; -- print_cmd 

end -- MIDDLE_LOAD_ADR_COMMAND
