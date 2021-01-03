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

indexing

	description: "Platform-independent universal properties. This %
	             %class is an ancestor to all developer-written %
	             %classes."
	
	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";

class GENERAL

feature -- Access

	generating_type: STRING is
	-- Name of current object's generating type
	-- (type of which it is a direct instance)
		do
			Result := "nyi: generating_type unknown";
		end; -- generating_type
		
	generator: STRING is
	-- Name of current object€s generating class
	-- (base class of the type of which it is a direct instance)
		do
			Result := "nyi: generator unknown"; 
		end; -- generator

	id_object(id: INTEGER): ANY is
	-- Object for which object_id has returned id;
	-- Void if none.
		do 
			if id>=id_objects_array.lower and id<id_objects_array.upper then
				Result := id_objects_array @ id
			end; 
		end; -- id_object
		
	object_id: INTEGER is
	-- Value identifying current object uniquely;
	-- meaningful only for reference types.
		do
			from
				Result := id_objects_array.lower
			until
				id_objects_array @ Result = Current or
				id_objects_array @ Result = Void
			loop
				Result := Result + 1
			end;
			id_objects_array.put(Current,Result);
			if Result = id_objects_array.upper then
				id_objects_array.resize(id_objects_array.lower,2*id_objects_array.upper);
			end;
		ensure
			Result > 0;
			-- Current is reference implies id_objects @ Result = Current;
			id_objects_array @ id_objects_array.upper = Void
		end; -- object_id;
		
	id_objects_array: ARRAY[ANY] is
	-- This is meant to be used by object_id and id_object exclusively:
		once
			!!Result.make(1,100);
		ensure
			Result.lower = 1;
			Result @ Result.upper = Void;
		end; -- id_objects_array

	stripped (other: GENERAL): like other is
	-- New object with fields copied from current object, 
	-- but limited to attributes of type other. 
		require
			conformance: conforms_to(other)
		local
			low_level: LOW_LEVEL;
		do
			Result := low_level.new(low_level.get_type(other));
			other.standard_copy(Current);
		ensure
			stripped_to_other: Result.same_type(other)
		end; -- stripped

feature -- Status report

	frozen conforms_to (other: GENERAL): BOOLEAN is
	-- Does type of current object conform to type
	-- of other (as per Eiffel: The language, chapter 13)?
		require
			other_not_void: other /= Void
		local
			low_level: LOW_LEVEL;
		do
			if low_level.eiffel_conforms_to(other,Current) = Current then
				Result := true
			end;
		end; -- conforms_to
		
	frozen same_type (other: GENERAL): BOOLEAN is
	-- Is type of current object identical to type of other?
		require
			other_not_void: other /= Void
		local
			low_level: LOW_LEVEL;
			self: GENERAL;
		do
			self := Current;  -- create reference object if current is expanded
			if low_level.get_type(self) = low_level.get_type(other) then
				Result := true
			end;
		ensure
			definitione: Result = (conforms_to(other) and 
				other.conforms_to(Current));
		end; -- same_type

feature -- Comparison

	frozen deep_equal (some: GENERAL; other: like some): BOOLEAN is
	-- Are some and other either both void or attached to 
	-- isomorphic object structures?
		do
			-- nyi
		ensure
			shallow_implies_deep: standard_equal(some,other) implies Result
			same_type: Result implies same_type(other);
			symmetric: Result implies deep_equal(other,some);
		end; -- deep_equal

	frozen equal (some: GENERAL; other: like some): BOOLEAN is
	-- Are some and other either both Void or attached to objects considered
	-- equal?
		do
			Result := (some = other) or else 
			          (some /= Void) and then
			          (other /= Void) and then
			          some.is_equal(other);
		ensure
			definition: Result = (some = Void and other = Void) or else
				((some /= Void and other /= Void) and then some.is_equal(other));
		end -- equal
		
	is_equal (other: like Current): BOOLEAN is
	-- Is other attached to an object considered equal to current object?
		require
			other_not_void: other /= Void;
		do
			Result := standard_is_equal(other);
		ensure
			consistent: standard_is_equal(other) implies Result
			-- same_type: Result implies same_type(other); only holds for references types
			symmetrix: Result = other.is_equal(Current);
		end; -- is_equal
		
	frozen standard_equal (some: GENERAL; other: like some): BOOLEAN is
	-- Are some and other either both Void or attached to
	-- field-by-field identical objects of the same type?
	-- Always uses the default object comparison criterion.
		do
				Result := (some = other) or else 
				          (some /= Void) and then
				          (other /= Void) and then
				          some.standard_is_equal(other);
		ensure
			definition: Result = (some = Void and other = Void) or else
										(some /= Void and then other /= Void and then
										some.standard_is_equal(other));
		end; -- standard_is_equal
		
	frozen standard_is_equal (other: like Current): BOOLEAN is
	-- Is other attached to an object of the same type as current object, and 
	-- field-by-field identical to it?
		require
			other_not_void: other /= Void;
		local
			p1,p2: POINTER;
			size: INTEGER;
			low_level: LOW_LEVEL;
		do	
			if same_type(other) then
				p1 := low_level.eiffel_reference_to_pointer(Current);
				p2 := low_level.eiffel_reference_to_pointer(other);
				size := low_level.get_object_size(low_level.get_type(other));
				if low_level.memcmp(p1,p2,size) = 0 then
					Result := true;
				end;
			end;
		ensure
			same_type: Result implies same_type(other);
			symmetric: Result implies other.standard_is_equal(Current);
		end; -- standard_is_equal

feature -- Duplication

	frozen clone (other: GENERAL): like other is
	-- Void if other is void; otherwise new object equal to other.
		do 
			-- NOTE: unqualified calls to clone are automatically inlined by the 
			-- compiler.
			Result := clone(other); 
		ensure
			equal: equal(Result,other);
		end; -- clone
		
	copy (other: like Current) is
	-- Update current object using fields of object attached 
	-- to other, so as to yield equal objects.
		require
			other_not_void: other /= Void;
			-- nyi: type_identity: same_type(other); *** should be other.confomrs_to(Current)
		do
			standard_copy(other);
		ensure
			is_equal: is_equal(other);
		end; -- copy

	frozen deep_clone (other: GENERAL): like other is
	-- Void if other is void; otherwise, new object structures 
	-- recursively duplicated from the one attached to other
		do
			-- nyi
		ensure
			deep_equal: deep_equal(other, Result);
		end; -- deep_clone
		
	frozen standard_clone (other: like Current): like Current is
	-- Void if other is void; otherwise new object field-by-field
	-- identical to other.
	-- Always uses the default copying semantics.
		do	
			-- NOTE: unqualified calls to standard_clone are automatically inlined by the 
			-- compiler.
			Result := standard_clone(other);
		ensure
			equal: standard_equal(Result,other);
		end; -- standard_clone
		
	frozen standard_copy (other: like Current) is
	-- Copy every field of other onto corresponding field fo
	-- current object.
		require
			other_not_void: other /=Void;
			-- nyi: type_identity: same_type(other); *** should be other.confomrs_to(Current)
		do	
			-- NOTE: unqualified calls to standard_copy are automatically inlined by the 
			-- compiler.
			standard_copy(other);
		ensure
			is_stanard_equal: standard_is_equal(other);
		end; -- standard_copy

feature -- Basic operations

	frozen default: like Current is
	-- Default value of current type
		do
			-- nyi: this implementation is only good for reference types
			Result := Void
		end; -- default
		
	frozen default_pointer: POINTER is
	-- Default value of type POINTER
	-- (Avoid the need to write p.default for some p of type POINTER).
		do
		ensure
			-- nyi: Result = Result.default *** this is nonsense since Result.default is a reference type
		end; -- default_pointer
		
	default_rescue is
	-- Handle exception if no Rescue clause. 
	-- (Default: do nothing.)
		do
		end; -- default_rescue

	frozen do_nothing is
	-- execute a null action. 
		do
		end; -- do_nothing

	frozen Void: NONE is
	-- Void reference
		do
			-- NOTE: unqualified calls to Void are automatically inlined by the 
			-- compiler.
			Result := Void
		end; -- Void

feature -- Output

	io: STD_FILES is
	-- Handle to standard file setup
		once
			!!Result;
			Result.set_output_default;
		end; -- io

	out: STRING is
	-- New string containing terse printable representation
	-- of current object 
		do
			Result := "nyi: <Object>";
		end; -- out

	print(some: GENERAL) is
	-- Write terse external representation of some on standard output.
		local
			low_level: LOW_LEVEL;
		do
			low_level.writestr(some.out.to_external);
		end; -- print

	frozen tagged_out: STRING is
	-- New string containing printable representation of
	-- current object, each field preceded by its attribute
	-- name, a colon and a space.
		do
			Result := "nyi: tagged_out. out = " | out | "%N"; 
		end; 
	
invariant

	-- these are comments for efficiency:

	-- reflexive_equalitiy: standard_is_equal(Current);
	-- reflexive_conformace: conforms_to(Current);
	-- involutive_object_is: id_object(object_id)=Current;

end -- GENERAL
