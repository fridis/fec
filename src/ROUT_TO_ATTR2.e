class ROUT_TO_ATTR2

inherit
	ROUT_TO_ATTR1
		redefine
			int4, int5, int6,
			string4, string5, string6
		end;

creation
	make

feature
	make is
		do
			int2 := 2002;
			string2 := "ROUT_TO_ATTR2: string2%N";
			int5 := 2005;
			string5 := "ROUT_TO_ATTR2: string5%N";
		end;

	int1 : INTEGER is do Result := 2001 end;
	int2 : INTEGER;
	int3 : INTEGER is 2003;
	int4 : INTEGER is do Result := 2004 end;
	int5 : INTEGER;
	int6 : INTEGER is 2006;

	string1 : STRING is do Result := "ROUT_TO_ATTR2: string1%N" end; 
	string2 : STRING;
	string3 : STRING is "ROUT_TO_ATTR2: string3%N";
	string4 : STRING is do Result := "ROUT_TO_ATTR2: string4%N" end;
	string5 : STRING;
	string6 : STRING is "ROUT_TO_ATTR2: string6%N";

	print_attr2 is
		do
			print(int1); print("%N");
			print(int2); print("%N");
			print(int3); print("%N");
			print(int4); print("%N");
			print(int5); print("%N");
			print(int6); print("%N");
			print(string1);
			print(string2);
			print(string3);
			print(string4);
			print(string5);
			print(string6);
		end; -- print_attr2

end -- ROUT_TO_ATTR2








