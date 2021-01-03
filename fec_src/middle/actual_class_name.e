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

class ACTUAL_CLASS_NAME

-- This is the name of a class for which code is created. If this is a generic 
-- reference class, actual generics that are references are replaced by "_ref".
-- Here some examples:
--
-- Eiffel class                ACTUAL_CLASS_NAME
-- STACK[INTEGER]              STACK[INTEGER]
-- STACK[C]                    STACK[_ref]            -- C is reference class
-- STACK[STACK[INTEGER]]       STACK[_ref]
-- STACK[exp STACK[C]]         STACK[exp STACK[C]]
-- exp STACK[STACK[C]]         exp STACK[STACK[_ref]] -- C becomes _ref because
--                           -- is is actual generic of "STACK", not of "exp STACK" 
-- exp STACK[STACK[STACK[C]]]  exp STACK[STACK[_ref]]
--
-- Dieser Name kann nicht fŸr das Erzeugen von Objekten oder den Assignment-
-- Attempt hergenommen werden, falls has_refs_in_code_name true ist, da dann 
-- der genaue Typ bei der erst bei der Systemerzeugung bekannt ist. Ein Verweis
-- auf den aktuellen Typ muss dann im Typdeskriptor gespeichert werden.

inherit
	COMPARABLE;
	ACTUAL_CLASSES
		undefine
			is_equal
		end;
	DATATYPE_SIZES
		undefine
			is_equal
		end;
	FRIDISYS
		undefine
			is_equal
		end;

creation
	make
	
--------------------------------------------------------------------------------
	
feature { ANY }

	name: INTEGER;        -- id of this class' name
	
	is_expanded: BOOLEAN;  -- true bei "expanded INTEGER", false bei "INTEGER"
	
	is_reference: BOOLEAN;  -- true bei "like Current", selbst wenn Current = expanded class INTEGER.

	actual_generics: LIST[ACTUAL_CLASS_NAME];

--------------------------------------------------------------------------------
	
feature { NONE }
	
	make (new_name: INTEGER; 
			new_is_expanded, new_is_reference: BOOLEAN;
			new_actual_generics: LIST[ACTUAL_CLASS_NAME]) is
	-- this modifies new_actual_generics, so the argument cannot be used again.
		require
			new_is_expanded implies not new_is_reference
		local
			i: INTEGER;
			actual_generic: ACTUAL_CLASS_NAME;
		do	
			name := new_name;
			is_expanded := new_is_expanded;
			is_reference := new_is_reference;
			has_refs_in_code_name := new_name = globals.string_ref;
			if new_actual_generics /= Void then
				if not actual_is_expanded then
					from
						i := 1
					until
						i > new_actual_generics.count
					loop
						actual_generic := new_actual_generics @ i;
						if not actual_generic.actual_is_expanded then
-- write_string("ACN: "); actual_generics := new_actual_generics; print_name; write_string(" replacing "); actual_generic.print_name; write_string("%N");
							new_actual_generics.replace(globals.ref_class_name,i)
							has_refs_in_code_name := true;
						elseif actual_generic.has_refs_in_code_name then
							has_refs_in_code_name := true;
						end;
						i := i + 1;
					end;
				end;
				actual_generics := new_actual_generics;
			else
				actual_generics := empty_actual_generic_list;
			end;
		end; -- make

--------------------------------------------------------------------------------

feature { ANY }

	actual_is_expanded: BOOLEAN is
		do
			Result := (name /= globals.string_ref) and then
			          (is_expanded or
			           not is_reference and then
			           get_class(name).parse_class.is_expanded);
		end;
	
	clone_x_or_ref (must_be_expanded: BOOLEAN): ACTUAL_CLASS_NAME is
	-- return this actual class name, but make it explicitly expanded/reference if
	-- needed
		local
			is_r, is_x: BOOLEAN;
		do
			if actual_is_expanded = must_be_expanded then
				Result := Current
			else
				is_r := is_reference;
				is_x := is_expanded;
				if must_be_expanded then
					is_x := not is_r;
					is_r := false;
				else
					is_r := not is_x;
					is_x := false;
				end;
				!!Result.make(name,is_x,is_r,actual_generics);
			end;
		ensure
			Result.actual_is_expanded = must_be_expanded
		end;
		
--------------------------------------------------------------------------------

	is_none: BOOLEAN is
		do
			Result := name = globals.string_none and then actual_generics.is_empty
		end; -- is_none

--------------------------------------------------------------------------------

	corresponding_reference: ACTUAL_CLASS_NAME is
	-- If this is a reference type, return Current, else return this type's
	-- base type, if it's a reference type, or create a new explicit
	-- reference type from current.
		local
			i: INTEGER;
			new_actual_generics: LIST[ACTUAL_CLASS_NAME];
		do
			if actual_is_expanded then
				if not actual_generics.is_empty then
memstats(488);
					!!new_actual_generics.make;
					from
						i := 1
					until
						i > actual_generics.count
					loop
						new_actual_generics.add(actual_generics @ i);
						i := i + 1;
					end;
				end;
				if is_expanded then
					!!Result.make(name,false,false,new_actual_generics)  -- base type
				else
					!!Result.make(name,false,true,new_actual_generics)   -- explicit reference type
				end;
			else
				Result := Current
			end;
		ensure
			not Result.actual_is_expanded
		end; -- corresponding_reference


	corresponding_expanded: ACTUAL_CLASS_NAME is
	-- If this is an expanded type, return Current, else return this type's
	-- base type, if it's an expanded type, or  create a new explicit
	-- expanded type from current.
		do
			if not actual_is_expanded then
				if is_reference then
					!!Result.make(name,false,false,actual_generics)  -- base type
				else
					!!Result.make(name,true,false,actual_generics)   -- explicit expanded type
				end;
			else
				Result := Current
			end;
		ensure
			Result.actual_is_expanded
		end; -- corresponding_expanded

--------------------------------------------------------------------------------

	code_name: INTEGER is 
	-- creates name like "x#stack[r#integer]" to be used in object files.
		do
			if code_name_id=0 then
				get_code_name
			end;
			Result := code_name_id;
		end; -- code_name

	true_class_name: TRUE_CLASS_NAME is
	-- create corresponding TRUE_CLASS_NAME
		require
			not has_refs_in_code_name;
		local
			list: LIST[TRUE_CLASS_NAME];
			i: INTEGER;
		do
if has_refs_in_code_name then
	write_string("*********************Compilerfehler: has_refs%N");
elseif name = globals.string_ref then
	write_string("*********************Compilerfehler: name=_ref%N");
end;
			if not actual_generics.is_empty then
				from
					!!list.make;
					i := 1;
				until
					i > actual_generics.count
				loop
					list.add((actual_generics @ i).true_class_name);
					i := i + 1;
				end;
			end;
			!!Result.make(name,is_expanded,is_reference,list);
		end; -- true_class_name

	has_refs_in_code_name: BOOLEAN;
	-- true, wenn code_name generische Parameter "_ref" enthŠlt. Ist dies der
	-- Fall, so kann dieser code_name nicht zum Erzeugen von Objekten hergenommen
	-- werden

--------------------------------------------------------------------------------

feature { ACTUAL_CLASS_NAME }

	get_code_name is 
	-- Creates name like "X_STACK[R_INTEGER]" and saves its id in code_name_id
	-- NOTE: This calls itself recursively and uses tmp_str. The recursive calls
	-- therefore have to be done before tmp_str is used, since they destroy the
	-- tmp_str.
		local
			i: INTEGER; 
		do
			if code_name_id=0 then
				if not actual_generics.is_empty then
					from
						i := 1;
					until
						i > actual_generics.count
					loop
						(actual_generics @ i).get_code_name;
						i := i + 1;
					end;
				end;
				if is_expanded then
					tmp_str.copy(explicit_expanded_prefix);
				elseif is_reference then
					tmp_str.copy(explicit_reference_prefix);
				else
					tmp_str.wipe_out;
				end;
				tmp_str.append(strings @ name);
				if not actual_generics.is_empty then
					from
						tmp_str.append_character('[');
						tmp_str.append(strings @ (actual_generics @ 1).code_name_id);
						i := 2;
					until 
						i > actual_generics.count
					loop
						tmp_str.append_character(',');
						tmp_str.append(strings @ (actual_generics @ i).code_name_id);
						i := i + 1;
					end;
					tmp_str.append_character(']');
				end;
				code_name_id := strings # tmp_str;
			end;
		end; -- get_code_name

	code_name_id: INTEGER; -- previously determined id of code_name

--------------------------------------------------------------------------------

feature { ANY }
	
	local_type: LOCAL_TYPE is
		do
			if     not actual_is_expanded         then Result := globals.local_reference
			elseif name = globals.string_integer   then Result := globals.local_integer
			elseif name = globals.string_pointer   then Result := globals.local_pointer
			elseif name = globals.string_character then Result := globals.local_character
			elseif name = globals.string_boolean   then Result := globals.local_boolean
			elseif name = globals.string_real      then Result := globals.local_real
			elseif name = globals.string_double    then Result := globals.local_double
			else
				!!Result.make_expanded(actual_classes.find(Current));
			end;
		end; -- local_type

--------------------------------------------------------------------------------

feature { TRUE_CLASS }

	type_id: INTEGER is
	-- This actual class' type_id, as defined in DATATYPE_SIZES and used for td_type_id:
		do
			if     not actual_is_expanded          then Result := type_id_reference
			elseif name = globals.string_integer   then Result := type_id_integer
			elseif name = globals.string_pointer   then Result := type_id_pointer
			elseif name = globals.string_character then Result := type_id_character
			elseif name = globals.string_boolean   then Result := type_id_boolean
			elseif name = globals.string_real      then Result := type_id_real
			elseif name = globals.string_double    then Result := type_id_double
			else                                        Result := type_id_expanded
			end;
		end; -- type_id

--------------------------------------------------------------------------------

feature { NONE }
	
	tmp_str: STRING is 
		once
			!!Result.make(80)
		end; -- tmp_str

--------------------------------------------------------------------------------

feature { NONE }

	empty_actual_generic_list : LIST [ACTUAL_CLASS_NAME] is
		once
memstats(3);
			!!Result.make;
		end; -- empty_actual_generic_list

--------------------------------------------------------------------------------
		
feature { ANY }

	infix "<" (other: like Current) : BOOLEAN is
		local
			i: INTEGER; 
		do
			if is_expanded and not other.is_expanded then 
				Result := false;
			elseif not is_expanded and other.is_expanded then
				Result := true
			else -- is_expanded = other.is_expanded
				if is_reference and not other.is_reference then 
					Result := false;
				elseif not is_reference and other.is_reference then
					Result := true
				else -- is_reference = other.is_reference
					if name < other.name then 
						Result := true
					elseif name > other.name then 
						Result := false
					else
						from
							i := 1
						until
							i > actual_generics.count or else
							i > other.actual_generics.count or else
							not (actual_generics @ i).is_equal((other.actual_generics @ i))				
						loop
							i := i + 1;
						end;
						if i > actual_generics.count or else
						   i > other.actual_generics.count
						then
							Result := false
						else
							Result := (actual_generics @ i) < (other.actual_generics @ i);
						end;
					end;
				end;
			end;
		end; -- infix "<"	

--------------------------------------------------------------------------------

feature { ANY }

	print_name is
		local
			i: INTEGER; 
		do
			if is_expanded then
				write_string("expanded ");
			elseif is_reference then
				write_string("reference ");
			end;
			write_string(strings @ name); 
			if not actual_generics.is_empty then
				from
					write_string("[");
					(actual_generics @ 1).print_name;
					i := 2;
				until 
					i > actual_generics.count
				loop
					write_string(","); 
					(actual_generics @ i).print_name;
					i := i + 1;
				end;
				write_string("]");
			end;
		end; -- print_name		

--------------------------------------------------------------------------------

end -- ACTUAL_CLASS_NAME
