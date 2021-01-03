class INSPECT_TEST

creation
	make
	
feature
	make is
		local
			i: INTEGER; 
		do
			print("%NTesting INTEGER-inspect:%N%N"); 
			from
				i := 0
			until
				i = 72
			loop
				if i \\ 8 = 0 then 
					print("%N");
				end;
				integer_test(i);
				i := i + 1;
			end;
			print("%N%NTesting Character-inspect:%N%N"); 
			from
				i := 0
			until
				i > 255
			loop
				if i \\ 16 = 0 then 
					print("%N");
				end;
				character_test(i.to_character);
				i := i + 1;
			end;
			print("%N%N");
		end; -- make

	integer_test(i: INTEGER) is
		do
			inspect i
			when 
				2,3,4,5,9,14,16,23,24,26,29,31,
				32,39,40,42,45,47,48,51,52,55,57,62,
				66,67,68,69
			then
				print("##");
			else
				print("..");
			end;
		end; -- integer_test
		
	character_test(c: CHARACTER) is
		do
			inspect c
			when
				' '..'~','%/160/'..'%/255/'
			then
				print(c);
			else
				print('.');
			end;
		end; -- character_test
		
end -- INSPECT_TEST
