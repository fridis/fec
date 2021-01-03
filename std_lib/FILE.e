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

	description: "Files viewed as persistent sequences of characters"

	copyright: "Fridi's Eiffel Library Class, (c) 1997 F. Siebert";
	
class FILE

creation	{ ANY }	
	make, 
	make_create_read_write,
	make_open_append,
	make_open_read,
	make_open_read_write,
	make_open_write

creation { STD_FILES }
	make_standard_input,
	make_standard_output,
	make_standard_error
	
feature -- Creation

	make (fn: STRING) is
	-- Create file object with fn as file name.
		require
			string_exists: fn /= Void;
			string_not_empty: not fn.empty; 
		do
			!!name.make_from_string(fn);
			!!last_string.make(256);
			is_closed := true;
			is_open_read := false;
			is_open_write := false;
		ensure
			file_named: name.is_equal(fn);
			file_closed: is_closed
		end; -- make

	make_create_read_write (fn: STRING) is
	-- Create file object with fn as file name
	-- and open file for both reading and writing;
	-- create it if it does not exist.
		require
			string_exists: fn /= Void;
			string_not_empty: not fn.empty;
		do
			make(fn);
			open_read_write;
		ensure
			exists: exists;
			open_read: is_open_read;
			open_write: is_open_write;
		end; -- make_create_read_write

	make_open_append (fn: STRING) is
	-- Create file object with fn as file name
	-- and open file in append-only mode.
		require
			string_exists: fn /= Void;
			string_not_empty: not fn.empty;
		do
			make(fn);
			open_read_append;
		ensure
			exists: exists;
			open_append: is_open_append;
		end; -- make_open_append

	make_open_read (fn: STRING) is
	-- Create file object with fn as file name
	-- and open file in read mode.
		require
			string_exists: fn /= Void;
			string_not_empty: not fn.empty;
		do
			make(fn);
			open_read;
		ensure
			exists: exists;
			open_read: is_open_read;
		end; -- make_open_read

	make_open_read_write (fn: STRING) is
	-- Create file object with fn as file name
	-- and open file for both reading and writing.
		require
			string_exists: fn /= Void;
			string_not_empty: not fn.empty;
		do
			make(fn);
			open_read_write;
		ensure
			exists: exists;
			open_read: is_open_read;
			open_write: is_open_write;
		end; -- make

	make_open_write (fn: STRING) is
	-- Create file object with fn as file name
	-- and open file for writing;
	-- create it if it does not exist.
		require
			string_exists: fn /= Void;
			string_not_empty: not fn.empty;
		do
			make(fn);
			open_write;
		ensure
			exists: exists;
			open_write: is_open_write;
		end; -- make

feature { STD_FILES }

	make_standard_input is
	-- Create file object for standard input
		local
			low_level: LOW_LEVEL;
		do
			make("*");
			handle := low_level.eiffel_standard_input;
			is_closed := false;
			is_open_read := true;
		ensure
			open_read: is_open_read
		end; -- make_standard_input

	make_standard_output is
	-- Create file object for standard input
		local
			low_level: LOW_LEVEL;
		do
			make("*");
			handle := low_level.eiffel_standard_output;
			is_closed := false;
			is_open_write := true;
		ensure
			open_write: is_open_write
		end; -- make_standard_output

	make_standard_error is
	-- Create file object for standard input
		local
			low_level: LOW_LEVEL;
		do
			make("*");
			handle := low_level.eiffel_standard_error;
			is_closed := false;
			is_open_write := true;
		ensure
			open_write: is_open_write
		end; -- make_standard_error
			
feature -- Access

	name: STRING; -- File name
	
feature -- Measurement

	count: INTEGER; -- Size in bytes (0 if associated physical file)
	
feature -- Status report

	empty: BOOLEAN; -- Is structure empty?
	
	end_of_file: BOOLEAN is
	-- Has an EOF been detected?
		require
			opened: not is_closed
		local
			low_level: LOW_LEVEL;
		do
			Result := low_level.feof(handle);
		end; -- end_of_file
	
	exists: BOOLEAN is
	-- Does physical file exist?
		do
			if is_closed then
				-- nyi
			else
				Result := true
			end;
		end; -- exists
	
	is_closed: BOOLEAN; -- Is file closed?
	
	is_open_read: BOOLEAN; -- Is file open for reading?
	
	is_open_write: BOOLEAN; -- Is file open for writing?
	
	is_open_append: BOOLEAN; -- nyi: not specified by ELKS, but used in assertions
	
	is_plain_text: BOOLEAN is FALSE; -- Is file reserved for text (character sequences)?
	
	is_readable: BOOLEAN is
	-- Is file readable?
		require
			handle_exists: exists
		do
			Result := is_open_read;
		end; -- is_readable
	
	is_writable: BOOLEAN is
	-- Is file writeable?
		require
			handle_exists: exists
		do
			Result := extendible;
		end; -- is_writable
		
	extendible: BOOLEAN is
	-- nyi: ?!? not specified in ELKS
		do
			Result := is_open_write and is_writable;
		end; -- extendible
		
	last_character: CHARACTER; -- Last character read by read_character
	
	last_double: DOUBLE; -- Last double read by read_double
	
	last_integer: INTEGER; -- Last integer read by read_integer
	
	last_real: REAL; -- Last real read by read_real
	
	last_string: STRING;	-- Last string read by read_line, read_stream or read_word
	
feature -- Status setting

	close is
	-- Close file
		require
			medium_is_open: not is_closed
		local
			low_level: LOW_LEVEL;
			err: INTEGER;
		do
			err := low_level.fclose(handle);
			is_closed := true;
			is_open_read := false;
			is_open_write := false;
			is_open_append := false;
		ensure
			is_closed: is_closed
		end; -- close
		
	open_read is
	-- Open file in read_only mode.
		require
			is_closed: is_closed
		local
			low_level: LOW_LEVEL;
		do
			handle := low_level.fopen(name.to_external,("r").to_external);
			is_closed := false;
			is_open_read := true;
		ensure
			exists: exists;
			open_read: is_open_read
		end; -- open_read
		
	open_read_append is
	-- Open file in read and write-at-end mode; 
	-- create it if it does not exist.
		require
			is_closed: is_closed
		local
			low_level: LOW_LEVEL;
		do
			handle := low_level.fopen(name.to_external,("r+").to_external);
			is_closed := false;
			is_open_read := true;
			is_open_append := true;
		ensure
			exists: exists;
			open_read: is_open_read;
			open_append: is_open_append
		end; -- open_read_append
	
	open_read_write is
	-- Open file in read and write mode.
		require
			is_closed: is_closed
		local
			low_level: LOW_LEVEL;
		do
			handle := low_level.fopen(name.to_external,("r+").to_external);
			is_closed := false;
			is_open_read := true;
			is_open_write := true;			
		ensure
			exists: exists;
			open_read: is_open_read;
			open_write: is_open_write;
		end; -- open_read_write
		
	open_write is
	-- Open file in write_only mode;
	-- create it if it does not exist.
		require
			is_closed: is_closed
		local
			low_level: LOW_LEVEL;
		do
			handle := low_level.fopen(name.to_external,("w").to_external);
			is_closed := false;
			is_open_write := true;			
		ensure
			exists: exists;
			open_write: is_open_write
		end; -- open_write
		
feature -- Cursor movement

	to_next_line is
	-- Move to next input line.
		require
			readable: is_readable
		local
			c: CHARACTER;
		do
			from
				c := ' '
			until
				end_of_file or else c = '%N'
			loop
				read_character;
				c := last_character
			end;
		end; -- to_next_line
		
feature -- Element change

	change_name (new_name: STRING) is
	-- Change file name to new_name
		require
			not_new_name_void: new_name /= Void;
			file_exists: exists
		do
			-- nyi
		ensure
			name_changed: name.is_equal(new_name) 
		end; -- change_name	
	
feature -- Removal

	delete is
	-- Remove link with phyisical file; delete physical
	-- file if no more link.
		require
			exists: exists
		do
			-- nyi
		end; -- delete
		
	dispose is
	-- ensure this medium is closed when garbage-collected
		do
			-- nyi
		end; -- dispose
		
feature -- Input

	read_character is
	-- Read a new character. 
	-- Make result available in last_character.
		require
			readable: is_readable
		local
			low_level: LOW_LEVEL;
		do
			last_character := low_level.fgetc(handle);
		end; -- read_character
		
	read_double is
	-- Read the ASCII representation of a new double
	-- from file. Make result available in last_double.
	-- nyi: this does not allow exponents.
		require
			readable: is_readable
		local
			d, value: DOUBLE;
			c: CHARACTER;
			negative: BOOLEAN;
		do
			read_next_printable_character;
			-- sign: 
			negative := last_character='-';
			if negative or last_character='+' then
				read_character;
			end;
			-- read integral part:
			from
				d := 0;
				c := last_character;
			until
				c < '0' or c > '9'
			loop
				d := d * 10 + (c.code - ('0').code);
				if end_of_file then
					c := ' '
				else
					read_character;
					c := last_character;
				end;
			end;
			if c = '.' then
				-- read fractional part:
				from
					value := 1;
					read_character;
					c := last_character;
				until
					c < '0' or c > '9'
				loop
					value := value / 10;
					d := d + value * (c.code - ('0').code);
					if end_of_file then
						c := ' '
					else
						read_character;
						c := last_character;
					end;
				end;
			end;
			if negative then
				d := - d
			end;
			last_double := d;
		end; -- read_double
		
	read_integer is
	-- Read the ASCII representation of a new integer
	-- from file. Make result available in last_integer.
		require
			readable: is_readable
		local
			i: INTEGER;
			c: CHARACTER; 
			negative: BOOLEAN;
		do
			read_next_printable_character;
			-- sign: 
			negative := last_character='-';
			if negative or last_character='+' then
				read_character;
			end;
			-- digits:
			from
				i := 0;
				c := last_character;
			until
				c < '0' or c > '9'
			loop
				if negative then
					i := i * 10 - (c.code - ('0').code);
				else
					i := i * 10 + (c.code - ('0').code);
				end;
				if end_of_file then
					c := ' '
				else
					read_character;
					c := last_character;
				end;
			end;
			last_integer := i;
		end; -- read_integer
		
	read_line is
	-- Read a string until new line or end of file.
	-- Make result available in last_string.
	-- New line will be consumed but not part of last_string.
		require
			readable: is_readable
		local
			c: CHARACTER;
		do
			last_string.wipe_out;
			from
				read_character;
				c := last_character;
			until
				c = '%N'
			loop
				last_string.append_character(c);
				if end_of_file then
					c := '%N'
				else
					read_character;
					c := last_character;
				end;
			end;
		end; -- read_line
		
	read_real is
	-- Read the ASCII representation of a new real
	-- from file. Make result available in last_real.
		require
			readable: is_readable
		do
			read_double; 
			last_real := last_double.to_real;
		end; -- read_real
		
	read_stream (nb_char: INTEGER) is
	-- Read a string of at most nb_char bound characters
	-- or until end of file.
	-- Make result available in last_string.
		require
			readable: is_readable
		local
			remaining_chars: INTEGER;
		do
			last_string.wipe_out;
			from
				remaining_chars := nb_char;
			until
				end_of_file or
				remaining_chars <= 0
			loop
				read_character;
				last_string.append_character(last_character);
				remaining_chars := remaining_chars - 1;
			end;
		end; -- read_stream
	
	read_word is
	-- Read a new word from standard input.
	-- Make result available in last_string.
		local
			c: CHARACTER;
		do
			read_next_printable_character;
			-- read characters until white space found:
			last_string.wipe_out;
			if not end_of_file then
				from
				until
					c = ' '  or
					c = '%N' or 
					c = '%T' or
					c = '%F'
				loop
					last_string.append_character(c);
					if end_of_file then
						c := ' '
					else
						read_character;
						c := last_character;
					end;
				end;
			end;
		end; -- read_word
	
	read_next_printable_character is
	-- do read_character until first printable character or end of file
	-- encountered.
		local
			c: CHARACTER;
		do
			-- remove white space:
			from
				read_character;
				c := last_character;
			until
				end_of_file or
				c > '%/032/' and c < '%/128/' or
				c > '%/160/'
			loop
				read_character;
				c := last_character;
			end;
		end; -- read_next_printable_character
	
feature -- Output

	put_boolean (b: BOOLEAN) is
	-- Write ASCII value of b at current position.
	-- nyi: What is meant by ASCII value of a boolean?
		require
			extendible: extendible
		do
			if b then
				put_string("true")
			else
				put_string("false")
			end;
		end; -- put_boolean
		
	put_character (c: CHARACTER) is
	-- Write c at current position.
		require
			extendible: extendible
		local
			low_level: LOW_LEVEL;
			err: CHARACTER;
		do
			err := low_level.fputc(c,handle);
		end; -- put_character
		
	put_double (d: DOUBLE) is
	-- Write ASCII value of d at current position.
		require
			extendible: extendible
		do
			temp_string.wipe_out; 
			temp_string.append_double(d);
			put_string(temp_string);
		end; -- put_double
		
	put_integer (i: INTEGER) is
	-- Write ASCII value of i at current position.
		require
			extendible: extendible
		do
			temp_string.wipe_out; 
			temp_string.append_integer(i);
			put_string(temp_string);
		end; -- put_integer
		
	put_real (r: REAL) is
	-- Write ASCII value of r at current position.
		require
			extendible: extendible
		do
			temp_string.wipe_out; 
			temp_string.append_real(r);
			put_string(temp_string);
		end; -- put_real
		
	put_string (s: STRING) is
	-- Write s at cuurrent position.
		require
			extendible: extendible
		local
			i: INTEGER;
		do
			from
				i := 1
			until
				i > s.count
			loop
				put_character(s @ i)
				i := i + 1;
			end;
		end; -- put_string

feature { NONE } -- internal data

	handle: POINTER; -- file handle
	
	temp_string: STRING is
		once
			!!Result.make(256)
		end; -- temp_string

invariant
	
	name_exists: name /= Void;
	
	name_not_empty: not name.empty;

	writable_if_extendible: extendible implies is_writable

end -- FILE
