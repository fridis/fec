class D
-- This class is used by DYNAMIC_TEST to demonstrate dynamic binding.

inherit
	B;
	C
		rename
			x as x1
		select
			x1
		end; 

end -- D