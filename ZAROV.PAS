unit illizarov;
INTERFACE
uses glib;
PROCEDURE call_ILLI;

IMPLEMENTATION

PROCEDURE call_ILLI;
var
	xd,yd,zd:real;
	x,y,z:integer;
	i,j,k:integer;
	pic,temp1,temp2:link;
        zf:text;
        No_rings,No_rods:integer;
begin
assign(zf,'zarov.dwg');
reset(zf);
readln(zf,No_rings,No_rods);

for i:=1 to No_rings do
    begin
    newbase(dbase,first,sbase);
    readln(zf,dbase^.d[1],dbase^.d[2],dbase^.d[3],dbase^.d[4]);
		dbase^.ID:='C';
		dbase^.d0:=0;
		mp(0);
		drawusing(dbase);
		mp(1);
    end;

for i:=1 to No_rods do
    begin
    with dbase^ do
         readln(zf,d[1],d[2],d[3],d[4],d[5],d[6]);
    newbase(dbase,first,sbase);
		dbase^.ID:='L';
		dbase^.d0:=ord('S');
		mp(0);
		drawusing(dbase);
		mp(1);
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









