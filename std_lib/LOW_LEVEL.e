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

indexing
	
	description: "Low level routines used by the compiler and some standard classes. %
	             %The features are not intended to be used by applications programs %
	             %They will change in future version without notice. Classess using %
	             %these features are not portable and will fail with future version %
	             %of the compiler.";
	
	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";

expanded class LOW_LEVEL

feature

-- type conversion

	eiffel_reference_to_pointer(ref: GENERAL): POINTER is
		external "C"
		alias "eiffel_reference_to_pointer"
		end;

-- memory allocation

	new (type: POINTER): NONE is
	-- allocate a new object. type is the new object's type descriptor.
	-- Result is pointer to new object.
	-- NOTE: Result type is NONE for easy assignment to a writeable of
	-- any reference type
	external "C"
	alias "eiffel_new"
	end; 

	malloc(size: INTEGER): POINTER is
	-- allocate size bytes
	external "C"
	alias "malloc"
	end;
	
	realloc(oldptr: POINTER; size: INTEGER): POINTER is
	-- reallocate memory 
	external "C"
	alias "realloc"
	end;

-- memory access
	
	memcpy(dst,src: POINTER; size: INTEGER) is
	-- copy mem[src..src+size-1] to mem[dst..dst+size-1]
	external "C"
	alias "memcpy"
	end;
	
	memset(src: POINTER; init: CHARACTER; size: INTEGER) is
	-- fill mem[src..src+size-1] with init.
	external "C"
	alias "memset"
	end;

	memcmp (s1,s2: POINTER; size: INTEGER): INTEGER is
	-- compare memory
	external "C"
	alias "memcmp"
	end;
	
	put_byte(adr: POINTER; offset: INTEGER; byte: CHARACTER) is
	-- mem[adr+offset] := byte
	external "C"
	alias "put_byte"
	end;

	get_byte(adr: POINTER; offset: INTEGER): CHARACTER is
	-- Result := mem[adr+offset]
	external "C"
	alias "get_byte"
	end;

-- Type descriptor access

	get_type (object: GENERAL): POINTER is
	-- get type descriptor of object
	external "C"
	alias "get_type"
	end;

	get_actual_generic (object: ANY; n: INTEGER): POINTER is
	-- get type descriptor of actual generic #n (numbering starts with 0)
	external "C"
	alias "get_actual_generic"
	end;
	
	get_type_id (type: POINTER): INTEGER is
	-- get the id of given type descriptor. Result is one of the constants
	-- defined below.
	external "C"
	alias "get_type_id"
	end;

	expanded_id : INTEGER is -1;
	reference_id: INTEGER is 0;
	integer_id  : INTEGER is 1;
	pointer_id  : INTEGER is 2;
	character_id: INTEGER is 3;
	boolean_id  : INTEGER is 4;
	real_id     : INTEGER is 5;
	double_id   : INTEGER is 6;
	
	get_type_size (type: POINTER): INTEGER is
	-- determine the size of objects of the specified type descriptor. For
	-- reference objects, this returns the size to store the reference, not the
	-- actual object's size
	external "C"
	alias "get_type_size"
	end;
	
	get_object_size (type: POINTER): INTEGER is
	-- This returns the size of objects allocated for a reference type.
	require
		get_type_id(type) = reference_id
	external "C"
	alias "get_object_size"
	end;

	eiffel_conforms_to (dst,src: ANY): ANY is
	-- does src object conform to dst object? returns src if true, null else
		external "C"
		alias "eiffel_conforms_to"
		end;

-- Files

	fopen(f,m: POINTER): POINTER is
	external "C"
	alias "fopen"
	end;

	fclose(file: POINTER): INTEGER is
	external "C"
	alias "fclose"
	end;

	fputc(c: CHARACTER; file: POINTER): CHARACTER is
	external "C"
	alias "fputc"
	end;

	fgetc(stream_pointer : POINTER): CHARACTER is
	external "C"
	alias "fgetc"
	end;
	
	feof(stream_pointer : POINTER): BOOLEAN is
	external "C"
	alias "feof"
	end;

	fflush(stream_pointer : POINTER): INTEGER is
	external "C"
	alias "fflush"
	end;

	eiffel_standard_input: POINTER is 
	external "C"
	alias "eiffel_standard_input"
	end;

	eiffel_standard_output: POINTER is 
	external "C"
	alias "eiffel_standard_output"
	end;

	eiffel_standard_error: POINTER is 
	external "C"
	alias "eiffel_standard_error"
	end;
	
-- Arguments

	argc: INTEGER is
	external "C"
	alias "eiffel_get_argc"
	end; -- argc
	
	eiffel_get_arg(num: INTEGER): POINTER is
	external "C"
	alias "eiffel_get_arg"
	end; -- eiffel_get_arg
		
-- Debugging

	writestr(s: POINTER) is
	-- write C-string to stdout
	external "C"
	alias "writestr"
	end;

end -- LOW_LEVEL
