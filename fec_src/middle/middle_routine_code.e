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

class MIDDLE_ROUTINE_CODE

inherit
	DATATYPE_SIZES;

creation -- this class is not to be instanciated.
	
--------------------------------------------------------------------------------

feature { ANY }

	class_code: CLASS_CODE;       -- Die Klasse, zu der die Routine gehört

	first_block: BASIC_BLOCK;     -- der Zwischencodegraph

--------------------------------------------------------------------------------
	
	current_local: LOCAL_VAR;     -- Die lokale Variable, die Current enthält
	result_local: LOCAL_VAR;      -- Bei Funktionen, die lokale Variable für Result

	static_generic_type_of_precondition: LOCAL_VAR is
	                              -- When compiling a precondition of a generic class,
	                              -- the type descriptor of the static type is passed
	                              -- as an additional argument. This local variable
	                              -- is a pointer to this type descriptor.
		require
			fi.doing_precondition;
			not class_code.actual_class.key.actual_generics.is_empty;
			not class_code.actual_class.is_expanded;
		do
			Result := arguments @ arguments.count;
		end;

--------------------------------------------------------------------------------

	expanded_result: BOOLEAN;     -- True wenn das Ergebnis expanded ist.

	has_expanded_result: BOOLEAN is
		do
			Result := result_local /= Void and then expanded_result;
		end; -- has_expanded_result;

	has_unexpanded_result: BOOLEAN is
		do
			Result := result_local /= Void and then not expanded_result;
		end; -- has_expanded_result;

--------------------------------------------------------------------------------

	fi: FEATURE_INTERFACE;        -- Das Feature dieser Routine

--------------------------------------------------------------------------------

feature { NONE }
	
	current_block: BASIC_BLOCK;   -- Für diesen Block des Graphs wird gerade
	                              -- Code erzeugt
	
	blocks: LINKED_LIST[BASIC_BLOCK];    
	                              -- Grundblöcke des Zwischencodes in der Reihen-
	                              -- folge der entstehung (wie im Quelltext).

feature { LOCAL_VAR, BASIC_BLOCK, BLOCK_SUCCESSORS, FEATURE_INTERFACE }  -- FEATURE_INTERFACE nur für Debugging
	                              
	arguments: LIST[LOCAL_VAR];   -- Argumente dieser Routine
	locals: SORTABLE_LIST[INTEGER,LOCAL_VAR]; -- Lokale und temporäre Variablen

--------------------------------------------------------------------------------

feature { NONE }

	make is
		do
memstats(381);
memstats(382);
			!!arguments.make;
			!!locals.make;
			!!blocks.make;
		end; -- make

--------------------------------------------------------------------------------

feature { NONE }

	init (new_class_code: CLASS_CODE; 
	      new_fi: FEATURE_INTERFACE;
	      current_type: LOCAL_TYPE;
	      result_type: TYPE) is 
	-- result_type ist der Typ für result_local oder Void.
		require
			current_type.is_reference or current_type.is_pointer;
		local
			cur: ROUTINE_CODE;
			result_l_type: LOCAL_TYPE; 
		do
			cur ?= Current;
			arguments.make;
			locals.make;
			blocks.make;
			class_code := new_class_code;
			fi := new_fi;
			current_local := recycle.new_local(cur,current_type);
			arguments.add(current_local);
			if result_type /= Void then
				result_l_type := result_type.local_type(cur);
				if result_l_type.is_expanded then
					expanded_result := true;
					result_local := recycle.new_local(cur,globals.local_pointer);
				else
					expanded_result := false;
					result_local := recycle.new_local(cur,result_l_type);
				end;
			else
				result_local := Void;
			end;
			first_block := Void;
		ensure
			first_block = Void
		end; -- make

--------------------------------------------------------------------------------

feature { ROUTINE, INTERNAL_ROUTINE, COMPILE_READ_ATTRIBUTE }

	set_first_block (new_first_block: BASIC_BLOCK) is
		require
			first_block = Void; 
			new_first_block /= Void;
		do
			first_block := new_first_block;
			current_block := new_first_block;
		ensure
			first_block = new_first_block
		end; -- set_code

--------------------------------------------------------------------------------
		
feature { ANY }

	finish_block (succ: BLOCK_SUCCESSORS; next: BASIC_BLOCK) is
	-- Beendet einen Grundblock und setzt seine Nachfolger. next wird als
	-- neuer Grundblock benutzt.
	-- next = Void für letzten Block erlaubt.
		require
			succ /= Void;
			first_block /= Void;
		do
--succ.print_succ;
			blocks.add_tail(current_block);
			current_block.set_successors(succ);
			current_block := next;
		end; -- finish_block

--------------------------------------------------------------------------------

	current_weight: INTEGER is
	-- return weight of current block
		do
			Result := current_block.weight;
		end; -- current_weight

--------------------------------------------------------------------------------

	add_cmd (cmd: COMMAND) is
	-- abbreviation for current_block.add_tail(cmd).
		do
-- cmd.print_cmd;
			current_block.add_tail(cmd)
		end; -- add_cmd

--------------------------------------------------------------------------------

	print_blocks is
		local
			b: BASIC_BLOCK;
		do
			from 
				b := blocks.head
			until
				b = Void
			loop
				b.print_block;
				b := b.next;
			end;
		end; -- print_blocks

--------------------------------------------------------------------------------

end -- MIDDLE_ROUTINE_CODE
