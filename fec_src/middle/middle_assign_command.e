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

deferred class MIDDLE_ASSIGN_COMMAND

-- An Assignment or numeric conversion.

inherit
	COMMAND;
	
--------------------------------------------------------------------------------

feature { NONE }
	
	src,dst: LOCAL_VAR; -- src := dst

--------------------------------------------------------------------------------

feature { ANY }

	make_assignment (dest,source: LOCAL_VAR) is
	-- dest := source, this automatically handles conversion between 
	-- character <-> integer,
	-- integer <-> real,
	-- integer <-> double
	-- real <-> double
		require
		-- nyi:	convert_to_real_possible:   dest  .type.is_real_or_double implies (source.type.is_real_or_double or source.type.is_word);
			convert_from_real_possible: source.type.is_real_or_double implies (dest  .type.is_real_or_double or dest  .type.is_word);
			convert_from_char_possible: source.type.is_character      implies (dest  .type.is_character      or dest  .type.is_word);
		-- nyi:	convert_to_char_possible:   dest  .type.is_character      implies (source.type.is_character      or source.type.is_word);
		-- nyi:	cannot_convert_boolean:     source.type.is_boolean        implies  dest  .type.is_boolean;
		-- nyi:	cannot_assign_expanded:     not (source.type.is_expanded or dest.type.is_expanded);
		do
			src := source;
			dst := dest; 
		end; -- make_assignment

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	get_alive (alive: SET) is
	-- lûscht jede von diesem Befehl geschriebene Variable aus alive und
	-- fÄgt jede gelesene Variable in alive ein.
	-- alive := (alive \ written variables) U read variables.
		do
			alive.exclude(dst.number);
			alive.include(src.number);
		end; -- get_alive
		
	get_conflict_matrix (code: ROUTINE_CODE; alive: SET; weight: INTEGER) is
	-- Bestimmt alive und trÉgt alle im Konflikt stehenden Variablen in 
	-- code.conflict_matrix ein. Die bijektive HÄlle des Konfliktgrafen wird
	-- danach noch bestimmt, so dass es reicht wenn ein Konflikt nur einmal
	-- (d.h. bei der Zuweisung an eine Variable) eingetragen wird. 
	-- ZusÉtzlich wird alive wie bei get_alive bestimmt und must_not_be_volatile
	-- gesetzt fÄr diejenigen locals, die wÉhrend eines Aufrufs leben.
		do
			code.add_conflict(dst,alive);
			
			src.add_preferred_synonym(dst);
			dst.add_preferred_synonym(src);
			
			src.inc_use_count(weight);
			dst.inc_use_count(weight);

			get_alive(alive);
			
		end; -- get_conflict_matrix

--------------------------------------------------------------------------------

feature { ANY }

	print_cmd is 
		do
			dst.print_local; write_string(" := "); src.print_local;
			write_string("%N"); 
		end; -- print_cmd 
		
end -- MIDDLE_ASSIGN_COMMAND
