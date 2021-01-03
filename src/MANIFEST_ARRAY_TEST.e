class MANIFEST_ARRAY_TEST

creation
	make

feature
	make is
		do
			test1(<<"Testing ","Manifest"," ","Array","!%N">>);
			test2(<<"Now a more sophisticated test:",
				true,
				false,
				4,
				fuenf,
				"sechs",
				minus_sieben,
				8.0,
				minus_neun,
				'A',
				(('A').code+1).to_character,
				"Ende">>);
			test3(<< << "A", "B", "C", "D" >>,
				 << 0, 1, 2, 3 >>,
				 << false, true >>,
				 << 3.14, 2.71828, 1.4142 >>,
				 << 3.14, true, 2, "D">> >>);
		end;

	fuenf: INTEGER is 5;

	minus_sieben: INTEGER is -7;

	minus_neun: DOUBLE is - 9.0;

	test1 (a: ARRAY[STRING]) is
		local
			i: INTEGER;
		do
			from
				i := a.lower;
			until
				i > a.upper
			loop
				if a @ i = Void then
					print("a @ i = Void!%N");
				end;
				print(a @ i);
				i := i + 1;
			end;
		end;

	test2 (a: ARRAY[ANY]) is
		local
			i: INTEGER;
		do
			from
				i := a.lower;
			until
				i > a.upper
			loop
				print(i); 
				print(": "); 
				print(a @ i);
				print("%N");
				i := i + 1;
			end;
		end;

	test3 (a: ARRAY[ARRAY[ANY]]) is
		local
			b: ARRAY[ANY];
			i,j: INTEGER;
		do
			from
				i := a.lower;
			until
				i > a.upper
			loop
				b := a @ i;
				from
					j := b.lower
				until
					j > b.upper
				loop
					print("a[" | i.out | "," | j.out | "] = " | (a @ i @ j).out | "%T");
					j := j + 1;
				end;
				print("%N");
				i := i + 1;
			end;
		end;


end -- MANIFEST_ARRAY_TEST

