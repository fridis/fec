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

class STRIP_EXPRESSION
-- die Liste der Attributebezeichner ist nach Kleinbuchstaben umgewandelt.

inherit
	EXPRESSION;
	SCANNER_SYMBOLS;
	
creation
	parse
	
creation { STRIP_EXPRESSION }
	new_view
	
--------------------------------------------------------------------------------
	
feature { ANY }

	attributes: LIST[INTEGER]

--	position: POSITION; -- (geerbt)
	
--------------------------------------------------------------------------------

	parse (s: SCANNER) is 
	-- Strip = "strip" "(" Attribute_list ")".
	-- Attribute_list = {Identifier "," ...}.
		require
			s.current_symbol.type = s_strip
		do
			position := s.current_symbol.position;
memstats(239);
			!!attributes.make;
			s.next_symbol;
			if s.current_symbol.type /= s_left_parenthesis then
				s.current_symbol.position.error(msg.lp_str_expected); 
			else
				s.next_symbol;
				from
					s.check_and_get_identifier(0);
					attributes.add_tail(s.last_identifier);
				until
					s.current_symbol.type /= s_comma
				loop
					s.next_symbol;
					s.check_and_get_identifier(0);
					attributes.add_tail(s.last_identifier);
				end;
				s.check_right_parenthesis(msg.rpr_st_expected);
			end;	
		end; -- parse

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE; expected_type: TYPE) is
		local
			i,j: INTEGER;
			f: FEATURE_INTERFACE;
		do
			from
				i := 1
			until
				i > attributes.count
			loop
				f := fi.interface.feature_list.find(attributes @ i);
				if f = Void or else not f.feature_value.is_attribute then
					position.error(msg.vwst1);
					i := attributes.count; 
				end;
				i := i + 1;
			end; 
			from
				i := 1
			until
				i > attributes.count
			loop
				from
					j := i + 1
				until
					j > attributes.count
				loop
					if attributes @ i = attributes @ j then
						position.error(msg.vwst2)
					end;
					j := j + 1;
				end;
				i := i + 1;
			end; 
memstats(240);
			!CLASS_TYPE!type.make_array_of_any;
		end; -- validity

--------------------------------------------------------------------------------

feature { ASSERTION }

	view (pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST): STRIP_EXPRESSION is
	-- get the view of this call inherited through the specified
	-- parent_clause. 
		do
			!!Result.new_view(Current,pc,old_args,new_args);
		end; -- view

feature { NONE }

	new_view (original: STRIP_EXPRESSION; pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST) is
		local
			i: INTEGER;
		do
			position := original.position;
			!!attributes.make;
			from
				i := 1
			until
				i > original.attributes.count
			loop
				attributes.add(pc.renames.get_rename(original.attributes @ i));
				i := i + 1;
			end;
		end; -- new_view
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE): VALUE is
		do
			-- nyi:
memstats(389);
			!INTEGER_CONSTANT!Result.make(0);
		end; -- compile
						
--------------------------------------------------------------------------------

end -- STRIP_EXPRESSION	
