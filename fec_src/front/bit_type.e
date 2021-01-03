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

class BIT_TYPE

inherit
	TYPE
		redefine
			is_bit_type
		end;
	PARSE_MANIFEST_CONSTANT;  
	SCANNER_SYMBOLS;
	
creation
	parse, make

--------------------------------------------------------------------------------
	
feature { ANY }

	constant_attribute: INTEGER;  -- Zahl der Bits: Konstantes Attribut oder 0

--	constant: MANIFEST_CONSTANT; -- (geerbt:) Zahl der Bits: Manifest_constant oder Void

--	position: POSITION;    -- (geerbt:) Position des Typs im Quelltext (nur wenn constant /= Void)

	num_bits: INTEGER;     -- falls constant = Void, die Zahl der Bits

--------------------------------------------------------------------------------

	parse (s: SCANNER) is 
	-- Bit_type = "BIT" Identifier | Manifest_constant
		require
			s.current_symbol.type = s.s_bit 
		do
			position := s.current_symbol.position;
			s.next_symbol;
			if s.current_symbol.type = s_identifier then
				s.check_and_get_identifier(0);
				constant_attribute := s.last_identifier;
			else
				parse_manifest_constant(s);
			end;
		end; -- parse

	make (n: INTEGER) is
	-- Von Bit_constant zum Erzeugen des Typs benûtigt.
		require
			n >= 0
		do
			num_bits := n; 
			constant_attribute := 0;
			constant := Void;
		end; -- make
		
--------------------------------------------------------------------------------
-- VALIDITY ºBERPRºFUNG:                                                      --		
--------------------------------------------------------------------------------

	is_bit_type : BOOLEAN is
		do
			Result := true
		end; -- is_bit_type

	is_identical (fi: FEATURE_INTERFACE; 
	              other: TYPE) : BOOLEAN is
	-- testet, ob Current und other identisch sind.
		local
			other_bit: BIT_TYPE;
		do
			other_bit ?= other;
			if other_bit /= Void then
				Result := num_bits = other_bit.num_bits;
			end;
		end; -- is_identical

	is_reference (fi: FEATURE_INTERFACE): BOOLEAN is
		do
			Result := false
		end; -- is_reference

	is_expanded (fo: FEATURE_INTERFACE): BOOLEAN is
		do
			Result := true;
		end;
		
	conforms_directly_to(fi: FEATURE_INTERFACE; 
	                     other: TYPE): BOOLEAN is
	-- testet, ob Current direkt other entspricht.
 		local
 			other_ct: CLASS_TYPE;
 			other_bit: BIT_TYPE;
 		do
 			-- vncb 1:
 			other_ct ?= other;
 			if other_ct /= Void and then
 				other_ct.name = globals.string_any and then
 				not other_ct.is_expanded(fi)
 			then
 				Result := true
 			else
 			-- vncb 2:
				other_bit ?= other;
				Result := other_bit /= Void and then
				          num_bits <= other_bit.num_bits;
 			end;
		end; -- conforms_directly_to
		
	conforms_recursively(fi: FEATURE_INTERFACE; 
							other: TYPE): BOOLEAN is
	-- testet VNCC: 5, ob ein U existiert so, da¤ Current U entspricht und U
	-- other entspricht
		do
			Result := globals.type_any.is_conforming_to(fi,other);
		end; -- conforms_recursively

--------------------------------------------------------------------------------

feature { ANY }

	ancestor_name (interface: CLASS_INTERFACE): ANCESTOR_NAME is
	-- Der Ancestor_name dieses Typs. 
		do
memstats(260); 
			!!Result.make_class_type(globals.string_bit_n,Void);
		end; -- ancestor_name

--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		local
			f: FEATURE_INTERFACE;
			mcv: MANIFEST_CONSTANT_VALUE;
			ic: INTEGER_CONSTANT;
			bug: BOOLEAN;
		do
			if constant_attribute /= 0 then
				f := fi.interface.feature_list.find(constant_attribute);
				if f = Void or else not f.feature_value.is_constant_attribute then
					position.error(msg.vwca1);
				else
					if f.type = Void or else 
					   not f.type.is_integer or else 
					   f.feature_value.is_unique
					then
						bug := true;
					else
						mcv ?= f.feature_value;
						ic ?= mcv.constant;
						num_bits := ic.value;
					end;
				end; 
			else
				if constant.type.is_integer then
					ic ?= constant;
					num_bits := ic.value;
				else
					bug := true
				end;
			end;
			if bug or num_bits <= 0 then
				position.error(msg.vtbt1);
				num_bits := 1;
			end;
		end; -- validity
			
--------------------------------------------------------------------------------

feature { TYPE }

	base_type (fi: FEATURE_INTERFACE) : CLASS_TYPE is
		do
			Result := globals.type_bit;
		end; -- base_type

--------------------------------------------------------------------------------

feature { ANY }

	view(parent: PARENT): TYPE is
	-- bestimmt die Sicht auf diesen Typ, wie er beim Erben von parent sich in
	-- der Tochterklasse ergibt. 
	-- Bsp: inherit STACK[INTEGER], wobei die Vaterklasse STACK[G] so ist
	-- "ARRAY[G]".view(interface,stack_parent) = "ARRAY[INTEGER]".
	-- entsprechend wird bei Anchored Types der Anchor verÉndert, wenn er
	-- umbenannt wurde.
		do
			Result := Current;
		end; -- view

	view_client (fi: FEATURE_INTERFACE; 
	             target: EXPRESSION; 
	             target_type: TYPE;
	             original: CLASS_INTERFACE): TYPE is
	-- bestimmt die Sicht auf diesen Typ, der aus der Klasse original stammt, 
	-- wie sie sich ergibt wenn die Klasse als actual_type verwendet wird.
		do
			Result := Current
		end; -- view_client

	view_constraint (fi: FEATURE_INTERFACE; 
	                 new_type: CLASS_TYPE): TYPE is
	-- bestimmt die Sicht auf diesen Constraint eines formal generics im
	-- Typ new_type.
		do
			Result := Current
		end; -- view_constraint

--------------------------------------------------------------------------------

feature { ANY }

	add_to_uses (fi: FEATURE_INTERFACE) is
	-- FÄgt diesen Typ fi.interface.uses_types zu. Falls Current 
	-- Anchored ist, so wird der Typ des Ankers verwendet. 
	-- Dies mu¤ Aufgerufen werden fÄr alle Typen, fÄr die Objekte
	-- alloziert werden, und fÄr expandierte lokale Bezeichner.
		do
			globals.type_bit.add_to_uses(fi);
		end -- add_to_uses

--------------------------------------------------------------------------------

feature { ANY }

	actual_class_name (actual: ACTUAL_CLASS_NAME): ACTUAL_CLASS_NAME is
	-- Der aktuelle Name des Typs in der aktuellen Klasse actual
		once
			!!Result.make(globals.string_bit_n,false,false,Void); 
		end; -- actual_class_name

	actual_is_reference (code: ROUTINE_CODE): BOOLEAN is
	-- Ist der aktuelle Typ Referenztyp?
		do
			Result := false; 
		end; -- actual_is_reference

	true_class_name (tcn: TRUE_CLASS_NAME; fi: FEATURE_INTERFACE): TRUE_CLASS_NAME is
	-- Get true_class_name of this type that is used within fi as seen from 
	-- within class tcn.
		once
			!!Result.make(globals.string_bit_n,false,false,Void);
		end; -- true_class_name

	true_class_name_code_parent (code: ROUTINE_CODE; no_parent: BOOLEAN): TRUE_CLASS_NAME is
	-- This tries to get the true_class_name of this type during compilation of
	-- a routine. NOTE: This might fail and return Void if the name can't be
	-- determined before system creation.
		once
			!!Result.make(globals.string_bit_n,false,false,Void);
		end; -- true_class_name_code

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	local_type(code: ROUTINE_CODE): LOCAL_TYPE is
		do
			!!Result.make_bit(num_bits);
		end; -- local_type

--------------------------------------------------------------------------------
	
	print_type is
	-- for debugging only
		do	
			write_string("BIT_N"); 
		end; 
	
end -- BIT_TYPE
