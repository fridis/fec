class HELLO

creation
	make
	
feature
	make is
		local
			sin,cos,i: INTEGER;
		do
			from
				sin := 0; 
				cos := 20;
			until
				i = 100
			loop
				print((" "^(20+sin)) | "Hallo" | ("_"^(sin // 2  + 10)) | "Welt!%N");
				sin := sin + cos // 4;
				cos := cos - sin // 4;
				i := i + 1;
			end;
		end; -- make
		
end -- HELLO
