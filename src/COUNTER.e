class COUNTER

feature
	set(new_counter: INTEGER) is
		do
			counter := new_counter;
		end;

	increment is
		do
			counter := counter + 1;
		end; 
		
	counter: INTEGER; 
	
end -- COUNTER
