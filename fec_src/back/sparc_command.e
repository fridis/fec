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

deferred class SPARC_COMMAND

-- Descendants of this class represent single sparc commands. They are inserted 
-- in the basic blocks during the expand2 process of code generation. 
-- Descendants have to effect the routine create_machine_code to create an 
-- effective class.

inherit
	COMMAND;
	SPARC_CONSTANTS;
	FRIDISYS;

--------------------------------------------------------------------------------

feature { NONE }

	get_alive (alive: SET) is
		do
			write_string("Compilerfehler: SPARC_COMMAND.get_alive%N"); 
		end; -- get_alive
		
	get_conflict_matrix (code: ROUTINE_CODE; alive: SET; weight: INTEGER) is
		do
			write_string("Compilerfehler: SPARC_COMMAND.get_conflict_matrix%N"); 
		end; -- get_conflict_matrix

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
		do
			write_string("Compilerfehler: SPARC_COMMAND.expand%N"); 
		end; -- expand

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
		do
			write_string("Compilerfehler: SPARC_COMMAND.expand2%N"); 
		end; -- expand2

	print_cmd is 
		do
			write_string("Compilerfehler: SPARC_COMMAND.print_command%N"); 
		end; -- print_cmd 

--------------------------------------------------------------------------------

end -- SPARC_COMMAND
