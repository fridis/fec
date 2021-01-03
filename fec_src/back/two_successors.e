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

class TWO_SUCCESSORS

inherit
	MIDDLE_TWO_SUCCESSORS;
	COMMANDS;
	SPARC_CONSTANTS;

creation { RECYCLE_OBJECTS }
	clear
	
--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	expand (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt für die Zielarchitektur nötige zusätzliche Befehle vor der Registervergabe
	-- ein
		local
			ass_const_cmd: ASSIGN_CONST_COMMAND;
		do
			if test2 = Void then
				if const_test2<simm13_min or const_test2>simm13_max then
					test2 := recycle.new_local(code,globals.local_integer);
					ass_const_cmd := recycle.new_ass_const_cmd;
					ass_const_cmd.make_assign_const_int(test2,const_test2);
					block.add_tail(ass_const_cmd);
				end; 
			end;
		ensure then
			test2 = Void implies (const_test2>=simm13_min and const_test2<=simm13_max)
		end; -- expand

--------------------------------------------------------------------------------

	expand2 (code: ROUTINE_CODE; block: BASIC_BLOCK) is
	-- Fügt nötige Befehle nach der Registervergabe ein und entfernt unnötige.
	-- Dies kann Current aus block entfernen, es darf danach also nicht mehr 
	-- auf Current zugegriffen werden.
	-- expand2 darf keine neuen Register allozieren, da die Registervergabe bereits
	-- vorbei ist.
		local
			ari_cmd: ARITHMETIC_COMMAND;
			fcmpe_cmd: FCMPE_COMMAND;
			cnd, inv_cnd: INTEGER;
			tmp1,tmp2: LOCAL_VAR;
			is_real,is_real_or_double: BOOLEAN;
		do
			is_real_or_double := test1.type.is_real_or_double;
			if is_real_or_double then
				is_real := test1.type.is_real;
				if is_real then tmp1 := code. f_temp1_register; tmp2 := code. f_temp2_register;
				           else tmp1 := code.df_temp1_register; tmp2 := code.df_temp2_register;
				end;
				if test1.fp_register < 0 then
					block.insert_and_expand2(code,recycle.new_ass_cmd(tmp1,test1),Void);
					test1 := tmp1;			
				end;
				if test2.fp_register < 0 then
					block.insert_and_expand2(code,recycle.new_ass_cmd(tmp2,test2),Void);
					test2 := tmp2;
				end;
				fcmpe_cmd := recycle.new_fcmpe_cmd;
				fcmpe_cmd.make(is_real,test1.fp_register,test2.fp_register);
				block.add_tail(fcmpe_cmd);
				block.add_tail(recycle.new_nop_cmd);
				inspect condition
				when c_equal            then cnd := fcc_e;  inv_cnd := fcc_ne;
	 			when c_not_equal        then cnd := fcc_ne; inv_cnd := fcc_e;
	 			when c_less             then cnd := fcc_l;  inv_cnd := fcc_ge;
	 			when c_less_or_equal    then cnd := fcc_le; inv_cnd := fcc_g;
	 			when c_greater_or_equal then cnd := fcc_ge; inv_cnd := fcc_l;
	 			when c_greater          then cnd := fcc_g;  inv_cnd := fcc_le;
	 			end;
			else
				if test1.gp_register < 0 then
					block.insert_and_expand2(code,recycle.new_ass_cmd(code.temp1_register,test1),Void);
					test1 := code.temp1_register;			
				end;
				if test2 /= Void and then test2.gp_register < 0 then
					block.insert_and_expand2(code,recycle.new_ass_cmd(code.temp2_register,test2),Void);
					test2 := code.temp2_register;
				end;
				ari_cmd := recycle.new_ari_cmd;
				if test2 = Void then ari_cmd.make_binary_const(b_sub,code.registers @ g0,test1,const_test2);
				                else ari_cmd.make_binary      (b_sub,code.registers @ g0,test1,test2      );
				end;
				ari_cmd.activate_set_cc;
				block.add_tail(ari_cmd);
				inspect condition
				when c_equal            then cnd := icc_e;  inv_cnd := icc_ne;
	 			when c_not_equal        then cnd := icc_ne; inv_cnd := icc_e;
	 			when c_less             then cnd := icc_l;  inv_cnd := icc_ge;
	 			when c_less_or_equal    then cnd := icc_le; inv_cnd := icc_g;
	 			when c_greater_or_equal then cnd := icc_ge; inv_cnd := icc_l;
	 			when c_greater          then cnd := icc_g;  inv_cnd := icc_le;
	 			end;
	 		end;
 			if block.next /= true_branch then
 				block.add_tail(recycle.new_bra_cmd(is_real_or_double,cnd,true_branch));
 				block.add_tail(recycle.new_nop_cmd);
	 			if block.next /= false_branch then
 					block.add_tail(recycle.new_bra_cmd(is_real_or_double,icc_a,false_branch));
	 				block.add_tail(recycle.new_nop_cmd);
	 			end;
	 		else
	 			if block.next /= false_branch then
 					block.add_tail(recycle.new_bra_cmd(is_real_or_double,inv_cnd,false_branch));
	 				block.add_tail(recycle.new_nop_cmd);
	 			end;
	 		end;
		end; -- expand2

--------------------------------------------------------------------------------

end -- TWO_SUCCESSORS
