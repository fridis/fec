class REAL_TEST

creation
	make

feature
	p (d: REAL; i: INTEGER) is
		do
			print(" " ^ i);
			print(d); 
			print("%N");
		end; -- p

	test (d: REAL; i: INTEGER) is	
		do	
			p(d,i);
			if d>0.001 then
				test(d/2,i+3);
			end;
			p(d,i);
		end; -- test

	pd (d: DOUBLE; i: INTEGER) is
		do
			print(" " ^ i);
			print(d); 
			print("%N");
		end; -- p

	testd (d: DOUBLE; i: INTEGER) is	
		do	
			pd(d,i);
			if d>0.001 then
				testd(d/2,i+3);
			end;
			pd(d,i);
		end; -- testd

	make is
	local
		a,b,c: REAL;
		d,e,f: DOUBLE;
		i,j: INTEGER;
	do
		test(10,0);
		a := b + c;
		a := b - c;
		a := b * c;
		a := b / c;
		a := b + c;
		a := -a;
		d := e + f;
		d := e - f;
		d := e * f;
		d := e / f;
		d := -d;
		from
			i := 1;
			a := 3.1452;	
		until
			i > 10
		loop
			i := i + 1;
			print(a); print("%N");
			a := a*10;
		end;
		testd(10,0);
		from
			i := 1;
			d := 3.1452;	
		until
			i > 10
		loop
			i := i + 1;
			print(d); print("%N");
			d := d*10;
		end;
	end; -- make

end -- REAL_TEST
	
		





