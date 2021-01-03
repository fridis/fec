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

deferred class MIDDLE_CALL_COMMAND   

-- A call 

inherit
	COMMAND;
	ACTUAL_CLASSES;
	FRIDISYS;
	
--------------------------------------------------------------------------------

feature { NONE }

	dynamic: LOCAL_VAR;     -- Ziel für dynamischen Call oder Void
	
	static: INTEGER;        -- Ziel für statischen Call oder 0 
	
	arguments: LIST[LOCAL_VAR];

--------------------------------------------------------------------------------

feature { ANY }
		
	make_static (code: ROUTINE_CODE;
	             name: INTEGER;
	             args: LIST[LOCAL_VAR]; 
	             res_type: LOCAL_TYPE) is
	-- Result is a local containing the routine's result
	-- args is not modified by this command, the same argument list might be used
	-- for different call commands, but different argument lists require the creation
	-- of different list objects.
		require
			name /= 0;
			args /= Void;
		do
			dynamic := Void;
			static := name;
			arguments := args;
			get_res_type(code,res_type);
		end; -- make_static

--------------------------------------------------------------------------------
		
	make_dynamic (code: ROUTINE_CODE;
	              to: LOCAL_VAR; 
	              args: LIST[LOCAL_VAR]; 
	              res_type: LOCAL_TYPE) is
	-- Result is a local containing the routine's result
	-- args is not modified by this command, the same argument list might be used
	-- for different call commands, but different argument lists require the creation
	-- of different list objects.
		require
			to.type.is_word;
			args /= Void;
		do
			dynamic := to;
			static := 0;
			arguments := args;
			get_res_type(code,res_type);
		end; -- make_dynamic

--------------------------------------------------------------------------------

feature { NONE }

	get_res_type (code: ROUTINE_CODE; res_type: LOCAL_TYPE) is
		deferred
		end; -- get_res_type

end -- MIDDLE_CALL_COMMAND
