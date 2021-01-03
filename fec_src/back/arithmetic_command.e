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

class ARITHMETIC_COMMAND
-- Backend class specific for SUN/SPARC 

inherit
	MIDDLE_ARITHMETIC_COMMAND;
	SPARC_CONSTANTS;
	FRIDISYS;
	
--------------------------------------------------------------------------------

creation	{ RECYCLE_OBJECTS }
	clear
		
--------------------------------------------------------------------------------

feature { NONE }

	set_cc: BOOLEAN;   -- set condition codes?

--------------------------------------------------------------------------------

feature { RECYCLE_OBJECTS }

	clear is
		do
			next := Void;
			prev := Void;
			operator := 0; 
			dst := Void;
			src1 := Void;
			src2 := Void;
			const := 0
			set_cc := false;
		end; -- clear

--------------------------------------------------------------------------------

feature { BLOCK_SUCCESSORS }

	activate_set_cc is
		require
			can_set_cc
		do
			set_cc := true
		end; -- activate_set_cc
		
	can_set_cc: BOOLEAN is 
		do
			Result := operator = b_add or operator = b_sub;
		end; -- can_set_cc

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- FŸgt fŸr die Zielarchitektur nštige zusŠtzliche Befehle vor der Registervergabe
	-- ein
		local
			ari_cmd: ARITHMETIC_COMMAND;
			ass_cmd: ASSIGN_COMMAND;
			call_cmd: CALL_COMMAND;
			args: LIST[LOCAL_VAR];
			called,bn: INTEGER; 
			temp,swap: LOCAL_VAR;
		do
			if dst.type.is_real_or_double then

				-- nothing to be done here
				
			elseif is_integer_nop then

				ass_cmd := recycle.new_ass_cmd(dst,src1);
				block.insert(ass_cmd,Current);
				block.remove(Current);
			
			else
			
				-- convert
				--    mod    src1,2^n,dst
				-- to
				--    and    src1,2^n-1,dst
				if operator=b_mod and src2=Void then
					if bit_number(const)>=0 then
						const := const - 1;
						operator := b_and;
					end;
				end;
			
				-- load constant in register if it does not fit into simm13:
				if src2=Void then
					if const<simm13_min or const>simm13_max then
						load_const_into_register(code,block);
					end; 
				end;
				 
				-- convert 
				--    subf  src1,src2/const,dst
				-- to 
				--   [ld    const, src2]
				--    sub   src2,src1,dst
				-- (this is necessary since SPARC does not provide "subtract-from-constant" 
				-- but only subtract (which could be done using add -const).
				if operator = b_subf then
					if src2 = Void then
						load_const_into_register(code,block);
					end;
					swap := src2;
					src2 := src1;
					src1 := swap;
					operator := b_sub;
				end;
				
				-- convert
				--    nand  src1,src2/const,dst
				-- to
				--    and   src1,src2/const,dst
				--    xnor  dst,0,dst
				-- (SPARC does not provide nand)
				if operator = b_nand then
					operator := b_and;
					ari_cmd := recycle.new_ari_cmd;
					ari_cmd.make_binary_const(b_eqv,dst,dst,const);
					block.insert(ari_cmd,next);
				end;
				
				-- convert
				--    nor   src1,src2/const,dst
				-- to
				--    or    src1,src2/const,dst
				--    xnor  dst,0,dst
				-- (SPARC does not provide nor)
				if operator = b_nor then
					operator := b_or;
					ari_cmd := recycle.new_ari_cmd;
					ari_cmd.make_binary_const(b_eqv,dst,dst,const);
					block.insert(ari_cmd,next);
				end;

				-- convert
				--    mul   src1,2^n,dst
				-- to
				--    sll   src1,n,dst	
				if operator = b_mul and then src2 = Void then
					bn := bit_number(const);
					if bn >= 0 then
						operator := b_shift_left; 
						const := bn;
					end;
				end;
				
				-- convert
				--    div   src1,2^n,dst
				-- to
				--    sra   src1,n,dst	
				if operator = b_div and then src2 = Void then
					bn := bit_number(const);
					if bn >= 0 then
						operator := b_shift_right; 
						const := bn;
					end;
				end;

				-- convert
				--    mul/div/mod    src1,src2/const,dst
				-- to
				--    dst := .mul/.div/.rem(src1,src2/const);
				inspect operator
				when b_mul, b_div, b_mod then
					if src2=Void then
						load_const_into_register(code,block);
					end;
					inspect operator
					when b_mul then called := globals.string_dot_mul;
					when b_div then called := globals.string_dot_div;
					when b_mod then called := globals.string_dot_rem;
					end;
					args := recycle.new_args_list;
					args.add(src1);
					args.add(src2);
					call_cmd := recycle.new_call_cmd;
					call_cmd.make_static(code,called,args,globals.local_integer);
					temp := call_cmd.result_local;
					block.insert_and_expand(code,call_cmd,Current);
					ass_cmd := recycle.new_ass_cmd(dst,temp);
					block.insert(ass_cmd,Current);
					block.remove(Current);
				else
				end;
				
			end;
			
		ensure then
			block.has(Current) implies
				operator /= b_nand and
				operator /= b_nor  and
				operator /= b_mod  and
				operator /= b_subf and
				(src2 = Void implies 
					const >= simm13_min and
					const <= simm13_max)
		end; -- expand

feature { NONE }

	load_const_into_register (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- load constant operand into local variable (used if it cannot be provided as
	-- an immediate value to the command)
		require
			src2 = Void;
		local
			ass_const_cmd: ASSIGN_CONST_COMMAND;
		do
			if const = 0 then
				src2 := code.registers @ g0;
			else
				src2 := recycle.new_local(code,globals.local_integer);
				ass_const_cmd := recycle.new_ass_const_cmd;
				ass_const_cmd.make_assign_const_int(src2,const);
				block.insert(ass_const_cmd,Current);
			end;
		ensure 
			src2 /= Void;
		end;  -- load_const_into_register

	is_integer_nop: BOOLEAN is
	-- true if this command has no effect
		require
			dst.type.is_word;
		do
			if src2 = Void then
				if const = 0 then
					inspect operator
					when b_add,
					     b_sub,
					     b_or,  
					     b_nor, 
					     b_xor, 
					     b_nimplies 
					then Result := true
					else
					end;
				elseif const = 1 then
					inspect operator
					when b_mul, 
					     b_div 
					then Result := true
					else
					end;
				elseif const = -1 then
					inspect operator
					when b_and, 
					     b_nand 
					then Result := true
					else
					end;
				end;
			end;
		end; -- is_integer_nop

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt nötige Befehle nach der Registervergabe ein und entfernt unnötige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
		do
			if dst.type.is_real_or_double then
				expand2_for_real_or_double(code,block);
			else
				expand2_for_integer(code,block);
			end;
		ensure then
			not block.has(Current) or
			(dst.gp_register >= 0 or dst.type.is_real_or_double and
			 src1.gp_register >= 0 or src1.type.is_real_or_double and
			 (src2 /= Void implies (src2.gp_register >= 0 or src2.type.is_real_or_double)));
		end; -- expand2
		
--------------------------------------------------------------------------------

feature { NONE }

	expand2_for_integer (code: ROUTINE_CODE; block: BASIC_BLOCK) is
		local
			ass_const_cmd: ASSIGN_CONST_COMMAND;
		do
			-- convert 
			--    add   src1,reg3/const,reg1
			-- to 
			--    ld    src1, temp1_reg
			--    add   temp1_reg,reg3/const,reg1
			--
			if src1.gp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(code.temp1_register,src1),Current);
				src1 := code.temp1_register;
			end;
		
			-- convert 
			--    add   reg2,src2,reg1
			-- to 
			--    ld    src2, temp2_reg
			--    add   reg2,temp2_reg,reg1
			--
			if src2 /= Void and then src2.gp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(code.temp2_register,src2),Current);
				src2 := code.temp2_register;
			end;
			
			-- convert
			--    add   reg2,reg3/const,dst
			-- to
			--    add   reg2,reg3/const,temp1_reg
			--    st    temp1_reg, dst
			if dst.gp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(dst,code.temp1_register),next);
				dst := code.temp1_register;
			end;
				
			-- worst case converts
			--    add   src1,src2,dst
			-- to
			--    ld    src1,temp1_reg
			--    ld    src2,temp2_reg
			--    add   temp1_reg,temp2_reg,temp1_reg
			--    st    temp1_reg,dst
		ensure
			src1.gp_register >= 0;
			src2 /= Void implies src2.gp_register >= 0;
			dst .gp_register >= 0;
		end; -- expand2_for_integer

--------------------------------------------------------------------------------

	expand2_for_real_or_double (code: ROUTINE_CODE; block: BASIC_BLOCK) is
		local
			tmp1,tmp2: LOCAL_VAR;
			ass_cmd: ASSIGN_COMMAND;
		do
			if dst.type.is_real then
				tmp1 := code.f_temp1_register;
				tmp2 := code.f_temp2_register;
			else
				tmp1 := code.df_temp1_register;
				tmp2 := code.df_temp2_register;
			end;
			
			-- convert 
			--    fadd   src1,reg3,reg1
			-- to 
			--    ld[d]f src1, [d]f_temp1_reg
			--    fadd   [d]f_temp1_reg,reg3,reg1
			--
			if src1.fp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(tmp1,src1),Current);
				src1 := tmp1;
			end;
		
			-- convert 
			--    fadd   reg2,src2,reg1
			-- to 
			--    ld[d]f src2, [d]f_temp2_reg
			--    fadd   reg2,[d]f_temp2_reg,reg1
			--
			if src2 /= Void and then src2.fp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(tmp2,src2),Current);
				src2 := tmp2;
			end;
			
			-- convert
			--    fadd   reg2,reg3,dst
			-- to
			--    fadd   reg2,reg3,[d]f_temp1_reg
			--    st[d]f [d]f_temp1_reg, dst
			if dst.fp_register < 0 then
				block.insert_and_expand2(code,recycle.new_ass_cmd(dst,tmp1),next);
				dst := tmp1;
			end;
				
			-- worst case converts
			--    fadd   src1,src2,dst
			-- to
			--    ldf    src1,f_temp1
			--    ldf    src2,f_temp2_reg
			--    fadd   f_temp1_reg,f_temp2_reg,f_temp1_reg
			--    stf    f_temp1_reg,dst
			
			if src1.type.is_double and (operator = u_neg or operator = u_abs) then
				-- SPARC V8 cannot neg or move doubles!
				ass_cmd := recycle.new_ass_cmd(code.fp_registers @ (dst .fp_register + 1),
				                               code.fp_registers @ (src1.fp_register + 1));
				block.insert_and_expand2(code,ass_cmd,next);
				src1 := code.fp_registers @ src1.fp_register;
				dst  := code.fp_registers @ dst .fp_register;
			end;
		ensure
			block.has(Current) implies
				src1.fp_register >= 0 and 
				(src2 /= Void implies src2.fp_register >= 0) and
				dst.fp_register >= 0 and
				((operator = u_neg or operator = u_abs) implies
					not src1.type.is_double and 
					not dst .type.is_double); 
		end; -- expand2_for_real_or_double

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }
		
	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		local
			rs1_v,rs2_v,rd_v,frs1_v,frs2_v,frd_v,opf_v,cc,opf_sd: INTEGER;
		do
			if dst.type.is_real_or_double then
				frs1_v := src1.fp_register;
				frd_v  := dst .fp_register;
				if dst.type.is_real then opf_sd := opf_single
				                    else opf_sd := opf_double  
				                     -- this case does does not occur (it is excluded by 
				                     -- expand2's postcondition), but it should work on SPARC V9
				end;
				if operator = u_neg or operator = u_abs then
					if operator = u_neg then opf_v := opf_neg
					                    else opf_v := opf_abs
					end;
					mc.asm_fari2(opf_v+opf_sd,src1.fp_register,dst.fp_register);
				else
					frs2_v := src2.fp_register;
					inspect operator
					when b_add then opf_v := opf_add;
					when b_sub then opf_v := opf_sub;
					when b_mul then opf_v := opf_mul;
					when b_div then opf_v := opf_div;
					end;
					mc.asm_fari(opf_v+opf_sd,frs1_v,frs2_v,frd_v);
				end;
			else
				rs1_v := src1.gp_register;
				rd_v := dst.gp_register;
				if set_cc then
					cc := op3_cc
				else
					cc := 0
				end;
				if src2=Void then
					inspect operator
					when b_add         then mc.asm_ari_imm(op3_add +cc,rs1_v,const,rd_v);
					when b_sub         then mc.asm_ari_imm(op3_sub +cc,rs1_v,const,rd_v);
					when b_and         then mc.asm_ari_imm(op3_and +cc,rs1_v,const,rd_v);
					when b_or          then mc.asm_ari_imm(op3_or  +cc,rs1_v,const,rd_v);
					when b_xor         then mc.asm_ari_imm(op3_xor +cc,rs1_v,const,rd_v);
					when b_eqv         then mc.asm_ari_imm(op3_xnor+cc,rs1_v,const,rd_v);
					when b_implies     then mc.asm_ari_imm(op3_orn +cc,rs1_v,const,rd_v);
					when b_nimplies    then mc.asm_ari_imm(op3_andn+cc,rs1_v,const,rd_v);
					when b_shift_left  then mc.asm_ari_imm(op3_sll +cc,rs1_v,const,rd_v);
					when b_shift_right then mc.asm_ari_imm(op3_sra +cc,rs1_v,const,rd_v);
					end;
				else
					rs2_v := src2.gp_register;
					inspect operator
					when b_add          then mc.asm_ari_reg(op3_add +cc,rs1_v,rs2_v,rd_v);
					when b_sub          then mc.asm_ari_reg(op3_sub +cc,rs1_v,rs2_v,rd_v);
					when b_and          then mc.asm_ari_reg(op3_and +cc,rs1_v,rs2_v,rd_v);
					when b_or           then mc.asm_ari_reg(op3_or  +cc,rs1_v,rs2_v,rd_v);
					when b_xor          then mc.asm_ari_reg(op3_xor +cc,rs1_v,rs2_v,rd_v);
					when b_eqv          then mc.asm_ari_reg(op3_xnor+cc,rs1_v,rs2_v,rd_v);
					when b_implies      then mc.asm_ari_reg(op3_orn +cc,rs1_v,rs2_v,rd_v);
					when b_nimplies     then mc.asm_ari_reg(op3_andn+cc,rs1_v,rs2_v,rd_v);
					when b_shift_left   then mc.asm_ari_reg(op3_sll +cc,rs1_v,rs2_v,rd_v);
					when b_shift_right  then mc.asm_ari_reg(op3_sra +cc,rs1_v,rs2_v,rd_v);
					end;
				end;
			end;
		end; -- create_machine_code

--------------------------------------------------------------------------------
		
	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			if set_cc then
				inspect operator
				when b_add      then write_string("addcc   "); 
				when b_subf     then write_string("subfcc  ");
				when b_sub      then write_string("subcc   ");
				when b_mul      then write_string("mulcc   ");
				when b_div      then write_string("divcc   ");
				when b_mod      then write_string("modcc   ");
				when b_and      then write_string("andcc   ");
				when b_nand     then write_string("nandcc  ");
				when b_or       then write_string("orcc    ");
				when b_nor      then write_string("norcc   ");
				when b_xor      then write_string("xorcc   ");
				when b_eqv      then write_string("eqvcc   ");
				when b_implies  then write_string("orncc   ");
				when b_nimplies then write_string("andncc  ");
				end;
			else
				inspect operator
				when b_add      then write_string("add     "); 
				when b_subf     then write_string("subf    ");
				when b_sub      then write_string("sub     ");
				when b_mul      then write_string("mul     ");
				when b_div      then write_string("div     ");
				when b_mod      then write_string("mod     ");
				when b_and      then write_string("and     ");
				when b_nand     then write_string("nand    ");
				when b_or       then write_string("or      ");
				when b_nor      then write_string("nor     ");
				when b_xor      then write_string("xor     ");
				when b_eqv      then write_string("eqv     ");
				when b_implies  then write_string("orn     ");
				when b_nimplies then write_string("andn    ");
				when b_shift_left  then write_string("sll     ");
				when b_shift_right then write_string("sra     ");
				end;
			end;
			src1.print_local; write_string(",");
			if src2/=Void then
				src2.print_local
			else
				write_integer(const);
			end;
			write_string(","); 
			dst.print_local;
			write_string("%N"); 
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- ARITHMETIC_COMMAND
