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

class FRIDI_FILE_WRITE

-- An extension to SmallEiffel's STD_FILE_WRITE to write the binary
-- representation of REALs and DOUBLEs.

inherit 
	STD_FILE_WRITE;
	DATATYPE_SIZES;

creation 
	connect_to

feature { NONE }
   fwrite (ptr: POINTER; size,nmemb: INTEGER; stream: POINTER): INTEGER is
      external "IC"
      end;

feature { ANY }

	put_real_bits(r: REAL) is
		local
			written: INTEGER;
		do
			real := r;
			written := fwrite($real,1,real_size,output_stream);
		end; -- put_real_bits

	put_double_bits(d: DOUBLE) is
		local
			written: INTEGER;
		do
			double := d;
			written := fwrite($double,1,double_size,output_stream);
		end; -- put_double_bits

feature { NONE }

	real: REAL;
	double: DOUBLE;

end -- FRIDI_FILE_WRITE
