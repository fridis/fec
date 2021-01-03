class EXPANDED_TEST

creation
	make

feature 
	make is
		local
			c1,c2,c3,c4,c5: COMPLEX;
			x1,x2,x3,x4,x5: expanded COMPLEX;
			y1,y2,y3,y4,y5: XCOMPLEX;
			order_one: COUNT;
			three: THREE;
			cologne: COLOGNE;
			order_two,order_three,order_four: COUNT;
			zero: ZERO;
			order_five: COUNT;
			ea1_ref: EXPANDED_ATTRIBUTES1;
			ea1_exp: expanded EXPANDED_ATTRIBUTES1;
			ea2_ref: EXPANDED_ATTRIBUTES2;
			ea2_exp: expanded EXPANDED_ATTRIBUTES2;
		do
			print("Testing Comparison:%N%N");
			!!c1; !!c2;	
			c1.make(3,4);
			c2.make(5,6);
			c3 := c1 + c2;
			c4 := c3 - c1;
			c5 := c3 - c4;
			if (c5 /= c1) and not (c5 = c1) and
				c5.is_equal(c1) 
			then
				print(c5); print(" Reference comparison: OK%N");
			else
				print("Ref comparison: BUG: c5 = " | c5.out | "c1 = " | c1.out | "%N");
			end;
			x1.make(3,4);
			x2.make(5,6);
			x3 := x1 + x2;
			x4 := x3 - x1;
			x5 := x3 - x4;
			if (x5 /= x4) and not (x5 =  x4) and
			   (x5 =  x1) and not (x5 /= x1)
			then
				print(x5); print(" Explicitly expanded: OK%N");
			else
				print("Explicitly expanded: BUG: x5 = " | x5.out | "x1 = " | x1.out | "%N");
			end;
			y1.make(3,4);
			y2.make(5,6);
			y3 := y1 + y2;
			y4 := y3 - y1;
			y5 := y3 - y4;
			if (y5 /= y4) and not (y4 =  y5) and
			   (y5 =  y1) and not (y5 /= y1)
			then
				print(y5); print(" Expanded class: OK%N");
			else
				print("Expanded class: BUG: y5 = " | y5.out | "y1 = " | y1.out | "%N");
			end;
			print("%NTesting once-Functions with expanded Result:%N");
			print("twentyfive     = "); print(twentyfive    ); print("%N");
			print("five_i         = "); print(five_i	); print("%N");
			print("-five_i*five_i = "); print(-five_i*five_i); print("%N");

			print("%NTesting default initialisation:%N"); 
			print("zero    = " | zero.out | "%N");
			print("three   = " | three.out | "%N");
			print("cologne = " | cologne.out | "%N"); 
			print("%NTesting initialization order:%N");
			print("order_one   = " | order_one.out | "%N");
			print("order_two   = " | order_two.out | "%N");
			print("order_three = " | order_three.out | "%N");
			print("order_four  = " | order_four.out | "%N");
			print("order_five  = " | order_five.out | "%N");

			print("%NTesting default initialisation of attributes:%N");
			!!ea1_ref;
			!!ea2_ref.make;
			print("ea1_exp.three            = " | ea1_exp.three.out | "%N");
			print("ea1_exp.cologne          = " | ea1_exp.cologne.out | "%N");
			print("ea1_exp.count            = " | ea1_exp.count.out | "%N");
			print("ea1_ref.three            = " | ea1_ref.three.out | "%N");
			print("ea1_ref.cologne          = " | ea1_ref.cologne.out | "%N");
			print("ea1_ref.count           = " | ea1_ref.count.out | "%N");
			print("ea2_exp.ea1_exp.three   = " | ea2_exp.ea1_exp.three.out | "%N");
			print("ea2_exp.ea1_exp.cologne = " | ea2_exp.ea1_exp.cologne.out | "%N");
			print("ea2_exp.ea1_exp.count   = " | ea2_exp.ea1_exp.count.out | "%N");
			print("ea2_exp.ea1_ref.three   = " | ea2_exp.ea1_ref.three.out | "%N");
			print("ea2_exp.ea1_ref.cologne = " | ea2_exp.ea1_ref.cologne.out | "%N");
			print("ea2_exp.ea1_ref.count   = " | ea2_exp.ea1_ref.count.out | "%N");
			print("ea2_ref.ea1_exp.three   = " | ea2_ref.ea1_exp.three.out | "%N");
			print("ea2_ref.ea1_exp.cologne = " | ea2_ref.ea1_exp.cologne.out | "%N");
			print("ea2_ref.ea1_exp.count   = " | ea2_ref.ea1_exp.count.out | "%N");
			print("ea2_ref.ea1_ref.three   = " | ea2_ref.ea1_ref.three.out | "%N");
			print("ea2_ref.ea1_ref.cologne = " | ea2_ref.ea1_ref.cologne.out | "%N");
			print("ea2_ref.ea1_ref.count   = " | ea2_ref.ea1_ref.count.out | "%N");
			
		end; -- make

	twentyfive: XCOMPLEX is
		once
			Result.make(0,-5);
			Result := twentyfive*-Result;
		end -- nine

	five_i: XCOMPLEX is
		once
			Result.make(0,5);
		end; -- complex_three

end -- EXPANDED_TEST








