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

class ASSIGN_CONST_COMMAND

inherit
	MIDDLE_ASSIGN_CONST_COMMAND
		redefine
			remove_assigns_to_dead
		end;
	SPARC_CONSTANTS;
	DATATYPE_SIZES;
	COMMANDS;

creation { RECYCLE_OBJECTS }
	clear

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
		do
			-- nothing to be done here
		end; -- expand

--------------------------------------------------------------------------------

	remove_assigns_to_dead (alive: SET; block: BASIC_BLOCK) is
	-- Entfernt unnûtige Zuweisungen an tote Variablen, insbesondere
	-- unnûtige Initialisierungen
		do
			if dst.gp_register < 0 and then  
				dst.fp_register < 0 and then -- test if dst is a normal local var, not %o0,... for result, arguments etc.
			   not alive.has(dst.number) 
			then
				block.remove(Current);
			else
				get_alive(alive);
		   end;
		end; -- remove_assigns_to_dead

--------------------------------------------------------------------------------

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- FÄgt nûtige Befehle nach der Registervergabe ein und entfernt unnûtige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
		local
			setlo_cmd: SETLO_COMMAND;
			sethi_cmd: SETHI_COMMAND;
			hi,lo, addend: INTEGER;
			ari_cmd: ARITHMETIC_COMMAND;
			fp_adr: INTEGER;
			const_real_symbol: INTEGER;
			temp: LOCAL_VAR;
		do
			if dst.type.is_real_or_double then
				fp_adr := code.temp1_register.gp_register;
				fp_adr_reg := fp_adr;
				if dst.type.is_real then
					addend := real_size * code.class_code.const_reals.count;
					code.class_code.const_reals.add(const_real.to_real);
					temp := code.f_temp1_register;
					const_real_symbol := const_reals_name(code.class_code.actual_class.name);
				else
					addend := double_size * code.class_code.const_doubles.count;
					code.class_code.const_doubles.add(const_real)
					temp := code.df_temp1_register;
					const_real_symbol := const_doubles_name(code.class_code.actual_class.name);
				end;
				if dst.fp_register < 0 then
					block.insert_and_expand2(code,recycle.new_ass_cmd(dst,temp),next);
					dst := temp;
				end;
				sethi_cmd := recycle.new_sethi_cmd;
				sethi_cmd.make_reloc(const_real_symbol,fp_adr,addend);
				block.insert(sethi_cmd,Current);
				setlo_cmd := recycle.new_setlo_cmd;
				setlo_cmd.make_reloc(const_real_symbol,fp_adr,addend);
				block.insert(setlo_cmd,Current);
			else
				if dst.gp_register < 0 then
					block.insert_and_expand2(code,recycle.new_ass_cmd(dst,code.temp1_register),next);
					dst := code.temp1_register;
				end;
				if symbol /= 0 then
					sethi_cmd := recycle.new_sethi_cmd;
					sethi_cmd.make_reloc(symbol,dst.gp_register,const);   -- set upper 22 bits
					block.insert(sethi_cmd,Current);
					setlo_cmd := recycle.new_setlo_cmd;
					setlo_cmd.make_reloc(symbol,dst.gp_register,const);   -- set lower 10 bits
					block.insert(setlo_cmd,Current);
					block.remove(Current);
				elseif const<simm13_min or const>simm13_max then
					hi := hi22(const);
					lo := lo10(const);
					sethi_cmd := recycle.new_sethi_cmd;
					sethi_cmd.make(hi,dst.gp_register);      -- set upper 22 bits
					block.insert(sethi_cmd,Current);
					if lo/=0 then                  -- set lower 10 bits if necessary
						ari_cmd := recycle.new_ari_cmd; 
						ari_cmd.make_binary_const(b_or,dst,dst,lo);
						block.insert(ari_cmd,Current);
					end;	
					block.remove(Current);
					const := 0;
				end;
			end;
		ensure then
			dst.type.is_real_or_double or 
			(dst.gp_register >= 0 and 
			 const >= simm13_min and
			 const <= simm13_max)
		end; -- expand2
		
--------------------------------------------------------------------------------

feature { NONE }

	fp_adr_reg: INTEGER;  -- GP register to store adr of constant real or double

feature { BASIC_BLOCK }

	create_machine_code (mc: MACHINE_CODE) is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			if dst.type.is_real_or_double then
				if dst.type.is_real then
					mc.asm_ldf_imm(op3_ldf,fp_adr_reg,0,dst.fp_register);
				else -- is_double
					mc.asm_ldf_imm(op3_lddf,fp_adr_reg,0,dst.fp_register);
				end;
			else
				mc.asm_ari_imm(op3_or,g0,const,dst.gp_register);
			end;
		end; -- create_machine_code

--------------------------------------------------------------------------------

	print_machine_code is
	-- erzeugt den Current entsprechenden Maschinenbefehl.
		do
			if dst.type.is_real then
				write_string("mov     "); write_string("real,"); dst.print_local; 
			elseif dst.type.is_double then
				write_string("mov     "); write_string("double,"); dst.print_local; 
			else
				write_string("mov     "); write_integer(const); write_string(","); dst.print_local;
			end;
			write_string("%N");
		end; -- print_machine_code

--------------------------------------------------------------------------------

end -- ASSIGN_CONST_COMMAND
