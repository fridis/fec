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

class ANY

-- Ancestor class for all classes of the FEC compiler.
-- 
-- This allows direct access to an once-instance of GLOBAL_OBJECTS,
-- RECYCLE_OBJECTS, MY_STRINGS and MESSAGES.
-- 
-- Feature memstats() is used to count the memory allocated by most 
-- creation instructions.

inherit PLATFORM;

feature 

	globals: GLOBAL_OBJECTS is
		once
			!!Result.make
		end; -- globals

	recycle: RECYCLE_OBJECTS is
		once
			!!Result.make
		end; -- recycle

	strings: MY_STRINGS is
		once
			!!Result.make
		end; -- strings

	msg: MESSAGES is
		once
			!!Result.make_english;
		end; -- msg

--------------------------------------------------------------------------------

	memstats(n: INTEGER) is
		do
			memstatistics.put((memstatistics @ n) + 1,n);
		end; 
	
	memstatistics: ARRAY[INTEGER] is
		once
			!!Result.make(1,512);
		end;  
		
	show_memory_statistics is
		local
			index: ARRAY[INTEGER];
			mem,sorted,sorted_index,swap: ARRAY[INTEGER];
			i,j,k,s,t,total_mem, num_allocs, unknwn_allocs : INTEGER; 
			mes: STRING;
		do
			!!mem.make(1,512);
			!!index.make(1,512);
			!!sorted.make(1,512);
			!!sorted_index.make(1,512);
			from
				i := 1
			until
				i > 512
			loop
				mem.put(memstatistics @ i,i);
				index.put(i,i);
				i := i + 1;
			end;
			from
				s := 1
			until
				s = 512
			loop  -- join two arrays of size s as one of size 2*s
				from
					k := 1;
					t := 1;
				until
					k > 512
				loop  -- join [t..t+s-1] and [t+s..t+2*s-1]
					from
						i := 0;
						j := 0;
					until
						i+j >= 2*s
					loop
						if j>=s or else i<s and then mem @ (t+i) > mem @ (t+s+j) then
							sorted      .put(mem   @ (t+i),k);
							sorted_index.put(index @ (t+i),k);
							i := i + 1;
						else
							sorted      .put(mem   @ (t+j+s),k);
							sorted_index.put(index @ (t+j+s),k);
							j := j + 1;
						end;
						k := k + 1;
					end;
					t := t + 2*s
				end; 
				swap := sorted;       sorted       := mem;   mem   := swap;
				swap := sorted_index; sorted_index := index; index := swap;
				s := 2*s;
			end;
			print("%N%NMemory statistics:%N%N");  
			from
				i := 1
				total_mem := 0;
				num_allocs := 0;
				unknwn_allocs := 0;
			until
				i > 512 or else
				mem @ i = 0
			loop
				s := mem @ i;
				print(s.out); print(" allocations # "); print((index @ i).out); print("  ");
				inspect index @ i
				when 231 then s := s*16; mes := " Bytes: SCANNER.add_symbol: !!new_symbol";
				when 122 then s := s*16; mes := " Bytes: List.add: !!data";
				when  73 then s := s*20; mes := " Bytes: CLASS_TYPE.actual_class_name: !!Result";
				when   2 then s := s*52; mes := " Bytes: ACTUAL_CLASS_NAME.code_name: !!cod_nam";
				when 123 then s := s*64; mes := "?Bytes: List.add: !!data.resize";
				when  72 then s := s*16; mes := " Bytes: CLASS_TYPE.actual_class_name: !!list";
				when  19 then s := s*16; mes := " Bytes: CALL.make_binary: !!actual";
				when  94 then s := s*36; mes := " Bytes: FEATURE_INTERFACE.compile: !!routine_code.make";
				when  92 then s := s*28; mes := " Bytes: FEATURE_DECLARATION_LIST.parse_feature_clause: !!feature_declaration";
				when  84 then s := s*12; mes := " Bytes: FEATURE_DECLARATION.parse: !!new_feature.parse";
				when  17 then s := s*16; mes := " Bytes: CALL.parse_unqualified_call: !!actual.parse";
				when  81 then s := s*24; mes := " Bytes: ENTITY_DECLARATION_LIST.parse_e_d_g: !!new.parse (LOCAL_OR_ARG)";
				when 118 then s := s*16; mes := " Bytes: INTERNAL_ROUTINE.parse: !!compound.parse";
				when   8 then s := s*20; mes := " Bytes: ANCESTOR_NAME.internal_actual_class_name: !!Result";
				when  13 then s := s*12; mes := " Bytes: ASSERTION.parse: !!assertion_clause.parse";
				when  93 then s := s*16; mes := " Bytes: FEATURE_INTERFACE.get_locals: !!local_identifiers.make";
				when 399 then s := s*84; mes := " Bytes: RECYCLE_OBJECTS.new_feature_interface: !!Result";
				when 312 then s := s*16; mes := " Bytes: RECYCLE_OBJECTS.new_args_list: !!Result.make (LIST)";
				when 197 then s := s*40; mes := " Bytes: PARSE_EXPR.pars_any_but_binary: !CALL!expression";
				when 201 then s := s*24; mes := "?Bytes: PARSE_INSTR.pars_instruction: !any instruction!Result";
				when 188 then s := s*40; mes := " Bytes: PARSE_EXPR.op_prec_expression: !CALL!expression.make_binary";
				when 202 then s := s* 8; mes := "?Bytes: PARSE_M_C.parse_manifest_constant: !any constant!Result";
				when 191 then s := s*12; mes := " Bytes: PARSE_EXPR.parse_any_but_binary: !CONSTANT_EXPRESSION!expression.parse";
				when 381 then s := s*16; mes := " Bytes: ROUTINE_CODE.make: !!arguments.make (LIST)";
				when 382 then s := s*16; mes := " Bytes: ROUTINE_CODE.make: !!locals.make (LIST)";
				when 374 then s := s*44; mes := " Bytes: PARSE_INSTR.parse_instruction: !ASSIGNMENT!instruction.make";
				when 205 then s := s* 8; mes := " Bytes: PARSE_M_C.parse_integer_or_real: !INTEGER_CONSTANT!constant.make";
				when 141 then s := s*12; mes := " Bytes: NEW_FEATURE.parse: !!name.parse";
				when 200 then s := s*36; mes := " Bytes: PARSE_FEAT_VALUE.parse_feat_value: !ROUTINE!feature_value.parse";
				when 357 then s := s*100; mes := "?Bytes: INTERNAL_ROUTINE.validity: !!calls_currents_features.make(1,fi.num_dynamic_features)";
				when 225 then s := s*12; mes := " Bytes: ROUTINE.parse_routine_body: !INTERNAL_ROUTIN!routine_body.parse";
				when 375 then s := s*40; mes := " Bytes: PARSE_INSTR.parse_instruction: !CALL!Result.parse";
				when  61 then s := s*20; mes := " Bytes: CLASS_TYPE.vncn_and_vncg: !!new_ct.make_class_type";
				when 238 then s := s*40; mes := "?Bytes: SORTABLE_LIST: !!tmp.make(1,data.upper)";
				when 210 then s := s*20; mes := " Bytes: PARSE_TYPE.extended_parse_type: !CLASS_TYPE!type.parse";
				when 400 then s := s*36; mes := " Bytes: RECYCLE_OBJECTS.new_ass_cmd: !!Result.clear";
				when 401 then s := s*28; mes := " Bytes: RECYCLE_OBJECTS.new_call_cmd: !!Result.clear";
				when 402 then s := s*28; mes := " Bytes: RECYCLE_OBJECTS.new_ari_cmd: !!Result.clear";
				when 403 then s := s*20; mes := " Bytes: RECYCLE_OBJECTS.new_local: !!Result.clear";
				when 404 then s := s*16; mes := " Bytes: RECYCLE_OBJECTS.new_block: !!Result.clear";
				when 405 then s := s*20; mes := " Bytes: RECYCLE_OBJECTS.new_off_ind: !!Result.clear";
				when 406 then s := s*12; mes := " Bytes: RECYCLE_OBJECTS.new_indexed: !!Result.clear";
				when 407 then s := s*24; mes := " Bytes: RECYCLE_OBJECTS.new_boolval: !!Result.clear";
				when 408 then s := s*24; mes := " Bytes: RECYCLE_OBJECTS.new_two_succ: !!Result.clear";
				when 409 then s := s* 8; mes := " Bytes: RECYCLE_OBJECTS.new_one_succ: !!Result.clear";
				when  74 then s := s*16; mes := " Bytes: CONDITIONAL.parse: !!then_part.parse (COMPOUND)";
				when  76 then s := s*16; mes := " Bytes: CONDITIONAL.parse: !!else_part.parse (COMPOUND)";
				when  87 then s := s*16; mes := " Bytes: FEATURE_DECLARATION.parse: !!formal_arguments.parse";
				when 162 then s := s*24; mes := " Bytes: PARENT.join_ancestors: !!new_ancestor.make";
				when   4 then s := s*400; mes := "?Bytes: ANCESTOR.allocate_features: !!features.make(1,num)";
				when   5 then s := s*100; mes := "?Bytes: ANCESTOR.allocate_features: !!ambiguous.make(1,num)";
				when   6 then s := s*400; mes := "?Bytes: ANCESTOR.allocate_features: !!selects.make(1,num)";
				when  18 then s := s*16; mes := " Bytes: CALL.parse_unqualified_call: !!actual.parse";
				when 214 then s := s*400; mes := "?Bytes: PS_ARRAY.add: data.resize(1,count*2-1)";
				when 215 then s := s*800; mes := "?Bytes: PS_ARRAY.get_sorted: !!Result.make(1,count)";
				when 322 then s := s*16; mes := " Bytes: CLASS_TYPE.ancestor_name: !!Result.make_class_type";
				when 342 then s := s*12; mes := " Bytes: CREATION_INSTRUCITON.compile: !!args.make";
				when 252 then s := s*12; mes := " Bytes: ANCESTOR_NAME.get_heirs_view: !!new_generics.make";
				when 253 then s := s*16; mes := " Bytes: ANCESTOR_NAME.get_heirs_view: !!Result.make_class_type";
				when 412 then s := s*800; mes := "?Bytes: ROUTINE_CODE.get_conflict_matrix: !!conflict_matrix.make(1,locals.count)"; 
				when 413 then s := s*12; mes := " Bytes: ROUTINE_CODE.get_conflict_matrix: !!set.make(locals.count)"; 
				when 417 then s := s*12; mes := " Bytes: BASIC_BLOCK.clear_live_spans: !!alive.make(code.locals.count)"; 
				when 418 then s := s*12; mes := " Bytes: TWO_SUCCESSORS.get_live_spans: !!alive.make(code.locals.count)"; 
				when 419 then s := s*12; mes := " Bytes: MULTI_SUCCESSORS.get_live_spans: !!alive.make(code.locals.count)"; 
				when 420 then s := s*12; mes := " Bytes: NO_SUCCESSOR.get_live_spans: !!alive.make(code.locals.count)"; 
				when 421 then s := s*200; mes := "?Bytes: SET.make: !!bits.make(1,new_max)"; 
				when 424 then s := s*104; mes := "?Bytes: SORTABLE.get_sorted: sort_data.make(1,count)"; 
				when 446 then s := s*16; mes := " Bytes: CALL.parse_call_chain: !!new_target.make_from(Current)";
				when 119 then s := s*80; mes := " Bytes: STRING_CONSTANT.need_local_no_exp: !!str_name.make(40)";
				when 228 then s := s*204; mes := "?Bytes: SCANNER.add_string: strings.resize(1,strings.upper*2";
				when 213 then s := s*64; mes := " Bytes: PS_ARRAY.make: !!data.make(1,min_size);";
				when  91 then s := s*16; mes := " Bytes: FEATURE_DECL_LIST.parse_feature_clause: !!clients.parse(s)";
				when  88 then s := s* 8; mes := " Bytes: FEATURE_DECL.parse: !ATTRIBUTE!feature_value.make";
				when 222 then s := s*16; mes := " Bytes: ROUTINE.parse_local_declarations: !!locals.parse";
				when 326 then s := s*80; mes := "?Bytes: SCANNER.add_string: clone(str)";
				when 451 then s := s*16; mes := " Bytes: RECYCLE_OBJECTS.new_reloc: !!Result.clear";
				when 447 then s := s*80; mes := "?Bytes: MACHINE_CODE.define_symbol: clone(tmp_symbol_name)";
				when 448 then s := s*20; mes := " Bytes: RECYCLE_OBJECTS.new_symbol: !!Result.clear";
				when 452 then s := s*80; mes := "?Bytes: MY_STRINGS.get_id: !!new_string.copy(of)";
				when 453 then s := s*12; mes := " Bytes: MY_STRINGS.get_id: !!Result.make";
				when   7 then s := s*12; mes := " Bytes: ANCESTOR_NAME.internal_actual_class_name: !!list.make";
				when 391 then s := s* 8; mes := " Bytes: UNIQUE_VALUE.constant_value: !INTEGER_CONSTANT!Result.make";
				when 473 then s := s*24; mes := " Bytes: CLASS_TYPE.true_class_name: !!Result.make";
				when 472 then s := s*12; mes := " Bytes: CLASS_TYPE.true_class_name: !!list.make";
				else
					s := -1; 
				end;
				if s>=0 then
					print(s.out); print(mes);
					total_mem := total_mem + s;
				else
					unknwn_allocs := unknwn_allocs + mem @ i;
				end;
				num_allocs := num_allocs + mem @ i;
				print("%N");	
				i := i + 1
			end;
			print("%NAt least "); print(total_mem.out); 
			print(" bytes allocated by "); print(num_allocs.out); 
			print(" allocations ("); print(unknwn_allocs.out); 
			print(" of unknown size)%N");
		end; -- show_memory_statistics

end -- ANY
