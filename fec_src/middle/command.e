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

deferred class COMMAND

-- Abstract ancestors of all commands in the intermediate representation.
--
-- The middle-end classes inherit this class and redefine the routines that
-- are independend of the target machine. 
--
-- A concrete back-end class then finally implements the remaining code
-- generation routines.

inherit 
	LINKABLE;
	FRIDISYS;
		
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt für die Zielarchitektur nötige zusätzliche Befehle vor der Registervergabe
	-- ein
		deferred
		end; -- expand
		
	get_alive (alive: SET) is
	-- löscht jede von diesem Befehl geschriebene Variable aus alive und
	-- fügt jede gelesene Variable in alive ein.
	-- alive := (alive \ written variables) U read variables.
		deferred
		end; -- get_alive
		
	get_conflict_matrix (code: ROUTINE_CODE; alive: SET; weight: INTEGER) is
	-- Bestimmt alive und trägt alle im Konflikt stehenden Variablen in 
	-- code.conflict_matrix ein. Die bijektive Hülle des Konfliktgrafen wird
	-- danach noch bestimmt, so dass es reicht wenn ein Konflikt nur einmal
	-- (d.h. bei der Zuweisung an eine Variable) eingetragen wird. 
	-- Zusätzlich wird alive wie bei get_alive bestimmt und must_not_be_volatile
	-- gesetzt für diejenigen locals, die während eines Aufrufs leben.
	-- Der use_count jeder benutzten Local_var wird um weight erhöht.
		deferred
		end; -- get_conflict_matrix

	remove_assigns_to_dead (alive: SET; block: BASIC_BLOCK) is
	-- Entfernt unnötige Zuweisungen an tote Variablen, insbesondere
	-- unnötige Initialisierungen
		do
			get_alive(alive);
		end; -- remove_assigns_to_dead

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt nötige Befehle nach der Registervergabe ein und entfernt unnötige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
	-- expand2 darf keine neuen Register allozieren, da die Registervergabe bereits
	-- vorbei ist.
		deferred
		end; -- expand2
		
	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		deferred
		end; -- create_machine_code

--------------------------------------------------------------------------------

feature

	print_cmd is 
		deferred
		end; -- print_cmd

	print_machine_code is
		deferred
		end; -- print_machine_code 

--------------------------------------------------------------------------------

end -- COMMAND
