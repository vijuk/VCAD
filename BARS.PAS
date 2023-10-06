unit bars;
interface
uses lib,dlib,crt;
procedure selectbar(s:string;ast:real;var n1,d1,n2,d2:integer);
implementation
procedure selectbar(s:string;ast:real;var n1,d1,n2,d2:integer);
label 100,200;

const
	TotalBar=7;
	TMN=49;
var
	menus:menutype;
	menu:integer;
	nomenu:integer;
	errp:real;
	menustart:integer;
	c1,c2:integer;
	screen:image;
	barmap:array[0..7,1..2] of byte;

PROCEDURE bars(var ast:real;var d1,d2,n1,n2:integer;var errp:real;var nomenu:integer;var excode:char);
label 100;
var
	a1,a2,aused:real;
	i:integer;
begin
if eq(ast,0) then
		begin
		ast:=2*pi*100/4;
		msg('Stirrup holding bars');
		end;
excode:=#0;
fillchar(barmap,sizeof(barmap),0);
for i:=50 to 70 do  menus^[i]:=' ';
if (d1=0) and (d2=0) then
		begin
		msg('Not admissible !');
		excode:=ESC;
		goto 100;
		end;
if d1=0 then d1:=d2;
if d2=0 then d2:=d1;
a1:=sqr(d1)*pi/4;
a2:=sqr(d2)*pi/4;
i:=50;
if d1=d2 then
	begin
	n1:=mytrunc(ast/a1)+1;
	aused:=n1*a1;
	errp:=(n1*a1-ast)/ast*100;
	if (errp>el1) or (errp<(-abs(el2))) then menus^[i]:=''
		else
		begin
		menus^[i]:=strint(n1,2)+' - '+strint(d1,2)+'    '
		+strreal(aused,5,2)+ '   +'+strreal(errp,4,2)+'%';
		barmap[0,1]:=n1;
		barmap[0,2]:=0;
		end;
	i:=i+1;
	end
else
	begin
	n1:=0;
	repeat
	if ast>n1*a1 then
		n2:=mytrunc((ast-n1*a1)/a2)+1;
	aused:=n1*a1+n2*a2;
	errp:=(aused-ast)/ast*100;
	if (errp>el1) or (errp<el2) then menus^[i]:=''
		else
		begin
		menus^[i]:=strint(n1,2)+' - '+strint(d1,2)+'   &   '
			+strint(n2,2)+' - '+strint(d2,2)
			+'   '+strreal(aused,9,2)+'  +' +strreal(errp,4,2)+'%';
		barmap[n1,1]:=n1;
		barmap[n1,2]:=n2;
		end;
	inc(n1);
	inc(i);
	until (n2=0) or (n1=8);
	end;
100:
nomenu:=i-50;
for i:=50 to 70 do menus^[i]:=fixlength(menus^[i],44,LEFT);
end;


PROCEDURE makemenu(TMN:integer);
var
	i,j:integer;
begin
	{Make menu items}
	i:=0;
	j:=0;
	while i<TMN do
		begin
		inc(j);
			d1:= rangedia[i div (TotalBar)];
			d2:= rangedia[i mod (TotalBar)];
                        if (d1=0) and (d2=0) then
				menus^[j]:=bartypes[1]
				else
				begin
				{
				if d2<>0 then
				}
				menus^[j]:=strint(d1,2)+' -'+
						+strint(d2,2);
				{
				else
				menus^[j]:=strint(d1,3);
				}
				menus^[j]:=fixlength(menus^[j],10,LEFT);
				end;
			i:=i+1;
		end;
end;


begin
sw(4);
new(menus);
put(screen);
choice[10]:=1;
repeat
get(screen);
msg('AST reqd : '+justify(ast,10,3,LEFT));
	scode[2]:=#0;
	makemenu(TMN);
	menustart:=1;
	scode[2]:=NOREAD;
	multipix(menus,'V',100,TotalBar,TotalBar,10,menustart,6,6,choice[10],scode[2]);
	scode[2]:=#0;
	repeat
		rev:=FALSE;
		highletter:=FALSE;
	multipix(menus,'V',100,TotalBar,TotalBar,10,menustart,6,6,choice[10],scode[2]);
		rev:=FALSE;
	until (scode[2]=ENTER) or (scode[2]=ESC);
if choice[10]=1 then begin
				{ Do something }
			end;
c1:=choice[10] div TotalBar;
c2:=choice[10] mod TotalBar-1;
if (c1>=1) and (c2=-1) then
			begin
			c1:=c1-1;
			c2:=TotalBar-1;
			end;
d1:= rangedia[c1];
d2:= rangedia[c2];
if scode[2]=ENTER then
begin
	scode[1]:=#0;
	menustart:=50;
	bars(ast,d1,d2,n1,n2,errp,nomenu,excode);
	if excode=ESC then
			begin
			msg('No choice/Not admissible'+noise);
			scode[1]:=ESC;
			goto 200;
			end;
	choice[9]:=1;
	scode[1]:=NOREAD;
	multipix(menus,'V',100,TotalBar,1,44,menustart,21,10,choice[9],scode[1]);
	scode[1]:=#0;
	repeat
		rev:=FALSE;
		highletter:=FALSE;
		multipix(menus,'V',100,TotalBar,1,44,menustart,21,10,choice[9],scode[1]);
		rev:=FALSE;
	until ((scode[1]=ENTER) and (choice[9]<=nomenu)) or (scode[1]=ESC);
end;
200:
until (scode[1]=ENTER) and
		not((barmap[choice[9]-1,1]=0) and (barmap[choice[9]-1,2]=0));
100:
	n1:=barmap[choice[9]-1,1];
	n2:=barmap[choice[9]-1,2];
	dispose(menus);
	get(screen);
rw(4);
end;
end.

