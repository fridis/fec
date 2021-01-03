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

deferred class EXPRESSION

-- Ancestor to all expression classes, like CALL, strip, ...

feature { ANY }

--------------------------------------------------------------------------------

	type: TYPE; -- dieses Attribut wird beim Aufruf von validity gesetzt
	
	position: POSITION; 
	
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE; expected_type: TYPE) is
	-- fi ist das Feature, in dem der Ausdruck steht. 
	-- expected_type ist Void oder gibt den erwarteten Typ dieses Ausdrucks an, 
	-- dieser Typ wird dann von Manifest_array als Typ des Ausdrucks geliefert.
		deferred
		end; -- validity

--------------------------------------------------------------------------------

	check_boolean_expression is
	-- Prüft, ob dies eine Boolean_expression ist.
		do
			if not type.is_boolean then
				position.error(msg.vwbe1); 
			end; 
		end; -- check_boolean_expression
		
--------------------------------------------------------------------------------

	is_conforming_to (fi: FEATURE_INTERFACE; tt: TYPE) : BOOLEAN is
	-- prüft, ob dieser Ausdruck tt entspricht, nach VNCH 1-3. 
		local
			vta,tta: ANCHORED;
			unq_call: INTEGER;
		do
			vta ?= type; 
			tta ?= tt; 
			if tta /= Void then 
				unq_call := is_unqualified_call; 
				if unq_call /= 0 and then unq_call = tta.anchor then
					Result := true;
				elseif vta /= Void and then tta.anchor = vta.anchor then
					Result := true
				end;
			end; 
			if not Result then
				Result := type.is_conforming_to(fi,tt)
			end;
		end;  -- is_conforming_to

--------------------------------------------------------------------------------

	is_entity (v: INTEGER; fi: FEATURE_INTERFACE): BOOLEAN is
	-- true, wenn dieser Ausdruck das Entity v ist.
		do
			Result := false
		end; -- is_entity
		
	is_current : BOOLEAN is
	-- true für den Ausdruck "Current".
		do
			Result := false
		end; -- is_current
	
	is_unqualified_call : INTEGER is
	-- Ist dies ein unqualifizierter Aufruf, so ergibt dies den Namen des
	-- Aufgerufenen Features, Local entities, Result oder Current.
	-- Ansonsten ist es Void.
		do
			Result := 0
		end; -- is_unqualified_call
		
--------------------------------------------------------------------------------

	get_entity_or_feature (fi: FEATURE_INTERFACE): INTEGER is
	-- Result ist der Name der Entität oder des Features dieser Klasse, falls
	-- der Ausdruck eines von beidem ist, sonst Void.
		do
			Result := 0
		end; -- get_entity_or_feature
		
--------------------------------------------------------------------------------

feature { ANY }

	view (pc: PARENT; old_args, new_args: ENTITY_DECLARATION_LIST): EXPRESSION is
	-- get the view of an expression inherited through the specified
	-- parent_clause
		deferred
		end; -- view

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY } 

	compile(code: ROUTINE_CODE): VALUE is
		deferred
		ensure
			Result /= Void
		end; -- compile
		
--------------------------------------------------------------------------------

end -- EXPRESSION
