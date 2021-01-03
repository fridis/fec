-- Part of SmallEiffel -- Read DISCLAIMER file -- Copyright (C) 
-- Dominique COLNET and Suzanne COLLIN -- colnet@loria.fr
-- Modified for use with FEC by Fridtjof Siebert, 1997.
--
-- Originally written by Emmanuel CECCHET --
--
class STD_FILE_READ_WRITE
--
inherit 
	STD_FILE_READ
		undefine 
			connect_to, 
			disconnect 
		redefine 
			read_character, 
			end_of_input
		end;
	STD_FILE_WRITE
		redefine 
			connect_to, 
			put_character
		end;
   
creation 
	connect_to
   
feature 
   
   connect_to(new_path: STRING) is
		local
			rewrite_fic : STD_FILE_WRITE ;
			low_level: LOW_LEVEL;
		do
			input_stream := low_level.fopen(new_path.to_external,("r+").to_external);
			if input_stream.is_not_void then
			   path := new_path;
			   output_stream := input_stream;
			end;
		end;
   
   read_character is
		local
			err: INTEGER;
			low_level: LOW_LEVEL;
		do
			err := low_level.fflush(output_stream);
			last_character_memory := low_level.fgetc(input_stream);
		end;
   
   put_character(c: CHARACTER) is
		local
			err: CHARACTER;
			err2: INTEGER;
			low_level: LOW_LEVEL;
		do
			err2 := low_level.fflush(output_stream);
			err := low_level.fputc(c,output_stream);
			if err /= c then
			   print("Error while writing character."); 
			   --crash;
			end;
		end;
   
   end_of_input: BOOLEAN is
		local
			err: INTEGER;
			low_level: LOW_LEVEL;
		do
			err := low_level.fflush(output_stream);
			Result := low_level.feof(input_stream)
		end;
   
end -- STD_FILE_READ_WRITE

