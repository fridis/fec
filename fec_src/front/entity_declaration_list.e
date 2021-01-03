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

class ENTITY_DECLARATION_LIST

inherit
	SCANNER_SYMBOLS;
	PARSE_TYPE;
	LIST[LOCAL_OR_ARGUMENT]
	rename
		make as list_make
	end;

creation
	parse, clear
	
feature { ANY }

--------------------------------------------------------------------------------

	parse (s: SCANNER; is_argument: BOOLEAN) is
	-- Entity_declaration_list = { Entity_declaration_group ";" ... }.
	-- Entity_declaration_group = Identifier_list Type_mark.
	-- Identifier_list = {Identifier "," ... }+.
		do
			list_make;
			if s.current_symbol.type = s_identifier then  -- if first_of_Entitiy_declaration_group(s)
				from
					parse_entity_declaration_group(s, is_argument);
					s.remove_redundant_semicolon;
				until 
					s.current_symbol.type /= s_identifier
				loop
					parse_entity_declaration_group(s, is_argument)
					s.remove_redundant_semicolon;
				end;
			end;
		end; -- parse
		
	clear is
	-- create an empty list
		do
			list_make;
		end; -- clear

--------------------------------------------------------------------------------

	parse_entity_declaration_group (s: SCANNER; is_argument: BOOLEAN) is -- von parse aufgerufen.
	-- Entity_declaration_group = Identifier_list Type_mark.
	-- Identifier_list = {Identifier "," ... }+.
		local
			new: LOCAL_OR_ARGUMENT; 
			num_in_group,i: INTEGER; 
		do
			from
				num_in_group := 1;
memstats(81);
				!!new.parse(s, is_argument);
				add_tail(new);
			until
				s.current_symbol.type /= s_comma
			loop
				s.next_symbol;
memstats(82);
				!!new.parse(s, is_argument);
				add_tail(new);
				num_in_group := num_in_group + 1; 
			end; 
			s.check_colon(msg.cln_fa_expected); 
			parse_type(s);
			from  -- Nun mu§ der Typ noch Ÿberall eingetragen werden:
				i := count;
			until
				num_in_group = 0
			loop
				item(i).set_type(type);
				i := i - 1;
				num_in_group := num_in_group - 1;
			end;
		end; -- parse_entity_declaration_group

--------------------------------------------------------------------------------

	view (parent: PARENT): ENTITY_DECLARATION_LIST is 
	-- bestimmt die Sicht auf die Liste beim Erben von parent, d.h. die formalen
	-- Argumente werden durch die in parent angegebenen aktuellen erstetzt.
		local
			i,j: INTEGER;
			ole,new: LOCAL_OR_ARGUMENT; 
		do
			if not is_empty and then not parent.class_type.actual_generics.is_empty then
				from
					i := 1
				until
					i > count
				loop
					ole := item(i);
					new := ole.view(parent); 
					if new /= ole and Result = Void then
memstats(83);
						!!Result.clear;
						from 
							j := 1
						until
							j = i
						loop
							Result.add(item(j));
							j := j + 1;
						end;
					end;
					if Result /= Void then
						Result.add(new)
					end;
					i := i + 1; 
				end; 
			end; 
			if Result = Void then
				Result := Current
			end;
		end; -- view

--------------------------------------------------------------------------------

feature { CALL }

	find (name: INTEGER): INTEGER is
	-- this is used by view() of CALL to rename argument names of an
	-- inherited and redeclared precondition.
		do
			from 
				Result := count
			until
				Result = 0 or else item(Result).key = name
			loop
				Result := Result - 1;
			end; 
		ensure
			Result /= 0 implies item(Result).key = name
		end -- find

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

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

end -- ENTITY_DECLARATION_LIST
