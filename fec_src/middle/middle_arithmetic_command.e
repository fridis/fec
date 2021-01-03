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

deferred class MIDDLE_ARITHMETIC_COMMAND

-- a := b + c

inherit
	COMMAND;
	COMMANDS;
	
--------------------------------------------------------------------------------

feature { NONE }

	operator: INTEGER;            -- der Operator (b_*)
	
	dst,src1,src2: LOCAL_VAR;  -- dst := src1 <operator> src2 oder
	                           -- dst := src1 <operator> const  (bei src2 = Void) 

	const: INTEGER;

--------------------------------------------------------------------------------

feature { ANY }

	make_binary (oper: INTEGER; dest,source1,source2: LOCAL_VAR) is
		require
			not_unary: 
				oper /= u_neg or oper /= u_abs
			real_with_real: 
				dest.type.is_real = source1.type.is_real and 
			   dest.type.is_real = source2.type.is_real;
			double_with_double: 
				dest.type.is_double = source1.type.is_double and 
				dest.type.is_double = source2.type.is_double;
			int_with_int: 
			-- nyi 	dest.type.is_word = source1.type.is_word and
			-- nyi	dest.type.is_word = source2.type.is_word;
			real_or_double_or_int:
				dest.type.is_real_or_double or dest.type.is_word;
			no_weird_reference:
			-- nyi:	dest.type.is_word implies (source1.type.is_integer or source2.type.is_integer);
			only_allowed_operations:
				dest.type.is_real_or_double implies (oper=b_add or oper=b_sub or oper=b_mul or oper=b_div);
		do
			operator := oper;
			dst := dest; 
			src1 := source1;
			src2 := source2;
		end; -- make_binary

	make_binary_const (oper: INTEGER; dest,source: LOCAL_VAR; c: INTEGER) is
		require
			not_unary: 
				oper /= u_neg or oper /= u_abs
			only_integers:
			-- nyi:	dest.type.is_word;
			int_with_int: 
			-- nyi 	dest.type.is_word = source.type.is_word;
		do
			operator := oper;
			dst := dest; 
			src1 := source;
			src2 := Void;
			const := c;
		end; -- make_binary_const

	make_unary (oper: INTEGER; dest,source: LOCAL_VAR) is
		require
			unary: 
				oper = u_neg or oper = u_abs
			only_reals:
				dest.type.is_real_or_double;
			real_with_real: 
				dest.type.is_real = source.type.is_real;
			double_with_double: 
				dest.type.is_double = source.type.is_double;
		do
			operator := oper;
			dst := dest;
			src1 := source;
			src2 := Void;
		end; -- make_unary

--------------------------------------------------------------------------------

feature { BASIC_BLOCK }

	get_alive (alive: SET) is
	-- lûscht jede von diesem Befehl geschriebene Variable aus alive und
	-- fÄgt jede gelesene Variable in alive ein.
	-- alive := (alive \ written variables) U read variables.
		do
			alive.exclude(dst.number)
			alive.include(src1.number);
			if src2 /= Void then
				alive.include(src2.number);
			end;
		end; -- get_alive
		
	get_conflict_matrix (code: ROUTINE_CODE; alive: SET; weight: INTEGER) is
	-- Bestimmt alive und trÉgt alle im Konflikt stehenden Variablen in 
	-- code.conflict_matrix ein. Die bijektive HÄlle des Konfliktgrafen wird
	-- danach noch bestimmt, so dass es reicht wenn ein Konflikt nur einmal
	-- (d.h. bei der Zuweisung an eine Variable) eingetragen wird. 
	-- ZusÉtzlich wird alive wie bei get_alive bestimmt und must_not_be_volatile
	-- gesetzt fÄr diejenigen locals, die wÉhrend eines Aufrufs leben.
		do
			dst.inc_use_count(weight);
			src1.inc_use_count(weight);
			if src2/=Void then 
				src2.inc_use_count(weight)
			end;
			code.add_conflict(dst,alive);
			get_alive(alive);
		end; -- get_conflict_matrix

--------------------------------------------------------------------------------

feature { ANY }

	print_cmd is 
		local
			i: INTEGER; 
		do
			dst.print_local;
			write_string(" := "); 
			src1.print_local; 
			inspect operator
			when b_add then write_string(" + ");
			when b_sub then write_string(" sub "); 
			when b_subf then write_string(" subf ");
			when b_mul then write_string(" * ");
			when b_div then write_string(" / ");
			when b_mod then write_string(" mod ");
			when b_and then write_string(" and ");
			when b_nand then write_string(" nand ");
			when b_or then write_string(" or ");
			when b_nor then write_string(" nor ");
			when b_xor then write_string(" xor ");
			when b_eqv then write_string(" eqv ");
			when b_implies then write_string(" implies ");
			when b_nimplies then write_string(" nimplies ");			
			when u_neg then write_string(".abs");
			when u_abs then write_string(".neg");
			when b_shift_left then write_string(" << ");
			when b_shift_right then write_string(" >> ");
			end;
			if src2 /= Void then
				src2.print_local
			else
				write_integer(const)
			end; 
			write_string("%N"); 
		end; -- print_cmd 

--------------------------------------------------------------------------------

end -- MIDDLE_ARITHMETIC_COMMAND
