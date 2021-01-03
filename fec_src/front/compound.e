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

class COMPOUND

inherit
	SCANNER_SYMBOLS;
	LIST[INSTRUCTION]
	rename
		make as list_make
	end;
	PARSE_INSTRUCTION;
	FRIDISYS;

creation
	parse, clear

--------------------------------------------------------------------------------
	
feature { ANY }

	parse (s: SCANNER) is
	-- Compound = {Instruction ";" ... }
		do
			list_make;
			from
				s.remove_redundant_semicolon;
			until
				not s.first_of_instruction
			loop
				parse_instruction(s);
				add_tail(instruction);
				s.remove_redundant_semicolon;
			end;
		end; -- parse

	clear is
	-- create an empty list
		do
			list_make;
		end;  -- clear

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		local 
			i: INTEGER; 
		do
			from
				i := 1;
			until
				i > count
			loop
-- write_string(".");
				item(i).validity(fi);
				i := i + 1;
			end;
		end; -- validity

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
		local 
			i: INTEGER; 
		do
			from 
				i := 1
			until
				i > count
			loop
				item(i).compile(code);
				i := i + 1;
			end;
		end; -- compile
		
--------------------------------------------------------------------------------
		
end -- COMPOUND
