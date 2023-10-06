unit sub;
interface
PROCEDURE  sub_ana(afilename:string);
implementation
uses crt,lib,alib;
type real_6=array[1..4,1..6] of real;
var
	zp,n,spans:integer;
	result:array[1..6,1..7] of real;
	balance:real;
	sumfem1,sumfem2:real;
	hpx,hpy,hpz:real;

PROCEDURE  LeftRight;
begin
point:=hpoint;
with point^ do
begin
if (rlud[1]=nil) and (rlud[2]=nil)
	then
	begin
	if (rlud[3]=nil) and (rlud[4]<>nil) then point:=rlud[4];
	if (rlud[4]=nil) and (rlud[3]<>nil) then point:=rlud[3];
	end;
while (rlud[2]<>nil) do	point:=rlud[2];
end;
leftmost:=point;
spans:=0;
point:=leftmost;
while (point^.rlud[1]<>nil) do
	begin
		fillchar(point^.max,sizeof(point^.max),0);
		point:=point^.rlud[1];
		spans:=spans+1;
	end;
fillchar(point^.max,sizeof(point^.max),0);
rightmost:=point;
end;

PROCEDURE  loadmatrix;
		      {****** GENERATION OF LOAD MATRIX ******}
begin
fillchar(loadmat,sizeof(loadmat),0);
if leftmost^.sup='F'
	then
		loadmat[1,1]:=2
	else
		loadmat[1,1]:=1; { useless array }
if rightmost^.sup='F'
	then
		loadmat[spans+1,spans]:=2    { useless array }
	else
		loadmat[spans+1,1]:=1;
for subk:=2 to spans do
	begin
		loadmat[subk,subk-1]:=1;
		loadmat[subk,subk]:=1;
	end;
for subk:=1 to spans do
	if odd(subk) then
			loadmat[spans+2,subk]:=1  {Live loading on odd spans}
		else
			loadmat[spans+3,subk]:=1; {Live loading on even spans}
for subk:=1 to spans do
	loadmat[spans+4,subk]:=1;
end;

PROCEDURE  analyse;
var
	tz:byte;
	i,n:integer;
begin
{INITIALIZATION OF VARIABLES TO ZERO}
point:=leftmost;
repeat
with point^ do
  begin
   fillchar(mm,sizeof(mm),0);
   if rlud[3]<>nil then fillchar(rlud[3]^.mm[4],sizeof(rlud[3]^.mm[4]),0);
   if rlud[4]<>nil then fillchar(rlud[4]^.mm[3],sizeof(rlud[4]^.mm[3]),0);
  end;
  point:=point^.rlud[1];
until point=nil;
point:=leftmost;


if loadmat[subj,1]<>2
	then
		begin
		writeln(out);
		write(out,'Loading Pattern  : ');
		point:=leftmost;
		with point^ do
for subk:=1 to spans do
	 begin
	    write(out,point^.id);
	    if point^.rlud[1]<>nil then
		begin
		if loadmat[subj,subk]=1 then write(out,' __DL+LL__ ');
		if loadmat[subj,subk]=0 then write(out,' ___DL____ ');
		point:=point^.rlud[1];
		end;
	  end;
		write(point^.id);
		writeln(out);
		writeln(out);
			point:=leftmost;
			subk:=0;
                        while point^.rlud[1]<>nil do
			     begin
			     inc(subk);
				tot_fems(point^.id,point^.rlud[1]^.id,sumfem1,sumfem2);
				point^.mm[1][1]:=sumfem1;
                                point^.rlud[1]^.mm[2][1]:=sumfem2;
                                point:=point^.rlud[1];
                            end;

i:=-1;
repeat
i:=i+2;
point:=leftmost;
repeat
    n:=i;
    balance:=0-(point^.mm[1][n]+point^.mm[2][n]+point^.mm[3][n]+point^.mm[4][n]);
    n:=n+1;
					{BALANCING}
for zp:=1 to 4 do
	begin
	case zp of
		1:tz:=2;
		2:tz:=1;
		3:tz:=4;
		4:tz:=3;
	end;
	with point^ do
	    if rlud[zp]<>nil
		then
			begin
			mm[zp][n]:=u4[zp]*balance;
			if n<6 then rlud[zp]^.mm[tz][n+1]:=mm[zp][n]/2;
			end;
	end;
{CARRY OVER}
	point:=point^.rlud[1];
until point=nil;
until i=5;
end;
end;

PROCEDURE  results;
var i:integer;
begin
point:=leftmost;
writeln(out,'------------------------------------------------------------------------------');
writeln(out,' NAME       D.F     FEM      BAL      CO       BAL      CO       BAL     TOTAL');
writeln(out,'------------------------------------------------------------------------------');
repeat
with point^ do
begin
	fillchar(mtotal,sizeof(mtotal),0);
	for zp:=1 to 4 do
	if (rlud[zp]<>nil) and (sup<>'F') then
	    begin
		for i:=1 to 6 do mtotal[zp]:=mtotal[zp]+mm[zp,i];
		if abs(max[zp])<abs(mtotal[zp]) then max[zp]:=mtotal[zp];
		{ # check above ineqalities }
		write(out,id:2,'-',rlud[zp]^.id:2,'      ',u4[zp]:3:2);
		for i:=1 to 6 do
			write(out,mm[zp][i]:9:2);
		writeln(out,mtotal[zp]:9:2);
	    end;
end;
point:=point^.rlud[1];
until point=nil;
writeln(out,'------------------------------------------------------------------------------');
msg('<HOLD>');
waitfor(any);
end;


PROCEDURE bendresult(subk:integer);
var bmdfile,sfdfile:text;
	maxpo,maxer,contra1,contra2,sfl,sfr:real;
begin
with point^ do
	begin
	bendmax(bmdfile,sfdfile,FALSE,id,rlud[1]^.id,mtotal[1],
	rlud[1]^.mtotal[2],maxpo,maxer,contra1,contra2,sfl,sfr);
	if abs(result[subk,1])<abs(maxpo) then
			begin
				result[subk,1]:=maxpo;
				result[subk,5]:=maxer;
				result[subk,6]:=contra1;
				result[subk,7]:=contra2;
			end;
	if abs(result[subk,3])<abs(sfl) then result[subk,3]:=sfl;
	if abs(result[subk,4])<abs(sfr) then result[subk,4]:=sfr;
	{ result[subk,2] transferred to write_dvalues}
	end;
end;

PROCEDURE  designvalues;
begin
subk:=0;
point:=leftmost;
repeat
if (point^.rlud[1]<>nil) then
	begin
		subk:=subk+1;
		{
		if ((subj=spans+2) and odd(subk))
			or ((subj=spans+3) and not odd(subk)) then
		}
		bendresult(subk);
	end;
	point:=point^.rlud[1];
	until point=rightmost;
end;

PROCEDURE  write_dvalues;
var
	bmdfile,sfdfile:text;
	maxpo,maxer,contra1,contra2,sfl,sfr:real;
	j:integer;
begin
window(1,1,80,25);
clrscr;
writeln(out,'                                 CRITICAL VALUES ');
writeln(out);
writeln(out,'-------------------------------------------------------------------------------');
writeln(out,'MEMBER    B.M(L)   B.M(M)   B.M(R)   S.F(L)   S.F(R)    S.F=0    B.M=0    B.M=0');
writeln(out,'-------------------------------------------------------------------------------');

point:=leftmost;
subk:=0;
repeat
with point^ do
begin
if (rlud[1]<>nil) then
	begin
	inc(subk);
	result[subk,2]:=rlud[1]^.max[2];
	write(out,id:2,'-',rlud[1]^.id:2,'  ',max[1]:9:2);
	for j:=1 to 7 do write(out,result[subk,j]:9:2);
	writeln(out);
	end;
if rlud[3]<>nil  then
	writeln(out,id:2,'-',rlud[3]^.id:2,'  ',max[3]:9:2);
if rlud[4]<>nil then
	writeln(out,id:2,'-',rlud[4]^.id:2,'  ',max[4]:9:2);
end;
point:=point^.rlud[1];
until point=nil;
writeln(out,'-------------------------------------------------------------------------------');

{
point:=leftmost;
repeat
with point^ do
	if rlud[1]<>nil then
bendmax(bmdfile,sfdfile,FALSE,id,rlud[1]^.id,
		max[1],rlud[1]^.max[2],maxpo,maxer,contra1,contra2,sfl,sfr);

point:=point^.rlud[1];
until point=nil;
}
end;

PROCEDURE  sub_ana(afilename:string);
var
	heap:^integer;
	screen:image;
begin
put(screen);
clrscr;
soker:='S';
makeframe(hpx,hpy,hpz);
leftright;
disfact;
loadmatrix;
fillchar(result,sizeof(result),0);
for subj:=1 to spans+4 do
	begin
	analyse;
	results;
	designvalues;
	end;
write_dvalues;
msg('<HOLD>');
waitfor(any);
get(screen);
end;
end.
