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

class BASIC_BLOCK

-- A list of COMMANDs terminated by a BLOCK_SUCCESSORs object.

inherit
	LINKED_LIST[COMMAND]
		rename
			make as linked_list_make
		end;
	LINKABLE;
	FRIDISYS;

creation { RECYCLE_OBJECTS }
	clear

--------------------------------------------------------------------------------

feature { ANY }
	
	successors: BLOCK_SUCCESSORS;

	weight: INTEGER; -- how important is it to optimize this block (weight_min..weight_max)
	
	weight_min: INTEGER is 1;
	weight_normal: INTEGER is 16;  -- weight for regular block
	weight_max: INTEGER is 256;
	
feature { ROUTINE_CODE, BLOCK_SUCCESSORS }

	alive: SET;        -- Local variables alive at beginning of this block

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is 
		do
			next := Void;
			prev := Void;
			linked_list_make;
			successors := Void;
			weight := 1;
			address := -1;  
		end; -- clear

--------------------------------------------------------------------------------

feature { ANY }

	make (new_weight: INTEGER) is
		do
			address := -1;
			if new_weight<weight_min then
				weight := weight_min;
			elseif new_weight>weight_max then
				weight := weight_max
			else
				weight := new_weight;
			end;
		end; -- make

--------------------------------------------------------------------------------

feature { MIDDLE_ROUTINE_CODE }

	set_successors(new_successors: BLOCK_SUCCESSORS) is
		do
			successors := new_successors;
		end; -- set_successors

--------------------------------------------------------------------------------

feature { ROUTINE_CODE }

	expand_commands (code: ROUTINE_CODE) is 
	-- fügt, wo nötig, zusätzliche Maschinenbefehle ein, z.B. wird
	-- "l1 := l2 + c" zu "l3 := c; l1 := l2 + l3" wenn c zu gross ist um
	-- im Additionsbefehl gespeichert zu werden.
		local 
			cmd, nxt: COMMAND;
		do
			from 
				cmd := head;
			until
				cmd = Void
			loop
				nxt := cmd.next;
				cmd.expand(code,Current); -- this might remove cmd from the list
				cmd := nxt;
			end; 
			successors.expand(code,Current);
		end; -- expand_commands;

feature { COMMAND, BLOCK_SUCCESSORS }

	insert_and_expand (code: ROUTINE_CODE; element, nxt: COMMAND) is
	-- This can be used by expand of COMMANDs to insert new commands and
	-- immediately expand them. If a command to be inserted is not guaranteed
	-- to be be expand-ed, it has to be inserted using this routine.
		do
			insert(element,nxt);
			element.expand(code,Current);
		end; -- insert_and_expand
	
--------------------------------------------------------------------------------

feature { ROUTINE_CODE }

	clear_live_spans (code: ROUTINE_CODE) is
		do
			if alive=Void then
memstats(417);
				!!alive.make(code.locals.count)
			else
				alive.make(code.locals.count);
			end;
			succ_alive_pop_count := -1;
			alive_pop_count := -1;
		end; -- clear_live_spans

	get_live_spans (code: ROUTINE_CODE) is
		local
			old_popc: INTEGER;
			cmd: COMMAND;
		do
			old_popc := succ_alive_pop_count;
			successors.get_alive (code);
			succ_alive_pop_count := successors.alive.pop_count;
			if old_popc /= succ_alive_pop_count then
				alive.copy(successors.alive);
				from
					cmd := tail
				until
					cmd = Void
				loop
					cmd.get_alive(alive);
					cmd := cmd.prev;
				end; 
				old_popc := alive_pop_count;
				alive_pop_count := alive.pop_count;
				live_span_changed := alive_pop_count /= old_popc;
			else 
				live_span_changed := false;
			end;
		end; -- get_live_spans;
	
	live_span_changed: BOOLEAN;

feature { NONE }

	succ_alive_pop_count: INTEGER; -- successors.alive.pop_count or -1 (for first iteration)
	
	alive_pop_count: INTEGER;      -- alive.pop_count or -1 for first iteration

feature { ROUTINE_CODE }

	get_conflict_matrix (code: ROUTINE_CODE) is
	-- bestimmt die Konfliktmatrix nachdem die Lebensspänne der Variablen
	-- bestimmt wurden. Danach muss noch die bijektive Hülle der Matrix
	-- gebildet werden (conflict(i,j) := conflict(i,j) or conflict(j,i)).
		local
			cmd: COMMAND;
		do
			successors.get_conflict_matrix(code,weight);
			alive.copy(successors.alive);
			from
				cmd := tail
			until
				cmd = Void
			loop
				cmd.get_conflict_matrix(code,alive,weight);
				cmd := cmd.prev;
			end;
		end; -- get_conflict_matrix;

--------------------------------------------------------------------------------

	remove_assigns_to_dead is
	-- remove unneccessary assignments to locals, this especially removes
	-- unneeded initializations of locals.
		local
			cmd,prv: COMMAND;
		do
			alive.copy(successors.alive);
			from
				cmd := tail
			until
				cmd = Void
			loop
				prv := cmd.prev;
				cmd.remove_assigns_to_dead(alive, Current);  -- this call may discard cmd.prev!
				cmd := prv;
			end; 
		end; -- remove_assigns_to_dead

--------------------------------------------------------------------------------

feature { ROUTINE_CODE }

	expand2_commands (code: ROUTINE_CODE) is 
	-- fügt nach der Registervergabe, wo nötig, zusätzliche Maschinenbefehle ein
		local 
			cmd,nxt: COMMAND;
		do
			from 
				cmd := head;
			until
				cmd = Void
			loop
				nxt := cmd.next;
				cmd.expand2(code,Current); -- this call may discard cmd.next!
				cmd := nxt;
			end; 
			successors.expand2(code,Current);
		end; -- expand2_commands;

feature { COMMAND, BLOCK_SUCCESSORS }

	insert_and_expand2 (code: ROUTINE_CODE; element, nxt: COMMAND) is
	-- This can be used by expand2 of COMMANDs to insert new commands and
	-- immediately expand2 them. If a command to be inserted is not guaranteed
	-- to be be expand2-ed, it has to be inserted using this routine.
		do
			insert(element,nxt);
			element.expand2(code,Current);
		end; -- insert_and_expand2
	
--------------------------------------------------------------------------------

feature { ROUTINE_CODE }

	create_machine_code (code: ROUTINE_CODE; mc: MACHINE_CODE) is 
	-- erzeugt die Maschinenbefehle des Blocks und fügt sie mc an.
		local 
			cmd: COMMAND;
		do
			address := mc.pc;
			from 
				cmd := head;
			until
				cmd = Void
			loop
				cmd.create_machine_code(mc);
				cmd := cmd.next;
			end; 
		end; -- create_machine_code;

--------------------------------------------------------------------------------

feature { COMMAND }

	address: INTEGER;  -- start address of this command

--------------------------------------------------------------------------------

feature { ANY }

	print_block is
		local
			cmd: COMMAND; 
		do
			write_integer(object_id); write_string(":%T");
			from
				cmd := head;
			until
				cmd = Void
			loop
				cmd.print_cmd;
				cmd := cmd.next;
				write_string("%T");
			end;
			successors.print_succ;
		end; -- print_block

--------------------------------------------------------------------------------

	print_machine_code is 
	-- erzeugt die Maschinenbefehle des Blocks und fügt sie mc an.
		local 
			cmd: COMMAND;
		do
			from 
				write_integer(object_id); write_string(":"); 
				cmd := head;
			until
				cmd = Void
			loop
				write_string("%T"); 
				cmd.print_machine_code;
				cmd := cmd.next;
			end; 
		end; -- print_machine_code;

--------------------------------------------------------------------------------

end -- BASIC_BLOCK
