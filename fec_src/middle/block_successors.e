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

deferred class BLOCK_SUCCESSORS

-- The heirs of this class describe the termination of a basic block, ie. the
-- set of successors and the condition or expression to be tested to branch into
-- one of the successors.

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt für die Zielarchitektur nötige zusätzliche Befehle vor der Registervergabe
	-- ein
		deferred
		end; -- expand
		
	alive: SET;    -- Union of alive-sets of all successors

	get_alive (code: ROUTINE_CODE) is
	-- determine alive from alive sets of successors.
		deferred
		end; -- get_alive
		
	get_conflict_matrix (code: ROUTINE_CODE; weight: INTEGER) is
	-- Trägt alle im Konflikt stehenden Variablen in code.conflict_matrix 
	-- ein. Die bijektive Hülle des Konfliktgrafen wird danach noch bestimmt, 
	-- so dass es reicht wenn ein Konflikt nur einmal (d.h. bei der Zuweisung 
	-- an eine Variable) eingetragen wird. 
	-- Der use_count jeder benutzten 
	-- Local_var wird um weight erhöht.
		deferred
		end; -- get_conflict_matrix

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt nötige Befehle nach der Registervergabe ein und entfernt unnötige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
	-- expand2 darf keine neuen Register allozieren, da die Registervergabe bereits
	-- vorbei ist.
		deferred
		end; -- expand2

--------------------------------------------------------------------------------

feature { ANY }
	
	print_succ is
		deferred
		end; -- print_succ
		
--------------------------------------------------------------------------------

end -- BLOCK_SUCCESSORS
