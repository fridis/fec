class GENERIC_TEST

creation
	make

feature
	list: LIST[NUMBERED_STRING];
	psa: PS_ARRAY[STRING,NUMBERED_STRING];
	sorted: SORTED_ARRAY[STRING,NUMBERED_STRING];

	make is 
		local
			n: NUMBERED_STRING;
		do
			!!list.make; 
			!!psa.make;
			!!n.make("eins"	  , 1); list.add(n); psa.add(n);
			!!n.make("zwei"	  , 2); list.add(n); psa.add(n);
			!!n.make("drei"	  , 3); list.add(n); psa.add(n);
			!!n.make("vier"	  , 4); list.add(n); psa.add(n);
			!!n.make("fuenf"	 , 5); list.add(n); psa.add(n);
			!!n.make("sechs"	 , 6); list.add(n); psa.add(n);
			!!n.make("sieben"	, 7); list.add(n); psa.add(n);
			!!n.make("acht"	  , 8); list.add(n); psa.add(n);
			!!n.make("neun"	  , 9); list.add(n); psa.add(n);
			!!n.make("zehn"	  ,10); list.add(n); psa.add(n);
			!!n.make("elf"	   ,11); list.add(n); psa.add(n);
			!!n.make("zwoelf"	,12); list.add(n); psa.add(n);
			!!n.make("dreizehn"      ,13); list.add(n); psa.add(n);
			!!n.make("vierzehn"      ,14); list.add(n); psa.add(n);
			!!n.make("fuenfzehn"     ,15); list.add(n); psa.add(n);
			!!n.make("sechzehn"      ,16); list.add(n); psa.add(n);
			
			print_list(list);
			
			print("%N");
			print("psa.find(%"sieben%").number = " | psa.find("sieben").number.out | "%N");
			print("psa.find(%"fuenfzehn%").number = " | psa.find("fuenfzehn").number.out | "%N");
			
			sorted := psa.get_sorted;
			
			print_sorted;
			
		end;

	print_list(l: LIST[NUMBERED_STRING]) is
		local
			i: INTEGER;
		do
			from
				i := 1
			until
				i > list.count
			loop
				print(list @ i); print("%N");
				i := i + 1;
			end;
		end; -- print_list

	print_sorted is
		local
			i: INTEGER;
		do
			print("%NSorted alphabetically:%N");
			from
				i := sorted.lower
			until
				i > sorted.upper
			loop
				print(sorted @ i); print("%N");
				i := i + 1;
			end;
		end; -- print_list

end -- GENERIC_TEST
			

