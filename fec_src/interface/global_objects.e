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

class GLOBAL_OBJECTS

-- This class contains features that should be globally accessible for 
-- performance or convenience. 
--
-- It also collects some statistical information.

inherit
	DATATYPE_SIZES; 

creation
	make

--------------------------------------------------------------------------------
	
feature

	make is
		do 
		end; -- make

--------------------------------------------------------------------------------

-- constant string ids:

	string_current,
	string_result,
	string_any,
	string_general,
	string_none,
	string_integer,
	string_real,
	string_double,
	string_boolean,
	string_character,
	string_pointer,
	string_string,
	string_array,
	string_bit_n,
	string_ref,
	string_code,
	string_to_integer,
	string_to_character,
	string_to_pointer,
	string_truncated_to_integer,
	string_to_real,
	string_to_double,
	string_three_way_comparison,
	string_prefix_plus,    
	string_prefix_minus,    
	string_prefix_not,    
	string_infix_equal,
	string_infix_not_equal,
	string_infix_less,
	string_infix_less_or_equal,
	string_infix_greater,
	string_infix_greater_or_equal,
	string_infix_and_then,
	string_infix_or_else, 
	string_infix_and,     
	string_infix_or,      
	string_infix_xor,      
	string_infix_implies,
	string_infix_plus,      
	string_infix_minus,      
	string_infix_times,      
	string_infix_div,        
	string_infix_mod,      
	string_infix_divide,      
	string_infix_power,
	string_infix_at,
	string_void,
	string_clone,
	string_copy,
	string_standard_clone,
	string_standard_copy,
	string_standard_is_equal,
	string_equal,
	string_put,
	string_item,
	string_element_size,
	string_storage,
	string_make,
	string_allocate_object,
	string_conforms_to_number,
	string_std_clone_name,
	string_std_copy_name,
	string_make_from_mem,
	string_memcpy,
	string_memset,
	string_dot_mul,
	string_dot_div,
	string_dot_rem,
	string_color_prefix,
	string_init_trace,
	string_check_failed,
	string_void_reference,
	string_precondition_failed,
	string_source_file_names: INTEGER;
	
--------------------------------------------------------------------------------

-- basic types

	type_boolean: CLASS_TYPE;
	type_character: CLASS_TYPE;
	type_integer: CLASS_TYPE;
	type_real: CLASS_TYPE;
	type_double: CLASS_TYPE;
	type_string: CLASS_TYPE;
	type_any: CLASS_TYPE;
	type_general: CLASS_TYPE;
	type_pointer: CLASS_TYPE;
	type_bit: CLASS_TYPE;
	type_none: CLASS_TYPE;

-- types of local_var
	
	local_reference: LOCAL_TYPE;
	local_pointer: LOCAL_TYPE;
	local_integer: LOCAL_TYPE;
	local_character: LOCAL_TYPE;
	local_boolean: LOCAL_TYPE;
	local_real: LOCAL_TYPE;
	local_double: LOCAL_TYPE;

-- name of reference class that is actual generic parameter

	ref_class_name: ACTUAL_CLASS_NAME;
	
	general_class_name: ACTUAL_CLASS_NAME;

	general_ancestor_name: ANCESTOR_NAME;

--------------------------------------------------------------------------------
		
	allocate is
		do 
			string_current                := strings # "current";
			string_result                 := strings # "result";
			string_any                    := strings # "any";
			string_general                := strings # "general";
			string_none                   := strings # "none";
			string_integer                := strings # "integer";
			string_real                   := strings # "real";
			string_double                 := strings # "double";
			string_boolean                := strings # "boolean";
			string_character              := strings # "character";
			string_pointer                := strings # "pointer";
			string_string                 := strings # "string";
			string_array                  := strings # "array";
			string_bit_n                  := strings # "bit_n";
			string_ref                    := strings # "_ref";
			string_code                   := strings # "code";
			string_to_integer             := strings # "to_integer";
			string_to_character           := strings # "to_character";
			string_to_pointer             := strings # "to_pointer";
			string_truncated_to_integer   := strings # "truncated_to_integer";
			string_to_real                := strings # "to_real";
			string_to_double              := strings # "to_double";
			string_three_way_comparison   := strings # "three_way_comparison";
			string_prefix_plus            := strings # "++";    
			string_prefix_minus           := strings # "+-";    
			string_prefix_not             := strings # "+not";    
			string_infix_equal            := strings # "*=";
			string_infix_not_equal        := strings # "*/=";
			string_infix_less             := strings # "*<";
			string_infix_less_or_equal    := strings # "*<=";
			string_infix_greater          := strings # "*>";
			string_infix_greater_or_equal := strings # "*>=";
			string_infix_and_then         := strings # "*and then";
			string_infix_or_else          := strings # "*or else"; 
			string_infix_and              := strings # "*and";     
			string_infix_or               := strings # "*or";      
			string_infix_xor              := strings # "*xor";      
			string_infix_implies          := strings # "*implies";
			string_infix_plus             := strings # "*+";      
			string_infix_minus            := strings # "*-";      
			string_infix_times            := strings # "**";      
			string_infix_div              := strings # "*//";      
			string_infix_mod              := strings # "*\\";      
			string_infix_divide           := strings # "*/";      
			string_infix_power            := strings # "*^";
			string_infix_at               := strings # "*@";
			string_void                   := strings # "void";
			string_clone                  := strings # "clone";
			string_copy                   := strings # "copy";
			string_standard_clone         := strings # "standard_clone";
			string_standard_copy          := strings # "standard_copy";
			string_standard_is_equal      := strings # "standard_is_equal";
			string_equal                  := strings # "equal";
			string_put                    := strings # "put";
			string_item                   := strings # "item";
			string_element_size           := strings # "element_size";
			string_storage                := strings # "storage";
			string_make                   := strings # "make";
			string_allocate_object        := strings # allocate_object;
			string_conforms_to_number     := strings # conforms_to_number;
			string_std_clone_name         := strings # std_clone_name;
			string_std_copy_name          := strings # std_copy_name;
			string_make_from_mem          := strings # make_from_mem;
			string_memcpy                 := strings # memcpy;
			string_memset                 := strings # memset;
			string_dot_mul                := strings # dot_mul;
			string_dot_div                := strings # dot_div;
			string_dot_rem                := strings # dot_rem;
			string_color_prefix           := strings # color_prefix;
			string_init_trace             := strings # init_trace;
			string_check_failed           := strings # check_failed;
			string_void_reference         := strings # void_reference;
			string_precondition_failed    := strings # precondition_failed;
			string_source_file_names      := strings # source_file_names;
memstats(104);
memstats(105);
memstats(106);
memstats(107);
memstats(108);
memstats(109);
memstats(110);
memstats(111);
memstats(112);
memstats(113);
			!!type_boolean.make_standard  (string_boolean);
			!!type_character.make_standard(string_character);
			!!type_integer.make_standard  (string_integer);
			!!type_real.make_standard     (string_real);
			!!type_double.make_standard   (string_double);
			!!type_string.make_standard   (string_string);
			!!type_any.make_standard      (string_any);
			!!type_general.make_standard  (string_general);
			!!type_pointer.make_standard  (string_pointer);
			!!type_bit.make_bit;
			!!type_none.make_standard     (string_none);
			
			!!ref_class_name.make(string_ref,false,false,Void);
			!!general_class_name.make(string_general,false,false,Void);
			!!general_ancestor_name.make_class_type(string_general,Void);
			
			!!local_reference.make_reference;
			!!local_pointer.make_pointer;
			!!local_integer.make_integer;
			!!local_character.make_character;
			!!local_boolean.make_boolean;
			!!local_real.make_real;
			!!local_double.make_double;
		end; -- allocate

--------------------------------------------------------------------------------

-- compilation options:

feature { ANY }

	create_trace_code: BOOLEAN;        -- do we have to trace the call graph?
	create_gc_code: BOOLEAN is FALSE;  -- do we need gc code?
	
	create_reference_check : BOOLEAN;
	create_require_check   : BOOLEAN;
	create_ensure_check    : BOOLEAN;
	create_invariant_check : BOOLEAN;
	create_loop_check      : BOOLEAN;
	create_all_check       : BOOLEAN;
	create_debug_check     : BOOLEAN;
	
feature { FEC }

	set_no_check is
		do
			create_trace_code      := false;
			create_reference_check := false;
			create_require_check   := false;
			create_ensure_check    := false;
			create_invariant_check := false;
			create_loop_check      := false;
			create_all_check       := false;
			create_debug_check     := false;
		end; 
		
	set_reference_check is
		do
			create_trace_code      := true;
			create_reference_check := true;
			create_require_check   := false;
			create_ensure_check    := false;
			create_invariant_check := false;
			create_loop_check      := false;
			create_all_check       := false;
			create_debug_check     := false;
		end; 
	
	set_require_check is
		do
			create_trace_code      := true;
			create_reference_check := true;
			create_require_check   := true;
			create_ensure_check    := false;
			create_invariant_check := false;
			create_loop_check      := false;
			create_all_check       := false;
			create_debug_check     := false;
		end; 
		
	set_ensure_check is
		do
			create_trace_code      := true;
			create_reference_check := true;
			create_require_check   := true;
			create_ensure_check    := true;
			create_invariant_check := false;
			create_loop_check      := false;
			create_all_check       := false;
			create_debug_check     := false;
		end; 
		
	set_invariant_check is
		do
			create_trace_code      := true;
			create_reference_check := true;
			create_require_check   := true;
			create_ensure_check    := true;
			create_invariant_check := true;
			create_loop_check      := false;
			create_all_check       := false;
			create_debug_check     := false;
		end; 
		
	set_loop_check is
		do
			create_trace_code      := true;
			create_reference_check := true;
			create_require_check   := true;
			create_ensure_check    := true;
			create_invariant_check := true;
			create_loop_check      := true;
			create_all_check       := false;
			create_debug_check     := false;
		end; 
		
	set_all_check is
		do
			create_trace_code      := true;
			create_reference_check := true;
			create_require_check   := true;
			create_ensure_check    := true;
			create_invariant_check := true;
			create_loop_check      := true;
			create_all_check       := true;
			create_debug_check     := false;
		end; 
		
	set_debug_check is
		do
			create_trace_code      := true;
			create_reference_check := true;
			create_require_check   := true;
			create_ensure_check    := true;
			create_invariant_check := true;
			create_loop_check      := true;
			create_all_check       := true;
			create_debug_check     := true;
		end; 

--------------------------------------------------------------------------------

-- load path support

feature { CLASSES }

	loadpath : ARRAY [STRING] is
		once
			!!Result.make(1,10);
		end; -- loadpath
	
	num_loadpaths: INTEGER;

feature { FEC }

	add_loadpath(path: STRING) is
		do
			if num_loadpaths = loadpath.upper then
				loadpath.resize(1,2*num_loadpaths);
			end;
			num_loadpaths := num_loadpaths + 1;
			loadpath.put(path,num_loadpaths);
		end; -- add_loadpath

--------------------------------------------------------------------------------

-- Linking

feature { CLASS_CODE, SYSTEM }

	object_file_names: STRING is
	-- this is a concatenation of the names of all object files created,
	-- separated by spaces.
		once
			!!Result.make(512);
		end; -- object_file_name

	linker: STRING; -- "gcc" or "cc"
	executable: STRING; -- name of executable program to create
	
feature { FEC }

	set_linker (new_linker: STRING) is
		do
			linker := new_linker;
		end; -- set_linker

	set_executable (new_executable: STRING) is
		do
			executable := new_executable;
		end; -- set_executable

--------------------------------------------------------------------------------

-- tuning and statistics

feature { ANY }

	routine_stats(num_locals: INTEGER; is_inherited: BOOLEAN) is 
		do
			num_routines := num_routines + 1;
			total_locals := total_locals + num_locals;
			if max_locals < num_locals then
				max_locals := num_locals
			end;
			if is_inherited then
				num_inherited := num_inherited + 1
			end;
		end; -- routine_stats;
		
	code_stats(num_insns: INTEGER) is
		do
			total_insns := total_insns + num_insns; 
		end; -- code_stats
		
	num_routines: INTEGER;
	total_locals: INTEGER;
	max_locals: INTEGER;
	num_inherited: INTEGER;
	total_insns: INTEGER;

--------------------------------------------------------------------------------
		
end -- GLOBAL_OBJECTS
