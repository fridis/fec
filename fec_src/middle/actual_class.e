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

class ACTUAL_CLASS

-- A class corresponding to an ACTUAL_CLASS_NAME.

inherit
	SORTABLE[ACTUAL_CLASS_NAME];
	DATATYPE_SIZES;
	ACTUAL_CLASSES;
	FRIDISYS;

creation
	make
	
--------------------------------------------------------------------------------

feature { ANY }

--	key: ACTUAL_CLASS_NAME;    -- (geerbt)
	
	name: INTEGER;             -- key.code_name

	base_class: CLASS_INTERFACE; 

--------------------------------------------------------------------------------

	make (type: ACTUAL_CLASS_NAME) is
		do
			key := type; 
			name := type.code_name;
			base_class := get_class(type.name);
memstats(465);
			!!must_be_duplicated.make(1,base_class.this_class.features.count);
			if base_class.parse_class.is_deferred then
memstats(466);
				!!cant_be_compiled.make(1,base_class.this_class.features.count);
			end;
			!!true_types.make;
			!!true_types_features.make;
			!!true_types_actual_classes.make;
		end; -- make
		
--------------------------------------------------------------------------------

	is_expanded: BOOLEAN is
		do
			Result := key.actual_is_expanded;
		end -- is_expanded

--------------------------------------------------------------------------------
	
feature { NONE }

	getting_size: BOOLEAN; 
	getting_offset_of: FEATURE_INTERFACE;

feature { ANY }
	
	attribute_offsets: ARRAY[INTEGER];  -- Offsets der expanded Features, Indiziert
	                                    -- mit FEATURE_INTERFACE.number

	got_size: BOOLEAN;
	
	size: INTEGER; 
	
	get_size is
		require
			not got_size
		local
			i: INTEGER;
		do
memstats(244); 
			!!attribute_offsets.make(1,base_class.num_dynamic_features);
			if getting_size then
				getting_offset_of.position.error(msg.vlec1);
			else
				getting_size := true;
				from
					i := 1
				until
					i > base_class.feature_list.upper
				loop
					getting_offset_of := base_class.feature_list @ i;
					if getting_offset_of.feature_value.is_variable_attribute then
						get_offset_of(getting_offset_of);
					end;
					i := i + 1;
				end;
			end;
			size := pad_size(size);
			got_size := true;
		ensure
			got_size
		end; -- get_size

feature { NONE }

	get_offset_of (fi: FEATURE_INTERFACE) is
		local
			sz: INTEGER; 
		do
			sz := get_size_of(fi.type);
			size := align(size,sz);
			attribute_offsets.put(size,fi.number);
			size := size + sz;
		end; -- get_offset_of

	get_size_of (type: TYPE): INTEGER is
		local
			bit_type: BIT_TYPE;
			ac_name: ACTUAL_CLASS_NAME;
			ac: ACTUAL_CLASS;
		do
			if     type.is_integer   then Result := integer_size
			elseif type.is_character then Result := character_size
			elseif type.is_boolean   then Result := boolean_size
			elseif type.is_real      then Result := real_size
			elseif type.is_double    then Result := double_size
			elseif type.is_pointer   then Result := reference_size
			elseif type.is_reference(base_class.no_feature) 
			                         then Result := reference_size
			elseif type.is_bit_type  then
				bit_type ?= type;
				Result := (bit_type.num_bits + 7) // 8;
			else
				ac_name := type.actual_class_name(key);
				if ac_name = globals.ref_class_name then
					Result := reference_size
				else
					ac := actual_classes.find(ac_name);
					if ac=Void then
						write_string("Compilerfehler: ACTUAL_CLASS.get_size#1 "); key.print_name; write_string(" uses "); type.actual_class_name(key).print_name; write_string("%N");
					else
						if not ac.got_size then
							ac.get_size;
						end;
						Result := ac.size;
					end;
				end;
			end;
		end; -- get_size_of

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { ANY }
	
	get_duplicated_features is
	-- determines the actual names to be used when calling a feature with static
	-- binding, this may be the original symbol of an inherited feature, or it may
	-- be the new symbol for a feature that had to be duplicated.
	-- These names have to be used for calls if the dynamic type of the call's target
	-- is none, namely with an expanded target or for unqualified calls with Current 
	-- as implicit target.
		do
			base_class.get_duplicated_features(Current);
		end; -- get_duplicated_features
		
feature { FEATURE_INTERFACE, CLASS_INTERFACE }

	set_must_be_duplicated (number: INTEGER) is
		do
			must_be_duplicated.put(true,number);
		end; -- set_actual_feature_name

	must_be_duplicated: ARRAY[BOOLEAN]; 
		-- this is true for all inherited features that have to be recompiled
	
	cant_be_compiled: ARRAY[BOOLEAN];
		-- in a deferred class this holds an array which is true for all
		-- effective internal features that call deferred features of Current
		-- and therefore can't be compiled.

	set_cant_be_compiled (number: INTEGER) is
		do
			cant_be_compiled.put(true,number);
		end; -- set_cant_be_compiled

--------------------------------------------------------------------------------

feature { ANY }

	class_code: CLASS_CODE;

	compile is
		do
memstats(1);
			!!class_code.make(Current);
			base_class.compile(Current);
			class_code.create_initialization;
			class_code.save_object_file;
			recycle.forget_machine_code;
			globals.code_stats(class_code.machine_code.commands.count);
		end -- compile

--------------------------------------------------------------------------------

	find_ancestor (type: TYPE; code: ROUTINE_CODE): ANCESTOR_NAME is
	-- search ancestor corresponding to type in this class. Void if not successful.
	-- The Result is currently Void if there are several ancostors with the same
	-- class name.
		local
			type_acn: INTEGER;
			aa: ARRAY[ANCESTOR];
			i: INTEGER;
		do
		-- nyi: this does not work for several ancestors that differ only
		--      in their actual generics, like STACK[A] and STACK[B];
			type_acn := type.actual_class_code(code).key.name;
			from 
				aa := base_class.ancestor_list;
				i := aa.lower;
			until  
				Result /= Void or i > aa.upper
			loop 
				Result := (aa @ i).key;
				if Result.name /= type_acn then
					Result := Void;
				end;
				i := i + 1;
			end;
			if Result /= Void and then
				i <= aa.upper and then
				(aa @ i).key.name = type_acn then
				-- ambiguious ancestors:
				Result := Void
			end;
		end; -- find_ancestor

--------------------------------------------------------------------------------

-- The following lists are used for the creation of objects whose type is
-- depending on the true_type of Current. The actual types will be put
-- into the td_true_types list of the type descriptor, where (true_type @ i)
-- will be found at [[type_descriptor + td_true_types] + reference_size * (i-1)].

	true_types: LIST[TYPE];
	true_types_features: LIST[FEATURE_INTERFACE];
	true_types_actual_classes: LIST[ACTUAL_CLASS];

--------------------------------------------------------------------------------

end -- ACTUAL_CLASS
