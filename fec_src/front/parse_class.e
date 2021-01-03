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

class PARSE_CLASS
-- Hauptklasse des Parsers

inherit 
	SCANNER_SYMBOLS;
	FRIDISYS;
	SORTABLE [INTEGER]
--		rename	
--			key as class_name
		end;
	
creation 
	parse, make_dummy, make_none

feature { ANY }

--	key: INTEGER;    -- (geerbt:) der Name dieser Klasse
	
	is_dummy: BOOLEAN;     -- true, wenn der Quelltext dieser Klasse nicht gefunden wurde

	name_position: POSITION;
	
	obsolete_msg: INTEGER; -- Id der obsolete-Meldung oder Void
	is_expanded: BOOLEAN;  -- Schlüsselwort "expanded" im Class_header vorhanden
	is_deferred: BOOLEAN;  -- Schlüsselwort "deferred" im Class_header vorhanden
	indices: INDEX_LIST;      
	formal_generics: FORMAL_GENERIC_LIST;
	parents: PARENT_LIST;     
	creators: CREATION_LIST;
	feature_declarations: FEATURE_DECLARATION_LIST;
	invariant_assertion: ASSERTION; 

--------------------------------------------------------------------------------

	parse (s: SCANNER; name: INTEGER) is 
	-- eine Eiffel-Klasse parsen
	-- Class_declaration = Indexing
	--                     Class_header
	--                     Formal_generics
	--                     Obsolete
	--                     Inheritance
	--                     Creators
	--                     Features
	--                     Invariant
	--                     end ["--" class Class_name].
		require
			s /= Void
		local
			end_is_optional: BOOLEAN;
		do
			unique_value := 0; 
			s.set_parse_class(Current);
			key := name;
			s.next_symbol;
			parse_indexing(s);
			parse_class_header(s);
			parse_formal_generics(s);
			parse_obsolete(s);
			parse_inheritance(s);
			if s.current_symbol.type = s_eof and then
			   not parents.is_empty and then
			   (parents @ parents.count).got_unneccessary_end
			then
				end_is_optional := true
			end;
			parse_creators(s);
			parse_features(s);
			parse_invariant(s);
			if s.current_symbol.type = s_end then
				s.next_symbol_or_comment;
				s.check_final_comment(strings @ key);
				if s.current_symbol.type /= s_eof then
					s.current_symbol.position.error(msg.eof_expected);
				end;
			elseif not end_is_optional then
				s.current_symbol.position.error(msg.end_expected);
			end;
		ensure
			key = name;
		end; -- parse

	make_dummy (name: INTEGER) is  
	-- erzeugt eine leere Klasse mit diesem Namen. Dies wird im Fehlerfall verwendet, wenn
	-- eine Klasse nicht gefunden werden kann.
		require
			name /= 0
		do	
			key := name;
			is_dummy := true;
memstats(165);
memstats(166);
memstats(167);
memstats(168);
memstats(169);
			!!indices.clear;
			!!formal_generics.clear;
			!!parents.make_dummy;     
			creators := Void;
			!!feature_declarations.clear;
			!!invariant_assertion.clear;
		end; -- make dummy			
		
	make_none is
	-- erzeugt die Pseudo-Klasse NONE
		do
			make_dummy(globals.string_none);
		end; -- make_none

--------------------------------------------------------------------------------
	
feature { UNIQUE_VALUE }

	unique_value: INTEGER; -- Anzahl der Unique-Konstanten. 
	
	increment_unique_value is
		do
			unique_value := unique_value + 1
		end; -- increment_unique_value
	
feature { ANY }

--------------------------------------------------------------------------------
			
	parse_indexing (s: SCANNER) is
	-- Indexing = ["indexing" Index_list].
		do
			if s.current_symbol.type = s_indexing then
				s.next_symbol
memstats(170);
				!!indices.parse(s);
			else
memstats(171);
				!!indices.clear;
			end;
		end; -- parse_indexing

--------------------------------------------------------------------------------
			
	parse_class_header (s: SCANNER) is
	-- Class_header = [Header_mark] "class" Class_name.
	-- Header_mark = "deferred" | "expanded".
	-- Class_name = Identifier.
		do
			if s.current_symbol.type = s_expanded then
				is_expanded := true
				s.next_symbol
			elseif s.current_symbol.type = s_deferred then
				is_deferred := true
				s.next_symbol
			end
			s.check_keyword(s_class)
			name_position := s.current_symbol.position;
			s.check_and_get_identifier(msg.id_cls_expected);
			if s.last_identifier /= key then 
				name_position.error(msg.name_wrong);
			end;
		end; -- parse_class_header

--------------------------------------------------------------------------------

	parse_formal_generics (s: SCANNER) is
	-- Formal_generics = ["[" Formal_generic_list "]"].
	-- Formal_generic_list = {Formal_generic "," ...}.
		do
			if s.current_symbol.type = s_left_bracket then
				s.next_symbol;
memstats(172);
				!!formal_generics.parse(s);
				s.check_right_bracket(msg.rbk_fg_expected);
			else
memstats(173);
				!!formal_generics.clear;
			end;
			formal_generics.get_formal_generic_types; 
		end; -- parse_formal_generics

--------------------------------------------------------------------------------

	parse_obsolete (s: SCANNER) is
	-- Obsolete = ["obsolete" Message].
	-- Message = Manifest_string.
		do
			if s.current_symbol.type = s_obsolete then
				s.next_symbol;
				s.check_and_get_string(msg.obs_expected);
				obsolete_msg := s.last_string;
			end;
		end; -- parse_obsolete
		
--------------------------------------------------------------------------------
		
	parse_inheritance (s: SCANNER) is
	-- Inheritance = ["inherit" Parent_list].
		do
			if s.current_symbol.type = s_inherit then
				s.next_symbol;
memstats(174);
				!!parents.parse(s);
			else
memstats(175);
				!!parents.clear(s); 
			end;
		end; -- parse_inheritance

--------------------------------------------------------------------------------
		
	parse_creators (s: SCANNER) is
	-- Creators = ["creation" {Creation_clause "creation" ...}+].
		do
			if s.current_symbol.type = s_creation then
memstats(176);
				!!creators.parse(s);
			end;
		end; -- parse_creators

--------------------------------------------------------------------------------
			
	parse_features (s: SCANNER) is
	-- Features = ["feature" {Feature_clause "feature" ...}+].
	-- Feature_clause = [Clients] [Header_comment] Feature_declaration_list.
	-- Feature_declaration_list = {Feature_declaration ";" ...}.
	-- Header_comment = Comment.
		do
			if s.current_symbol.type = s_feature then
memstats(177);
				!!feature_declarations.parse(s);
			else
memstats(178);
				!!feature_declarations.clear;
			end;
		end; -- parse_features
		
--------------------------------------------------------------------------------
			
	parse_invariant (s: SCANNER) is
	-- Invariant = ["Invariant" Assertion].
		do
			if s.current_symbol.type = s_invariant then
				s.next_symbol;
memstats(179);
				!!invariant_assertion.parse(s);
			else
memstats(180);
				!!invariant_assertion.clear;
			end;
		end; -- parse_invariant

--------------------------------------------------------------------------------

invariant
	not is_expanded or not is_deferred;
	indices /= Void;
end -- PARSE_CLASS
