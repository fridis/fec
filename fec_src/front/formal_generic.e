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

class FORMAL_GENERIC

inherit
	SCANNER_SYMBOLS;

creation
	parse
	
feature { ANY }

	name : INTEGER;             -- id des Formal_generic_name
	constraint: CLASS_TYPE;     -- constraint (nie Void).

	position: POSITION;

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Formal_generic = Formal_generic_name [Constraint].
	-- Formal_generic_name = Identifier.
	-- Constraint = "->" Class_type.
		do
			position := s.current_symbol.position;
			s.check_and_get_identifier(msg.id_fgn_expected);	 
			name := s.last_identifier;
			if s.current_symbol.type = s_arrow then 
				s.next_symbol; 
memstats(101);
				!!constraint.parse(s,false);
			else
				constraint := globals.type_any;
			end;
		end; -- parse
		
--------------------------------------------------------------------------------

feature { FORMAL_GENERIC_LIST }
	
	get_formal_generic_type(formal_generics: FORMAL_GENERIC_LIST) is
		do
			constraint := constraint.get_formal_generic_type(formal_generics,name);
		end; -- get_formal_generic_type

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	validity (interface: CLASS_INTERFACE) is
		do
			constraint.validity(interface.no_feature);
		end; -- validity
		
--------------------------------------------------------------------------------

end -- FORMAL_GENERIC
