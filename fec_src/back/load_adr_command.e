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

class LOAD_ADR_COMMAND

inherit
	MIDDLE_LOAD_ADR_COMMAND
		redefine
			remove_assigns_to_dead
		end;
	SPARC_CONSTANTS;

creation { RECYCLE_OBJECTS }
	clear

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
		do
			-- nothing to be done here
		end; -- expand

--------------------------------------------------------------------------------

	remove_assigns_to_dead (alive: SET; block: BASIC_BLOCK) is
	-- Entfernt unnötige Zuweisungen an tote Variablen, insbesondere
	-- unnötige Initialisierungen
		do
			if dst.gp_register < 0 and then not alive.has(dst.number) then
				block.remove(Current);
			else
				get_alive(alive);
			end;
		end; -- remove_assigns_to_dead

--------------------------------------------------------------------------------

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt nötige Befehle nach der Registervergabe ein und entfernt unnötige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
		do
			if dst.gp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(dst,code.temp1_register),next);
				dst := code.temp1_register;
			end;
		ensure then
			dst.gp_register >= 0;
		end; -- expand2
		
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			mc.asm_ari_imm(op3_add,src.sp_or_fp,src.stack_position,dst.gp_register);
		end; -- create_machine_code

--------------------------------------------------------------------------------

	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			write_string("ld      #"); src.print_local; write_string(","); dst.print_local;
			write_string("%N");
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- LOAD_ADR_COMMAND
