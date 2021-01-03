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

deferred class MIDDLE_ONE_SUCCESSOR

inherit
	BLOCK_SUCCESSORS;
	FRIDISYS;
		
--------------------------------------------------------------------------------

feature { ANY }

	next: BASIC_BLOCK;  -- der Nachfolgeblock
	
--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }
	
	clear is 
		do
			next := Void
		end; -- clear
	
--------------------------------------------------------------------------------

feature { ANY }
	
	make (new_next: BASIC_BLOCK) is 
	-- NOTE: This successor may be used for more than one basic_block (unlike  
	-- TWO_SUCCESSORS and MULTI_SUCCESSORS).
		require
			new_next /= Void
		do
			next := new_next;
		ensure
			next = new_next; 
		end; -- make

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	get_alive (code: ROUTINE_CODE) is
		do
			alive := next.alive;
		end; -- get_alive

--------------------------------------------------------------------------------

	get_conflict_matrix (code: ROUTINE_CODE; weight: INTEGER) is
	-- Trägt alle im Konflikt stehenden Variablen in code.conflict_matrix 
	-- ein. Die bijektive Hülle des Konfliktgrafen wird danach noch bestimmt, 
	-- so dass es reicht wenn ein Konflikt nur einmal (d.h. bei der Zuweisung 
	-- an eine Variable) eingetragen wird. 
	-- Der use_count jeder benutzten 
	-- Local_var wird um weight erhöht.
		do
			-- no locals used
		end; -- get_conflict_matrix;

--------------------------------------------------------------------------------

feature { ANY }

	print_succ is
		do
			write_string("GOTO ");
			if next/=Void then
				write_integer(next.object_id)
			else
				write_string("VOID"); 
			end;
			write_string("%N");
		end; -- print_succ
		
--------------------------------------------------------------------------------
	
end -- MIDDLE_ONE_SUCCESSOR
