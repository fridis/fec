class NUMBER

inherit
	ANY
		redefine
			out
		end;

creation 
	{ NONE }

feature 

	num: INTEGER;

	three is do num := 3 end; 

	cologne is do num := 4711 end;

	count is do num := counter.counter; counter.increment end;

	counter: COUNTER is once !!Result; counter.set(1); end;
	
	out: STRING is do Result := num.out end; 

end -- NUMBER
