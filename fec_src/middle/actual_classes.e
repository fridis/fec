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

class ACTUAL_CLASSES

-- The classes corresponding to an ACTUAL_CLASS_NAME

inherit
	CLASSES;
	FRIDISYS;
	ERRORS;

--------------------------------------------------------------------------------

feature { NONE }

	actual_classes: PS_ARRAY[ACTUAL_CLASS_NAME,ACTUAL_CLASS] is
		once
			!!Result.make
		end; -- actual_classes
		
	actual_classes_list: LIST[ACTUAL_CLASS] is
		once
			!!Result.make
		end; -- actual_classes_list

feature { ANY }
		
	compile_classes (root: CLASS_INTERFACE; root_creation: INTEGER) is
		require
			root.parse_class.formal_generics.is_empty;
			error_status.error_count = 0
		local
			root_type: ACTUAL_CLASS_NAME;
			root_class: ACTUAL_CLASS;
			sys: SYSTEM;
		do
--write_string("getting used types:%N"); 
memstats(245); 
			!!root_type.make(root.key,false,false,Void);
memstats(246); 
			!!root_class.make(root_type); 
			get_used_types(root_class);
--write_string("getting type sizes:%N"); 
			get_type_sizes;
			if error_status.error_count = 0 then
--write_string("finding features to be duplicated:%N");
				get_need_for_duplication;
msg.write(msg.compiling); 
				compile_them;
				if error_status.error_count = 0 then
memstats(467);
					!!sys.create_system(root_class,root_creation);
				end;
			end;
		end; -- compile_classes

feature { NONE }

	get_used_types (ac: ACTUAL_CLASS) is
		local
			got: INTEGER;
		do
			actual_classes.add(ac);
			actual_classes_list.add(ac);
			from
				got := 1
			until
				got > actual_classes_list.count
			loop
				get_used(actual_classes_list @ got); 
				got := got + 1;
			end; 
		end; -- get_used_types
				
	get_used (of: ACTUAL_CLASS) is
		local
			i: INTEGER;
			type: TYPE; 
			uses: LIST[TYPE];
			parents: PARENT_LIST;
		do
			if of.key.actual_is_expanded then
				add_used_type(of.key.corresponding_reference);
			end;
			from
				uses := of.base_class.uses_types;
				i := 1
			until
				i > uses.count
			loop
				type := uses @ i;
				add_used_type(type.actual_class_name(of.key));
				i := i + 1;
			end;
		end; -- get_used

	add_used_type(new_type: ACTUAL_CLASS_NAME) is
		local
			new_ac: ACTUAL_CLASS;
		do
			if new_type /= globals.ref_class_name and then 
			   not actual_classes.has(new_type) then
memstats(247); 
				!!new_ac.make(new_type);
				actual_classes.add(new_ac);
				actual_classes_list.add(new_ac);
			end;
		end; -- add_used_type

--------------------------------------------------------------------------------

	get_type_sizes is
		local
			got: INTEGER;
			ac: ACTUAL_CLASS;
		do
			from 
				got := 1
			until 
				got > actual_classes_list.count or
				error_status.error_count > 0
			loop
				ac := actual_classes_list @ got;
				if not ac.got_size then
					ac.get_size
				end;
				got := got + 1;
			end;
		end; -- get_types_sizes 

--------------------------------------------------------------------------------

	get_need_for_duplication is
		local
			got: INTEGER;
			ac: ACTUAL_CLASS;
		do
			from 
				got := 1
			until 
				got > actual_classes_list.count
			loop
				(actual_classes_list @ got).get_duplicated_features;
				got := got + 1;
			end;
		end; -- get_need_for_duplication 

--------------------------------------------------------------------------------

	compile_them is
		local
			compiled: INTEGER;
		do
			from
				compiled := 1;
			until
				compiled > actual_classes_list.count
			loop
				(actual_classes_list @ compiled).compile;
				compiled := compiled + 1; 
			end;
		end; -- compile_them

--------------------------------------------------------------------------------

end -- ACTUAL_CLASSES
