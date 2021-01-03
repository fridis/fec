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

class TRUE_CLASS

-- A class with actual generic parameters.

inherit
	SORTABLE[TRUE_CLASS_NAME];
	DATATYPE_SIZES;
	TRUE_CLASSES;
	FRIDISYS;

creation
	make
	
--------------------------------------------------------------------------------

feature { ANY }

--	key: TRUE_CLASS_NAME;    -- (geerbt)
	
	name: INTEGER;             -- key.code_name

	actual_class: ACTUAL_CLASS; 

--------------------------------------------------------------------------------

	make (tcn: TRUE_CLASS_NAME; actual: ACTUAL_CLASS) is
		require
			tcn.name = actual.key.name;
		do
			key := tcn;
			actual_class := actual;
			name := tcn.code_name;
			color := -1;
			number := -1;
		end; -- make
		
--------------------------------------------------------------------------------
-- SYSTEM CREATION:                                                           --
--------------------------------------------------------------------------------

	color: INTEGER; -- the color of this true_class. The color of two true_classes 
	                -- is different if those two classes have a common 
	                -- descendant within a system.
	
	set_color (new_color: INTEGER) is
		do
			color := new_color
		end; -- set_color

--------------------------------------------------------------------------------

	number: INTEGER; -- The number is a unique value for all true_classes in
	                 -- a system.

	set_number (new_number: INTEGER) is
		do
			number := new_number;
		end; -- set_number

--------------------------------------------------------------------------------

	create_type_descriptor(mc: MACHINE_CODE; num_colors: INTEGER) is
		local
			type_id, gen_name, tt_name, anc_name: INTEGER;
		do
--write_string("creating type descriptor of: "); key.print_name; write_string("%N");
			if color >= 0 then
				mc.define_abs_symbol(color_name(name),td_feature_descriptor+reference_size*color);
			end;
			if number >= 0 then
				mc.define_abs_symbol(number_name(name),number);
			end;
--			if not actual_class.base_class.parse_class.is_deferred then
				mc.define_data_symbol(type_descriptor_name(name),mc.data_index);
				type_id := actual_class.key.type_id;
				mc.add_data_word(type_id);
				if type_id = type_id_reference then 
					mc.add_data_word(reference_size)
				else
					mc.add_data_word(actual_class.size);
				end;
				if type_id = type_id_reference or type_id = type_id_expanded then
					if not key.actual_generics.is_empty then
						gen_name := generics_name(name);
						mc.add_data_reloc(mc.data_index,gen_name);
					else
						gen_name := 0;
					end;
					mc.add_data_word(0); -- generics
					mc.add_data_word(0); -- name (nyi)
					mc.add_data_word(0); -- attributes (nyi)
					if type_id = type_id_reference then
						mc.add_data_word(actual_class.size); -- heap object size
						mc.add_data_word(td_feature_descriptor+reference_size*color);
						mc.add_data_word(number);
						if not actual_class.base_class.parse_class.is_deferred then
							tt_name  := true_types_name(name); mc.add_data_reloc(mc.data_index, tt_name); mc.add_data_word(0);
							anc_name := ancestors_name (name); mc.add_data_reloc(mc.data_index,anc_name); mc.add_data_word(0);
							create_feature_array(mc,num_colors);
							create_true_types(mc,tt_name);
							create_ancestors(mc,anc_name);
						end;
					end;
					if gen_name /= 0 then
						create_generics(mc,gen_name);
					end;
				end;
--			end;
		end; -- create_type_descriptor

--------------------------------------------------------------------------------

feature { NONE }

	create_feature_array(mc: MACHINE_CODE; num_colors: INTEGER) is
		local
			di,i: INTEGER;
			aa: ARRAY[ANCESTOR];
			ancestor: ANCESTOR;
			ancestors_actual_name: ACTUAL_CLASS_NAME;
			ancestors_true_name: TRUE_CLASS_NAME;
			ancestors_true_class: TRUE_CLASS;
			ancestors_feat_descr: INTEGER;
			feat_descr_start: INTEGER;
		do
--write_string("Feature_array of "); actual_class.key.print_name; write_string("%N");
			di := mc.data_index;
			from
				i := 1
			until
				i > num_colors
			loop
				mc.add_data_word(0);
				i := i + 1;
			end; 
			from 
				i := 1
				aa := actual_class.base_class.ancestor_list;
			until
				i > aa.upper
			loop
				ancestor := aa @ i;
				ancestors_actual_name := ancestor.key.actual_class_name(actual_class.key);
				ancestors_true_name := ancestor.key.true_class_name(key);
				ancestors_true_class := true_classes.find(ancestors_true_name);
				feat_descr_start := di + reference_size * ancestors_true_class.color;
				ancestors_feat_descr := feature_descriptor_name(actual_class.key,ancestors_actual_name);
--write_string(strings @ ancestors_feat_descr); write_string("%N");
				mc.add_data_reloc(feat_descr_start,ancestors_feat_descr);
				i := i + 1;
			end;
		end; -- create_feature_array

	create_generics(mc: MACHINE_CODE; gen_name: INTEGER) is
		local
			i: INTEGER;
		do
			mc.define_data_symbol(gen_name,mc.data_index);
			from
				i := 1
			until
				i > key.actual_generics.count
			loop
				mc.add_data_reloc(mc.data_index,type_descriptor_name((key.actual_generics @ i).code_name));
				mc.add_data_word(0);
				i := i + 1;
			end;
			mc.add_data_word(0);
		end; -- create_generics

	create_true_types (mc: MACHINE_CODE; tt_name: INTEGER) is
		local
			i: INTEGER;
			tt_list: LIST[TYPE];
			tf_list: LIST[FEATURE_INTERFACE];
			fi: FEATURE_INTERFACE;
			atcn, new_tcn: TRUE_CLASS_NAME;
		do
--write_string("Create true types: "); write_string(strings @ tt_name); write_string("%N");
			mc.define_data_symbol(tt_name,mc.data_index);
			from
				tt_list := actual_class.true_types;
				tf_list := actual_class.true_types_features;
				i := 1;
			until
				i > actual_class.true_types.count
			loop
				atcn := key;
				fi := (tf_list @ i);
				if fi.parent_clause /= Void then
					atcn := fi.ancestor.key.true_class_name(atcn);
				end;
--write_string("   tt = "); (tt_list @ i).print_type; write_string(" tf = "); write_string(strings @ fi.key);
--write_string(" atcn = "); atcn.print_name; write_string("%N");
				new_tcn := (tt_list @ i).true_class_name(atcn,fi);
--write_string(" new_tcn = "); new_tcn.print_name; write_string("%N");
				mc.add_data_reloc(mc.data_index,type_descriptor_name(new_tcn.code_name));
				mc.add_data_word(0);
				i := i + 1;
			end;
		end; -- create_true_types

	create_ancestors (mc: MACHINE_CODE; anc_name: INTEGER) is
		local
			i: INTEGER;
			al: SORTED_ARRAY[ANCESTOR_NAME,ANCESTOR];
			atcn: TRUE_CLASS_NAME;
			tc: TRUE_CLASS;
		do
			mc.define_data_symbol(anc_name,mc.data_index);
			from
				al := actual_class.base_class.ancestor_list;
				i := 1;
			until
				i > al.count
			loop
				atcn := (al @ i).key.true_class_name(key);
				tc := true_classes.find(atcn);
				mc.add_data_word(tc.number);
				i := i + 1;
			end;
			mc.add_data_word(-1);
		end; -- create_true_types

--------------------------------------------------------------------------------

end -- TRUE_CLASS
