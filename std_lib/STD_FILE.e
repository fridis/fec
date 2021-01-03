-- Part of SmallEiffel -- Read DISCLAIMER file -- Copyright (C) 
-- Dominique COLNET and Suzanne COLLIN -- colnet@loria.fr
-- Modified for use with FEC by Fridtjof Siebert, 1997.
--
deferred class STD_FILE
--
-- Root class of : 
--   - STD_INPUT to read on the keyboard (known as `std_input').
--   - STD_OUTPUT to write on the screen (known as `std_output').
--   - STD_INPUT_OUTPUT to read/write on the keyboard/screen (known as `io').
--   - STD_FILE_READ to read a named file on disk. 
--   - STD_FILE_WRITE to write a named file on disk.
--   - CURSES interactive screen/cursor handling.
--   - STD_ERROR to write on the error file (default is screen).
--
-- Note : a common list of feature (such as `put_character',  
--        `put_string', etc.) are shared by all classes so you can 
--        exchanges objects.
--        For example, it easy to test writing on the screen (using 
--        `std_output') and then to use a named file (using 
--        STD_FILE_WRITE or `connect_to').
--

feature 
   
   path: STRING;
	 -- Not Void when connected to the corresponding file on the disk.
   
   connect_to(new_path: STRING) is
		require
			not is_connected;
			path = Void;
			not new_path.empty;
		deferred
		end;
   
   disconnect is
		require
			is_connected;
		deferred
		end;
   
   is_connected: BOOLEAN is
		do
			Result := path /= Void;
		end;
   
end -- STD_FILE
