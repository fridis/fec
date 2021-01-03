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

class COMPILE_READ_ATTRIBUTE

-- this class provides a feature compile_read_attribute used by ATTRIBUTE, 
-- MANIFEST_CONSTANT_VALUE and UNIQUE_VALUE to create a routine that returns
-- the attribute's value as it's result.

inherit
	COMPILE_ASSIGN;
	
creation -- do not create objects of this class, inherit from it to use its features

--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

feature { NONE } -- this is to be used in unqualified calls only

	compile_attribute_access_routine(code: ROUTINE_CODE; src: VALUE) is
	-- create routine that returns src. src and result of type code.fi.type.
		local
			basic: BASIC_BLOCK;
			dst_offset: INTEGER;
			dst: LOCAL_VAR;
			dst_is_indirect: BOOLEAN;
		do
			-- prolog
			basic := recycle.new_block(basic.weight_normal);
			code.set_first_block(basic);
			-- write to result
			dst := code.result_local;
			if code.expanded_result then
				dst_offset := 0;
				dst_is_indirect := true;
			end;
			compile_assign.clone_or_copy(code,
			                             code.fi.type,
			                             code.fi.type,
			                             src,
			                             dst,
			                             dst_offset,
			                             dst_is_indirect);
			-- epilog
			code.finish_block(no_successor,Void);
		end; -- compile_attribute_access_routine

	no_successor: NO_SUCCESSOR is
		once
			!!Result.make
		end -- no_successor

--------------------------------------------------------------------------------
	
end -- COMPILE_READ_ATTRIBUTE
