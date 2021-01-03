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

class TRUE_CLASS_NAME

-- This is the name of a class for which a type descriptor is created. In the
-- case of a reference class with actual generics that are references a 
-- one ACTUAL_CLASS_NAME may be used by several TRUE_CLASSes.

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

	actual_generics: LIST[TRUE_CLASS_NAME];

--------------------------------------------------------------------------------
	
feature { NONE }
	
	make (new_name: INTEGER;
			new_is_expanded, new_is_reference: BOOLEAN;
			new_actual_generics: LIST[TRUE_CLASS_NAME]) is
		require
			new_is_expanded implies not new_is_reference
		do	
			name := new_name;
			is_expanded := new_is_expanded;
			is_reference := new_is_reference;
			actual_is_expanded := new_is_expanded or
			          not new_is_reference and then
			          get_class(name).parse_class.is_expanded;
			if new_actual_generics /= Void then
				actual_generics := new_actual_generics;
			else
				actual_generics := empty_actual_generic_list;
			end;
		end; -- make

--------------------------------------------------------------------------------

feature { ANY }

	actual_is_expanded: BOOLEAN;

--------------------------------------------------------------------------------

	code_name: INTEGER is 
	-- creates name like "x#stack[r#integer]" to be used in object files.
		do
			if code_name_id=0 then
				get_code_name
			end;
			Result := code_name_id;
		end; -- code_name

--------------------------------------------------------------------------------

feature { TRUE_CLASS_NAME }

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

feature { NONE }
	
	tmp_str: STRING is 
		once
			!!Result.make(80)
		end; -- tmp_str

--------------------------------------------------------------------------------

feature { NONE }

	empty_actual_generic_list : LIST [TRUE_CLASS_NAME] is
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

end -- TRUE_CLASS_NAME
