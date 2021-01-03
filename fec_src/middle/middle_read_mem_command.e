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

deferred class MIDDLE_READ_MEM_COMMAND

inherit
	COMMAND;
	
--------------------------------------------------------------------------------

feature { NONE }
	
	dst,src1,src2: LOCAL_VAR; 
									-- Befehle haben die Form
	                        --   dst := off(src1)
	                        --   dst := off+reloc(label)(src1)
	                        --   dst := (src1+src2)
	                        --   dst := label

	offset: INTEGER;        -- for is_offset_indirect

	label: INTEGER;         -- label für global und labelled offset oder 0 

--------------------------------------------------------------------------------

	is_offset_indirect: BOOLEAN is
		do
			Result := src1 /= Void and src2 = Void
		end; -- is_offset_indirect
		
	is_indexed: BOOLEAN is
		do
			Result := src1 /= Void and src2 /= Void
		end; -- is_indexed
		
	is_global: BOOLEAN is
		do
			Result := src1 = Void
		end; -- is_global

--------------------------------------------------------------------------------

feature { ANY }

	make_read_global (dest: LOCAL_VAR; src: INTEGER) is
	-- dest := <src>
		require
			src /= 0;
			not dest.type.is_expanded;
		do
			label := src;
			dst := dest;
			src1 := Void;
		ensure
			is_global
		end; -- make_read_global

--------------------------------------------------------------------------------

	make_read_offset (dest: LOCAL_VAR; off: INTEGER; lab: INTEGER; src: LOCAL_VAR) is
	-- dest := offset(src) oder
	-- dest := offset+<lab>(src) für lab /= Void
		require
			src.type.is_word;
			not dest.type.is_expanded;
		do
			offset := off; 
			label := lab;
			src1 := src;
			dst := dest;
		ensure
			is_offset_indirect;
		end; -- make_read_offset

	make_read_indexed (dest,source1,source2: LOCAL_VAR) is
	-- dest := (source1+source2)
		require
			source1.type.is_word;
			source2.type.is_word;
			not dest.type.is_expanded;
		do
			src1 := source1;
			src2 := source2;
			dst := dest;
		ensure
			is_indexed;
		end; -- make_read_indexed
		
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	get_alive (alive: SET) is
	-- löscht jede von diesem Befehl geschriebene Variable aus alive und
	-- fügt jede gelesene Variable in alive ein.
	-- alive := (alive \ written variables) U read variables.
		do
	   	alive.exclude(dst.number);
	   	if src1 /= Void then
		   	alive.include(src1.number);
		   end;
		   if src2 /= Void then
		   	alive.include(src2.number);
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
		   code.add_conflict(dst,alive);

			dst.inc_use_count(weight); 
			if src1/=Void then src1.inc_use_count(weight) end; 
			if src2/=Void then src2.inc_use_count(weight) end; 

			get_alive(alive);
			
		end; -- get_conflict_matrix

--------------------------------------------------------------------------------

feature { ANY }

	print_cmd is 
		do
			dst.print_local; write_string(" := "); 
			if is_offset_indirect then
				write_integer(offset); if label/=0 then write_string("+"); print_label end; write_string("("); src1.print_local; write_string(")"); 
			elseif is_indexed then
				write_string("("); src1.print_local; write_string("+"); src2.print_local; write_string(")"); 
			else
				print_label;
			end;
			write_string("%N"); 
		end; -- print_cmd 
		
	print_label is
		do
			write_string(strings @ label);
		end; -- print_label

end -- MIDDLE_READ_MEM_COMMAND
