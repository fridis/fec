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

	description: "Commonly used input and output mechanisms. This %
	             %class may be used as either ancestor or supplier %
	             %by classes needing its facilities."

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";

class STD_FILES

feature -- Access

	default_output: FILE;
	-- Default output.
		
	error: FILE is
	-- Standard error file
		once
			!!Result.make_standard_error;
		end; -- error

	input: FILE is
	-- Standard input file
		once
			!!Result.make_standard_input;
		end; -- input

	output: FILE is
	-- Standard output file
		once
			!!Result.make_standard_output;
		end; -- output

	standard_default: FILE is
	-- Return the default_output or output
	-- if default_output is Void.
		do
			if default_output /= Void then
				Result := default_output
			else
				Result := output
			end; 
		end; -- standard_default

feature -- Status report

	last_character: CHARACTER;
	-- Last charactter read by read_character

	last_double: DOUBLE;
	-- Last doublue read by read_double

	last_integer: INTEGER;
	-- Last integer read by read_integer

	last_real: REAL;
	-- Last real read by read_real

	last_string: STRING;
	-- Last string read by read_line, 
	-- read_stream, or read_word

feature -- Output

	put_boolean (b: BOOLEAN) is
	-- Write b at end of default output.
		do
			standard_default.put_boolean(b);
		end; -- put_boolean

	put_character (c: CHARACTER) is
	-- Write c at end of default output.
		do
			standard_default.put_character(c);
		end; -- put_character

	put_double (d: DOUBLE) is
	-- Write d at end of default output.
		do
			standard_default.put_double(d);
		end; -- put_double

	put_integer (i: INTEGER) is
	-- Write i at end of default output.
		do
			standard_default.put_integer(i);
		end; -- put_integer

	put_new_line is
	-- Write line feed at end of default output.
		do
			put_string("%N");
		end; -- put_new_line

	put_real (r: REAL) is
	-- Write r at end of default output.
		do
			standard_default.put_real(r);
		end; -- put_real

	put_string (s: STRING) is
	-- Write s at end of default output.
		require
			s /= Void
		do
			standard_default.put_string(s);
		end; -- put_string

	set_error_default is
	-- Use standard error as default output.
		do
			default_output := error;
		end; -- set_error_default
		
	set_output_default is
	-- Use standard output as default output.
		do
			default_output := output;
		end; -- set_output_default
		
feature -- Input

	read_character is
	-- Read a new character from standard input. 
	-- Make result available in last_character.
		do
			input.read_character;
			last_character := input.last_character;
		end; -- read_character

	read_double is
	-- Read a new double from standard input. 
	-- Make result available in last_double.
		do
			input.read_double;
			last_double := input.last_double;
		end; -- read_double

	read_integer is
	-- Read a new integer from standard input. 
	-- Make result available in last_integer.
		do
			input.read_integer;
			last_integer := input.last_integer;
		end; -- read_integer

	read_line is
	-- Read a line from standard input. 
	-- Make result available in last_string.
	-- New line will be consumed but not part of last_string.
		do
			if last_string=Void then
				!!last_string.make(256);
			end;
			input.read_line;
			last_string.wipe_out;
			last_string.append_string(input.last_string);
		end; -- read_line

	read_real is
	-- Read a new real from standard input. 
	-- Make result available in last_real.
		do
			input.read_real;
			last_real := input.last_real;
		end; -- read_real

	read_stream (nb_char: INTEGER) is
	-- Read a string of at most nb_char bound characters
	-- from standard input. 
	-- Make result available in last_string.
		do
			if last_string=Void then
				!!last_string.make(256);
			end;
			input.read_stream(nb_char);
			last_string.wipe_out;
			last_string.append_string(input.last_string);
		end; -- read_stream

	read_word is
	-- Read a new word from standard input. 
	-- Make result available in last_string.
		do
			if last_string=Void then
				!!last_string.make(256);
			end;
			input.read_word;
			last_string.wipe_out;
			last_string.append_string(input.last_string);
		end; -- read_stream

	to_next_line is
	-- Move to next input line on standard input.
		do
			input.read_line;
		end; -- to_next_line

end -- STD_FILES
