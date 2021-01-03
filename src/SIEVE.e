class SIEVE

creation
	make

feature
	array: ARRAY[BOOLEAN];

	max: INTEGER is 1000;

	make is
		local
			i,j,nl: INTEGER;
		do
			!!array.make(2,max);
			from
				i := 2
			until
				i = max
			loop
				if not (array @ i) then
					print(i);
					nl := nl + 1;
					if nl \\ 8 = 0 then print("%N") else print("%T") end;
					from
						j := 2*i
					until
						j > max
					loop
						array.put(true,j);
						j := j + i
					end;
				end;
				i := i + 1;
			end;
			print("%N");
		end; -- make

end -- SIEVE











