unit illiz;
INTERFACE
uses glib;
PROCEDURE call_ILLI;

IMPLEMENTATION

PROCEDURE call_ILLI;
var
	{xd,yd,zd:real;}
	x,y,z:integer;
	i,j,k:integer;
	pic,temp1,temp2:link;
        zf:text;
        No_rings,No_rods,No_segs:integer;
        x1,y1,z1,r1,b,d,zb,zd:real;
        bx1,bx2,by1,by2,bz1,bz2,dia:real;
        zi:integer;
begin
assign(zf,'zarov.dwg');
reset(zf);
readln(zf,No_rings,No_rods);

No_segs:=10;

{cordinates and dia of bones}
readln(zf,bx1,by1,bz1,bx2,by2,bz2,dia);
mp(0);

for j:=1 to No_segs do
    begin
    newbase(dbase,first,sbase);

    		dbase^.ID:='L';
		dbase^.d0:=ord('S');

                dbase^.d[1]:=bx1+dia*cos(2*3.1415/No_segs*(j-1));
                dbase^.d[2]:=by1+dia*sin(2*3.1415/No_segs*(j-1));
                dbase^.d[3]:=bz1;

                dbase^.d[4]:=dbase^.d[1];
                dbase^.d[5]:=dbase^.d[2];
                dbase^.d[6]:=bz2;

		drawusing(dbase);


    end;

   for j:=1 to No_segs+1 do
   for i:=1 to No_Segs+1 do
       begin
                newbase(dbase,first,sbase);

    		dbase^.ID:='L';
		dbase^.d0:=ord('S');

                dbase^.d[1]:=bx1+dia*cos(2*3.1415/No_segs*(i-1));
                dbase^.d[2]:=by1+dia*sin(2*3.1415/No_segs*(i-1));
                dbase^.d[3]:=bz1+(bz2-bz1)/No_segs*(j-1);

                dbase^.d[4]:=bx1+dia*cos(2*3.1415/No_segs*i);
                dbase^.d[5]:=by1+dia*sin(2*3.1415/No_segs*i);
                dbase^.d[6]:=bz1+(bz2-bz1)/No_segs*(j-1);
       end;

No_segs:=10;

    for i:=1 to No_rings do
    begin
    readln(zf,x1,y1,z1,r1,b,d);

    for j:=1 to No_segs do

    for zi:=1 to 4 do
    begin

    case zi of
         1:begin zb:=1;zd:=1; end;
         2:begin zb:=1;zd:=-1; end;
         3:begin zb:=-1;zd:=1; end;
         4:begin zb:=-1;zd:=-1; end;
       end;

    newbase(dbase,first,sbase);

    		dbase^.ID:='L';
		dbase^.d0:=ord('S');
                dbase^.d[1]:=x1+(r1+zb*b/2)*cos(2*3.1415/No_segs*(j-1));
                dbase^.d[2]:=y1+(r1+zb*b/2)*sin(2*3.1415/No_segs*(j-1));
                dbase^.d[3]:=z1+zd*d/2;

                dbase^.d[4]:=x1+(r1+zb*b/2)*cos(2*3.1415/No_segs*j);
                dbase^.d[5]:=y1+(r1+zb*b/2)*sin(2*3.1415/No_segs*j);
                dbase^.d[6]:=z1+zd*d/2;

		drawusing(dbase);

    end;
    end;

    mp(1);

for k:=1 to No_rods do
    begin

readln(zf,bx1,by1,bz1,bx2,by2,bz2,dia);

for j:=1 to No_segs do
    begin
    newbase(dbase,first,sbase);

    		dbase^.ID:='L';
		dbase^.d0:=ord('S');

                dbase^.d[1]:=bx1+dia*cos(2*3.1415/No_segs*(j-1));
                dbase^.d[2]:=by1+dia*sin(2*3.1415/No_segs*(j-1));
                dbase^.d[3]:=bz1;

                dbase^.d[4]:=dbase^.d[1];
                dbase^.d[5]:=dbase^.d[2];
                dbase^.d[6]:=bz2;

		drawusing(dbase);


    end;

   for j:=1 to No_segs+1 do
   for i:=1 to No_Segs+1 do
       begin
                newbase(dbase,first,sbase);

    		dbase^.ID:='L';
		dbase^.d0:=ord('S');

                dbase^.d[1]:=bx1+dia*cos(2*3.1415/No_segs*(i-1));
                dbase^.d[2]:=by1+dia*sin(2*3.1415/No_segs*(i-1));
                dbase^.d[3]:=bz1+(bz2-bz1)/No_segs*(j-1);

                dbase^.d[4]:=bx1+dia*cos(2*3.1415/No_segs*i);
                dbase^.d[5]:=by1+dia*sin(2*3.1415/No_segs*i);
                dbase^.d[6]:=bz1+(bz2-bz1)/No_segs*(j-1);
       end;
   end;



close(zf);

{
Gwrite('X-No ? ');
greadint(x);
Gwrite('Y-No ? ');
greadint(y);
Gwrite('Z-No ? ');
greadint(z);

Gwrite('X-distance ? ');
greadreal(xd);

Gwrite('Y-distance ? ');
greadreal(yd);

Gwrite('Z-distance ? ');
greadreal(zd);

new(temp1);
new(temp2);

pic:=first^.a;
while pic<>NIL do
	begin
	if pic^.d0=ord('S') then
		begin
		i:=0;
		repeat
		i:=i+1;
		j:=0;
		repeat
		j:=j+1;
		k:=0;
		repeat
		k:=k+1;
		call_TRAN(0,0,0,(i-1)*xd,(j-1)*yd,(k-1)*zd,pic,temp1);
		newbase(dbase,first,sbase);
		copybase(temp1,dbase);
		dbase^.ID:=pic^.ID;
		dbase^.d0:=0;
		mp(0);
		drawusing(dbase);
		mp(1);
		until k=z;
		until j=y;
		until i=x;
		end;
	pic:=pic^.a;
	end;

dispose(temp1);
dispose(temp2);
}
end;
end.



