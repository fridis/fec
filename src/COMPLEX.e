class COMPLEX

inherit
	ANY
		redefine
			out
		end;

feature
	re, im: DOUBLE;

	make (r,i: DOUBLE) is
		do
			re := r; 
			im := i;
		ensure
			re = r; 
			im = i;
		end; -- make
		
	infix "+" (other: COMPLEX): COMPLEX is
		do
			!!Result;
			Result.make(re+other.re,im+other.im);
		end; 
				
	infix "-" (other: COMPLEX): COMPLEX is
		do
			!!Result;
			Result.make(re-other.re,im-other.im);
		end; 
			
	infix "*" (other: COMPLEX): COMPLEX is
		do
			!!Result;
			Result.make(re*other.re-im*other.im,
			            re*other.im+im*other.re);
		end;
	
	infix "/" (other: COMPLEX): COMPLEX is
		local
			othersq: DOUBLE;
		do
			othersq := other.re*other.re - other.im*other.im;	
			!!Result;
			Result.make((re*other.re+im*other.im)/othersq,
			            (re*other.im-im*other.re)/othersq);
		end; 
	
	prefix "+" : COMPLEX is
		do
			Result := clone(Current);
		end;
		
	prefix "-" : COMPLEX is
		do
			!!Result;
			Result.make(-re,-im);
		end;

	out: STRING is
		do
			Result := "[re=" | re.out | ", im=" | im.out | "]";
		end; -- out 
		
end -- COMPLEX
	
















