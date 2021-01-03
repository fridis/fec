class HEXDUMP

inherit ARGUMENTS;

creation make

feature 

	make is 
		local
			filename: STRING;
			src: STD_FILE_READ;
		do
			if argument_count /= 1 then
				print("Usage: hexdump <<file>>%N");
			else
				filename := argument(1); 
				!!src.connect_to(filename);
				if src.is_connected then
					from
						adr := 0;
						src.read_character;
					until
						src.end_of_input
					loop
						write(src.last_character.code);
						src.read_character;
					end;
					if asc.count<16 then
						print(" " ^ ((16-asc.count)*2+(4-asc.count // 4)));
						print("%"");
						print(asc);
						print("%"%N");
					end;
					src.disconnect;
				else
					print("file not found%N");
				end;
			end;
		end;  -- make

	adr: INTEGER;
  
	write (b: INTEGER) is 
		do
			if adr \\ 16 = 0 then
				hex(adr,8);
				print(": ");
				asc.copy("");
			end;
			hex(b,2);
			inspect b.to_character
			when ' ' .. '%/127/',
				 '%/160/' .. '%/255/'
			then
				asc.append_character(b.to_character);
			else
				asc.append_character('.');
			end;
			adr := adr + 1;
			if adr \\ 4 = 0 then
				print(" ");
			end;
			if adr \\ 16 = 0 then
				print("%"");
				print(asc);
				print("%"%N");
			end;
		end;  -- write

	hex(i,n: INTEGER) is 
		do
			if n>0 then
				hex(i // 16,n-1);
				tmp.copy(" ");
				tmp.put(("0123456789ABCDEF") @ (i \\ 16 + 1),1);
				print(tmp);
			end;
		end; -- hex
		
	tmp: STRING is once !!Result.make(80) end;
		
	asc: STRING is once !!Result.make(16) end;
		
end -- HEXDUMP
