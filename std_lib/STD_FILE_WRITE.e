-- Part of SmallEiffel -- Read DISCLAIMER file -- Copyright (C) 
-- Dominique COLNET and Suzanne COLLIN -- colnet@loria.fr
-- Modified for use with FEC by Fridtjof Siebert, 1997.
--
class STD_FILE_WRITE
--
-- Basic output facilities to write a named file on the disk.
--
-- Note : most features are common with STD_OUTPUT so you can 
--        test your program first on the screen and then, changing 
--        of instance (STD_OUTPUT/STD_FILE_WRITE), doing the same
--        on a file.
--
   
inherit STD_FILE
   
creation connect_to
   
feature 

	connect_to(new_path: STRING) is
		local
			low_level: LOW_LEVEL;
		do
			output_stream := low_level.fopen(new_path.to_external,("w").to_external);
				if output_stream.is_not_void then
				path := new_path;
			end;
      end;
   
   disconnect is
      local
			err: INTEGER;
			low_level: LOW_LEVEL;
      do
			err := low_level.fclose(output_stream); 
			path := Void;
      end;
   
feature    
   
   put_character(c: CHARACTER) is
      local
			err: CHARACTER;
			low_level: LOW_LEVEL;
      do
			err := low_level.fputc(c,output_stream);
			debug
				if err /= c then
				   print("Error in STD_FILE_WRITE.put_character.%N");
				   --crash;
				end;
			end;
      end;

   put_string(s: STRING) is
		-- Output `s' to current output device.
      require
			s /= Void;
      local
			i: INTEGER;
      do
			from  
				i := 1;
			until
				i > s.count
			loop
				put_character(s.item(i));
				i := i + 1;
			end;
      end;
   
   put_integer (i: INTEGER) is
		-- Output `i' to current output device.
      do
			tmp_string.wipe_out;
			tmp_string.append_integer(i);
			put_string(tmp_string);
      end;
   
   put_integer_format(i, s: INTEGER) is
		-- Output `i' to current output device using at most
		-- `s' character.
      do
			tmp_string.wipe_out;
			tmp_string.append_integer(i);
			tmp_string.head(s);
			put_string(tmp_string);
      end;
   
   put_real(r: REAL) is
		-- Output `r' to current output device.
      do
			tmp_string.wipe_out;
			tmp_string.append_real(r);
			put_string(tmp_string);
      end;
   
   put_double(d: DOUBLE) is
		-- Output `d' to current output device.
      do
			tmp_string.wipe_out;
			tmp_string.append_double(d);
			put_string(tmp_string);
      end;
   
   put_boolean(b: BOOLEAN) is
		-- Output `b' to current output device according
		-- to the Eiffel format.
      do
			if b then
						put_string("true");
			else
						put_string("false");
			end;
      end;
   
   put_new_line is
		-- Output a newline character.
      do
		put_character('%N');
      end;
   
   put_spaces(nb: INTEGER) is
      -- Output `nb' spaces character.
      require
		nb >= 0;
      local
		count : INTEGER;
      do
		from  
		until
					count >= nb
		loop
					put_character(' ');
					count := count + 1;
		end;
      end; 

   flush is
      local
			err: INTEGER;
			low_level: LOW_LEVEL;
      do
			err := low_level.fflush(output_stream);
      end;

feature {NONE}
   
   tmp_file_read: STD_FILE_READ is
      once
			!!Result.make;
      end;
   
feature {NONE}
   --
   -- NOTE: use only a few basic ANSI C functions.
   -- Try to use as few external C calls as possible.
   --
   
   output_stream: POINTER;
   
   tmp_string: STRING is
      once
			!!Result.make(512);
      end;
   
end -- STD_FILE_WRITE
