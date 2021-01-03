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

deferred class MIDDLE_NO_SUCCESSOR

-- Marks the last basic block in the control flow graph.

inherit
	BLOCK_SUCCESSORS;
	FRIDISYS;

--------------------------------------------------------------------------------

feature { ANY }
	
	make  is 
		do
		end; -- make

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	get_alive (code: ROUTINE_CODE) is
		local
			res: LOCAL_VAR;
		do
			if alive=Void then
memstats(420);
				!!alive.make(code.locals.count)
			else
				alive.make(code.locals.count)
			end;
			if code.has_unexpanded_result then
				alive.include(code.result_local.number);
			end;
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
	
	print_succ is
		do
			write_string("RETURN%N");
		end; -- print_succ
		
--------------------------------------------------------------------------------

end -- MIDDLE_NO_SUCCESSOR
