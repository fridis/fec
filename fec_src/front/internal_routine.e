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

class INTERNAL_ROUTINE

inherit
	ROUTINE_BODY
		redefine
			is_once, 
			is_internal,
			compile,
			calls_currents_features,
			set_calls
		end;
	SCANNER_SYMBOLS;
	CONDITIONS;
	DATATYPE_SIZES;
	COMPILE_ASSIGN;
	INIT_EXPANDED;
	FRIDISYS;
	
creation
	parse
	
feature { ANY }

--------------------------------------------------------------------------------

	is_once : BOOLEAN;   -- ist dies eine ONCE-Routine?

	compound: COMPOUND;  -- Die Anweisungen.

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Internal = Routine_mark Compound.
	-- Routine_mark = "do" | "once".
		do
			if s.current_symbol.type = s_once then
				s.next_symbol;
				is_once := true; 
			else
				is_once := false; 
				s.check_keyword(s_do);
			end; 
memstats(118);
			!!compound.parse(s);
		end; -- parse
		
--------------------------------------------------------------------------------

	is_internal : BOOLEAN is
		do
			Result := true
		end; -- is_internal

--------------------------------------------------------------------------------
-- VALIDITY †BERPR†FUNG:                                                      --		
--------------------------------------------------------------------------------

feature { ANY }

	validity (fi: FEATURE_INTERFACE) is
		do
memstats(357);
			!!calls_currents_features.make(1,fi.interface.num_dynamic_features);
			compound.validity(fi)
		end; -- validity

	calls_currents_features: ARRAY[BOOLEAN]; -- alle Features von Current, die
	                                         -- diese Routine aufruft.
	                                         
	set_calls (n: INTEGER) is
		do
			if n>0 then
				calls_currents_features.put(true,n);
			end;
		end; -- set_calls
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
		local
			basic: BASIC_BLOCK;
			array_access: ARRAY_ACCESS;
		do
-- write_string("%NCode for "); write_string(strings @ code.class_code.actual_class.name); write_string("."); write_string(strings @ code.fi.key); write_string("%N");
			-- prolog
			basic := recycle.new_block(basic.weight_normal);
			code.set_first_block(basic);
			code.fi.alloc_arguments(code);
			code.fi.feature_value.alloc_locals(code);
			if code.fi.origin.name = globals.string_array and then 
				(code.fi.seed.key = globals.string_put      or else
				 code.fi.seed.key = globals.string_infix_at or else
				 code.fi.seed.key = globals.string_item)
			then
memstats(488);
				!!array_access.make(code);
			else
				if code.has_expanded_result then 
					clear_and_init_expanded(code,code.result_local,code.fi.type);
				elseif code.has_unexpanded_result then
					code.result_local.assign_initial_value(code);
				end;
				-- body:
				if is_once then 
					compile_once_body(code);
				else
					compound.compile(code);
				end;
			end;
			-- epilog
			code.finish_block(no_successor,Void);
		end; -- compile
		
feature { NONE }

	compile_once_body(code: ROUTINE_CODE) is
		local
			once_called, adr_of_once_result: LOCAL_VAR;
			once_called_global, once_result_global: INTEGER;
			read_mem_cmd: READ_MEM_COMMAND;
			write_mem_cmd: WRITE_MEM_COMMAND;
			ass_const_cmd: ASSIGN_CONST_COMMAND;
			one_succ: ONE_SUCCESSOR;
			two_succ: TWO_SUCCESSORS;
			main_block, final_block: BASIC_BLOCK;
			off_ind: OFFSET_INDIRECT_VALUE;
		do	
			main_block  := recycle.new_block(main_block .weight_normal);
			final_block := recycle.new_block(final_block.weight_normal);
			once_called := recycle.new_local(code,globals.local_boolean);
			once_called_global := once_called_name(code.fi);
			once_result_global := once_result_name(code.fi);
		-- if once_called = 0 then
			read_mem_cmd := recycle.new_read_mem_cmd;
			read_mem_cmd.make_read_global(once_called, once_called_global);
			code.add_cmd(read_mem_cmd);
			two_succ := recycle.new_two_succ;
			two_succ.make(once_called,Void,0,c_equal,main_block,final_block);
			code.finish_block(two_succ,main_block);
		--    once_called := true
			once_called := recycle.new_local(code,globals.local_boolean);
			ass_const_cmd := recycle.new_ass_const_cmd;
			ass_const_cmd.make_assign_const_bool(once_called,true);
			code.add_cmd(ass_const_cmd);
			write_mem_cmd := recycle.new_write_mem_cmd;
			write_mem_cmd.make_write_global(once_called_global,once_called);
			code.add_cmd(write_mem_cmd);
		--    routine_body
			compound.compile(code);
		-- end;
			code.finish_block(recycle.new_one_succ(final_block),final_block);
		-- Result := once_result;
			if code.has_unexpanded_result then
				read_mem_cmd := recycle.new_read_mem_cmd;
				read_mem_cmd.make_read_global(code.result_local,once_result_global);
				code.add_cmd(read_mem_cmd);
			elseif code.has_expanded_result then
				adr_of_once_result := recycle.new_local(code,globals.local_pointer);
				ass_const_cmd := recycle.new_ass_const_cmd;
				ass_const_cmd.make_assign_const_symbol(adr_of_once_result,once_result_global,0);
				code.add_cmd(ass_const_cmd);
				off_ind := recycle.new_off_ind;
				off_ind.make(0,adr_of_once_result);
				compile_assign.clone_or_copy(code,
				                             code.fi.type,
				                             code.fi.type,
				                             off_ind,
				                             code.result_local,
				                             0,
				                             true);
			end;
			if code.result_local /= Void then
				if code.expanded_result then
					once_result_size := code.fi.type.local_type(code).expanded_class.size;
				else
					once_result_size := code.result_local.type.byte_size;
				end;
			end;
		end; -- compile_once_body	

feature { SYSTEM }
	
	once_result_size: INTEGER; -- size of Result of a once function

feature { NONE }

	no_successor: NO_SUCCESSOR is
		once
			!!Result.make
		end -- no_successor
		
--------------------------------------------------------------------------------

end -- INTERNAL_ROUTINE
