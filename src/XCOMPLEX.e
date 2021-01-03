expanded class XCOMPLEX

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

--	copy (other: like Current) is
--		do
--			re := other.re;
--			im := other.im;
--		end;
		
	infix "+" (other: XCOMPLEX): XCOMPLEX is
		do
			Result.make(re+other.re,im+other.im);
		end; 
				
	infix "-" (other: XCOMPLEX): XCOMPLEX is
		do
			Result.make(re-other.re,im-other.im);
		end; 
	
	infix "*" (other: XCOMPLEX): XCOMPLEX is
		do
			Result.make(re*other.re-im*other.im,
			            re*other.im+im*other.re);
		end;
	
	infix "/" (other: XCOMPLEX): XCOMPLEX is
		local
			othersq: DOUBLE;
		do
			othersq := other.re*other.re - other.im*other.im;	
			Result.make((re*other.re+im*other.im)/othersq,
			            (re*other.im-im*other.re)/othersq);
		end; 
	
	prefix "+" : XCOMPLEX is
		do
			Result := Current;
		end;
		
	prefix "-" : XCOMPLEX is
		do
			Result.make(-re,-im);
		end;
		

	out: STRING is
		do
			Result := "[re=" | re.out | ", im=" | im.out | "]";
		end; -- out

end -- XCOMPLEX
	
