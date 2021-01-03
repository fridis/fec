class TEST_ALL

creation
	make

feature
	make is
		local
			hello: HELLO;
			sieve: SIEVE;
			inspect_test: INSPECT_TEST;
			real_test: REAL_TEST;
			dynamic_test: DYNAMIC_TEST;
			generic_test: GENERIC_TEST;
			once_test: ONCE_TEST;
			manifest_array_test: MANIFEST_ARRAY_TEST;
			rout_to_attr_test: ROUT_TO_ATTR_TEST;
			expanded_test: EXPANDED_TEST;
		do 
			print("%N%NEiffel demonstration:%N%N%
			      %We start our demonstration with the traditional %"Hello World!%":%N%N");
			!!hello.make;
			print("%N%NAs you see, this alsready was a more sophisticated demonstration %
			      %than most would have expected. Now lets do something useful and find %
			      %a few hundred primes:%N%N");
			!!sieve.make;
			print("%N%NThe current implementation of inspect-statements is simple, but as %
			      %long as efficiency is not too big a concern, this will do nicely:%N%N");
			!!inspect_test.make;
			print("%N%NAn important feature today is the support for REALs and DOUBLEs. Note %
			      %that so far no care has been taken to get the most accurate output, and %
 			      %also real constants that occur in the source text might get mungled slightly %
			      %by the compiler:%N%N");
			!!real_test.make;
			print("%N%NAnd now to the most important feature of Eiffel: Dynamic binding. Here %
			      %we have a complete test of the classical diamong-inheritance structure with %
			      %repeated inheritance, sharing and duplication:%N%N");
			!!dynamic_test.make;
			print("%N%NThe most brain consuming part of the compiler were generic classes, %
			      %especially in combination with inheritance. So here is a demo for generics:%N%N");
			!!generic_test.make;
			print("%N%NConvenient for the programmer, but a littly tricky for the language %
			      %implementor are the flexible redefinition rules in Eiffel that allow routines %
			      %to be redeclared as constant or variable attributes:%N%N");
			!!rout_to_attr_test.make;
			print("%N%NManifest arrays are nothing but syntactic sugar, but Eiffel developers %
			      %sometimes deserve some convenience:%N%N");
			!!manifest_array_test.make;
			print("%N%NSometimes tricky for the compiler are expanded classes, so here's a %
			      %small example using them:%N%N");
			!!expanded_test.make;
			print("%N%NAnd finally a simpler test, using a recursive once-function:%N%N");
			!!once_test.make;
			print("%N%NSo, this is enough for our small example today.%N%N");
		end; -- make

end -- TEST_ALL


