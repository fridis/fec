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

class SYSTEM

-- Creates the code to set up the Eiffel system.

inherit
	TRUE_CLASSES;
	SPARC_CONSTANTS;
	DATATYPE_SIZES;

creation
	create_system
		
--------------------------------------------------------------------------------

feature { NONE }

	create_system (root: ACTUAL_CLASS; root_creation: INTEGER) is
		local
			mc: MACHINE_CODE;
		do
memstats(466);
			!!mc.make(strings # main_code_name);
			-- 
			create_main(mc,root,root_creation);
			-- 
			get_true_classes;
			get_colors;
			create_type_descriptors(mc);
			--
			create_global_variables(mc);
			--
			create_source_file_names(mc);
			--
			save_object_file(mc);
			--
			create_link_file;
		end; -- create_system

	create_main (mc: MACHINE_CODE; 
	             root: ACTUAL_CLASS; 
	             root_creation: INTEGER) is
		local
			root_type_descr: INTEGER;
		do
			mc.define_func_symbol(strings # "main",mc.pc);
			mc.asm_save(-96);
			create_save_argc_and_argv(mc);
			-- mark beginning of stack trace
			if globals.create_trace_code or globals.create_gc_code then
				mc.asm_ari_reg(op3_or,0,sp,o0);
				mc.reloc_wdisp30(mc.pc,globals.string_init_trace);
				mc.asm_call;
				mc.asm_nop;
			end;
			--
			create_init_calls(mc);
			-- allocate root object
			root_type_descr := type_descriptor_name(root.key.code_name);
			mc.reloc_hi22(mc.pc,root_type_descr,0);
			mc.asm_sethi(0,o0);
			mc.reloc_lo10(mc.pc,root_type_descr,0);
			mc.asm_ari_imm(op3_or,o0,0,o0);
			mc.reloc_wdisp30(mc.pc,globals.string_allocate_object);
			mc.asm_call;
			mc.asm_nop;
			-- nyi: init expanded attributes!
			-- call root creation procedure
			mc.reloc_wdisp30(mc.pc,get_symbol_name(root.key.code_name,root_creation));
			mc.asm_call;
			mc.asm_nop;
			mc.asm_jmpl(i0+7,8,g0);
			mc.asm_restore;
		end; -- create_main
		
	create_save_argc_and_argv (mc: MACHINE_CODE) is
		local
			argc_id: INTEGER;
		do
			argc_id := strings # argc_name;      -- argc
			mc.reloc_hi22(mc.pc,argc_id,0);
			mc.asm_sethi(0,o0);
			mc.reloc_lo10(mc.pc,argc_id,0);
			mc.asm_ari_imm(op3_or,o0,0,o0);
			mc.asm_st_imm(op3_stw,i0,o0,0);
			argc_id := strings # argv_name;      -- argv
			mc.reloc_hi22(mc.pc,argc_id,0);
			mc.asm_sethi(0,o0);
			mc.reloc_lo10(mc.pc,argc_id,0);
			mc.asm_ari_imm(op3_or,o0,0,o0);
			mc.asm_st_imm(op3_stw,i0+1,o0,0);
		end; -- create_save_argc_and_argv
		
	create_init_calls (mc: MACHINE_CODE) is
		local
			i: INTEGER;
			ac: ACTUAL_CLASS;
		do
			from
				i := 1
			until
				i > actual_classes_list.count
			loop
				ac :=  actual_classes_list @ i;
				mc.reloc_wdisp30(mc.pc,initialization_name(ac.key.code_name));
				mc.asm_call;
				mc.asm_nop;
				i := i + 1;
			end;
		end; -- create_init_calls

	create_type_descriptors (mc: MACHINE_CODE) is
		local
			i: INTEGER;
		do
			from
				i := 1
			until
				i > true_classes_list.count
			loop
				(true_classes_list @ i).create_type_descriptor(mc,num_colors);
				i := i + 1;
			end;
		end; -- create_type_descriptors

	create_global_variables (mc: MACHINE_CODE) is
	-- create globals use by once-routines
		local
			i,j,size,algn: INTEGER;
			ac: ACTUAL_CLASS;
			ci: CLASS_INTERFACE;
			fl: ARRAY[FEATURE_INTERFACE];
			fi: FEATURE_INTERFACE;
			r: ROUTINE;
			ir: INTERNAL_ROUTINE;
			once_called_global, once_result_global: INTEGER;
		do
			from
				i := 1
			until
				i > actual_classes_list.count
			loop
				ci := (actual_classes_list @ i).base_class;
				fl := ci.feature_list;
				from
					j := 1
				until
					j > fl.count
				loop
					fi := fl @ j;
					if fi.feature_value.is_once and then
						fi.origin.name = ci.parse_class.key						
					then
						once_called_global := once_called_name(fi);
						once_result_global := once_result_name(fi);
						if not mc.symbol_defined(once_called_global) then
							mc.define_bss_symbol(once_called_global,mc.bss_index);
							mc.add_bss_word;
							if fi.type /= Void then
								r ?= fi.feature_value;								
								ir ?= r.routine_body;
								size := ir.once_result_size;
								algn := align(mc.bss_index,size) - mc.bss_index;
								mc.define_bss_symbol(once_result_global,mc.bss_index+algn);
								mc.add_bss_bytes(algn+size);
							end;
						end;
					end; 
					j := j + 1;
				end;
				i := i + 1;
			end;
		end; -- create_type_descriptors
		
	create_source_file_names (mc: MACHINE_CODE) is
	-- create strings that contain source code names
		local
			i: INTEGER;
			string_label: INTEGER;
			string_offset: INTEGER;
		do
			if globals.create_trace_code then
				mc.define_data_symbol(globals.string_source_file_names,mc.data_index);
				string_label := const_chars_name(strings # main_code_name)
				from
					i := 1;
				until
					i > scanners.count
				loop
					string_offset := mc.data_string_index;
					mc.add_data_string(strings # (scanners @ i).source_file_name);
					mc.add_data_reloc_addend(mc.data_index,string_label,string_offset);
					mc.add_data_word(0);
					i := i + 1;
				end; 
			end;
		end; -- create_source_file_names

	save_object_file(mc: MACHINE_CODE) is
		local
			out_file: FRIDI_FILE_WRITE;
		do
			msg.write(msg.save_main);
memstats(469); 
			!!out_file.connect_to("obj/main.o");
			if out_file.is_connected then
				msg.write(msg.lf);
				mc.write_object_file(out_file);
				globals.object_file_names.append(" obj/main.o");
			else
				msg.write(msg.couldnt_save);
			end;
		end; -- save_object_file

--------------------------------------------------------------------------------

	get_true_classes is
		local
			i,j: INTEGER;
			ac: ACTUAL_CLASS;
			acn: ACTUAL_CLASS_NAME;
			tcn,atcn,new_tcn: TRUE_CLASS_NAME;
			new_ac: ACTUAL_CLASS;
			tc: TRUE_CLASS;
			tt_list: LIST[TYPE];
			tf_list: LIST[FEATURE_INTERFACE];
			ta_list: LIST[ACTUAL_CLASS];
			fi: FEATURE_INTERFACE;
			aa: ARRAY[ANCESTOR];
			uses: LIST[TYPE];
		do
--write_string("getting true classes:%N");
-- nyi: get true classes from used types!
			from
				i := 1
			until
				i > actual_classes_list.count
			loop
				ac := actual_classes_list @ i;
--write_string("gtc of "); ac.key.print_name; 
				acn := ac.key;
				if not acn.has_refs_in_code_name then
--write_string("    ******* adding to true classes");
					add_true_class(acn.true_class_name,ac);
				end;
--write_string("%N");
				i := i + 1;
			end;
			from
				i := 1
			until
				i > true_classes_list.count
			loop
				tc := true_classes_list @ i;
				tcn := tc.key;
				ac := tc.actual_class;
				from
					uses := tc.actual_class.base_class.uses_types;
					j := 1
				until
					j > uses.count
				loop
					-- nyi: fi=Void or tc.actual_class.base_class.no_feature?
					new_tcn := (uses @ j).true_class_name(tcn,Void);
					new_ac := (uses @ j).actual_class(ac.key);
					add_true_class(new_tcn,new_ac);
					j := j + 1;
				end;
--write_string("gtc ancestors of "); ac.key.print_name; write_string("%N");
				if not ac.is_expanded then
					from 
						j := 1
						aa := ac.base_class.ancestor_list;
					until
						j > aa.upper
					loop
--write_string("   anc: "); (aa @ j).key.actual_class_name(ac.key).print_name; write_string("%N");
						new_tcn := (aa @ j).key.true_class_name(tcn);
						new_ac := actual_classes.find((aa @ j).key.actual_class_name(ac.key));
						add_true_class(new_tcn,new_ac);
						j := j + 1;
					end;
					from 
						tt_list := ac.true_types;
						tf_list := ac.true_types_features;
						ta_list := ac.true_types_actual_classes;
						j := 1
					until
						j > ac.true_types.count
					loop
						atcn := tcn;
						fi := (tf_list @ j);
						if fi.parent_clause /= Void then
							atcn := fi.ancestor.key.true_class_name(atcn);
						end;
						new_tcn := (tt_list @ j).true_class_name(atcn,fi);
						add_true_class(new_tcn,ta_list @ j);
						j := j + 1;
					end;
				end;
				i := i + 1;
			end;
		end; -- get_true_classes

	add_true_class (tcn: TRUE_CLASS_NAME; ac: ACTUAL_CLASS) is
		local
			tc: TRUE_CLASS;
		do
			if not true_classes.has(tcn) then
				!!tc.make(tcn,ac);
				true_classes.add(tc);
				true_classes_list.add(tc);
			end;
		end; -- add_true_class

--------------------------------------------------------------------------------

	num_colors: INTEGER; -- Number of different colors used to color the actual classes

	get_colors is
		local
			i,number: INTEGER;
			tc: TRUE_CLASS;
		do
		-- nyi: this should do some real graph coloring instead of this
		-- simple coloring.
			num_colors := 0;
			from
				i := 1;
				number := 0;
			until
				i > true_classes_list.count
			loop
				tc := (true_classes_list @ i);
				if not tc.key.actual_is_expanded then
					tc.set_number(number);
					number := number + 1;
					tc.set_color(num_colors);
					num_colors := num_colors + 1;
				end;
				i := i + 1;
			end;
		end; -- get_colors
			
--------------------------------------------------------------------------------

	create_link_file is
		local
			out_file: FRIDI_FILE_WRITE;
			out_name: STRING;
		do
			msg.write(msg.save_elink);
memstats(469); 
			!!out_file.connect_to("elink");
			if out_file.is_connected then
				msg.write(msg.lf);
				out_file.put_string(globals.linker);
				out_file.put_string(" -o ");
				out_file.put_string(globals.executable);
				out_file.put_string(" obj/fec_lib.o");
				out_file.put_string(globals.object_file_names);
				out_file.put_string("%N");
				out_file.disconnect;
			else
				msg.write(msg.couldnt_save);
			end;
		end;	

--------------------------------------------------------------------------------

end -- SYSTEM
