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

class ASSERTION

inherit
	SCANNER_SYMBOLS;
	LIST[ASSERTION_CLAUSE]
	rename
		make as list_make
	end;

creation	{ ANY } 
	parse, clear

creation { ASSERTION } 
	new_view
	
feature { ANY }

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Assertion = {Assertion_clause ";" ...}.
		local
			assertion_clause: ASSERTION_CLAUSE; 
		do	
			list_make;
			from
			until
				not s.first_of_assertion_clause
			loop		
memstats(13);
				!!assertion_clause.parse(s);
				add(assertion_clause);
				s.remove_redundant_semicolon;
			end;
		end; -- parse

	clear is
	-- create an empty list
		do
			list_make;
		end;  -- clear
			
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE) is
		local
			i: INTEGER;
		do
			from
				i := 1
			until
				i > count
			loop
				item(i).validity(fi);
				i := i + 1;
			end; 
		end; -- validity

--------------------------------------------------------------------------------

	view (pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST): ASSERTION is
	-- get the view of an assertion inherited through the specified
	-- parent_clause
		do
			!!Result.new_view(Current,pc,old_args,new_args);
		end; -- view

feature { NONE }

	new_view (original: ASSERTION; pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST) is
		local
			i: INTEGER;
		do
			list_make;
			from
				i := 1
			until
				i > original.count
			loop		
				add((original @ i).view(pc,old_args,new_args));
				i := i + 1;
			end;
		end; -- new_view
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }

	compile(code: ROUTINE_CODE; 
	        error_handler: INTEGER;
	        branch_on_error: BASIC_BLOCK) is
	-- create code to check assertion. If assertion does not hold,
	-- call error_handler if present or set code.result_local to 
	-- the pos_and_tag entry corresponding to the failed assertion
	-- and branch to branch_on_error.
	   require
	   	(error_handler = 0) xor (branch_on_error = Void)
		local
			i: INTEGER;
		do
			from
				i := 1
			until
				i > count
			loop
				item(i).compile(code,error_handler,branch_on_error);
				i := i + 1;
			end; 
		end; -- compile		
		
--------------------------------------------------------------------------------

end -- ASSERTION
