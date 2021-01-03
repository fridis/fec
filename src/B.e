class B
-- This class is used by DYNAMIC_TEST to demonstrate dynamic binding.

inherit
	A
		redefine
			x
		end;

feature
	x is 
		do
			print("B.x called%N");
		end; -- x

end -- B
