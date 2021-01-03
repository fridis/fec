class DYNAMIC_TEST

creation
	make

feature
	make is
		local
			a: A;
			b: B;
			c: C;
			d: D;
		do
			!!a;
			!!b;
			!!c;
			!!d;
			print("Static type = A, Dynamic type = A:%N");
			a.x; a.y;
			print("Static type = B, Dynamic type = B:%N");
			b.x; b.y;
			print("Static type = C, Dynamic type = C:%N");
			c.x; c.y;
			print("Static type = D, Dynamic type = D:%N");
			d.x; d.x1; d.y;
			a := b;
			print("Static type = A, Dynamic type = B:%N");
			a.x; a.y;
			a := c;
			print("Static type = A, Dynamic type = C:%N");
			a.x; a.y;
			a := d;
			print("Static type = A, Dynamic type = D:%N");
			a.x; a.y;
			b := d;
			print("Static type = B, Dynamic type = D:%N");
			b.x; b.y;
			c := d;
			print("Static type = C, Dynamic type = D:%N");
			c.x; c.y;

			print("%NTesting reverse assignment:%N");
			b := Void; c := Void; d := Void; 
			!D!a; 
			b ?= a;			
			c ?= a;
			d ?= a;
			print("D -> B/C/D: "); 
			if b = Void or c = Void or d = Void then
				print("WRONG%N");
			else
				print("CORRECT%N");
			end;
			b := Void; c := Void; d := Void;
			!!a;
			b ?= a;
			c ?= a;
			d ?= a;
			print("A -> B/C/D: ");
			if b /= Void or c /= Void or d /= Void then
				print("WRONG%N");
			else
				print("CORRECT%N");
			end;
		end; -- make

end -- DYNAMIC_TEST
















