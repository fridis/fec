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

class SPARC_CONSTANTS

-- Constants used for SPACH code generation.
--
-- Inherit this class to use the constants.

inherit 
	PLATFORM;

feature

	simm13_min: INTEGER is -4096;
	simm13_max: INTEGER is 4095;

-- Register numbers: 

	r0: INTEGER is 0;
	g0: INTEGER is 0;
	o0: INTEGER is 8; 
	l0: INTEGER is 16; 
	i0: INTEGER is 24; 
	sp: INTEGER is 14;
	fp: INTEGER is 30;
	
	f0: INTEGER is 32; -- the %f-registers are number 32..63
	
-- temp1 and temp2 are used to load or store temporary values

	temp1: INTEGER is 15; -- %o7
	temp2: INTEGER is 1;  -- %g1

	f_temp1: INTEGER is 44;   -- %f12/13 
	f_temp2: INTEGER is 46;   -- %f14/15

-- machine code fields:

	op (n: INTEGER): INTEGER is
		require
			n >= 0; 
			n < 4;
		do
			inspect n
			when 0 then Result := 0;
			when 1 then Result := b30;
			when 2 then Result := b31;
			when 3 then Result := b31+b30;
			end;
		end; -- op

	op3 (n: INTEGER): INTEGER is
		require
			n >= 0; 
			n < 64;
		do
			Result := n*b19;
		end; -- op3

	op3_add : INTEGER is  0;
	op3_and : INTEGER is  1;
	op3_or  : INTEGER is  2;
	op3_xor : INTEGER is  3;
	op3_sub : INTEGER is  4;
	op3_andn: INTEGER is  5;
	op3_orn : INTEGER is  6;
	op3_xnor: INTEGER is  7;
	op3_addc: INTEGER is  8;
	op3_umul: INTEGER is 10;
	op3_smul: INTEGER is 11;
	op3_subc: INTEGER is 12;
	op3_udiv: INTEGER is 14;
	op3_sdiv: INTEGER is 15;
	op3_cc  : INTEGER is 16;  -- add cc to op3 to get the cc-version

	op3_sll : INTEGER is 37;
	op3_srl : INTEGER is 38;
	op3_sra : INTEGER is 39;

	op3_jmpl    : INTEGER is 56;
	op3_save    : INTEGER is 60;
	op3_restore : INTEGER is 61;

	op3_ldsb : INTEGER is 9;
	op3_ldsh : INTEGER is 10;
	op3_ldsw : INTEGER is 8;
	op3_ldub : INTEGER is 1;
	op3_lduh : INTEGER is 2;
	op3_lduw : INTEGER is 0;
	
	op3_stb : INTEGER is 5;
	op3_sth : INTEGER is 6;
	op3_stw : INTEGER is 4;

	op3_ldf  : INTEGER is 32;
	op3_lddf : INTEGER is 35;
	op3_ldqf : INTEGER is 34;
	
	op3_stf  : INTEGER is 36;
	op3_stdf : INTEGER is 39;
	op3_stqf : INTEGER is 38;

	icc_a  : INTEGER is 8;  -- always
	icc_n  : INTEGER is 0;  -- never
	icc_ne : INTEGER is 9;
	icc_e  : INTEGER is 1;
	icc_g  : INTEGER is 10;
	icc_le : INTEGER is 2;
	icc_ge : INTEGER is 11;
	icc_l  : INTEGER is 3;
	icc_gu : INTEGER is 12;
	icc_leu: INTEGER is 4;
	icc_cc : INTEGER is 13;
	icc_cs : INTEGER is 5;
	icc_pos: INTEGER is 14;
	icc_neg: INTEGER is 6;
	icc_vc : INTEGER is 15;
	icc_vs : INTEGER is 7;

	fcc_a   : INTEGER is 8;
	fcc_n   : INTEGER is 0;
	fcc_u   : INTEGER is 7;
	fcc_g   : INTEGER is 6;
	fcc_ug  : INTEGER is 5;
	fcc_l   : INTEGER is 4;
	fcc_ul  : INTEGER is 3;
	fcc_lg  : INTEGER is 2;
	fcc_ne  : INTEGER is 1;
	fcc_e   : INTEGER is 9;
	fcc_ue  : INTEGER is 10;
	fcc_ge  : INTEGER is 11;
	fcc_uge : INTEGER is 12;
	fcc_le  : INTEGER is 13;
	fcc_ule : INTEGER is 14;
	fcc_o   : INTEGER is 15;
	
	op2 (n: INTEGER): INTEGER is
		require
			n >= 0; 
			n < 8;
		do
			Result := n*b22;
		end; -- op2

	opf (n: INTEGER): INTEGER is
		require
			n >= 0;
			n < 512;
		do
			Result := n*b5;
		end; -- opf
		
	opf_single : INTEGER is 1;  -- add one of these to opf_add/sub/mul/div
	opf_double : INTEGER is 2;

	opf_add : INTEGER is 64;    -- add opf_single/double to one of these four
	opf_sub : INTEGER is 68;
	opf_mul : INTEGER is 72;
	opf_div : INTEGER is 76;
	
	opf_mov : INTEGER is 0;     -- add opf_single/double to one of these three
	opf_neg : INTEGER is 4;
	opf_abs : INTEGER is 8;

	opf_movs : INTEGER is 1;     -- don't add anything to these 
	opf_movd : INTEGER is 2;
	opf_stoi : INTEGER is 209;
	opf_dtoi : INTEGER is 210;
	opf_stod : INTEGER is 201;
	opf_dtos : INTEGER is 198;
	opf_itos : INTEGER is 196;
	opf_itod : INTEGER is 200;

	opf_fcmpes : INTEGER is 85; 
	opf_fcmped : INTEGER is 86; 

	rd (n: INTEGER): INTEGER is
		require
			n >= 0; 
			n < 32;
		do
			Result := n*b25;
		end; -- rd

	rs1 (n: INTEGER): INTEGER is
		require
			n >= 0; 
			n < 32;
		do
			Result := n*b14;
		end; -- rs1

	rs2 (n: INTEGER): INTEGER is
		require
			n >= 0; 
			n < 32;
		do
			Result := n;
		end; -- rs2

	i_flag: INTEGER is 
		do
			Result := b13
		end; -- i_flag
	
	a_flag: INTEGER is 
		do
			Result := b29
		end; -- a_flag
	
	cond (n: INTEGER): INTEGER is
		require
			n >= 0; 
			n < 16;
		do
			Result := n*b25;
		end; -- cond

	simm13(n: INTEGER): INTEGER is
		require
			n >= -b12;
			n < b12;
		do
			if n<0 then
				Result := b13+n
			else
				Result := n
			end; 
		ensure
			Result >= 0;
			Result < b13
		end; -- simm13
	
	hi22(n: INTEGER): INTEGER is
	-- upper 22 bits of n
		do
			if n>=0 then
				Result := n // b10;
			else
				Result := -(n+1); -- one's complement
				Result := (b22 - 1) - Result // b10; 
			end;
		ensure
			Result >= 0; 
			Result < b22;
		end; -- hi22

	lo10(n: INTEGER): INTEGER is
		do
			if n>=0 then
				Result := n \\ b10
			else
				Result := -(n+1);  -- one's complement
				Result := (b10 - 1) - Result \\ b10;
			end;
		end; -- lo10

	disp22(n: INTEGER): INTEGER is
		require
			n >= -b21;
			n < b21;
		do
			if n<0 then
				Result := b22+n
			else
				Result := n
			end; 
		ensure
			Result >= 0;
			Result < b22
		end; -- disp22
	
-- bit numbers

	b0 : INTEGER is              1;
	b1 : INTEGER is              2;
	b2 : INTEGER is              4;
	b3 : INTEGER is              8;
	b4 : INTEGER is             16;
	b5 : INTEGER is             32;
	b6 : INTEGER is             64;
	b7 : INTEGER is            128;
	b8 : INTEGER is            256;
	b9 : INTEGER is            512;
	b10: INTEGER is          1_024;
	b11: INTEGER is          2_048;
	b12: INTEGER is          4_096;
	b13: INTEGER is          8_192;
	b14: INTEGER is         16_384;
	b15: INTEGER is         32_768;
	b16: INTEGER is         65_536;
	b17: INTEGER is        131_072;
	b18: INTEGER is        262_144;
	b19: INTEGER is        524_288;
	b20: INTEGER is      1_048_576;
	b21: INTEGER is      2_097_152;
	b22: INTEGER is      4_194_304;
	b23: INTEGER is      8_388_608;
	b24: INTEGER is     16_777_216;
	b25: INTEGER is     33_554_432;
	b26: INTEGER is     67_108_864;
	b27: INTEGER is    134_217_728;
	b28: INTEGER is    268_435_456;
	b29: INTEGER is    536_870_912;
	b30: INTEGER is  1_073_741_824;
	b31: INTEGER is -- -2_147_483_648;
		do
			Result := Minimum_integer
		end; -- b31;

	bit_number (n: INTEGER): INTEGER is
	-- Result >= 0 implies 2^Result = n
		do
			Result := -1;
			if n<b16 then
				if n<b8 then
					if n<b4 then
						if     n=b0  then Result := 0;
						elseif n=b1  then Result := 1;
						elseif n=b2  then Result := 2;
						elseif n=b3  then Result := 3;
						end;
					else
						if     n=b4  then Result := 4;
						elseif n=b5  then Result := 5;
						elseif n=b6  then Result := 6;
						elseif n=b7  then Result := 7;
						end;
					end;
				else
					if n<b12 then
						if     n=b8  then Result := 8;
						elseif n=b9  then Result := 9;
						elseif n=b10 then Result := 10;
						elseif n=b11 then Result := 11;
						end;
					else
						if     n=b12 then Result := 12;
						elseif n=b13 then Result := 13;
						elseif n=b14 then Result := 14;
						elseif n=b15 then Result := 15;
						end;
					end;
				end;
			else
				if n<b24 then
					if n<b20 then
						if     n=b16 then Result := 16;
						elseif n=b17 then Result := 17;
						elseif n=b18 then Result := 18;
						elseif n=b19 then Result := 19;
						end;
					else
						if     n=b20 then Result := 20;
						elseif n=b21 then Result := 21;
						elseif n=b22 then Result := 22;
						elseif n=b23 then Result := 23;
						end;
					end;
				else
					if n<b24 then
						if     n=b24 then Result := 24;
						elseif n=b25 then Result := 25;
						elseif n=b26 then Result := 26;
						elseif n=b27 then Result := 27;
						end;
					else
						if     n=b28 then Result := 28;
						elseif n=b29 then Result := 29;
						elseif n=b30 then Result := 30;
						-- b31 is sign bit
						end;
					end;
				end;
			end;
		end; -- bit_number
	
end -- SPARC_CONSTANTS
