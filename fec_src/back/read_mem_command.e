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

class READ_MEM_COMMAND

inherit
	MIDDLE_READ_MEM_COMMAND
		redefine
			remove_assigns_to_dead
		end;
	SPARC_CONSTANTS;
	DATATYPE_SIZES;

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
			dst := Void;
			src1 := Void;
			src2 := Void;
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

	remove_assigns_to_dead (alive: SET; block: BASIC_BLOCK) is
	-- Entfernt unnötige Zuweisungen an tote Variablen, insbesondere
	-- unnötige Initialisierungen
		do
			if dst.gp_register < 0 and then not alive.has(dst.number) then
				block.remove(Current);
			else
				get_alive(alive);
		   end;
		end; -- remove_assigns_to_dead

--------------------------------------------------------------------------------

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- FŸgt nštige Befehle nach der Registervergabe ein und entfernt unnštige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
		local
			sethi_cmd: SETHI_COMMAND;
			temp: LOCAL_VAR;
			read_mem_cmd: READ_MEM_COMMAND;
		do
			if dst.gp_register < 0 and then dst.fp_register < 0 then
				if     dst.type.is_word   then temp := code.   temp1_register;
				elseif dst.type.is_real   then temp := code. f_temp1_register;
				elseif dst.type.is_double then temp := code.df_temp1_register;
				                          else temp := code. c_temp1_register;
				end;
				block.insert_and_expand2(code,recycle.new_ass_cmd(dst,temp),next);
				dst := temp;
			end;

			if src1 /= Void and then src1.gp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(code.temp1_register,src1),Current);
				src1 := code.temp1_register;
			end;

			if src2 /= Void and then src2.gp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(code.temp2_register,src2),Current);
				src2 := code.temp2_register;
			end;
			
			-- for read global create
			--     sethi   hi(global),src1
			--     ld      src1+lo(global),dst
			--
			if is_global then
				if dst.gp_register >= 0 then
					src1 := dst; -- use dst-register if possible to enhance insn-scheduler
				else
					src1 := code.temp1_register;
				end;			
				sethi_cmd := recycle.new_sethi_cmd;
				sethi_cmd.make_reloc(label,src1.gp_register,0);
				block.insert(sethi_cmd,Current);
				is_reloc_lo10 := true;
				offset := 0;
			end;
			
			-- Read double might read the value from an unaligned address (this 
			-- is caused by the strange SPARC ABI definition), so in this case
			-- we'll have to do two loads:
			if dst.type.is_double and then 
				is_offset_indirect and then
				offset // 4 \\ 2 /= 0
			then -- misaligned load double
				read_mem_cmd := recycle.new_read_mem_cmd;
				read_mem_cmd.make_read_offset(code.fp_registers @ dst.fp_register,offset,label,src1); 
				block.insert(read_mem_cmd,Current);
				offset := offset + real_size;
				dst := code.fp_registers @ (dst.fp_register+1);
			end;

		ensure then
			not is_global;
			src1.gp_register >= 0;
			src2 /= Void implies src2.gp_register >= 0;
			dst.gp_register >= 0 or dst.fp_register >= 0;
			dst.type.is_double and is_offset_indirect implies offset // 4 \\ 2 = 0
		end; -- expand2
		
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		local
			op3_v,rd_v,rs1_v,rs2_v,frd_v: INTEGER;
		do
			if     dst.type.is_real   then op3_v := op3_ldf
			elseif dst.type.is_double then op3_v := op3_lddf
			elseif dst.type.is_word   then op3_v := op3_lduw
				                       else op3_v := op3_ldub  -- char or boolean
			end;
			frd_v := dst.fp_register;
			rd_v  := dst.gp_register;  -- this is -1 for real/double
			rs1_v := src1.gp_register;
			if is_offset_indirect then
				if label /= 0 then
					if is_reloc_lo10 then mc.reloc_lo10(mc.pc,label,0);
					                 else mc.reloc_13  (mc.pc,label);
					end;
				end;
				if rd_v >= 0 then mc.asm_ld_imm (op3_v,rs1_v,offset, rd_v)
				             else mc.asm_ldf_imm(op3_v,rs1_v,offset,frd_v) 
				end;
			else -- indexed
				rs2_v := src2.gp_register;
				if rd_v >= 0 then mc.asm_ld_reg (op3_v,rs1_v,rs2_v, rd_v) 
				             else mc.asm_ldf_reg(op3_v,rs1_v,rs2_v,frd_v) 
				end;
			end;
		end; -- create_machine_code

--------------------------------------------------------------------------------

	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			write_string("ld      ");
			if is_offset_indirect then
				write_integer(offset); write_string("("); src1.print_local; write_string(")");
			else
				src1.print_local; write_string("+"); src2.print_local;
			end;
			write_string(","); 
			dst.print_local;
			write_string("%N");
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- READ_MEM_COMMAND
