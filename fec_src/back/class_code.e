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

class CLASS_CODE

-- The code created for on class.

inherit
	MIDDLE_CLASS_CODE;
	DATATYPE_SIZES;
	SPARC_CONSTANTS;
	FRIDISYS;

creation
	make
	
--------------------------------------------------------------------------------

feature { ANY }

	const_pos_and_tag_offset: INTEGER is 
	-- offset of next pos_and_tag added, relative to const_pos_and_tags
		do
			Result := const_positions.count * pos_and_tag_size;
		end; -- const_pos_and_tag_offset

--------------------------------------------------------------------------------

feature { NONE }

	make (new_actual_class: ACTUAL_CLASS) is 
		do
			middle_make(new_actual_class);
			const_pos_and_tags := const_pos_and_tags_name(new_actual_class.name);
		end; -- middle_make

--------------------------------------------------------------------------------
		
feature { ACTUAL_CLASS }
	
	create_initialization is
		local
			i, type_descr, chr_id, str_id, chars_index: INTEGER;
			const_string: INTEGER;
		do
			create_data; 
			machine_code.define_func_symbol(initialization_name(actual_class.key.code_name),machine_code.pc);
			machine_code.asm_save(-96);
			chr_id := const_chars_name(actual_class.name);
			from
				i := 1
			until
				i > const_strings.count
			loop
				const_string := const_strings @ i;
				chars_index := machine_code.data_string_index;
				machine_code.add_data_string(const_string);
				str_id := const_string_name(actual_class.name,i);
				machine_code.define_bss_symbol(str_id,machine_code.bss_index);
				machine_code.add_bss_word;
			
				type_descr := type_descriptor_name(globals.string_string);
				machine_code.reloc_hi22(machine_code.pc,type_descr,0);
				machine_code.asm_sethi(0,o0);
				machine_code.reloc_lo10(machine_code.pc,type_descr,0);
				machine_code.asm_ari_imm(op3_or,o0,0,o0);
				machine_code.reloc_wdisp30(machine_code.pc,globals.string_allocate_object);
				machine_code.asm_call;
				machine_code.asm_nop;
				
				machine_code.reloc_hi22(machine_code.pc,str_id,0);
				machine_code.asm_sethi(0,o0+1);
				machine_code.reloc_lo10(machine_code.pc,str_id,0);
				machine_code.asm_ari_imm(op3_or,o0+1,0,o0+1);
				machine_code.asm_st_imm(op3_stw,o0,o0+1,0);
				
				machine_code.reloc_hi22(machine_code.pc,chr_id,chars_index);
				machine_code.asm_sethi(0,o0+1);
				machine_code.reloc_lo10(machine_code.pc,chr_id,chars_index);
				machine_code.asm_ari_imm(op3_or,o0+1,0,o0+1);
				
				machine_code.asm_ari_imm(op3_or,g0,(strings @ const_string).count,o0+2);
				
				machine_code.reloc_wdisp30(machine_code.pc,get_symbol_name(globals.string_string,globals.string_make_from_mem));
				machine_code.asm_call;
				machine_code.asm_nop;
				
				i := i + 1;
			end;
			machine_code.asm_jmpl(i0+7,8,g0);
			machine_code.asm_restore;
		end; -- create_initialization;
	
--------------------------------------------------------------------------------

feature { NONE }

	create_data is	
		local 
			i: INTEGER;
			pos: POSITION;
			tag: INTEGER;
		do
			if const_positions.count >0 then
				machine_code.define_data_symbol(const_pos_and_tags,machine_code.data_index);
				from
					i := 1
				until
					i > const_positions.count
				loop
					pos := const_positions @ i;
					tag := const_tags @ i;
					machine_code.add_data_reloc_addend(machine_code.data_index,
					                                   globals.string_source_file_names,
					                                   reference_size*(pos.source_file_number-1));
					machine_code.add_data_word(0);
					machine_code.add_data_word(pos.line);
					machine_code.add_data_word(pos.column);
					if tag /= 0 then
						add_c_string(tag);
						machine_code.add_data_reloc_addend(machine_code.data_index,
						                                   c_string_label,
						                                   c_string_offset);
					end;
					machine_code.add_data_word(0);
					i := i + 1;
				end;
			end;
			machine_code.set_data_reals_and_doubles(const_reals,const_doubles);
		end; -- create_data
					
--------------------------------------------------------------------------------

feature { ANY }

	add_c_string(str: INTEGER) is
	-- add str as a C-string and set c_string_label and c_string_offset
	-- to point to this string.
		do
			if c_string_label = 0 then
				c_string_label := const_chars_name(actual_class.name);
			end;
			c_string_offset := machine_code.data_string_index;
			machine_code.add_data_string(str);
		end; -- add_c_string

--------------------------------------------------------------------------------

feature { ACTUAL_CLASS }

	save_object_file is
	-- create the object file for this class. indicate success in attribute
	-- successful_save
		local
			code_name,object_name: STRING;
			out_file: FRIDI_FILE_WRITE;
			i: INTEGER;
		do
			successful_save := false;
memstats(460);			
			!!code_name.make_from_string(strings @ actual_class.key.code_name);
			-- nyi: use actual_class.key.file_name for this and use numbers as
			-- actual generics.
			from
				i := code_name.index_of(',',1);
			until
				i = 0
			loop
				code_name.put('-',i);
				i := code_name.index_of(',',i);
			end;
			if code_name.count > 29 then
				code_name.head(29)
			end; 
memstats(461);
			!!object_name.make(code_name.count+4+2);
			object_name.append("obj/");
			object_name.append(code_name);
			object_name.append(".o");
			msg.write(msg.created_file_prefix); write_string(object_name);
memstats(470);
			!!out_file.connect_to(object_name);
			if out_file.is_connected then
				msg.write(msg.lf);
				machine_code.write_object_file(out_file);
				successful_save := true;
				globals.object_file_names.append(" ");
				globals.object_file_names.append(object_name);
			else
				msg.write(msg.couldnt_save);
			end;
		end; -- save_object_file

	successful_save: BOOLEAN;

--------------------------------------------------------------------------------

end -- CLASS_CODE
