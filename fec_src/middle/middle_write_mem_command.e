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

deferred class MIDDLE_WRITE_MEM_COMMAND

inherit
	COMMAND;
	
--------------------------------------------------------------------------------

feature { NONE }

	src,dst1,dst2: LOCAL_VAR;
	                        -- Befehle haben die Form
	                        --   off(dst1) := src
	                        --   off+reloc(label)(dst1) := src
	                        --   (dst1+dst2) := src
	                        --   label := src

	offset: INTEGER;        -- Konstante für Offset, Immediate-Wert

	label: INTEGER;  -- label für global und labelled offset

--------------------------------------------------------------------------------

	is_offset_indirect: BOOLEAN is
		do
			Result := dst1 /= Void and dst2 = Void
		end; -- is_offset_indirect
		
	is_indexed: BOOLEAN is
		do
			Result := dst1 /= Void and dst2 /= Void
		end; -- is_indexed
		
	is_global: BOOLEAN is
		do
			Result := dst1 = Void
		end; -- is_global

--------------------------------------------------------------------------------

feature { ANY }

	make_write_global (dest: INTEGER; source: LOCAL_VAR) is
	-- <dest> := source
		require
			dest /= 0;
			not source.type.is_expanded;
		do
			label := dest;
			src := source;
			dst1 := Void;
		ensure
			is_global
		end; -- make_write_global

--------------------------------------------------------------------------------

	make_write_offset (off: INTEGER; lab: INTEGER; dest,source: LOCAL_VAR) is
	-- off(dest) := source oder
	-- offt+<lab>(dest) := source für lab /= Void
		require
			dest.type.is_word;
			not source.type.is_expanded;
		do
			offset := off; 
			label := lab;
			dst1 := dest;
			src := source;
		ensure
			is_offset_indirect
		end; -- make_write_offset

	make_write_indexed (dest1,dest2,source: LOCAL_VAR) is
	-- (dst1+dst2) := src
		require
			dest1.type.is_word;
			dest2.type.is_word;
			not source.type.is_expanded;
		do
			dst1 := dest1;
			dst2 := dest2;
			src := source;
		ensure
			is_indexed;
		end; -- make_write_indexed

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	get_alive (alive: SET) is
	-- löscht jede von diesem Befehl geschriebene Variable aus alive und
	-- fügt jede gelesene Variable in alive ein.
	-- alive := (alive \ written variables) U read variables.
		do
	   	alive.include(src.number);
	   	if dst1 /= Void then
		   	alive.include(dst1.number);
		   end;
		   if dst2 /= Void then
		   	alive.include(dst2.number);
			end;
		end; -- get_alive
		
	get_conflict_matrix (code: ROUTINE_CODE; alive: SET; weight: INTEGER) is
	-- Bestimmt alive und trägt alle im Konflikt stehenden Variablen in 
	-- code.conflict_matrix ein. Die bijektive Hülle des Konfliktgrafen wird
	-- danach noch bestimmt, so dass es reicht wenn ein Konflikt nur einmal
	-- (d.h. bei der Zuweisung an eine Variable) eingetragen wird. 
	-- Zusätzlich wird alive wie bei get_alive bestimmt und must_not_be_volatile
	-- gesetzt für diejenigen locals, die während eines Aufrufs leben.
		do
			
			src.inc_use_count(weight); 
			if dst1/=Void then dst1.inc_use_count(weight) end; 
			if dst2/=Void then dst2.inc_use_count(weight) end; 

			get_alive(alive);

		end; -- get_conflict_matrix

--------------------------------------------------------------------------------

feature { ANY }

	print_cmd is 
		do
			if is_offset_indirect then
				write_integer(offset); if label/=0 then write_string("+"); print_label end; write_string("("); dst1.print_local; write_string(")"); 
			elseif is_indexed then
				write_string("("); dst1.print_local; write_string("+"); dst2.print_local; write_string(")"); 
			else
				print_label;
			end;
			write_string(" := "); 
			src.print_local;
			write_string("%N"); 
		end; -- print_cmd 
		
	print_label is
		do
			write_string(strings @ label)
		end; -- print_label

end -- MIDDLE_WRITE_MEM_COMMAND
