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

expanded class POSITION 

-- source code position

inherit 
	FRIDISYS;
	ERRORS;
	CLASSES;
	
--------------------------------------------------------------------------------

feature { NONE }

	pos : INTEGER; 

feature { ANY }
	
	line : INTEGER is 
		do
			Result := pos \\ 4096; 
		end; -- line

	column : INTEGER is 
		do
			Result := pos // 4096 \\ 256; 
		end; -- column
	
	source_file_name : STRING is 
		local
			i: INTEGER; 
		do
			i := pos // (256*4096); 
			if i>=1023 then
				Result := "__unknown file";
			else
				Result := (scanners @ (pos // (256*4096))).source_file_name
			end;
		end; -- source_file_name 

	source_file_number: INTEGER is
	-- scanners @ source_file_number contains this source text position.
	-- Result is 0 if the file is unknown.
		local
			i: INTEGER; 
		do
			Result := pos // (256*4096);
			if Result>=1023 then
				Result := 0;
			end;
		end; -- source_file_number

--------------------------------------------------------------------------------

feature { SCANNER }

	init (l,c,f: INTEGER) is
		local
			ll,lc,lf: INTEGER; 
		do
			ll := l; lc := c; lf := f;
			if ll > 4095 then ll := 4095 end;
			if lc >  255 then lc := 255 end;
			if lf > 2047 then lf := 2047 end;
			pos := l + 4096*c + (256*4096) * f;
		end;

--------------------------------------------------------------------------------

feature { ANY }

	error (msg_num: INTEGER) is  
	-- display error message at specified position. The printed message is
	-- msg @ msg_num.
		do
			error_str(msg @ msg_num);
		end; -- error
	
	error_m(texts: ARRAY[STRING]) is -- display concatenation of multiple strings as error message.
		do
			error_str(get_msg(texts));
		end; -- error_m

	warning (msg_num: INTEGER) is  -- display warning message at specified position
		do
			warning_str(msg @ msg_num);
		end; -- warning

	warning_m (texts: ARRAY[STRING]) is -- display concatenation of multiple strings as warning message
		do
			warning_str(get_msg(texts));
		end; -- warning_m

--------------------------------------------------------------------------------

feature { NONE }

	error_str (msg_str: STRING) is  
	-- display error message at specified position. The printed message is
	-- msg @ msg_num.
		do
			if error_status.report_to(source_file_name) then
				msg.write(msg.error_in_file_a); 
				if source_file_name = Void then
					msg.write(msg.unknown_file);
				else
					write_string(source_file_name);
				end;
				msg.write(msg.error_in_file_b); write_integer(line);
				msg.write(msg.error_in_file_c); write_integer(column);
				msg.write(msg.error_in_file_d); 
				write_string(msg_str);
				msg.write(msg.lflf); 
				error_status.inc_error_count;
			end;
		end; -- error

	warning_str (msg_str: STRING) is  -- display warning message at specified position
		do
			if error_status.report_to(source_file_name) then
				msg.write(msg.warning_in_file_a); 
				if source_file_name = Void then
					msg.write(msg.unknown_file);
				else
					write_string(source_file_name);
				end;
				msg.write(msg.warning_in_file_b); write_integer(line)
				msg.write(msg.warning_in_file_c); write_integer(column)
				msg.write(msg.warning_in_file_d); 
				write_string(msg_str) 
				msg.write(msg.lflf);
			end;
		end; -- warning_str

	get_msg(texts: ARRAY[STRING]): STRING is -- get concatenation of multiple strings.
		local
			i,c: INTEGER;
		do
			from  i := texts.lower
			      c := 0
			until i > texts.upper
			loop  c := c + (texts @ i). count;
			      i := i + 1; 
			end;
memstats(212);
			!!Result.make(c);
			from  i := texts.lower
			until i > texts.upper
			loop  Result.append((texts @ i));
			      i := i + 1; 
			end;
		end; -- get_msg

--------------------------------------------------------------------------------
	
end -- POSITION	
	
