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

class WRITE_MEM_COMMAND

inherit
	MIDDLE_WRITE_MEM_COMMAND;
	SPARC_CONSTANTS;
	DATATYPE_SIZES;
	COMMANDS;

creation { RECYCLE_OBJECTS }
	clear

--------------------------------------------------------------------------------

feature { NONE }

	is_reloc_lo10: BOOLEAN;  -- set for lo10-reloc while is_offset_indirect. 
	                         -- else sparc_13 relocation is used.

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is
		do
			next := Void;
			prev := Void;
			dst1 := Void;
			dst2 := Void;
			src := Void;
			offset := 0;
			label := 0;
			is_reloc_lo10 := false;
		end; -- clear

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
		do
			-- nothing to be done here
		end; -- expand

--------------------------------------------------------------------------------

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt nötige Befehle nach der Registervergabe ein und entfernt unnötige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
		local 
			temp: LOCAL_VAR;
			ari_cmd: ARITHMETIC_COMMAND;
			sethi_cmd: SETHI_COMMAND;
			write_mem_cmd: WRITE_MEM_COMMAND;
		do
		
			if dst1 /= Void and then dst1.gp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(code.temp1_register,dst1),Current);
				dst1 := code.temp1_register;
			end;
			
			if dst2 /= Void and then dst2.gp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(code.temp2_register,dst2),Current);
				dst2 := code.temp2_register;
			end;
			
			if src.gp_register < 0 and then src.fp_register < 0 then
				if     src.type.is_real   then
					temp := code.f_temp1_register;
				elseif src.type.is_double then
					temp := code.df_temp1_register;
				else
					-- find a free temp-reg for src:
					if dst1 = code.temp1_register then
						if dst2 = code.temp2_register then
							-- both temps used, then create offset indirect:
							ari_cmd := recycle.new_ari_cmd;
							ari_cmd.make_binary(b_add,dst1,dst1,dst2);
							block.insert(ari_cmd,Current);
							dst2 := Void;  -- change effective address to 0(dst1)
							offset := 0; 
							label := 0;
						end;
						if src.type.is_word then temp := code.  temp2_register;
						                    else temp := code.c_temp2_register;
						end;
					else
						if src.type.is_word then temp := code.  temp1_register;
						                    else temp := code.c_temp1_register;
						end;
					end;
				end;
				block.insert_and_expand2(code,recycle.new_ass_cmd(temp,src),Current);
				src := temp;
			end;
			
			-- for write global create
			--     sethi   hi(global),dst1
			--     st      src,dst1+lo(global)
			-- 
			if is_global then
				dst1 := code.temp1_register;
				sethi_cmd := recycle.new_sethi_cmd;
				sethi_cmd.make_reloc(label,dst1.gp_register,0);
				block.insert(sethi_cmd,Current);
				is_reloc_lo10 := true;
			end;
			
			-- Write doubles might write the value to an unaligend address (this
			-- is caused by the strange SPARC ABI definition), so in this case 
			-- we'll have to do two stores:
			if src.type.is_double and then
				is_offset_indirect and then
				offset // 4 \\ 2 /= 0
			then -- misaligned store double
				write_mem_cmd := recycle.new_write_mem_cmd;
				write_mem_cmd.make_write_offset(offset,label,dst1,code.fp_registers @ src.fp_register);
				block.insert(write_mem_cmd,Current);
				offset := offset + real_size;
				src := code.fp_registers @ (src.fp_register+1);
			end;
			
		ensure then
			not is_global;
			dst1.gp_register >= 0;
			dst2 /= Void implies dst2.gp_register >= 0;
			src.gp_register >= 0 or src.fp_register >= 0;
			src.type.is_double and is_offset_indirect implies offset // 4 \\ 2 = 0
		end; -- expand2

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		local
			op3_v,rs_v,frs_v,rd1_v,rd2_v: INTEGER;
		do
			if     src.type.is_real   then op3_v := op3_stf
			elseif src.type.is_double then op3_v := op3_stdf
			elseif src.type.is_word   then op3_v := op3_stw
				                       else op3_v := op3_stb  -- char or boolean
			end;
			frs_v := src.fp_register;
			rs_v := src.gp_register;
			rd1_v := dst1.gp_register;
			if is_offset_indirect then
				if label /= 0 then
					if is_reloc_lo10 then mc.reloc_lo10(mc.pc,label,0);
					                 else mc.reloc_13  (mc.pc,label);
					end;
				end;
				if rs_v >= 0 then mc.asm_st_imm (op3_v, rs_v,rd1_v,offset)
				             else mc.asm_stf_imm(op3_v,frs_v,rd1_v,offset)
				end;
			else -- indexed
				rd2_v := dst2.gp_register;
				if rs_v >= 0 then mc.asm_st_reg (op3_v, rs_v,rd1_v,rd2_v)
				             else mc.asm_stf_reg(op3_v,frs_v,rd1_v,rd2_v)
				end;
			end;
		end; -- create_machine_code

--------------------------------------------------------------------------------

	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			write_string("st      "); 		
			src.print_local;
			write_string(",");
			if is_offset_indirect then
				write_integer(offset); if label/=0 then write_string("+"); print_label end; write_string("("); dst1.print_local; write_string(")"); 
			else
				write_string("("); dst1.print_local; write_string("+"); dst2.print_local; write_string(")"); 
			end;
			write_string("%N"); 
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- WRITE_MEM_COMMAND
