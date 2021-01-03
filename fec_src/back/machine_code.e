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

class MACHINE_CODE

-- Represents the object file created for an ACTUAL_CLASS, with its code, 
-- constants and symbols.

inherit
	SPARC_CONSTANTS;
	DATATYPE_SIZES;
	FRIDISYS;

creation 
	make

--------------------------------------------------------------------------------

feature { ACTUAL_CLASS, SYSTEM } -- nyi: ACTUAL_CLASS only for code statistics

	code_name: INTEGER;                -- id of actual_class' code_name or unique name for this file ("_eiffel_main")
	
	commands: LIST[INTEGER];           -- .text section

	data: LIST[INTEGER];               -- .rodata section
	
	data_reals: LIST[REAL];            -- .rodata for real constants or Void
	data_doubles: LIST[DOUBLE];        -- .rodata for double constants or Void
	
	data_strings: LIST[INTEGER];       -- last part of .rodata section holding strings
	data_string_len: INTEGER;          -- cumulative length of data_strings

	bss_len: INTEGER;                  -- size of .bss section

	symbols: PS_ARRAY[INTEGER,SYMBOL]; -- .symtab section
	
	text_relocs: LIST[RELOC];           -- .rela.text section

	data_relocs: LIST[RELOC];           -- .rela.data section

feature { BRANCH_COMMAND }

	branch_fixups: LIST[BRANCH_COMMAND];

--------------------------------------------------------------------------------

feature { NONE }

	make (new_code_name: INTEGER) is
		do
			code_name := new_code_name;
memstats(422);
			!!commands.make;
			!!data.make;
			data_reals := Void;
			data_doubles := Void;
			!!data_strings.make;
			data_string_len := 0;
			!!symbols.make;
			!!text_relocs.make;
			!!data_relocs.make;
			bss_len := 0;
			!!branch_fixups.make;
		end; -- make

--------------------------------------------------------------------------------

feature { COMMAND, ROUTINE_CODE, CLASS_CODE, BASIC_BLOCK, SYSTEM }

	pc: INTEGER is 
	-- current program counter
		do
			Result := commands.count;
		end; -- pc

--------------------------------------------------------------------------------

	define_func_symbol (name: INTEGER; symbol_pc: INTEGER) is
	-- define a symbol for a function.
		require
			name /= 0;
		local
			symbol,has: SYMBOL;
		do
			symbol := symbols.find(name);
			if symbol = Void then
				symbol := recycle.new_symbol;
				symbol.make_function(name,4*symbol_pc);
				symbols.add(symbol);
			elseif symbol.type = symbol.stt_notype then
				symbol.make_function(name,4*symbol_pc);
			else
				write_string("Compilerfehler: MACHINE_CODE.define_symbol%N");
			end;
		end; -- define_func_symbol

feature { NONE }

	get_referenced_symbol (name: INTEGER): SYMBOL is
	-- find this symbol or create a no_type symbol with this name
		do
			Result := symbols.find(name);
			if Result = Void then
				Result := recycle.new_symbol;
				Result.make_undefined(name);
				symbols.add(Result);
			end;
		end; -- get_referenced_symbol
		
--------------------------------------------------------------------------------

feature { COMMAND, CLASS_CODE, SYSTEM }

	reloc_wdisp30 (reloc_pc: INTEGER; to: INTEGER) is
	-- create a R_SPARC_WDISP30 relocation for a function call
	-- reloc_pc gives the program counter position of the instruction affected
	-- by this relocation.
	-- to is the id of the referenced symbol.
		local
			reloc: RELOC;
		do
			reloc := recycle.new_reloc;
			reloc.make_wdisp30(4*reloc_pc,get_referenced_symbol(to));
			text_relocs.add(reloc);
		end; -- reloc_wdisp30

	reloc_hi22 (reloc_pc: INTEGER; to: INTEGER; addend: INTEGER) is
	-- create a R_SPARC_HI22 relocation 
	-- reloc_pc gives the program counter position of the instruction affected
	-- by this relocation.
	-- to is the id of the referenced symbol.
		local
			reloc: RELOC;
		do
			reloc := recycle.new_reloc;
			reloc.make_hi22(4*reloc_pc,get_referenced_symbol(to),addend);
			text_relocs.add(reloc);
		end; -- reloc_hi22

	reloc_lo10 (reloc_pc: INTEGER; to: INTEGER; addend: INTEGER) is
	-- create a R_SPARC_HI22 relocation 
	-- reloc_pc gives the program counter position of the instruction affected
	-- by this relocation.
	-- to is the id of the referenced symbol.
		local
			reloc: RELOC;
		do
			reloc := recycle.new_reloc;
			reloc.make_lo10(4*reloc_pc,get_referenced_symbol(to),addend);
			text_relocs.add(reloc);
		end; -- reloc_lo10

	reloc_13 (reloc_pc: INTEGER; to: INTEGER) is
	-- create a R_SPARC_13 relocation 
	-- reloc_pc gives the program counter position of the instruction affected
	-- by this relocation.
	-- to is the id of the referenced symbol.
		local
			reloc: RELOC;
		do
			reloc := recycle.new_reloc;
			reloc.make_13(4*reloc_pc,get_referenced_symbol(to));
			text_relocs.add(reloc);
		end; -- reloc_13

--------------------------------------------------------------------------------

feature { ANY }

-- machine code creation:

	asm_save (sz: INTEGER) is
	-- save %sp,sz,%sp
		do
			commands.add(op(2)+rd(sp)+op3(op3_save)+rs1(sp)+i_flag+simm13(sz));
		end; -- asm_save

	asm_restore is
	-- restore %g0,%g0,%g0
		do
			commands.add(op(2)+op3(op3_restore));
		end; -- asm_restore

	asm_ari_imm (op3_v,rs1_v,simm13_v,rd_v: INTEGER) is
		do
			commands.add(op(2)+rd(rd_v)+op3(op3_v)+rs1(rs1_v)+i_flag+simm13(simm13_v));
		end; -- asm_ari_imm

	asm_ari_reg (op3_v,rs1_v,rs2_v,rd_v: INTEGER) is
		do
			commands.add(op(2)+rd(rd_v)+op3(op3_v)+rs1(rs1_v)+rs2_v);
		end; -- asm_ari_reg

	asm_sethi (imm2_v,rd_v: INTEGER) is
		do
			commands.add(rd(rd_v)+op2(4)+imm2_v);
		end; -- asm_sethi
		
	asm_call is
		do
			commands.add(op(1)); 
		end; -- asm_call

	asm_jmpl (rs1_v, simm13_v, rd_v: INTEGER) is
		do
			commands.add(op(2)+rd(rd_v)+op3(op3_jmpl)+rs1(rs1_v)+i_flag+simm13(simm13_v));
		end; -- asm_jmpl

	asm_nop is
		do
			commands.add(op2(4));  -- sethi 0,%g0
		end; -- asm_nop
		
	asm_bcc (is_fbranch: BOOLEAN; cond_v: INTEGER; annul: BOOLEAN; dest_pc: INTEGER) is
		local
			c: INTEGER;
		do
			c := disp22(dest_pc-pc)+cond(cond_v); 
			if is_fbranch then c := c+op2(6)
			              else c := c+op2(2)
			end;
			if annul then 
				c := c + a_flag;
			end;
			commands.add(c)
		end; -- asm_bcc
		
	asm_bcc_forward (is_fbranch: BOOLEAN; cond_v: INTEGER; annul: BOOLEAN) is
	-- like asm_bcc, but displacement is set to 0 to be fixed later using fixup_branches
		local
			c: INTEGER;
		do
			c := cond(cond_v);
			if is_fbranch then c := c+op2(6)
			              else c := c+op2(2)
			end;
			if annul then 
				c := c + a_flag;
			end;
			commands.add(c)
		end; -- asm_bcc_forward
	
	asm_ld_imm(op3_v, rs1_v, simm13_v, rd_v: INTEGER) is
		do
			commands.add(op(3)+rd(rd_v)+op3(op3_v)+rs1(rs1_v)+i_flag+simm13(simm13_v));
		end; -- asm_ld_imm
		
	asm_ld_reg(op3_v, rs1_v, rs2_v, rd_v: INTEGER) is
		do
			commands.add(op(3)+rd(rd_v)+op3(op3_v)+rs1(rs1_v)+rs2_v);
		end; -- asm_ld_imm
	
	asm_st_imm(op3_v, rd_v, rs1_v, simm13_v: INTEGER) is
	-- NOTE: rd is the source, rs the destination!
		do
			commands.add(op(3)+rd(rd_v)+op3(op3_v)+rs1(rs1_v)+i_flag+simm13(simm13_v));
		end; -- asm_st_imm
		
	asm_st_reg(op3_v, rd_v, rs1_v, rs2_v: INTEGER) is
	-- NOTE: rd is the source, rs the destination!
		do
			commands.add(op(3)+rd(rd_v)+op3(op3_v)+rs1(rs1_v)+rs2_v);
		end; -- asm_st_imm

	asm_ldf_imm(op3_v, rs1_v, simm13_v, frd_v: INTEGER) is
	-- frd_v is f0..f0+31
		do
			commands.add(op(3)+rd(frd_v-f0)+op3(op3_v)+rs1(rs1_v)+i_flag+simm13(simm13_v));
		end; -- asm_ldf_imm
		
	asm_ldf_reg(op3_v, rs1_v, rs2_v, frd_v: INTEGER) is
	-- frd_v is f0..f0+31
		do
			commands.add(op(3)+rd(frd_v-f0)+op3(op3_v)+rs1(rs1_v)+rs2_v);
		end; -- asm_ldf_reg

	asm_stf_imm(op3_v, frd_v, rs1_v, simm13_v: INTEGER) is
	-- frd_v is f0..f0+31. frd_v is the source, rs1 destination
		do
			commands.add(op(3)+rd(frd_v-f0)+op3(op3_v)+rs1(rs1_v)+i_flag+simm13(simm13_v));
		end; -- asm_stf_imm
		
	asm_stf_reg(op3_v, frd_v, rs1_v, rs2_v: INTEGER) is
	-- frd_v is f0..f0+31. frd_v is the source, rs1/rs2 destination
		do
			commands.add(op(3)+rd(frd_v-f0)+op3(op3_v)+rs1(rs1_v)+rs2_v);
		end; -- asm_stf_reg
		
	asm_fari(opf_v, frs1_v, frs2_v, frd_v: INTEGER) is
	-- fr* are f0..f0+31
		do
			commands.add(op(2)+rd(frd_v-f0)+op3(52)+rs1(frs1_v-f0)+opf(opf_v)+rs2(frs2_v-f0));
		end; -- asm_fari
		
	asm_fari2(opf_v, frs2_v, frd_v: INTEGER) is
	-- fr* are f0..f0+31
		do
			commands.add(op(2)+rd(frd_v-f0)+op3(52)+opf(opf_v)+rs2(frs2_v-f0));
		end; -- asm_fari2

	asm_fcmp(opf_v, frs1_v, frs2_v: INTEGER) is
	-- fr* are f0..f0+31
		do
			commands.add(op(2)+op3(53)+rs1(frs1_v-f0)+opf(opf_v)+rs2(frs2_v-f0));
		end; -- asm_fcmp

--------------------------------------------------------------------------------

feature { ROUTINE_CODE }

	fixup_branches is
	-- this has to be called after code has been created for one routine and 
	-- before code is generated for the next routine. It fixes all forward
	-- branches that were unknown during code generation.
		local
			fixup: BRANCH_COMMAND;
			i,c,c_index,fixup_pc: INTEGER;
		do
			from
				i := 1
			until
				i > branch_fixups.count
			loop
				fixup := branch_fixups @ i;
				fixup_pc := fixup.fixup_pc; 
				c_index := fixup_pc + 1;
				c := (commands @ c_index) + disp22(fixup.fixup_destination - fixup_pc);
				commands.replace(c,c_index);
				i := i + 1;
			end;
			branch_fixups.make;
		end; -- fixup_branches

--------------------------------------------------------------------------------

feature { SYSTEM }

	symbol_defined (name: INTEGER): BOOLEAN is
		local
			symbol: SYMBOL;
		do
			symbol := symbols.find(name);
			Result := symbol /= Void and then 
			          symbol.type /= symbol.stt_notype;
		end; -- symbol_defined

--------------------------------------------------------------------------------

feature { ANCESTOR, TRUE_CLASS, CLASS_CODE, SYSTEM, ROUTINE_CODE }

-- Data creation

	add_data_word(i: INTEGER) is
		do
			data.add(i);
		end; -- add_data_word

	add_data_words(n: INTEGER) is
		local
			i: INTEGER;
		do
			from
				i := 1
			until
				i > n
			loop
				data.add(0);
				i := i + 1;
			end;
		end; -- add_data_words

	put_data_word(i,at: INTEGER) is
		do
			data.replace(i,at);
		end; -- put_data_word
		
	add_data_reloc_addend(data_indx: INTEGER; to: INTEGER; addend: INTEGER) is
		local
			reloc: RELOC;
		do
			reloc := recycle.new_reloc;
			reloc.make_32(data_indx,get_referenced_symbol(to),addend);
			data_relocs.add(reloc)
		end; -- add_data_reloc_addend
		
	add_data_reloc(data_indx: INTEGER; to: INTEGER) is
		do
			add_data_reloc_addend(data_indx,to,0);
		end; -- add_data_reloc

	data_index: INTEGER is -- current index in data array
		do
			Result := reference_size * data.count;
		end; -- data_index

	define_data_symbol (name: INTEGER; data_indx: INTEGER) is
	-- define a symbol for a function.
		require
			name /= 0;
		local
			symbol,has: SYMBOL;
		do
			symbol := symbols.find(name);
			if symbol = Void then
				symbol := recycle.new_symbol;
				symbol.make_object(name,data_indx);
				symbols.add(symbol);
			elseif symbol.type = symbol.stt_notype then
				symbol.make_object(name,data_indx);
			else
				write_string("Compilerfehler: MACHINE_CODE.define_data_symbol%N");
			end;
		end; -- define_data_symbol

--------------------------------------------------------------------------------

	set_data_reals_and_doubles(reals: LIST[REAL]; doubles: LIST[DOUBLE]) is
		do
			if reals /= Void and then reals.count /= 0 then
				data_reals := reals;
			end;
			if doubles /= Void and then doubles.count /= 0 then
				data_doubles := doubles;
			end;
		end; -- set_data_reals_and_doubles

--------------------------------------------------------------------------------

	add_data_string(id: INTEGER) is
	-- add string with given id at data_string_index to rodata section
		do
			data_strings.add(id);
			data_string_len := data_string_len + (strings @ id).count + 1;
		end; -- add_data_string
		
	data_string_index: INTEGER is
		do
			Result := data_string_len;
		end; -- data_string_index
		
--------------------------------------------------------------------------------

-- BSS section

	add_bss_word is
		do
			bss_len := bss_len + reference_size;
		end; -- add_bss_word

	add_bss_words(n: INTEGER) is
		do
			bss_len := bss_len + reference_size * n;
		end; -- add_bss_words

	add_bss_bytes(n: INTEGER) is
		do
			add_bss_words((n + reference_size - 1) // reference_size);
		end; -- add_bss_bytes

	bss_index: INTEGER is -- current index in bss array
		do
			Result := bss_len;
		end; -- data_index

	define_bss_symbol (name: INTEGER; bss_indx: INTEGER) is
	-- define a symbol for a function.
		require
			name /= 0;
		local
			symbol: SYMBOL;
		do
			symbol := symbols.find(name);
			if symbol = Void then
				symbol := recycle.new_symbol;
				symbol.make_bss(name,bss_indx);
				symbols.add(symbol);
			elseif symbol.type = symbol.stt_notype then
				symbol.make_bss(name,bss_indx);
			else
				write_string("Compilerfehler: MACHINE_CODE.define_bss_symbol%N");
			end;
		end; -- define_bss_symbol

--------------------------------------------------------------------------------

	define_abs_symbol (name: INTEGER; value: INTEGER) is
	-- define a symbol for a function.
		require
			name /= 0;
		local
			symbol: SYMBOL;
		do
			symbol := symbols.find(name);
			if symbol = Void then
				symbol := recycle.new_symbol;
				symbol.make_abs(name,value);
				symbols.add(symbol);
			else
				write_string("Compilerfehler: MACHINE_CODE.define_abs_symbol: ");
				write_string(strings @ name); write_string("%N");
			end;
		end; -- define_abs_symbol

--------------------------------------------------------------------------------

feature { NONE }

	define_rodata_symbols is
	-- this has to be called before an object file is created to define
	-- the symbols for the real, double and characters parts of the .rodata
	-- section
		local
			adr: INTEGER;
		do
			adr := data_index;
			if data_reals /= Void then
				adr := align(adr,real_size);
				define_data_symbol(const_reals_name(code_name),adr);
				adr := adr + real_size * data_reals.count;
			end;
			if data_doubles /= Void then
				adr := align(adr,double_size);
				define_data_symbol(const_doubles_name(code_name),adr);
				adr := adr + double_size * data_doubles.count;
			end;
			if data_strings.count > 0 then
				define_data_symbol(const_chars_name(code_name),adr);
				adr := adr + data_string_len;
			end;
			sect_rodata_len := align(adr,reference_size);
		end; -- define_rodata_symbols

--------------------------------------------------------------------------------

feature { CLASS_CODE, SYSTEM }

	write_object_file (file: FRIDI_FILE_WRITE) is
		require
			file /= Void;
		do
			define_rodata_symbols;
			obj_file := file;
			sorted_symbols := symbols.get_sorted;
			get_sect_strtab;
			write_elf_header;
			write_sect_shstrtab;
			write_sect_text;
			write_sect_rodata;
			write_sect_symtab;
			write_sect_strtab;
			write_sect_rela_text;
			write_sect_rela_rodata;
			write_sect_comment;
			write_section_header_table;
			obj_file.disconnect;
		ensure
			not file.is_connected;
		end; -- write_object_file

--------------------------------------------------------------------------------

feature { NONE }

-- symbols in the order of the object file

	sorted_symbols: ARRAY[SYMBOL];

-- elf constants:

	elf_header_size: INTEGER is 52;
	
	elf_class_none: INTEGER is 0;
	elf_class_32  : INTEGER is 1;
	elf_class_64  : INTEGER is 2;

	elf_data_none : INTEGER is 0;
	elf_data_2lsb : INTEGER is 1;
	elf_data_2msb : INTEGER is 2;

	ev_current : INTEGER is 1;

	et_none : INTEGER is 0;
	et_rel  : INTEGER is 1;
	et_exec : INTEGER is 2;
	et_dyn  : INTEGER is 3;
	et_core : INTEGER is 4;
	
	em_none : INTEGER is 0;
	em_m32  : INTEGER is 1;
	em_sparc: INTEGER is 2;
	em_386  : INTEGER is 3;
	em_68k  : INTEGER is 4;
	em_88k  : INTEGER is 5;
	em_860  : INTEGER is 7;

-- symbol binding, elf32_st_bind

	stb_local : INTEGER is 0;
	stb_global: INTEGER is 1;
	stb_weak  : INTEGER is 2;

-- symbol types:

	stt_notype : INTEGER is 0; 
	stt_object : INTEGER is 1; 
	stt_func   : INTEGER is 2; 
	stt_section: INTEGER is 3; 
	stt_file   : INTEGER is 4; 
	
-- section header index:

	shn_abs : INTEGER is -15;
	shn_undef : INTEGER is 0;
	code_section: INTEGER is 2;
	data_section: INTEGER is 3;
	bss_section: INTEGER is 4;
	
-- section header table

	sh_size: INTEGER is 40;

	sht_null    : INTEGER is 0;
	sht_progbits: INTEGER is 1;
	sht_symtab  : INTEGER is 2; 
	sht_strtab  : INTEGER is 3;
	sht_rela    : INTEGER is 4;
	sht_hash    : INTEGER is 5;
	sht_dynamic : INTEGER is 6;
	sht_note    : INTEGER is 7;
	sht_nobits  : INTEGER is 8;
	sht_rel     : INTEGER is 9;
	sht_shlib   : INTEGER is 10;
	sht_dynsym  : INTEGER is 11;
	
	shf_write    : INTEGER is 1;
	shf_alloc    : INTEGER is 2;
	shf_execinstr: INTEGER is 4;

--------------------------------------------------------------------------------

	write_elf_header is
		do
			write_e_ident;
			write_half(et_rel);
			write_half(em_sparc);
			write_word(ev_current);
			write_word(0);          -- e_entry
			write_word(0);          -- e_phoff
			write_word(elf_header_size +
			           sect_shstrtab_len +
			           sect_text_len +
			           sect_rodata_len +
			           sect_symtab_len +
			           sect_strtab_len +
			           sect_rela_text_len +
			           sect_rela_rodata_len +
			           sect_comment_len);  -- e_shoff
			write_word(0);          -- e_flags
			write_half(52);         -- e_ehsize
			write_half(0);          -- e_phentsize
			write_half(0);          -- e_phnum
			write_half(sh_size);    -- e_shentsize
			write_half(10);         -- e_shnum
			write_half(1);          -- e_shstrndx
		end; -- write_elf_header;

--------------------------------------------------------------------------------

	write_e_ident is
		do
			write_byte(127);
			write_byte(('E').code);
			write_byte(('L').code);
			write_byte(('F').code);
			write_byte(elf_class_32);
			write_byte(elf_data_2msb);
			write_byte(ev_current);
			write_pads(9);
		end; -- write_e_ident

--------------------------------------------------------------------------------

	sect_shstrtab_string: STRING is 
		local
			i: INTEGER;
		once
		-- sebug: this should be a constant attribute
			!!Result.make_from_string("U.shstrtabU%
	                                %.textU%
	                                %.rodataU%
	                                %.bssU%
	                                %.symtabU%
	                                %.strtabU%
	                                %.rela.textU%
	                                %.rela.rodataU%
	                                %.commentUU");
			from
				i := 1
			until
				i > Result.count
			loop
				if Result @ i = 'U' then
					Result.put('%U',i);
				end;
				i := i + 1;
			end;
		ensure
			Result.count = 80;
		end; -- sect_shstrtab_string
	                     
	sect_shstrtab_len: INTEGER is 
		do
			Result := sect_shstrtab_string.count
		end; -- sect_shstrtab_len
 
	write_sect_shstrtab is
		do
			obj_file.put_string(sect_shstrtab_string);
		end; -- write_sect_shstrtab

--------------------------------------------------------------------------------

	sect_text_len: INTEGER is
		do
			Result := 4 * commands.count;
		end; -- sect_text_len

	write_sect_text is
		local
			i: INTEGER;
		do
			from
				i := 1
			until
				i > commands.count
			loop
				write_word(commands @ i);
				i := i + 1;
			end;
		end; -- write_sect_text

--------------------------------------------------------------------------------

	sect_rodata_len: INTEGER; -- set by define_rodata_symbols 

	write_sect_rodata is
		local
			i,l: INTEGER;
			str: STRING;
		do
			l := 0;
			from
				i := 1
			until
				i > data.count
			loop
				write_word(data @ i);
				i := i + 1;
				l := l + reference_size;
			end;
			if data_reals /= Void then
				from
					i := 1
				until
					i > data_reals.count
				loop
					write_real(data_reals @ i);
					i := i + 1;
					l := l + real_size;
				end;
			end; 
			if data_doubles /= Void then
				if l \\ double_size /= 0 then
					write_word(0);
					l := l + reference_size;
				end;
				from
					i := 1
				until
					i > data_doubles.count
				loop
					write_double(data_doubles @ i);
					i := i + 1;
					l := l + double_size;
				end;
			end; 
			from
				i := 1;
			until
				i > data_strings.count
			loop
				str := strings @ (data_strings @ i);
				write_const_string(str);
				write_byte(0);
				l := l + str.count + 1;
				i := i + 1;
			end;
			from
			until
				l \\ 4 = 0
			loop
				write_byte(0);
				l := l + 1;
			end;
--write_string("sect_len = "); write_integer(sect_rodata_len);
--write_string(";  l = "); write_integer(l); write_string("%N");
		end; -- write_sect_rodata

--------------------------------------------------------------------------------

	sect_symtab_len: INTEGER is
		do
			Result := 16*(symbols.count+1+4);
		end; -- sect_symtab_len

	write_sect_symtab is
		local
			i,l,val: INTEGER;
			sym: SYMBOL;
		do
			write_word(0); -- initial symbol
			write_word(0);
			write_word(0);
			write_byte(4); write_byte(0); write_half(-15);
			
			write_word(1); 
			write_word(0);
			write_word(0);
			write_byte(4); write_byte(0); write_half(-15);
			
			write_word(0); 
			write_word(0);
			write_word(0);
			write_byte(3);
			write_byte(0);
			write_half(3);

			write_word(1 + ("eiffel.e").count + 1);
			write_word(0); 
			write_word(0);
			write_byte(0);
			write_byte(0);
			write_half(2);

			write_word(0); 
			write_word(0);
			write_word(0);
			write_byte(3);
			write_byte(0);
			write_half(2);

			from
				i := 1
				l := 1 + ("eiffel.e").count + 1 + ("fec compiled.").count + 1;
			until
				i > sorted_symbols.upper
			loop
				sym := sorted_symbols @ i;
				write_word(l);
				l := l + (strings @ sym.key).count + 1;
				write_word(sym.value);
				if sym.type /= 0 then 
					write_word(32);                      -- nyi: size
				else
					write_word(0);
				end;
				write_byte(16*stb_global + sym.type); -- st_info
				write_byte(0);                        -- st_other
				write_half(sym.section);
				i := i + 1;
			end;
		end; -- write_sect_symtab

--------------------------------------------------------------------------------

	get_sect_strtab is
		local
			i,l: INTEGER;
			sym: SYMBOL;
		do
			l := 1 + ("eiffel.e").count + 1 + ("fec compiled.").count + 1;
			from
				i := 1;
			until
				i > sorted_symbols.upper
			loop
				l := l + (strings @ (sorted_symbols @ i).key).count + 1;
				i := i + 1;
			end;
			l := (l + 3) // 4 * 4;
			!!sect_strtab_string.make(l);
			sect_strtab_string.append_character('%U');
			sect_strtab_string.append("eiffel.e");
			sect_strtab_string.append_character('%U');
			sect_strtab_string.append("fec compiled.");
			from
				i := 1
			until
				i > sorted_symbols.upper
			loop
				sym := sorted_symbols @ i;
				sym.set_number(i);
				sect_strtab_string.append_character('%U');
				sect_strtab_string.append(strings @ sym.key);
				i := i + 1;
			end;
			from
				sect_strtab_string.append_character('%U');
			until
				sect_strtab_string.count \\ 4 = 0
			loop
				sect_strtab_string.append_character('%U');
			end;
		ensure
			sect_strtab_string /= Void
		end; -- get_sect_strtab

	sect_strtab_string: STRING;
	
	sect_strtab_len: INTEGER is
		require
			sect_strtab_string /= Void
		do
			Result := sect_strtab_string.count;
		end; -- sect_strtab_len;

	write_sect_strtab is
		do
			obj_file.put_string(sect_strtab_string);
		end; -- write_sect_strtab
		
--------------------------------------------------------------------------------

	sect_rela_text_len: INTEGER is
		do
			Result := 12*text_relocs.count;
		end; -- sect_rela_text_len

	write_sect_rela_text is
		local
			i: INTEGER;
			reloc: RELOC;
		do
			from
				i := 1
			until
				i > text_relocs.count
			loop
				reloc := text_relocs @ i;
				write_word(reloc.offset); 
				write_word(256*(reloc.referenced_symbol.number+4)+reloc.type);
				write_word(reloc.addend);
				i := i + 1;
			end;
		end; -- write_sect_rela_text

--------------------------------------------------------------------------------

	sect_rela_rodata_len: INTEGER is
		do
			Result := 12*data_relocs.count;
		end; -- sect_rela_rodata_len

	write_sect_rela_rodata is
		local
			i: INTEGER;
			reloc: RELOC;
		do
			from
				i := 1
			until
				i > data_relocs.count
			loop
				reloc := data_relocs @ i;
				write_word(reloc.offset); 
				write_word(256*(reloc.referenced_symbol.number+4)+reloc.type);
				write_word(reloc.addend);
				i := i + 1;
			end;
		end; -- write_sect_rela_rodata

--------------------------------------------------------------------------------

-- here comes the best part:

	sect_comment_string: STRING is "Fridi's Eiffel for SPARC V0.0 17-2-97";
	
	sect_comment_len: INTEGER is 
		do
			Result := (sect_comment_string.count + 1 + 3) // 4 * 4;
		end;
 
	write_sect_comment is
		local
			i: INTEGER;
		do
			obj_file.put_string(sect_comment_string);
			from
				i := sect_comment_len - sect_comment_string.count
			until
				i = 0
			loop
				obj_file.put_character('%U');
				i := i - 1;
			end;
		end; -- write_sect_comment

--------------------------------------------------------------------------------

	write_section_header_table is 
		local
			offset: INTEGER;
		do
			write_word(0);	write_word(0); -- first entry
			write_word(0);	write_word(0);
			write_word(0);	write_word(0);
			write_word(0);	write_word(0);
			write_word(0);	write_word(0);
			
			offset := elf_header_size;

			write_word(sect_shstrtab_string.substring_index(".shstrtab",1)-1);
			write_word(sht_strtab);        -- type		
			write_word(0);                 -- flags
			write_word(0);                 -- addr
			write_word(offset);            -- offset
			write_word(sect_shstrtab_len); -- size
			write_word(0);                 -- link
			write_word(0);                 -- info
			write_word(1);                 -- align
			write_word(0);                 -- entity_size
			offset := offset + sect_shstrtab_len;
			
			write_word(sect_shstrtab_string.substring_index(".text",1)-1);
			write_word(sht_progbits);      -- type		
			write_word(shf_alloc+shf_execinstr); -- flags
			write_word(0);                 -- addr
			write_word(offset);            -- offset
			write_word(sect_text_len);     -- size
			write_word(0);                 -- link
			write_word(0);                 -- info
			write_word(4);                 -- align
			write_word(0);                 -- entity_size
			offset := offset + sect_text_len;
			
			write_word(sect_shstrtab_string.substring_index(".rodata",1)-1);
			write_word(sht_progbits);      -- type		
			write_word(shf_alloc);         -- flags
			write_word(0);                 -- addr
			write_word(offset);            -- offset
			write_word(sect_rodata_len);   -- size
			write_word(0);                 -- link
			write_word(0);                 -- info
			write_word(8);                 -- align
			write_word(0);                 -- entity_size
			offset := offset + sect_rodata_len;
			
			write_word(sect_shstrtab_string.substring_index(".bss",1)-1);
			write_word(sht_nobits);        -- type		
			write_word(shf_alloc+shf_write); -- flags
			write_word(0);                 -- addr
			write_word(0);                 -- offset
			write_word(bss_len);           -- size
			write_word(0);                 -- link
			write_word(0);                 -- info
			write_word(8);                 -- align
			write_word(0);                 -- entity_size
			-- offset remains unchanged for after bss section

			write_word(sect_shstrtab_string.substring_index(".symtab",1)-1);
			write_word(sht_symtab);        -- type		
			write_word(shf_alloc);         -- flags
			write_word(0);                 -- addr
			write_word(offset);            -- offset
			write_word(sect_symtab_len);   -- size
			write_word(6);                 -- link (section number of .strtab)
			write_word(5);                 -- info (index of first global symbol)
			write_word(4);                 -- align
			write_word(16);                -- entity_size
			offset := offset + sect_symtab_len;
			
			write_word(sect_shstrtab_string.substring_index(".strtab",1)-1);
			write_word(sht_strtab);        -- type		
			write_word(shf_alloc);         -- flags
			write_word(0);                 -- addr
			write_word(offset);            -- offset
			write_word(sect_strtab_len);   -- size
			write_word(0);                 -- link
			write_word(0);                 -- info
			write_word(1);                 -- align
			write_word(0);                 -- entity_size
			offset := offset + sect_strtab_len;
			
			write_word(sect_shstrtab_string.substring_index(".rela.text",1)-1);
			write_word(sht_rela);          -- type		
			write_word(shf_alloc);         -- flags
			write_word(0);                 -- addr
			write_word(offset);            -- offset
			write_word(sect_rela_text_len); -- size
			write_word(5);                 -- link
			write_word(2);                 -- info
			write_word(4);                 -- align
			write_word(12);                -- entity_size
			offset := offset + sect_rela_text_len;
			
			write_word(sect_shstrtab_string.substring_index(".rela.rodata",1)-1);
			write_word(sht_rela);          -- type		
			write_word(shf_alloc);         -- flags
			write_word(0);                 -- addr
			write_word(offset);            -- offset
			write_word(sect_rela_rodata_len);-- size
			write_word(5);                 -- link
			write_word(3);                 -- info
			write_word(4);                 -- align
			write_word(12);                -- entity_size
			offset := offset + sect_rela_rodata_len;
			
			write_word(sect_shstrtab_string.substring_index(".comment",1)-1);
			write_word(sht_progbits);      -- type		
			write_word(0);                 -- flags
			write_word(0);                 -- addr
			write_word(offset);            -- offset
			write_word(sect_comment_len);  -- size
			write_word(0);                 -- link
			write_word(0);                 -- info
			write_word(1);                 -- align
			write_word(0);                 -- entity_size
			offset := offset + sect_comment_len;
			
		end; -- write_section_header_table
		
--------------------------------------------------------------------------------

-- file usage

	obj_file: FRIDI_FILE_WRITE;
	
	write_word (i: INTEGER) is 
	-- write i as big endian 32-bit binary number to obj_file
		local
			c1,c2,c3,c4: CHARACTER;
			t: INTEGER;
		do
			if i<0 then
				t := -(i+1);  -- one's complement
				c4 := (255 - t \\ 256).to_character;
				t := t // 256;
				c3 := (255 - t \\ 256).to_character;
				t := t // 256;
				c2 := (255 - t \\ 256).to_character;
				t := t // 256;
				c1 := (255 - t).to_character;
			else
				t := i;
				c4 := (t \\ 256).to_character;
				t := t // 256;
				c3 := (t \\ 256).to_character;
				t := t // 256;
				c2 := (t \\ 256).to_character;
				t := t // 256;
				c1 := (t \\ 256).to_character;
			end;
			obj_file.put_character(c1);
			obj_file.put_character(c2);
			obj_file.put_character(c3);
			obj_file.put_character(c4);
		end; -- write_word

	write_half (i: INTEGER) is 
	-- write i as big endian 16-bit binary number to obj_file
		require
			i >= -(2^15);
			i < 2^15;
		local
			t: INTEGER;
			c1,c2: CHARACTER;
		do
			if i<0 then
				t := -(i+1);  -- one's complement
				c2 := (255 - t \\ 256).to_character;
				t := t // 256;
				c1 := (255 - t).to_character;
			else		
				t := i;
				c2 := (t \\ 256).to_character;
				t := t // 256;
				c1 := (t).to_character;
			end;
			obj_file.put_character(c1);
			obj_file.put_character(c2);
		end; -- write_half
		
	write_byte (i: INTEGER) is 
	-- write i as big endian 8-bit binary number to obj_file
		require
			i >= 0;
			i < 256;
		do
			obj_file.put_character(i.to_character);
		end; -- write_byte

	write_real (r: REAL) is 
	-- write ieee 32-real number
		do
			obj_file.put_real_bits(r);
		end; -- write_real

	write_double (d: DOUBLE) is 
	-- write ieee 32-real number
		do
			obj_file.put_double_bits(d);
		end; -- write_double

	write_const_string(str: STRING) is
		local
			j: INTEGER;
		do
			from
				j := 1
			until
				j > str.count
			loop
				obj_file.put_character(str @ j);
				j := j + 1;
			end; 
		end; -- write_const_string

	write_pads (n: INTEGER) is
	-- append n zero-bytes to obj_file.
		local
			i: INTEGER;
		do
			from
				i := n
			until 
				i <= 0
			loop
				obj_file.put_character('%/0/');
				i := i - 1;
			end;
		end; -- write_pads

--------------------------------------------------------------------------------

end -- MACHINE_CODE
