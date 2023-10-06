uses crt;
const
	alimit=2500;
type
	ab50=array[1..alimit] of byte;
	ar50=array[1..alimit] of real;
	pab50=^ab50;
 	par50=^ar50;
var
        NJ:integer;

PROCEDURE interchange(var x,y:real);
var
	temp:real;
begin
temp:=x;
x:=y;
y:=temp;
end;

FUNCTION eq(x,y:real):boolean;
begin
if abs(x-y)<1e-5 then eq:=TRUE else eq:=FALSE;
end;

PROCEDURE numberjoints(var xdist,ydist,zdist:par50;var convity:pab50);
label 100;
var
	i,j,n:integer;
	vbyte:byte;
        inpfile:text;
        ID:char;
        c2:integer;
        x1,y1,z1,x2,y2,z2:real;
        outfile:text;

begin
clrscr;
writeln('Sorting nodes. Please wait...');
assign(inpfile,'SOMA.SAP');
reset(inpfile);
assign(outfile,'SOMA.OUT');
rewrite(outfile);

i:=0;
while not eof(inpfile) do
begin
readln(inpfile,ID,c2,x1,y1,z1,x2,y2,z2);
if (ID='L') then
begin
	inc(i);
	xdist^[i]:=x1;
	ydist^[i]:=y1;
        zdist^[i]:=z1;
	inc(i);
	xdist^[i]:=x2;
	ydist^[i]:=y2;
        zdist^[i]:=z2;
end;
end;

n:=i;

{ SORTING wrt. Z CO-ORDINATES }
for i:=1 to n do
for j:=i+1 to n do
	begin
	if zdist^[i]>zdist^[j] then
			begin
			interchange(xdist^[i],xdist^[j]);
			interchange(ydist^[i],ydist^[j]);
                        interchange(zdist^[i],zdist^[j]);
			end;
	end;
{
writeln(outfile,'Sort Z');
for i:=1 to n do  writeln(outfile,i:5,'    ',xdist^[i]:5:2,'  ',ydist^[i]:5:2,'   ',zdist^[i]:5:2);
}

{ SORTING wrt. Y CO-ORDINATES }
for i:=1 to n do
for j:=i+1 to n do
	begin
{
	if ydist^[i]>ydist^[j] then
			begin
			interchange(xdist^[i],xdist^[j]);
			interchange(ydist^[i],ydist^[j]);
                        interchange(zdist^[i],zdist^[j]);
			end;
}
	if eq(zdist^[i],zdist^[j]) then
		begin
			if ydist^[i]>ydist^[j] then
				begin
				interchange(xdist^[i],xdist^[j]);
                                interchange(ydist^[i],ydist^[j]);
				end;
		end;
	end;
{
writeln(outfile,'Sort Y');
for i:=1 to n do  writeln(outfile,i:5,'    ',xdist^[i]:5:2,'  ',ydist^[i]:5:2,'   ',zdist^[i]:5:2);
}

{ SORTING wrt. X CO-ORDINATES  and marking connectivity info. }
fillchar(convity^,sizeof(convity^),0);
for i:=1 to n do
for j:=i+1 to n do
	begin
	if eq(ydist^[i],ydist^[j]) and eq(zdist^[i],zdist^[j]) then
		begin
			if eq(xdist^[i],xdist^[j]) then
					begin
					convity^[i]:=1;
					convity^[j]:=1;
					end
			else
			if xdist^[i]>xdist^[j] then
				begin
				interchange(xdist^[i],xdist^[j]);
                                interchange(zdist^[i],zdist^[j]);
				vbyte:=convity^[i];
				convity^[i]:=convity^[j];
				convity^[j]:=vbyte;
				end;
		end;
	end;

{ deleting duplicate co-ordinates }
j:=0;
xdist^[n+1]:=maxint;
ydist^[n+1]:=maxint;
zdist^[n+1]:=maxint;

for i:=1 to n do
	begin
	if not (eq(xdist^[i+1],xdist^[i]) and eq(ydist^[i+1],ydist^[i]) and
                eq(zdist^[i+1],zdist^[i]))
		then
		begin
		j:=j+1;
		xdist^[j]:=xdist^[i];
		ydist^[j]:=ydist^[i];
		zdist^[j]:=zdist^[i];
		convity^[j]:=convity^[i];

write(outfile,j:5,'C    ');
if eq(zdist^[i],1.5) then
                         write(outfile,'1    1    1    1    1    1')
                     else
                         write(outfile,'0    0    0    0    0    0');

writeln(outfile,xdist^[i]:10:3,'  ',ydist^[i]:10:3,'   ',zdist^[i]:10:3,'    0      .000');
{    1C   1    1    1    1    1    0      .000      .000      .000    0      .000}

		end;
	end;
NJ:=j;
close(inpfile);
close(outfile);
end;

var
   xdist,ydist,zdist:par50;
   convity:pab50;

begin
new(xdist);
new(ydist);
new(zdist);
new(convity);
numberjoints(xdist,ydist,zdist,convity);
end.
