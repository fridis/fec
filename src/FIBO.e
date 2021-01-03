class FIBO

creation
	make

feature
	make is 
	local
		f,p,n: INTEGER;
	do
		from
			f := 1;
			n := 1;
		until
			n > 30
		loop
			print(f); 
			print('%N');
			f := f + p;
			p := f - p;
			n := n + 1;
		end;
	end; -- make

end -- FIBO

