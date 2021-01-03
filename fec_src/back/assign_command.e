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

class ASSIGN_COMMAND

inherit
	MIDDLE_ASSIGN_COMMAND
		redefine
			remove_assigns_to_dead
		end;
	SPARC_CONSTANTS;

creation { RECYCLE_OBJECTS }
	clear

--------------------------------------------------------------------------------


feature { RECYCLE_OBJECTS }

	clear is
		do
			next := Void;
			prev := Void;
			src := Void;
			dst := Void;
			src_is_integer := false;
			dst_is_integer := false;
		end; -- clear

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
		local
			temp: LOCAL_VAR;
			ass_cmd: ASSIGN_COMMAND;
		do
			if src.type.is_word and then dst.type.is_real_or_double then
				-- conversiont int -> real requires storing src in memory first
				-- src(int/gp_reg) -> temp (int/memory) -> dst(real/fp_reg)
				temp := recycle.new_local(code,src.type);
				temp.set_must_not_be_register;
				block.insert(recycle.new_ass_cmd(temp,src),Current);
				src := temp;
			elseif src.type.is_real_or_double and then dst.type.is_word then
				-- conversiont real -> int requires storing converted src in memory
				-- src(real/fp_reg) -> temp (int/memory) -> dst (int/gp_reg)
				temp := recycle.new_local(code,dst.type);
				temp.set_must_not_be_register;
				block.insert(recycle.new_ass_cmd(dst,temp),next);
				dst := temp;
			end;
		ensure then
			src.type.is_word and dst.type.is_real_or_double implies src.must_not_be_register;
			dst.type.is_word and src.type.is_real_or_double implies dst.must_not_be_register;
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
	-- Stellt sicher, dass beide Operanden Register sind.
		local
			read_mem_cmd: READ_MEM_COMMAND;
			write_mem_cmd: WRITE_MEM_COMMAND;
			ass_cmd: ASSIGN_COMMAND;
			temp: LOCAL_VAR;
			src_type, dst_type: LOCAL_TYPE;
		do
			src_type := src.type;
			dst_type := dst.type;
			if src_type.is_real_or_double or
			   dst_type.is_real_or_double 
			then 
				src_is_integer := src_type.is_word;
				dst_is_integer := dst_type.is_word;
				if src_is_integer or src.fp_register < 0 then
					if src_type.is_double then temp := code.df_temp1_register
					                      else temp := code. f_temp1_register
					end;
					read_mem_cmd := recycle.new_read_mem_cmd;
					read_mem_cmd.make_read_offset(temp,
					                              src.stack_position,
					                              0,
					                              code.registers @ (src.sp_or_fp));
					block.insert(read_mem_cmd,Current);
					src := temp;
				end;
				if dst_is_integer or dst.fp_register < 0 then
					if dst_type.is_double then temp := code.df_temp1_register
					                      else temp := code. f_temp1_register
					end;
					write_mem_cmd := recycle.new_write_mem_cmd;
					write_mem_cmd.make_write_offset(dst.stack_position,
					                                0,
					                                code.registers @ (dst.sp_or_fp),
					                                temp);
					block.insert(write_mem_cmd,next);
					dst := temp;
				end;
				if src_type = dst_type and src.fp_register = dst.fp_register then 
					-- remove unneccessary move without conversion and same src and dst
					block.remove(Current);
				elseif src_type.is_double and src_type = dst_type then
					-- its sad, but SPARC V8 cannot move doubles, so we move two singles:
					ass_cmd := recycle.new_ass_cmd(code.fp_registers @ (dst.fp_register+1),
					                               code.fp_registers @ (src.fp_register+1));
					block.insert(ass_cmd,next);
					src := code.fp_registers @ src.fp_register;
					dst := code.fp_registers @ dst.fp_register;
				end;
			else
				if src.gp_register < 0 then
					if src_type.is_word then temp := code.  temp1_register
					                    else temp := code.c_temp1_register
					end;
					read_mem_cmd := recycle.new_read_mem_cmd;
					read_mem_cmd.make_read_offset(temp,
					                              src.stack_position,
					                              0,
					                              code.registers @ (src.sp_or_fp));
					block.insert(read_mem_cmd,Current);
					src := temp;
				end;
				if dst.gp_register < 0 then
					if dst_type.is_word then temp := code.  temp1_register
					                    else temp := code.c_temp1_register
					end;
					write_mem_cmd := recycle.new_write_mem_cmd;
					write_mem_cmd.make_write_offset(dst.stack_position,
					                                0,
					                                code.registers @ (dst.sp_or_fp),
					                                temp);
					block.insert_and_expand2(code,write_mem_cmd,next);
					dst := temp;
				end; 
				if dst.gp_register >= 0 and then src.gp_register = dst.gp_register then
				-- remove redundant "move %rx,%rx":
					block.remove(Current);
				end;
			end;
		ensure then
			block.has(Current) implies
				(src.gp_register >= 0 or src.fp_register >= 0) and 
				(dst.gp_register >= 0 or dst.fp_register >= 0) and
				(src.type.is_real_or_double = dst.type.is_real_or_double) and
				not (src.type.is_double and dst.type.is_double);
		end; -- expand2

feature { NONE }

	src_is_integer: BOOLEAN;  -- true for an integer value in src.fp_register
	dst_is_integer: BOOLEAN;  -- true for an integer value in dst.fp_register

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		local
			opf_v: INTEGER;
		do
			if src.type.is_real_or_double or
			   dst.type.is_real_or_double
			then
				if     src_is_integer     then if dst.type.is_real then opf_v := opf_itos
					                                                else opf_v := opf_itod end
				elseif dst_is_integer     then if src.type.is_real then opf_v := opf_stoi
				                                                   else opf_v := opf_dtoi end
				elseif src.type.is_real   then if dst.type.is_real then opf_v := opf_movs
				                                                   else opf_v := opf_stod end
				elseif src.type.is_double then if dst.type.is_real then opf_v := opf_dtos
				                                                   else -- this case is excluded by expand2's postcondition
				                                                   end
				end;                                          
				mc.asm_fari2(opf_v,src.fp_register,dst.fp_register);
			else
				mc.asm_ari_reg(op3_or,0,src.gp_register,dst.gp_register);
			end;
		end; -- create_machine_code

--------------------------------------------------------------------------------

	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			write_string("%Tmov     "); src.print_local; write_string(","); dst.print_local;
			write_string("%N");
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- ASSIGN_COMMAND
