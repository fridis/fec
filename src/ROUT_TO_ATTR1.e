deferred class ROUT_TO_ATTR1

feature

	int1: INTEGER is deferred end;
	int2: INTEGER is deferred end;
	int3: INTEGER is deferred end;
	int4: INTEGER is do Result := 1004 end;
	int5: INTEGER is do Result := 1005 end; 
	int6: INTEGER is do Result := 1006 end;

	string1: STRING is deferred end;
	string2: STRING is deferred end;
	string3: STRING is deferred end;
	string4: STRING is do Result := "ROUT_TO_ATTR1: string 4%N" end; 
	string5: STRING is do Result := "ROUT_TO_ATTR1: string 5%N" end;
	string6: STRING is do Result := "ROUT_TO_ATTR1: string 6%N" end;

	print_attr1 is 
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
		end; -- print_attr1


end -- ROUT_TO_ATTR1






