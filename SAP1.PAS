	procedure deldupli;
	var pic:link;
	begin
		dbase:=first^.a;
		while dbase<>NIL do
		begin
		dbase^.d0:=ord('X');
			pic:=first^.a;
			while pic<>NIL do
				begin
		if pic^.d0<>ord('X') then
			if (eq(pic^.d[1],dbase^.d[1])
			and eq(pic^.d[2],dbase^.d[2])
			and eq(pic^.d[3],dbase^.d[3])
			and eq(pic^.d[4],dbase^.d[4])
			and eq(pic^.d[5],dbase^.d[5])
			and eq(pic^.d[6],dbase^.d[6]))
			or
			   (eq(pic^.d[1],dbase^.d[4])
			and eq(pic^.d[2],dbase^.d[5])
			and eq(pic^.d[3],dbase^.d[6])
			and eq(pic^.d[4],dbase^.d[1])
			and eq(pic^.d[5],dbase^.d[2])
			and eq(pic^.d[6],dbase^.d[3]))
			then
				begin
                                dele(pic,first,sbase);
                                end;
			pic:=pic^.a;
			end;
			dbase^.d0:=0;
			dbase:=dbase^.a;
			end;

	end;
