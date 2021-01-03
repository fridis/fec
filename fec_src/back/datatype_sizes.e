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

class DATATYPE_SIZES

-- The sizes of data types and names of symbols in the 
-- target machine.

feature

-- Sizes of basic data types:

	reference_size: INTEGER is 4;
	integer_size  : INTEGER is 4;
	character_size: INTEGER is 1;
	boolean_size  : INTEGER is 1;
	real_size     : INTEGER is 4;
	double_size   : INTEGER is 8;

--------------------------------------------------------------------------------

	align (adr,size: INTEGER): INTEGER is
	-- find the next adress >=adr at which an object with size bytes 
	-- can be stored with correct alignment. size must be padded using
	-- pad_size().
		do
			if size > 4 then
				Result := (adr + 7) // 8 * 8;
			elseif size = 4 then
				Result := (adr + 3) // 4 * 4;
			elseif size = 2 then
				Result := (adr + 1) // 2 * 2;
			else
				Result := adr;
			end;
		end; -- align
		
	pad_size (size: INTEGER): INTEGER is
	-- Add pad bytes to an Object's size if they are needed. Return the new size.
		do
			if size > 4 then
				Result := (size + 7) // 8 * 8 -- align to 8 bytes
			elseif size = 3 then
				Result := 4        -- do not allow 3 byte objects
			else
				Result := size;    -- 1, 2 and 4 Bytes are ok.
			end;
		end; -- pad_size
		
--------------------------------------------------------------------------------

-- Offsets in type descriptors:

	obj_type_descr_offset: INTEGER is -4;   -- Offset of type descriptor pointer in heap object

	td_type_id: INTEGER is 0;               -- Offset of Type Id entry in type descriptor. This is an 
	                                        -- integer that holds one of the following constatns.
	
	type_id_expanded: INTEGER is -1;
	type_id_reference: INTEGER is 0;
	type_id_integer: INTEGER is 1;
	type_id_pointer: INTEGER is 2;
	type_id_character: INTEGER is 3;
	type_id_boolean: INTEGER is 4;
	type_id_real: INTEGER is 5;
	type_id_double: INTEGER is 6;
	
	td_size: INTEGER is 4;                  -- Offset of size entry in Object (this holds reference_size
	                                        -- for reference types

	-- All the following td entries are only present for
	-- type_id = type_id_expanded or type_id_reference.
	                                                                                
	td_actual_generics: INTEGER is 8;       
	                                        -- td_actual_generics is a null terminated array of pointers
	                                        -- to the type descriptors of this class' actual generic
	                                        -- arguments. It is null for a non-generic class.
	
	td_name: INTEGER is 12;                 -- pointer to a null terminated C-string for the name of 
	                                        -- this type, eg. "STACK[expanded C]"
	                                        
	td_attributes: INTEGER is 16;           -- pointer to array of null terminated array describing the
	                                        -- variable attributes of this type. This array has 3 entries
	                                        -- for each attribute: a pointer to its type descriptor, the
	                                        -- attribute offset and a pointer to a null terminated string
	                                        -- for the name of the attribute.

	-- All the following td entries are only present for 
	-- type_id = type_id_reference.
	
	td_object_size: INTEGER is 20;          -- Offset of object_size entry. This holds the number of 
	                                        -- bytes to be allocated on creation of a heap object. This
	                                        -- does only include the storage needed for the object's 
	                                        -- attributes, not for the type descriptor pointer and any
	                                        -- additional information the memory management might need.

	td_color: INTEGER is 24;                -- color of this type descriptor (a multiple of reference_size)

	td_number: INTEGER is 28;               -- number of this type descriptor (0,1,2,...)
	
	td_true_types: INTEGER is 32;           -- This points to a list of type_descriptors of objects
	                                        -- the routines of this class create. This is used for creation
	                                        -- of those objects whose type depend on actual generics that
	                                        -- are references and therefore cannot be determined at 
	                                        -- compile time of the creation instruction
	
	td_ancestors: INTEGER is 36;            -- Offset of a pointer to the array of ancestors of this
	                                        -- class. This is a list of numbers of the true_classes of the
	                                        -- ancestors. The last value is -1.
	                                        
	td_feature_descriptor: INTEGER is 40;   -- Starting at this offset the type descriptor holds the array
	                                        -- of feature descriptor pointer. For each ancestor a, 
	                                        -- td_feature_descriptor + reference_size * color(a) hold
	                                        -- a refernce to the feature descriptor for this ancestor. 
	                                        -- all other entries are null.

--------------------------------------------------------------------------------

-- Offsets in feature descriptors:
	
	fd_feature_array: INTEGER is 0;         -- Offset of first feature entry in feature descriptor

--------------------------------------------------------------------------------

-- Offsets in stack descriptor

	stack_trace_offset: INTEGER is 64;      -- Offset of stack descriptor pointer relative to stack pointer
	
	stack_size: INTEGER is 0;               -- size of stack frame in bytes
	stack_name: INTEGER is 4;               -- pointer to name of routine

--------------------------------------------------------------------------------

-- Position and Tag descriptor for runtime messages:

	pos_and_tag_size: INTEGER is 16;        -- Size of position and Tag record;
	
	pos_and_tag_srcname: INTEGER is  0;     -- Offset of fields of pos_and_tag record
	pos_and_tag_line   : INTEGER is  4; 
	pos_and_tag_column : INTEGER is  8; 
	pos_and_tag_tag    : INTEGER is 12;     -- Tag string or null.
	
	const_pos_and_tags_prefix: STRING is "pos#";  -- in trace mode: Positions and Tags in source text

--------------------------------------------------------------------------------
	
-- Symbols used in object files

	precondition_prefix: STRING is "prec#"; -- Routine checking precondition, e.g. "prec#stack[integer].top"

	color_prefix: STRING is "color#";       -- Index of class in type descriptor, e.g. "color#stack[r#integer]"

	number_prefix: STRING is "number#";     -- Unique number of this true_class in the system, e.g. "number#stack[r#integer]

	typedescr_prefix: STRING is "type#";    -- Type descriptor of actual class, e.g. "type#stack[r#integer]"

	featdescr_prefix: STRING is "feat#";    -- Type feature of ancestor of actual class, e.g. "feat#stack[r#integer]#collection[r#integer]"
	
	generics_prefix: STRING is "generics#"; -- List of actual generics for in a type descriptor

	true_types_prefix: STRING is "ttypes#"; -- List of true types used in the code of the actual_class

	ancestors_prefix: STRING is "ancestors#"; -- List of ancestors of a true_class
	
	init_prefix: STRING is "init#";         -- actual class initialization (alloc strings etc.) is at "feat#stack[_ref]"

	const_string_prefix: STRING is "string#";  -- Const string objects are stored at "strings#CLASS#1", "strings#CLASS#2",...
	const_chars_prefix: STRING is "chars#";  -- chars of all const string objects are stored at "chars#CLASS"

	const_reals_prefix: STRING is "reals#";       -- real constants are stored at "reals#CLASS"
	const_doubles_prefix: STRING is "doubles#";   -- double constants are stored at "doubles#CLASS"
	
	const_bit_suffix: STRING is ".bit#";  -- bit constants are stored at "CLASS.bit#1", "CLASS.bit#2",...
	
	constant_prefix: STRING is "constant#"; -- Bit_constant and Strings are stored at "constant#1", "constant#2",...
	
	stack_trace_prefix: STRING is "stack#";    -- Stack frame descriptors are stored at "stack#<class>.<feature>"
	source_file_names: STRING is "eiffel_src_file_names";  -- In trace mode: global array of the names of all source files involved.
	
	explicit_expanded_prefix: STRING is "x#";  -- prefixes for actual_class_name and true_class_name
	explicit_reference_prefix: STRING is "r#";

--------------------------------------------------------------------------------

-- Routines

	allocate_object: STRING is "eiffel_new";  -- Routine to allocate a new object on the heap. Has one argument
	                                          -- that points to the new objects type descriptor.

	conforms_to_number: STRING is "eiffel_conforms_to_number";  -- Routine that tests if heap object (2nd argument)
	                                          -- conforms the true type with the number given as first argument.

	std_copy_name: STRING is "std_copy";      -- std_copy(typedescr,$dst,$src) kopiert src auf dst
	
	std_clone_name: STRING is "std_clone";    -- std_clone(typedescr,$src): _ref alloziert neues Objekt und kopiert src darauf

	make_from_mem: STRING is "make_from_mem"; -- Routine of STRING. Receives 2 arguments: adr and length. It uses the characters
	                                          -- in memory starting at adr to create a string of length len.

	memcpy: STRING is "memcpy";               -- memcpy($dst,$src,size), copies size bytes from src to dst

	memset: STRING is "memset";               -- memset($dst,value,size), fills size bytes at dst with value

	dot_mul: STRING is ".mul";                -- Integers mul/div/mod
	dot_div: STRING is ".div";
	dot_rem: STRING is ".rem";
	
	init_trace: STRING is "eiffel_init_trace";   -- called on initialization to record first stack frame
	
	check_failed: STRING is "eiffel_check_failed";      -- called if check instruction failed
	void_reference: STRING is "eiffel_void_reference";  -- called when a void reference is used
	precondition_failed: STRING is "eiffel_precondition_failed"; -- called when a precondition is false

--------------------------------------------------------------------------------

-- entries in bss area (global variables):

	argc_name: STRING is "eiffel_argc";
	argv_name: STRING is "eiffel_argv";

	once_called_prefix: STRING is "once_called#";     -- for every once-routine there is a global variable "once_called#CLASS.feature"
	once_result_prefix: STRING is "once_result#";     -- for every once-function there is a global variable "once_result#CLASS.feature"

--------------------------------------------------------------------------------

-- build symbol name with prefix:

	get_symbol_name (name_prefix,name: INTEGER): INTEGER is
	-- get id of symbol consisting of name_prefix and name.
		require 
			name /= 0; -- name_prefix may be 0.
		do
			if name_prefix /= 0 then
				tmp_symbol_name.copy(strings @ name_prefix);
				tmp_symbol_name.append_character('.');
			else
				tmp_symbol_name.wipe_out;
			end; 
			tmp_symbol_name.append(strings @ name);
			Result := strings # tmp_symbol_name; 
		end; -- get_symbol_name

	get_precondition_name (type_name,feature_name: INTEGER): INTEGER is
	-- get id of precodition routine of feature_name in class type_name
		require 
			type_name /= 0;
			feature_name /= 0; 
		do
			tmp_symbol_name.copy(precondition_prefix);
			tmp_symbol_name.append(strings @ type_name);
			tmp_symbol_name.append_character('.');
			tmp_symbol_name.append(strings @ feature_name);
			Result := strings # tmp_symbol_name; 
		end; -- get_precondition_name
		
	color_name (type_name: INTEGER): INTEGER is
	-- get symbol of color number for true class type_name.
		do
			tmp_symbol_name.copy(color_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name; 
		end; -- color_name
		
	number_name (type_name: INTEGER): INTEGER is
	-- get symbol of number for true class type_name.
		do
			tmp_symbol_name.copy(number_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name; 
		end; -- number_name

	type_descriptor_name(type_name: INTEGER): INTEGER is
	-- get id of symbol of type descriptor
		do
			tmp_symbol_name.copy(typedescr_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name; 
		end; -- type_descriptor_name

	generics_name(type_name: INTEGER): INTEGER is
	-- get id of symbol of generics list in type descriptor
		do
			tmp_symbol_name.copy(generics_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name; 
		end; -- generics_name

	true_types_name(type_name: INTEGER): INTEGER is
	-- get id of symbol of list of true_types used by this actual_class (td_true_types)
		do
			tmp_symbol_name.copy(true_types_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name; 
		end; -- true_types_name

	ancestors_name (type_name: INTEGER): INTEGER is
	-- get id of symbol of list of ancestors used of this true_class (td_ancestors)
		do
			tmp_symbol_name.copy(ancestors_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name; 
		end; -- ancestors_name

	feature_descriptor_name(new_class,ancestor: ACTUAL_CLASS_NAME): INTEGER is
		do
			tmp_symbol_name.copy(featdescr_prefix);
			tmp_symbol_name.append(strings @ new_class.code_name);
			tmp_symbol_name.append_character('#');
			tmp_symbol_name.append(strings @ ancestor.code_name);
			Result := strings # tmp_symbol_name;
		end; -- 	feature_descriptor_name

	const_string_name(type_name: INTEGER; string_num: INTEGER): INTEGER is
		do
			tmp_symbol_name.copy(const_string_prefix);
			tmp_symbol_name.append(strings @ type_name);
			tmp_symbol_name.append_character('#');
			tmp_symbol_name.append_integer(string_num);
			Result := strings # tmp_symbol_name
		end; -- const_string_name

	const_chars_name(type_name: INTEGER): INTEGER is
		do
			tmp_symbol_name.copy(const_chars_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name
		end; -- const_chars_name

	const_reals_name(type_name: INTEGER): INTEGER is
		do
			tmp_symbol_name.copy(const_reals_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name
		end; -- const_reals_name

	const_doubles_name(type_name: INTEGER): INTEGER is
		do
			tmp_symbol_name.copy(const_doubles_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name
		end; -- const_doubles_name

	const_pos_and_tags_name(type_name: INTEGER): INTEGER is
		do
			tmp_symbol_name.copy(const_pos_and_tags_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name
		end; -- const_pos_and_tags_name

	initialization_name(type_name: INTEGER): INTEGER is
		do
			tmp_symbol_name.copy(init_prefix);
			tmp_symbol_name.append(strings @ type_name);
			Result := strings # tmp_symbol_name
		end; -- initialization_name

	once_called_name(fi: FEATURE_INTERFACE): INTEGER is
	-- class_name is the name of the PARSE_CLASS, ie. w/o generics
		do
			tmp_symbol_name.copy(once_called_prefix);
			tmp_symbol_name.append(strings @ fi.origin.name);
			tmp_symbol_name.append_character('.');
			tmp_symbol_name.append(strings @ fi.seed.key);
			Result := strings # tmp_symbol_name
		end; -- once_called_name
		
	once_result_name(fi: FEATURE_INTERFACE): INTEGER is
	-- class_name is the name of the PARSE_CLASS, ie. w/o generics
		do
			tmp_symbol_name.copy(once_result_prefix);
			tmp_symbol_name.append(strings @ fi.origin.name);
			tmp_symbol_name.append_character('.');
			tmp_symbol_name.append(strings @ fi.seed.key);
			Result := strings # tmp_symbol_name
		end; -- once_result_name
		
	stack_trace_name(feature_symbol: INTEGER): INTEGER is
	-- name of stack descriptor for given routine
		do
			tmp_symbol_name.copy(stack_trace_prefix);
			tmp_symbol_name.append(strings @ feature_symbol);
			Result := strings # tmp_symbol_name
		end; -- stack_trace_name

--------------------------------------------------------------------------------

	main_code_name: STRING is "_eiffel_main"; -- dummy name for machine code for system creation

--------------------------------------------------------------------------------

feature { NONE }

	tmp_symbol_name: STRING is
		once
			!!Result.make(128);
		end; -- tmp_symbol_name

--------------------------------------------------------------------------------

	
end -- DATATYPE_SIZES
