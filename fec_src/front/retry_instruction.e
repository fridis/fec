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

class RETRY_INSTRUCTION

inherit
	SCANNER_SYMBOLS;
	INSTRUCTION;
	
creation
	parse
	
--------------------------------------------------------------------------------
	
feature { ANY }

	position: POSITION; 

--------------------------------------------------------------------------------

	parse (s: SCANNER) is
	-- Retry = "retry".
		require
			s.current_symbol.type = s_retry
		do
			position := s.current_symbol.position;
			s.next_symbol;
		end; -- parse
		
--------------------------------------------------------------------------------

	validity (fi: FEATURE_INTERFACE) is
		do
			if not fi.doing_rescue then
				position.error(msg.vxrt1); 
			end;
		end; -- validity
		
--------------------------------------------------------------------------------
-- CODE GENERATION:                                                           --		
--------------------------------------------------------------------------------

	compile(code: ROUTINE_CODE) is
		do
			-- nyi:
		end; -- compile		
		
--------------------------------------------------------------------------------

end -- RETRY_INSTRUCTION	
