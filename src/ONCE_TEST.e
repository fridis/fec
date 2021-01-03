class ONCE_TEST

creation
	make

feature

	make is 
		do
			print("Once test:%N");
			print(once_function("drei%N"));
		end; -- make

	once_function (s: STRING): STRING is
		once
			print("eins%N");
			Result := "zwei%N";
			print(once_function("vier%N"));
			Result := s;
		end; -- once_function

end -- ONCE_TEST