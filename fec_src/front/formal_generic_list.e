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

class FORMAL_GENERIC_LIST

inherit
	LIST[FORMAL_GENERIC]
	rename 
		make as list_make
	end;
	SCANNER_SYMBOLS;
	
creation
	parse, clear
	
feature { ANY }

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Formal_generic_list = {Formal_generic "," ...}.
		local
			formal_generic: FORMAL_GENERIC;
		do
			list_make;
			if s.current_symbol.type = s_identifier then -- first_of_formal_generic(s)
				from
memstats(102);
					!!formal_generic.parse(s);
					add(formal_generic);
				until
					s.current_symbol.type /= s_comma
				loop
					s.next_symbol;
memstats(103);
					!!formal_generic.parse(s);
					add(formal_generic);
				end;	
			end;
		end; -- parse

	clear is
	-- create an empty list
		do
			list_make;
		end;  -- clear

--------------------------------------------------------------------------------

	find (name: INTEGER): INTEGER is
	-- Durchsucht die Liste nach name und gibt den Index des gefundenen Eintrags 
	-- oder -1 zurŸck
		do
			from
				Result := 1
			until
				Result > count or else
				name = item(Result).name
			loop
				Result := Result + 1
			end;
			if Result > count then
				Result := -1
			end;
		end; -- find

--------------------------------------------------------------------------------

feature { PARSE_CLASS }

	get_formal_generic_types is
	-- falls in den formal generics bereits formal generics verwendet wurden, so werden
	-- diese jetzt eingesetzt.
		local 
			i: INTEGER; 
		do
			from
				i := 1;
			until
				i > count
			loop
				item(i).get_formal_generic_type(Current);
				i := i + 1;
			end;
		end; -- get_formal_generic_typs

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	validity (interface: CLASS_INTERFACE) is 
		local
			i,j: INTEGER; 
			reported: BOOLEAN
		do
			from 
				i := 1
			until
				i > count
			loop
				item(i).validity(interface);
				from
					j := i + 1
				until
					j > count
				loop
					if item(i).name = item(j).name then
						if not reported then
							item(j).position.error(msg.vcfg1);
							reported := true;
						end;
					end;
					j := j + 1;
				end; 
				i := i + 1;
			end; 
		end;  -- validity
			
--------------------------------------------------------------------------------

end -- FORMAL_GENERIC_LIST

	
