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

class ERROR_STATUS

-- Global statistics on the number of errors found. 
-- This is also used to restrict reported error messages to the first corrupt
-- class that was encountered. 

creation 
	make
	
feature

	error_count: INTEGER; 
	
	first_error_found_in: STRING; -- file name of file containing first error
	
	make is
		do
			error_count := 0
		end;
		
	inc_error_count is 
		do
			error_count := error_count + 1
		end; -- inc_error_count
		
	set_first(to: STRING) is
		do
			first_error_found_in := to;
		end; -- set_first
		
	report_to(new: STRING): BOOLEAN is
		do
			if first_error_found_in=Void then
				first_error_found_in := new
			end;
			Result := new=first_error_found_in
		end; -- report_to
	
end -- ERROR_STATUS
