class ROUT_TO_ATTR_TEST

creation
	make

feature
	make is
		local
			r1: ROUT_TO_ATTR1;
			r2: ROUT_TO_ATTR2;
		do
			!!r2.make;
			r1 := r2;
			print("ROUT_TO_ATTR2:%N");
			print(r2.int1); print("%N");
			print(r2.int2); print("%N");
			print(r2.int3); print("%N");
			print(r2.int4); print("%N");
			print(r2.int5); print("%N");
			print(r2.int6); print("%N");
			print(r2.string1);
			print(r2.string2); 
			print(r2.string3); 
			print(r2.string4);
			print(r2.string5); 
			print(r2.string6);
			print("ROUT_TO_ATTR1:%N");
			print(r1.int1); print("%N");
			print(r1.int2); print("%N");
			print(r1.int3); print("%N");
			print(r1.int4); print("%N");
			print(r1.int5); print("%N");
			print(r1.int6); print("%N");
			print(r1.string1); 
			print(r1.string2);
			print(r1.string3); 
			print(r1.string4); 
			print(r1.string5); 
			print(r1.string6);
			print("r1.print_attr1:%N");
			r1.print_attr1;
			print("r2.print_attr1:%N");
			r2.print_attr1;
			print("r2.print_attr2:%N");
			r2.print_attr2;
		end; -- make

end -- ROUT_TO_ATTR_TEST








