class A
-- This class is used by DYNAMIC_TEST to demonstrate dynamic binding.

feature 

	x is
		do
			print("A.x called%N");
		end; -- x

	y is 
		do
			print("A.y called%N");
		end; -- y

	z: INTEGER;

end -- A

