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

class INTEGER_CONSTANT

inherit
	MANIFEST_CONSTANT;
	SCANNER_SYMBOLS;
	
creation
	make, parse
	
--------------------------------------------------------------------------------
	
feature { ANY }
	
	value: INTEGER;   -- Der Wert dieser Konstanten

--------------------------------------------------------------------------------

	make (initial_value: INTEGER) is 
		do
			value := initial_value;
		ensure
			value=initial_value
		end; -- make

	parse (s: SCANNER) is
	-- Integer_constant = [Sign] Integer.
	-- Sign = "+" | "-".
		local
			neg: BOOLEAN;
		do
			if s.current_symbol.type=s_plus then
				neg := false;
				s.next_symbol;
			elseif s.current_symbol.type=s_minus then
				neg := true;
				s.next_symbol;
			else
				neg := false; 
			end; 
			if s.current_symbol.type /= s_integer then
				s.current_symbol.position.error(msg.int_expected);
				value := 0;
			else
				value := s.get_integer;	
				if neg then
					value := - value;
				end;
			end; 
			s.next_symbol;
		end; -- parse;
				
--------------------------------------------------------------------------------
		
	type : TYPE is 
	-- sebug: dies sollte once-feature sein, das funkt aber mit SE nicht
		do
			Result := globals.type_integer; 
		end; -- type

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

	validity_of_constant_attribute (fi: FEATURE_INTERFACE) is
		do
			if fi.type = Void or else not fi.type.is_integer then
				fi.position.error(msg.vqmc3);
			end;
		end;  -- validity_of_constant_attribute
		 
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	need_local_no_exp (code: ROUTINE_CODE; l_type: LOCAL_TYPE) : LOCAL_VAR is 
	-- load this value into a local variable
		local
			ass_const_cmd: ASSIGN_CONST_COMMAND;
		do
			Result := recycle.new_local(code,l_type);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_int(Result,value);
			code.add_cmd(ass_const_cmd);
		end; -- need_local_no_exp

--------------------------------------------------------------------------------

	load_address (code: ROUTINE_CODE) : LOCAL_VAR is 
	-- load address of this value into a local variable
		local
			locl: LOCAL_VAR;
		do
			locl := need_local(code,globals.local_integer);
			Result := recycle.new_local(code,globals.local_pointer);
			code.add_cmd(recycle.new_load_adr_cmd(Result,locl));
		end; -- load_address

--------------------------------------------------------------------------------
		
end -- INTEGER_CONSTANT
