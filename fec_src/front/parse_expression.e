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

class PARSE_EXPRESSION
-- um diese Klasse zu benutzen, muß von ihr geerbt werden und parse_expression
-- aufgerufen werden.

inherit
	PARSE_MANIFEST_CONSTANT;
	SCANNER_SYMBOLS;

feature { ANY }

	expression : EXPRESSION;  -- der Ausdruck
	
	parse_expression (s: SCANNER) is
		do
			op_prec_expression(s,s_semicolon);
		ensure
			expression /= Void;
		end;  -- parse_expression;

--------------------------------------------------------------------------------								
		
	op_prec_expression(s: SCANNER; last_binary: INTEGER) is
	-- Operator-precedence-Parser für binäre Ausdrücke. 
	-- last_binary ist der vor diesem Ausdruck gefundene binäre Operator. Gibt es vor diesem
	-- Audruck keinen binären Operator, so muß last_binary=s_semicolon sein. 
	-- Der Ausdruck wird solange ausgewertet bis ein binärer Operator  op gefunden wird, für
	-- den last_binary *> op gilt.
	--
	-- Expression = {Anything_but_binary_expression Binary_Operator ...}.
		local
			left,right: EXPRESSION; 
			op_name: INTEGER;
			op: INTEGER; 
			pos: POSITION;
		do
		-- sebug: Bug in SE
			if left /= right or op_name /= 0 or op=3 then
				left := right; 
				right := left;
				op_name := 0;
				op := 0
			end;
		-- sebug: Bug end	
			from
				parse_anything_but_binary_expression(s);
			until
				not is_binary_operator(s) or else
				higher_precedence(last_binary,s.current_symbol.type)
			loop
				left := expression;
				pos := s.current_symbol.position;
				op := s.current_symbol.type;
				op_name := binary_operator_name(s);
				s.next_symbol;
				op_prec_expression(s,op);
				right := expression;
memstats(188);
				!CALL!expression.make_binary(left,op_name,right,pos);
			end;
		ensure
			expression /= Void;
		end; -- op_prec_expression	 

--------------------------------------------------------------------------------									
		
	is_binary_operator (s: SCANNER) : BOOLEAN is
		do
			inspect s.current_symbol.type
			when s_implies,
			     s_or, 
			     s_or_else, 
			     s_xor,
			     s_and, 
			     s_and_then,
			     s_equal, 
			     s_not_equal, 
			     s_less, 
			     s_less_or_equal, 
			     s_higher, 
			     s_higher_or_equal,
			     s_plus, 
			     s_minus,
			     s_times, 
			     s_divide, 
			     s_div, 
			     s_mod,
			     s_power,
			     s_free                 
			then 
				Result := true;
			else
				Result := false;
			end;
		end; -- is_binary_operator

	binary_operator_name (s: SCANNER) : INTEGER is
		do
			inspect s.current_symbol.type
			when s_implies         then Result := globals.string_infix_implies;
			when s_or              then Result := globals.string_infix_or;
			when s_or_else         then Result := globals.string_infix_or_else;
			when s_xor             then Result := globals.string_infix_xor;
			when s_and             then Result := globals.string_infix_and;
			when s_and_then        then Result := globals.string_infix_and_then;
			when s_equal           then Result := globals.string_infix_equal;
			when s_not_equal       then Result := globals.string_infix_not_equal;
			when s_less            then Result := globals.string_infix_less;
			when s_less_or_equal   then Result := globals.string_infix_less_or_equal;
			when s_higher          then Result := globals.string_infix_greater;
			when s_higher_or_equal then Result := globals.string_infix_greater_or_equal;
			when s_plus            then Result := globals.string_infix_plus;
			when s_minus           then Result := globals.string_infix_minus;
			when s_times           then Result := globals.string_infix_times;
			when s_divide          then Result := globals.string_infix_divide;
			when s_div             then Result := globals.string_infix_div;
			when s_mod             then Result := globals.string_infix_mod;
			when s_power           then Result := globals.string_infix_power;
			when s_free then 
				tmp_str.copy("*");
				tmp_str.append(strings @ s.get_free);
				Result := strings # tmp_str;
			end;
		end; -- binary_operator_name

	unary_operator_name (s: SCANNER) : INTEGER is
		do
			inspect s.current_symbol.type
			when s_plus  then Result := globals.string_prefix_plus;
			when s_minus then Result := globals.string_prefix_minus;
			when s_not   then Result := globals.string_prefix_not;
			when s_free then 
				tmp_str.copy("+");
				tmp_str.append(strings @ s.get_free);
				Result := strings # tmp_str;
			end;
		end; -- unary_operator_name

	tmp_str: STRING is 
		once
			!!Result.make(80);
		end; -- tmp_str
		
--------------------------------------------------------------------------------									
									
	higher_precedence (op1,op2: INTEGER) : BOOLEAN is
	-- Prüft, ob op1 höhere Präzedenz hat als op2, also ob
	-- op1 *> op2.
		do
			if op1=op2 then
				Result := op1 /= s_power                       -- nur "^" list rechtsassoziativ 
			else
				Result := precedence(op1) >= precedence(op2);
			end;
		end; -- higher_precedence
					
	precedence (op: INTEGER): INTEGER is
	-- Ergibt die Präzedenz von op.
		do
			inspect op
			when s_semicolon            then Result := 1
			when s_implies              then Result := 3
			when s_or, s_or_else, s_xor then Result := 4
			when s_and, s_and_then      then Result := 5
			when s_equal, 
			     s_not_equal, 
			     s_less, 
			     s_less_or_equal, 
			     s_higher, 
			     s_higher_or_equal      then Result := 6
			when s_plus, s_minus        then Result := 7
			when s_times, 
			     s_divide, 
			     s_div, 
			     s_mod                  then Result := 8
			when s_power                then Result := 9
			when s_free                 then Result := 10
			when s_old, 
			     s_strip					then Result := 11 
			end;
		end; -- precedence									
	
--------------------------------------------------------------------------------									
 	
	parse_anything_but_binary_expression (s: SCANNER) is 
	-- Anything_but_binary_expression = Call | 
	--                                  Operator_Expression | 
	--                                  Manifest_constant | 
	--                                  Manifest_array | 
	--                                  Old | 
	--                                  Strip.
	-- Operator_Expression = "(" Expression ")" | Unary_expression.	
	-- Call = [Parenthesized_qualifier] Call_chain.
	-- Call_chain = Unqualified_call ["." Call_chain].
	-- Parenthesized_qualifier = "(" Expression ")" ".".
	-- Unary_expression = Prefix_operator Anything_but_binary_expression.
	-- Prefix_operator = "not", "+", "-", Free_operator.
		local 
			target: EXPRESSION;
			op_name: INTEGER; 
			pos: POSITION;
		do
			pos := s.current_symbol.position;
		-- sebug: die folgende Zeile nur wg. Bug in SE
			if op_name=0 then target := Void end;
			inspect s.current_symbol.type
			when	s_true,
					s_false,
					s_integer,
					s_real,
					s_string,
					s_character,
					s_bit_sequence
			then
memstats(191);
				!CONSTANT_EXPRESSION!expression.parse(s); 
			when	s_left_angle_bracket then
memstats(192);
				!MANIFEST_ARRAY!expression.parse(s); 
			when s_old then
memstats(193);
				!OLD_EXPRESSION!expression.parse(s);
			when s_strip then
memstats(194);
				!STRIP_EXPRESSION!expression.parse(s);
			when s_not,s_plus,s_minus,s_free then
				op_name := unary_operator_name(s);
				s.next_symbol;
				parse_anything_but_binary_expression(s);
				target := expression;
memstats(195);
				!CALL!expression.make_unary(target,op_name,pos);
			when s_left_parenthesis then
				s.next_symbol;
				parse_expression(s);
				s.check_right_parenthesis(msg.rpr_ex_expected);
				if s.current_symbol.type = s_dot then 
					s.next_symbol;
					target := expression;
memstats(196);
					!CALL!expression.parse_call_chain(s,target,true); 
				end;
			else
memstats(197);
				!CALL!expression.parse_call_chain(s,Void,true);
			end;
		ensure
			expression /= Void
		end; -- parse_anything_but_binary_expression
		
--------------------------------------------------------------------------------									
		
end -- PARSE_EXPRESSION

					
