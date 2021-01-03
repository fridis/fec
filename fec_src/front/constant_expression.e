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

class CONSTANT_EXPRESSION

inherit
	EXPRESSION
	SCANNER_SYMBOLS;
	PARSE_MANIFEST_CONSTANT;
	
creation
	parse
	
--------------------------------------------------------------------------------	
	
feature { ANY }

-- constant : MANIFEST_CONSTANT;  -- (geerbt) Die Konstante.

-- position : POSITION;           -- (geerbt)
	
--------------------------------------------------------------------------------	
	
	parse (s: SCANNER) is
	-- Expression = Manifest_constant.
		do
			position := s.current_symbol.position;
			parse_manifest_constant(s);
		end; -- parse

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE; expected_type: TYPE) is
		do
			type := constant.type;
		end; -- validity
		
--------------------------------------------------------------------------------

feature { ASSERTION }

	view (pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST): CONSTANT_EXPRESSION is
	-- get the view of this call inherited through the specified
	-- parent_clause. 
		do
			Result := Current;
		end; -- view

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE): VALUE is
		do
			Result := constant;
		end; -- compile
		
--------------------------------------------------------------------------------

end -- CONSTANT_EXPRESSION
