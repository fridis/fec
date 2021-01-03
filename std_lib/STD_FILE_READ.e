-- Part of SmallEiffel -- Read DISCLAIMER file -- Copyright (C) 
-- Dominique COLNET and Suzanne COLLIN -- colnet@loria.fr
-- Modified for use with FEC by Fridtjof Siebert, 1997.
--
class STD_FILE_READ 
--
-- Basic input facilities to read a named file on the disc.
--
-- Note : most features are common with STD_INPUT so you can 
--        test your program on the screen first and then, just 
--        changing of instance (STD_INPUT/STD_FILE_READ), doing 
--        the same on a file.
--
	
inherit STD_FILE
	
creation
	connect_to, make
	
feature
	
	connect_to(new_path: STRING) is
		local
			low_level: LOW_LEVEL;
		do
			make;
			input_stream := low_level.fopen(new_path.to_external,("r").to_external);
			if input_stream.is_not_void then
				path := new_path;
			end;
		end;
	
	disconnect is
		local
			low_level: LOW_LEVEL;
			err: INTEGER;
		do
			err := low_level.fclose(input_stream); 
			path := Void;
		end;
	
	make is
		do
			path := Void;
		end;
	
feature			
	
	last_integer: INTEGER; 
	-- Last integer read using `read_integer'.
	
	last_real: REAL; -- Last real read with `read_real'.
	
	last_double: DOUBLE; -- Last double read with `read_double'.
	
	last_character: CHARACTER is 
	-- Last character read with `read_character'.
		do 
			Result := last_character_memory;
		end;
	
	last_string: STRING is
	-- Last STRING read with `read_line', `read_word' or `newline'.
	--
	-- NOTE: it is alway the same STRING.
		once
			!!Result.make(256);
		end;
	
	read_line is
	-- Read a complete line ended by '%N' or `end_of_input'. 
	-- Make the result available in `last_string'.
	-- Character '%N' is not added in `last_string'. 
	--			
	-- NOTE: the result is available in `last_string' without any 
	--				memory allocation.
		require
			not end_of_input;
		do
			read_line_in(last_string);
		end;
			
	read_line_in(str: STRING) is
	-- Same jobs as `read_line' but storage is directly done in `str'.
	--
		require
			not end_of_input;
		do
			from  
				str.wipe_out;
				read_character;
			until
				end_of_input or else
				last_character = '%N'
			loop
				str.append_character(last_character);
				read_character;
			end;
		end;
			
	read_word is
	-- Read a word using `is_separator' of class CHARACTER. 
	-- Result is available in `last_string' (no allocation 
	-- of memory).
	-- Heading separators are automatically skipped.
	-- Trailing separators are not skipped (`last_character' is
	-- left on the first one).  
	-- If `end_of_input' is encountered, Result can be the 
	-- empty string.
		require
			not end_of_input
		do
			skip_separators;
			from  
				last_string.wipe_out;
			until
				end_of_input or else
				last_character = ' '  or
				last_character = '%N' or
				last_character = '%R' or
				last_character = '%T' or
				last_character = '%U'
			loop
				last_string.append_character(last_character);
				read_character;
			end;
		end;
	
	read_word_using(separators: STRING) is
	-- Same jobs as `read_word' using `separators'.
		require 
			not end_of_input;
			separators /= void
		do
	-- Implemented by : Lars Brueckner 
	-- (larsbruk@rbg.informatik.th-darmstadt.de)
			skip_separators_using(separators);
			from  
				last_string.wipe_out;
			until
				end_of_input or else
				separators.occurrences(last_character)>0
			loop
				last_string.append_character(last_character);
				read_character;
			end;
		end;
			
	read_integer is
	-- Read an integer according to the Eiffel syntax.
	-- Make result available in `last_integer'.
	-- Heading separators (`is_separator' of CHARACTER)  
	-- are automatically skipped.
	-- Trailing sseparators are not skipped (`last_character'
	-- is after the last digit of the number).
		local
			state: INTEGER;
			sign: BOOLEAN;
	-- state = 0 : waiting sign or first digit.
	-- state = 1 : sign read, waiting first digit.
	-- state = 2 : in the number.
	-- state = 3 : end state.
	-- state = 4 : error state.
		do
			from
			until
				state > 2
			loop
				read_character;
				inspect 
					state
				when 0 then
					if last_character = ' '  or
						last_character = '%N' or
						last_character = '%R' or
						last_character = '%T' or
						last_character = '%U'
					 then
					elseif (last_character >= '0' and last_character <= '9') then
				 last_integer := last_character.code - 48;
				 state := 2;
					elseif last_character = '-' then
				 sign := true;
				 state := 1;
					elseif last_character = '+' then
				 state := 1;
					else
				 state := 4;
					end;
				when 1 then
					if last_character = ' '  or
						last_character = '%N' or
						last_character = '%R' or
						last_character = '%T' or
						last_character = '%U'
				 then
					elseif (last_character >= '0' and last_character <= '9') then
				 last_integer := last_character.code - 48;
				 state := 2;
					else
				 state := 4;
					end;
				else -- 2
					if (last_character >= '0' and last_character <= '9') then
				 last_integer := (last_integer * 10) + last_character.code - 48;
					else
				 state := 3;
					end;
				end;
			end;
			debug
				if state = 4 then
					print("Error in STD_FILE.read_integer.%N");
					--crash;
				end;
			end;
			if sign then
				last_integer := - last_integer;
			end;
		end;
	
	read_real is
	-- Read a REAL and make the result available in `last_real'
	-- and in `last_double'.
	-- The integral part is available in `last_integer'.
		do
			read_double;
			last_real := last_double.to_real;
		end;
	
	read_double is
	-- Read a DOUBLE and make the result available in 
	-- `last_double'. 
		local
			state: INTEGER;
			sign: BOOLEAN;
			ip, i: INTEGER;
	-- state = 0 : waiting sign or first digit.
	-- state = 1 : sign read, waiting first digit.
	-- state = 2 : in the integral part.
	-- state = 3 : in the fractional part.
	-- state = 4 : end state.
	-- state = 5 : error state.
		do
			from
			until
				state >= 4
			loop
				read_character;
				inspect 
					state
				when 0 then
					if last_character = ' '  or
						last_character = '%N' or
						last_character = '%R' or
						last_character = '%T' or
						last_character = '%U'
				 then
					elseif (last_character >= '0' and last_character <= '9') then
				 ip := last_character.code - 48;
				 state := 2;
					elseif last_character = '-' then
				 sign := true;
				 state := 1;
					elseif last_character = '+' then
				 state := 1;
					elseif last_character = '.' then
				 tmp_read_double.wipe_out;
				 state := 3;
					else
				 state := 5;
					end;
				when 1 then
					if last_character = ' '  or
						last_character = '%N' or
						last_character = '%R' or
						last_character = '%T' or
						last_character = '%U'
				 then
					elseif (last_character >= '0' and last_character <= '9') then
				 ip := last_character.code - 48;
				 state := 2;
					else
				 state := 5;
					end;
				when 2 then
					if (last_character >= '0' and last_character <= '9') then
				 ip := (ip * 10) + last_character.code - 48;
					elseif last_character = '.' then
				 tmp_read_double.wipe_out;
				 state := 3;
					else
				 state := 4;
					end;
				else -- 3 
					if (last_character >= '0' and last_character <= '9') then
				 tmp_read_double.append_character(last_character);
					else
				 state := 4;
					end;
				end;
			end;
			debug
				if state = 5 then
					print("Error in STD_FILE.read_double.%N");
					--crash;
				end;
			end;
			from  
				last_double := 0;
				i := tmp_read_double.count;
			until
				i = 0
			loop
				last_double := (last_double + tmp_read_double.item(i).code - 48) / 10;
				i := i - 1;
			end;
			last_double := last_double + ip;
			if sign then
				last_double := - last_double;
			end;
		end;
	
	read_character is
	-- Read a character and assign it to `last_character'.
		require
			not end_of_input;
		local
			low_level: LOW_LEVEL;
		do
			last_character_memory := low_level.fgetc(input_stream);
		end;

	read_tail_in(str: STRING) is
	-- Read all remaining character of the file in `str'.
		do
			from
				if not end_of_input then
					read_character;
				end;
			until
				end_of_input
			loop
				str.append_character(last_character);
				read_character;
			end;
		ensure
			end_of_input;
		end;

	newline is
	-- Consume input until newline is found.
	-- Corresponding STRING is stored in `last_string'.
	-- Then consume newline character.
		do
			from  
				last_string.wipe_out;
			until
				end_of_input or else last_character = '%N'
			loop
				read_character;
				last_string.append_character(last_character);
			end;
			if not end_of_input then
				read_character;
			end;		
		end;
		
	end_of_input : BOOLEAN is
	-- Has end-of-input been reached ?
		local
			low_level: LOW_LEVEL;
		do
			Result := low_level.feof(input_stream)
		end;

feature -- Skipping :

	skip_separators is
	-- Stop doing `read_character' as soon as `end_of_file' is reached
	-- or as soon as `last_character' is not `is_separator'.
	-- When first character is already not `is_separator' nothing 
	-- is done. 
		do
			from  
			until
				end_of_input or else 
				not ( last_character = ' '  or
						last_character = '%N' or
						last_character = '%R' or
						last_character = '%T' or
						last_character = '%U')
			loop
				read_character;
			end;
		end;
	
	skip_separators_using(separators:STRING) is
	-- Same job as `skip_separators' using `separators'.
		require 
			separators /= void;
		do
	-- Implemented by : Lars Brueckner 
	-- (larsbruk@rbg.informatik.th-darmstadt.de)
			from 
			until
				end_of_input or else 
				separators.occurrences(last_character)=0
			loop
				read_character;
			end;
		end;
  
feature {FILE_TOOLS}

	same_as(other: like Current): BOOLEAN is
		require
			is_connected;
			other.is_connected
		local
			is1, is2: POINTER;
			low_level: LOW_LEVEL;
		do
			from
				is1 := input_stream;
				is2 := other.input_stream;
				Result := true;
			until
				not Result or else low_level.feof(is1) 
			loop
				Result := low_level.fgetc(is1) = low_level.fgetc(is2);
			end
			disconnect;
			other.disconnect;
		ensure
			not is_connected;
			not other.is_connected
		end;

feature {STD_FILE_READ}
	
	input_stream: POINTER;
	
	last_character_memory: CHARACTER;

feature {NONE}

	tmp_read_double: STRING is
		once
			!!Result.make(12);
		end;

end -- STD_FILE_READ
