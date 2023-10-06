unit agi;
interface
uses 	crt,lib,graph,glib;
const
	maxrec=500; {  Max no.of slabs }
	alimit=500;
	col_load_factor=2.5;
	deadload=2.5;
type
	faxistype=array[1..50] of integer;
	fcotype=array[1..50] of real;
	fdirtype=array[1..50] of string[12];
	ar50=array[1..alimit] of real;
	ab50=array[1..alimit] of byte;

	pfaxistype=^faxistype;
	pfcotype=^fcotype;
	pfdirtype=^fdirtype;
	par50=^ar50;
	pab50=^ab50;

	ar8_3=array[1..8,1..3] of real;
	edgetype=array[1..3] of real;
	rectype=record
		edge:array[1..4] of edgetype;
		ec:byte;
		lx,ly,w:real;
		end;
	arec=array[1..maxrec] of rectype;
var
	pa:ar8_3;
	NJ:integer;
	Afile,Lfile,Sfile:text;
	sno:integer;
const
	fno:integer=1;

PROCEDURE graph2data(fname:string);
PROCEDURE genBMD(fname:string);
PROCEDURE genLD(fname:string);
implementation
PROCEDURE markframes(var faxis:pfaxistype;var fco:pfcotype;var fdir:pfdirtype);
var
	dupli:boolean;
	t:byte;
	j:integer;
	co:real;
	flag:boolean;
begin
dbase:=first^.a;
while dbase<>NIL do
begin
with dbase^ do
if (ID='L') then
	begin
	if eq(d[1],d[4]) and eq(d[2],d[5]) and not eq(d[3],d[6]) then
		begin
		faxis^[fno]:=1;
		fco^[fno]:=d[1];
		dupli:=FALSE;
		for i:=1 to fno-1 do
		if (faxis^[i]=faxis^[fno]) and eq(fco^[i],fco^[fno]) then
					dupli:=TRUE;
		if not dupli
				then
					begin
					{
					writeln(faxis^[fno],' ',fco^[fno]);
					}
					inc(fno);
					end;
		dupli:=FALSE;
		faxis^[fno]:=2;
		fco^[fno]:=d[2];
		for i:=1 to fno-1 do
		if (faxis^[i]=faxis^[fno]) and eq(fco^[i],fco^[fno]) then
					dupli:=TRUE;
		if not dupli
			then
				begin
				{ writeln(faxis^[fno],' ',fco^[fno]);}
				inc(fno);
				end;
		end;
	end;
dbase:=dbase^.a;
end;

dec(fno);
for i:=1 to fno do
	for j:=i+1 to fno do
		begin
		if ((faxis^[i]=faxis^[j]) and (fco^[i]>fco^[j])) or
		(faxis^[i]>faxis^[j]) then
			begin
				t:=faxis^[i];
				faxis^[i]:=faxis^[j];
				faxis^[j]:=t;
				co:=fco^[i];
				fco^[i]:=fco^[j];
				fco^[j]:=co;
			end;
		end;
flag:=TRUE;
j:=0;

for i:=1 to fno do
	begin
	if flag and (cLfix[faxis^[i]]='Y') then
				begin
				j:=0;
				flag:=FALSE;
				end;
	inc(j);
	fdir^[i]:='F'+cLfix[faxis^[i]]+nospace(strint(j,4))+'.ASI';
	{+'_'+strreal(fco^[i],5,3);}
	{writeln(faxis^[i],fco^[i]);}
	end;
end;

PROCEDURE datacheck;
label
	100;
begin
dbase:=first^.a;
while dbase<>NIL do
begin
with dbase^ do
	if (ID='L') then
		begin
		case Lfix of
			1:
			begin
			if (d[1]=pfix) and (d[4]=pfix) then
				begin
				     if (d[2]=d[5]) and (d[3]=d[6]) then goto 100;
				end
				     else goto 100;

			end;
			2:
			begin
			if (d[2]=pfix) and (d[5]=pfix) then
				begin
				     if (d[1]=d[3]) and (d[3]=d[6]) then goto 100;
				end
				     else goto 100;
			end;
			3:
			begin
			if (d[3]=pfix) and (d[6]=pfix) then
				begin
				     if (d[2]=d[5]) and (d[1]=d[3]) then goto 100;
				end
				     else goto 100;
			end;
		end;
		end;
100:	dbase:=dbase^.a;
end;
end;

PROCEDURE grfcheck;
label
	100;
begin
dbase:=first^.a;
while dbase<>NIL do
begin
with dbase^ do
	if (ID='L') then
		begin
		case Lfix of
			1:
			begin
			if (d[1]=pfix) and (d[4]=pfix) then
				begin
				     if (d[2]=d[5]) and (d[3]=d[6]) then goto 100;
				end
				     else goto 100;

			end;
			2:
			begin
			if (d[2]=pfix) and (d[5]=pfix) then
				begin
				     if (d[1]=d[3]) and (d[3]=d[6]) then goto 100;
				end
				     else goto 100;
			end;
			3:
			begin
			if (d[3]=pfix) and (d[6]=pfix) then
				begin
				     if (d[2]=d[5]) and (d[1]=d[3]) then goto 100;
				end
				     else goto 100;
			end;
		end;
		end;
100:	dbase:=dbase^.a;
end;
end;


PROCEDURE numberjoints(var xdist,ydist:par50;var convity:pab50);
label 100;
var
	i,j,n:integer;
	vbyte:byte;
begin
dbase:=first^.a;
i:=0;
while dbase<>NIL do
with dbase^ do
begin
if (ID='L') then
	begin
	case Lfix of
	1:
		begin
		if not (eq(d[1],pfix) and eq(d[4],pfix)) then goto 100;
		x1:=d[2];
		y1:=d[3];
		x2:=d[5];
		y2:=d[6];
		end;
	2:
		begin
		if not (eq(d[2],pfix) and eq(d[5],pfix)) then goto 100;
		x1:=d[1];
		y1:=d[3];
		x2:=d[4];
		y2:=d[6];
		end;
	3:
		begin
		if not (eq(d[3],pfix) and eq(d[6],pfix)) then goto 100;
		x1:=d[1];
		y1:=d[2];
		x2:=d[4];
		y2:=d[5];
		end;
	else halt;
end;
	inc(i);
	if i>300 then
		i:=i;
	xdist^[i]:=x1;
	ydist^[i]:=y1;
	inc(i);
	xdist^[i]:=x2;
	ydist^[i]:=y2;
end;
100: dbase:=dbase^.a;
end;
n:=i;
{
for i:=1 to n do
	begin
	writeln(i:5,'    ',xdist^[i]:5:2,'  ',ydist^[i]:5:2);
	end;
}
{ SORTING wrt. Y CO-ORDINATES }
for i:=1 to n do
for j:=i+1 to n do
	begin
	if ydist^[i]>ydist^[j] then
			begin
			interchange(xdist^[i],xdist^[j]);
			interchange(ydist^[i],ydist^[j]);
			end;
	end;
{
for i:=1 to n do
	begin
	writeln(i:5,'    ',xdist^[i]:5:2,'  ',ydist^[i]:5:2);
	end;
}

{ SORTING wrt. X CO-ORDINATES  and marking connectivity info. }
fillchar(convity^,sizeof(convity^),0);
for i:=1 to n do
for j:=i+1 to n do
	begin
	if eq(ydist^[i],ydist^[j]) then
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

for i:=1 to n do
	begin
	if not (eq(xdist^[i+1],xdist^[i]) and eq(ydist^[i+1],ydist^[i]))
		then
		begin
		j:=j+1;
		xdist^[j]:=xdist^[i];
		ydist^[j]:=ydist^[i];
		convity^[j]:=convity^[i];
{
		writeln(j:5,'    ',xdist^[i]:5:2,'  ',ydist^[i]:5:2);
}
		end;
	end;
NJ:=j;
end;

PROCEDURE givename(xdist,ydist:par50;x,y:real;var jname:integer);
var
	i:integer;
begin
jname:=0;
for i:=1 to NJ do
	if eq(xdist^[i],x) and eq(ydist^[i],y)
		then
			jname:=i;
if jname=0 then msg('NOT FOUND.'+#7);
end;


PROCEDURE writeload(var Lfile:text;loader,lx,ly:real);
begin
If not LD then exit;
writeln(Lfile,0,h,0,h,
(ly/2):6:2,h,
(loader*ly/2):6:2,h,
(lx-ly/2):6:2,h,
(loader*ly/2):6:2,h,
lx:6:2,h,
0);
end;


PROCEDURE getload(var Lfile:text;var rec:arec;wors:byte;var load:real);
var
	n:byte;
	lxt,lyt,lxb,lyb:real;
	pa:ar8_3;
	pic:link;
	xoy:char;
PROCEDURE d2p(x:byte;pic:link;y:byte;var pa:ar8_3);
	begin
	with pic^ do
	begin
	d0:=ord('M');
	case y of
	1:
		begin
			pa[x,1]:=x1;
			pa[x,2]:=y1;
			pa[x,3]:=d[3];
		end;
	2:
		begin
			pa[x,1]:=x2;
			pa[x,2]:=y2;
			pa[x,3]:=d[6];
		end;
	end;
	end;
	end;

	function eqpd(pa:ar8_3;x:byte;pic:link;y:byte):boolean;
	begin
	eqpd:=FALSE;
	with pic^ do
	case y of
	1:if eq(pa[x,1],x1) and eq(pa[x,2],y1) and eq(pa[x,3],d[3]) then eqpd:=TRUE;
	2:if eq(pa[x,1],x2) and eq(pa[x,2],y2) and eq(pa[x,3],d[6]) then eqpd:=TRUE;
	end;
	end;

	function yz(pic:link;wors:byte;x:byte):real;
	begin
	with pic^ do
	if wors=3
	then
		begin
		if x=1 then yz:=d[3] else yz:=d[6]
		end
	else
		begin
		if x=1 then yz:=y1 else yz:=y2;
		end;
	end;

	procedure ifyturn(dbase:link;var x1,y1,x2,y2:real);
	begin
	with dbase^ do
	begin
	if xoy='X' then
		begin
		x1:=d[1];
		y1:=d[2];
		x2:=d[4];
		y2:=d[5];
		end
	else
		begin
		x1:=d[2];
		y1:=d[1];
		x2:=d[5];
		y2:=d[4];
		end;
	end;
	end;

begin
{
writeln('Generating ',wors,' data ...');
}
if wors=3 then n:=2 else n:=3; { wors=2 for wall; 3 for wlab;
				n=2 for y fixed; 3 for z fixed }
lxt:=0;
lyt:=0;
lxb:=0;
lyb:=0;
fillchar(pa,sizeof(pa),0);
with dbase^ do
begin
if eq(d[2],d[5]) then
	begin
	x1:=d[1];
	y1:=d[2];
	x2:=d[4];
	y2:=d[5];
	xoy:='X';
	end
	else
if eq(d[1],d[4]) then
	begin
	x1:=d[2];
	y1:=d[1];
	x2:=d[5];
	y2:=d[4];
	xoy:='Y';
	end
	else
		begin
		writeln(#7,#7,#7,#7);
		halt;
		end;
if x1>x2 then
	begin
	d2p(1,dbase,2,pa);
	d2p(2,dbase,1,pa);
	end
    else
	begin
	d2p(1,dbase,1,pa);
	d2p(2,dbase,2,pa);
	end;
d0:=ord('M');
end;
pic:=first^.a;
while pic<>NIL do
	begin
	ifyturn(pic,x1,y1,x2,y2);
with pic^ do
if (d0<>ord('M')) and eq(x1,x2) and eq(yz(pic,wors,1),yz(pic,wors,2)) then
	if eqpd(pa,2,pic,1) then
			begin
			if yz(pic,n,2)>pa[2,n] then
					d2p(3,pic,2,pa)
				      else
					d2p(4,pic,2,pa);
			end
	else
	if eqpd(pa,2,pic,2) then
			begin
			if yz(pic,n,1)>pa[2,n] then
					d2p(3,pic,1,pa)
				else
					d2p(4,pic,1,pa);
			end;
	pic:=pic^.a;
	end;
pic:=first^.a;
while pic<>NIL do
	begin
	ifyturn(pic,x1,y1,x2,y2);
	with pic^ do
	if (d0<>ord('M')) and eq(y1,y2) and eq(d[3],d[6]) then
	if eqpd(pa,3,pic,1) and (x2<pa[3,1]) then
			d2p(5,pic,2,pa)
	else
	if eqpd(pa,3,pic,2) and (x1<pa[3,1]) then
			d2p(5,pic,1,pa)
	else
	if eqpd(pa,4,pic,1) and (x2<pa[4,1]) then
			d2p(6,pic,2,pa)
	else
	if eqpd(pa,4,pic,2) and (x1<pa[4,1]) then
			d2p(6,pic,1,pa);
	pic:=pic^.a;
	end;
pic:=first^.a;
while pic<>NIL do
	begin
	ifyturn(pic,x1,y1,x2,y2);
	with pic^ do
	if (d0<>ord('M')) and eq(x1,x2) and eq(yz(pic,wors,1),yz(pic,wors,2)) then

	if eqpd(pa,5,pic,1) and (yz(pic,n,2)<pa[5,n]) then
			d2p(7,pic,2,pa)
	else
	if eqpd(pa,5,pic,2) and (yz(pic,n,1)<pa[5,n]) then
			d2p(7,pic,1,pa)
	else
	if eqpd(pa,6,pic,1) and (yz(pic,n,2)>pa[6,n]) then
			d2p(8,pic,2,pa)
	else
	if eqpd(pa,6,pic,2) and (yz(pic,n,1)>pa[6,n]) then
			d2p(8,pic,1,pa);
	pic:=pic^.a;
	end;
if eq(pa[1,1],pa[7,1]) and eq(pa[1,2],pa[7,2]) and eq(pa[1,3],pa[7,3]) then
		begin
		if eq(pa[2,1]-pa[1,1],pa[3,1]-pa[5,1])
				then
					begin
					lxt:=pa[2,1]-pa[1,1];
					end
				else
					begin
					writeln('ERROR 1',#7);
					end;
		if eq(pa[5,n]-pa[1,n],pa[3,n]-pa[2,n])
				then
					begin
					lyt:=pa[5,n]-pa[1,n];
					end
				else
					begin
					writeln('ERROR 2',#7);
					end;

		end;
{
		else
			writeln('No ',wors,' on top');
}
if eq(pa[1,1],pa[8,1]) and eq(pa[1,2],pa[8,2]) and eq(pa[1,3],pa[8,3]) then
		begin
		if eq(pa[2,1]-pa[1,1],pa[4,1]-pa[6,1])
				then
					begin
					lxb:=pa[2,1]-pa[1,1];
					end
				else
					begin
					writeln('ERROR 3',#7);
					end;
		if eq(pa[1,n]-pa[6,n],pa[2,n]-pa[4,n])
				then
					begin
					lyb:=pa[1,n]-pa[6,n];
					end
				else
					writeln('ERROR 4',#7);
		end;
{
		else
			writeln('No ',wors,' on bottom');
if eq(lxt,lxb) then writeln('ERROR 5',#7);
writeln(lxt:5:2,lyt:5:2,lxb:5:2,lyb:5:2);
}
pic:=first^.a;
while pic<>NIL do
	begin
	pic^.d0:=ord('S');
	pic:=pic^.a;
	end;
case wors of
	3:               { Equivalent udl from slab on beam }
		begin
		if lxt>lyt then
			begin
				load:=(liveload+deadload)*lxt/2*(1-1/3.0*sqr(lyt/lxt)); {# lx > ly }
				writeload(Lfile,liveload+deadload,lxt,lyt);
			end
			else
			begin
				load:=(liveload+deadload)*lxt/3;
				writeload(Lfile,liveload+deadload,lxt,lxt);
			end;
		if lxb>lyb then
			begin
			load:=load+(liveload+deadload)*lxb/2*(1-1/3*sqr(lyb/lxb));      {# lx > ly }
			writeload(Lfile,liveload+deadload,lxb,lyb);
			end
			else
			begin
			load:=load+(liveload+deadload)*lxb/3;
			writeload(Lfile,liveload+deadload,lxb,lxb);
			end;
		end;
	2:      	{ Udl due to wt. of wall }
		begin
		load:=wload*lyt;
if LD then writeln(Lfile,0,h,0,h,0,h,load:6:2,h,lxt:6:2,h,load:6:2,h,lxt:6:2,h,0);
		end;
	end;

if (Lfix=1) and (wors=3) and not (eq(lxt,0) or eq(lyt,0)) then
		begin
		inc(sno);
		{
		writeln('slabno = ',sno);
		}
		if sno>maxrec then
					begin
					restorecrtmode;
					closegraph;
					DirectVideo:=TRUE;
msg('Fatal Error : Array limit exceeds.');
					halt;
					end;
		with rec[sno] do
			begin
			for i:=1 to 3 do
				begin
					edge[1][i]:=pa[5,i];
					edge[2][i]:=pa[3,i];
					edge[3][i]:=pa[2,i];
					edge[4][i]:=pa[1,i];
				end;
			if lxt>lyt then
					begin
					lx:=lyt;
					ly:=lxt;
					end
				else
					begin
					lx:=lxt;
					ly:=lyt;
					end;
			w:=(liveload+deadload);
			end;
		end;
end;

FUNCTION getsco(dbase:link):string;
var
	ts,s:string;
begin
s:='';
with dbase^ do
	begin
		str(d[1]:6:2,ts);
		insert(ts,s,length(s)+1);
		str(d[2]:6:2,ts);
		insert(ts,s,length(s)+1);
		str(d[3]:6:2,ts);
		insert(ts,s,length(s)+1);
		str(d[4]:6:2,ts);
		insert(ts,s,length(s)+1);
		str(d[5]:6:2,ts);
		insert(ts,s,length(s)+1);
		str(d[6]:6:2,ts);
		insert(ts,s,length(s)+1);
	end;
getsco:=s;
end;

procedure getdepth(var depthfile:text;x,y,z:real;var Dfix:real);
var
	hz,load:real;
	pic:link;
	mindiff,depth:real;
	i:integer;
	xt,yt,zt:real;
begin
xt:=x+100; { to assist read condition in while loop }
if Lfix<>1 then
	begin
	reset(depthfile);
while (not eof(depthfile)) and not (eq(x,xt) and eq(y,yt) and eq(z,zt)) do
		readln(depthfile,xt,yt,zt,Dfix);
	close(depthfile);
	if eq(x,xt) and eq(y,yt) and eq(z,zt) then
				exit
			else
				outtextxy(250,1,'ERROR');
	end;

hz:=z;
load:=0;
pic:=first^.a;
while pic<>NIL do
begin
with pic^ do
if eq(d[3],d[6]) and
	   ((eq(x,d[1]) and eq(y,d[2])) or (eq(x,d[4]) and eq(y,d[5])))
	   and (z<d[3]) then
				begin
				load:=load+pic^.ed/2;
				if d[3]>hz then hz:=d[3];
				end;
pic:=pic^.a;
end;
load:=col_load_factor*(load+(hz-z)*cfixedb*1e-3*0.5*25);
Dfix:=0;
repeat      { assume p=0.8% ; fck = 15 ; fy =250 }
Dfix:=Dfix+25;
until (load*1000<(0.4*15*(cfixedb*dfix-0.80*cfixedb*dfix/100)+0.67*250*0.80*cfixedb*dfix/100));
mindiff:=0;
depth:=0;
for i:=1 to 5 do
if (Dfix<cdrange[i]) and ((mindiff=0) or (cdrange[i]-Dfix<mindiff)) then
				 begin
				 mindiff:=cdrange[i]-Dfix;
				 depth:=cdrange[i];
				 end;
if depth=0 then
	outtextxy(250,1,'Range of depth for column inadequate')
	else Dfix:=depth;
if Lfix=1 then
	begin
		{$i-}
		writeln(depthfile,x:6:2,'   ',y:6:2,'  ',z:6:2,'  ',Dfix:6:2);
		{$i+}
	end;
end;


PROCEDURE graph2data(fname:string);
label 100,200;
var
	mnb:integer;
	depthfile:text;
	small,large:real;
	n1,n2:integer;
	resp:string[1];
	load:real;
	flag:boolean;

	faxis:pfaxistype;
	fco:pfcotype;
	xdist,ydist:par50;
	convity:pab50;
	fdir:pfdirtype;

	mindiff,depth,Dfix:real;
	i,j,k:integer;
	filename:string;
	c,ch,sup1,sup2:char;
	rec:arec;
	trec:rectype;
	b,d,z1,z2,z3,z4:real;
	fixback:integer;

	function eqedge(i,m,j,n:integer):boolean;
	var
		k:integer;
	begin
	eqedge:=TRUE;
	for k:=1 to 3 do
	if not eq(rec[i].edge[m][k],rec[j].edge[n][k])
				then eqedge:=FALSE;
	end;


	function getmember:boolean;
	begin
	getmember:=FALSE;
	with dbase^ do
	begin
	if (ID='L') then
		begin
		if not(eq(d[Lfix],pfix) and eq(d[Lfix+3],pfix))
						then
							exit
						else
							getmember:=TRUE;

		case Lfix of
		1:
			begin
			x1:=d[2];
			y1:=d[3];
			x2:=d[5];
			y2:=d[6];
			end;
		2:
			begin
			x1:=d[1];
			y1:=d[3];
			x2:=d[4];
			y2:=d[6];
			end;
		3:
			begin
			x1:=d[1];
			y1:=d[2];
			x2:=d[4];
			y2:=d[5];
			end;
		end;
	end;
	end;
	end;
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

begin
fixback:=Lfix;
new(faxis);
new(fco);
new(xdist);
new(ydist);
new(convity);
new(fdir);

deldupli;

z1:=LimX;
z2:=LimY;
sno:=0;
markframes(faxis,fco,fdir);
fullport;
setfile(depthfile,s,'VCAD_01.TMP','W',excode);
for i:=1 to fno do
begin
if (i in order) or (order=[]) then
begin
cvp;
flag:=TRUE;
Lfix:=faxis^[i];
pfix:=fco^[i];
outtextxy(1,1,'Writing to '+fdir^[i]+'...');
if (Lfix=2) then
	if i>1 then
		begin
		if faxis^[i-1]=1 then close(depthfile)
		end
		else outtextxy(250,1,'ERROR2');
setfile(Afile,s,fdir^[i],'W',excode);
writeln(Afile,'FRAME');
filename:=fdir^[i];
filename[1]:='L';
if LD then
	begin
	setfile(Lfile,s,filename,'W',excode);
	writeln(Lfile,'LOAD');
	end;
numberjoints(xdist,ydist,convity);
LimX:=xdist^[NJ]+4;
LimY:=ydist^[NJ]+4;
{clrscr;}
{ 	extracting beam data      }

Layerregen;

dbase:=first^.a;
while dbase<>NIL do
begin
if not getmember then goto 100;
if eq(y1,y2) then         {BEAM}
	begin
	if x1>x2 then
		begin
		small:=x2;
		large:=x1;
		end
	else
		begin
		small:=x1;
		large:=x2;
		end;
	if flag then
		begin
	writeln(Afile,small:6:3,h,y1:6:3,h,pfix:6:2);
		flag:=FALSE;
		end;
If LD then writeln(Lfile,'H',h,small:6:2,h,y1:6:2,h,large:6:2,h,y2:6:2);
	{
	writeln(Afile,getsco(dbase));
	}
	givename(xdist,ydist,small,y1,n1);
	outtextxy(adpx(small)-15,adpy(y1)+2,strint(n1,1));
	givename(xdist,ydist,large,y2,n2);
	outtextxy(adpx(large)-15,adpy(y1)+2,strint(n2,1));
	if (convity^[n1]=0) then
				sup1:='F'
			    else
				sup1:='C';
	if (convity^[n2]=0) then
				sup2:='F'
			    else
				sup2:='C';
	Dfix:=(trunc((large-small)/12*1000/50)*50);
	mindiff:=0;
	depth:=0;
	for k:=1 to 5 do
	if (Dfix<bdrange[k]) and ((mindiff=0) or (bdrange[k]-Dfix<mindiff)) then
				 begin
				 mindiff:=bdrange[k]-Dfix;
				 depth:=bdrange[k];
				 end;
	if depth=0 then
		outtextxy(250,1,'Range of depth for beam inadequate')
		else Dfix:=depth;
	writeln(Afile,n1,'-',n2,h             { NAME }
	,'R',h                   { DIR }
	,sup1,h
	,sup2,h
	,(large-small):6:2,h           { LENGTH }
	,bfixedb:6,h
	,round(Dfix):6);
	{ SLAB - 3 (Z) ; WALL - 2 (Y) }
	getload(Lfile,rec,3,load);
{
	if eq(load,0) then
			begin
			writeln(#7,#7,#7,#7);
			halt;
			end;
}
	dbase^.ed:=load*(large-small);
	if not eq(load,0) then
		begin
			writeln(Afile,'U',h,load:6:2,h,'D');
		end;
	getload(Lfile,rec,2,load);
	dbase^.ed:=dbase^.ed+load*(large-small);
	if not eq(load,0) then
		begin
			writeln(Afile,'U',h,load:6:2,h,'D');
		end;
	{ Self weight of beam }
	load:=bfixedb*Dfix*(1e-6)*25;
	dbase^.ed:=dbase^.ed+load*(large-small);
		writeln(Afile,'U',h,load:6:2,h,'D',h,'.');
If LD then writeln(Lfile,maxint,h,maxint);
end;
100:
	dbase:=dbase^.a;
end;

{ 	extracting column data      }

dbase:=first^.a;
while dbase<>NIL do
begin
if not getmember then goto 200;
if eq(x1,x2) then			 {COLUMN}
	begin
	if y1>y2 then
		begin
		small:=y2;
		large:=y1;
		end
	else
		begin
		small:=y1;
		large:=y2;
		end;
	if flag then
		begin
		writeln(Afile,x1:6:2,h
		,small:6:2,h
		,pfix:6:2);
		flag:=FALSE;
		end;
If LD then writeln(Lfile,'V',h,x1:6:2,h,small:6:2,h,x2:6:2,h,large:6:2);
	{
	writeln(Afile,getsco(dbase));
	}
	givename(xdist,ydist,x1,small,n1);
	outtextxy(adpx(x1)-15,adpy(small)+2,strint(n1,1));
	givename(xdist,ydist,x2,large,n2);
	outtextxy(adpx(x2)-15,adpy(large)+2,strint(n2,1));
	if (convity^[n1]=0) then sup1:='R'
				else sup1:='C';      { SUP 1 }
	if (convity^[n2]=0) then	sup2:='R'
				else sup2:='C';             { SUP 2 }
	with dbase^ do
	if d[3]<d[6]
		then
			getdepth(depthfile,d[1],d[2],d[3],Dfix)
		else
			getdepth(depthfile,d[4],d[5],d[6],Dfix);
	if Lfix=1 then
		begin
		b:=bfixedb;
		d:=Dfix;
		end
		else
                begin
		d:=bfixedb;
		b:=Dfix;
		end;
	writeln(Afile,n1,'-',n2,h             { NAME }
	,'U',h                   { DIR }
	,sup1,h
	,sup2,h
	,(large-small):6:2,h           { LENGTH }
	,round(b):6,h
	,round(d):6,h
	,'.');
If LD then writeln(Lfile,maxint,h,maxint);
	end;
200:
	dbase:=dbase^.a;
end;
writeln(Afile,'END');
close(Afile);
if LD then close(Lfile);
delay(250);
end;
end;

LimX:=z1;
LimY:=z2;

setfile(Afile,s,firstname(fname)+'.PRJ','W',excode);	{ # Writing name of frames to Project file }
writeln(Afile,'PROJECT');
for i:=1 to fno do writeln(Afile,fdir^[i]);
close(Afile);
{
until (scode[1]=ESC) or ((choice[1]=fno+1) and (i=fno));
}
fno:=1;
for i:=1 to sno do
begin
rec[i].ec:=0;
for j:=1 to sno do
	if i<>j then
	begin
	if  eqedge(i,1,j,4) and eqedge(i,2,j,3)
			then rec[i].ec:=rec[i].ec or 8;
	if  eqedge(i,2,j,1) and eqedge(i,3,j,4)
			then rec[i].ec:=rec[i].ec or 4;
	if  eqedge(i,4,j,1) and eqedge(i,3,j,2)
			then rec[i].ec:=rec[i].ec or 2;
	if  eqedge(i,1,j,2) and eqedge(i,4,j,3)
			then rec[i].ec:=rec[i].ec or 1;
	end;
end;

for i:=1 to sno do
for j:=i+1 to sno do
	if rec[i].edge[1][3]>rec[j].edge[1][3] then
		begin
		trec:=rec[j];
		rec[j]:=rec[i];
		rec[i]:=trec;
		end;

for i:=1 to sno do
for j:=i+1 to sno do
	if eq(rec[i].edge[1][3],rec[j].edge[1][3]) and
	     (rec[i].edge[1][2]>rec[j].edge[1][2]) then
		begin
		trec:=rec[j];
		rec[j]:=rec[i];
		rec[i]:=trec;
		end;

for i:=1 to sno do
for j:=i+1 to sno do
	if eq(rec[i].edge[1][3],rec[j].edge[1][3]) and
	   eq(rec[i].edge[1][2],rec[j].edge[1][2]) and
	     (rec[i].edge[1][1]>rec[j].edge[1][1]) then
		begin
		trec:=rec[j];
		rec[j]:=rec[i];
		rec[i]:=trec;
		end;
If SLB then
	begin
	setfile(Sfile,s,firstname(fname)+'.SLB','W',excode);
	writeln(Sfile,'S (Slab Input)');
	end;
for i:=1 to sno do
with rec[i] do
	begin
	case ec of
		{1111}			15	 :c:='A';
		{1011,1110}		11,14	 :c:='B';
		{0111,1101}		7,13	 :c:='C';
		{0011,0110,1001,1100}  	3,6,9,12 :c:='D';
		{1010}			10	 :c:='E';
		{0101}			5	 :c:='F';
		{0010,1000}	 	2,8	 :c:='G';
		{0001,0100}	 	1,4	 :c:='H';
		{0000}	 		0	 :c:='I';
		end;
If SLB then writeln(Sfile,'SLAB NO:',strint(i,1),'/',
		edge[1][1]:6:3,',',edge[1][2]:6:3,',',edge[1][3]:6:3,h
	,c,h
	,lx:6:3,h
	,ly:6:3,h
	,w:6:3,h
	,0);
	end;
If SLB then writeln(Sfile,'END');
If SLB then close(Sfile);
SetGraphmode(GetGraphMode);
dispose(faxis);
dispose(fco);
dispose(xdist);
dispose(ydist);
dispose(convity);
dispose(fdir);
Lfix:=fixback;
skelton;
regen;
end;

PROCEDURE genBMD(fname:string);
label 200;
var
	Bfile:text;
	x,y,z:real;
	horv:char;
	insx,insy,insz:real;
	flag:boolean;
	c:char;
	s:string;
begin
pxpy(LimX/2,LimY/2);
Gwrite('Insert point ?  ');
readpoint(insx,insy,insz,0,znp);
setfile(Bfile,s,fname,'R',excode);
if excode=ESC then exit;
s:='';
{$I-}
readln(Bfile,s);
{$I+}
if (ioresult<>0) or (s<>'BMD/SFD') then goto 200;

z:=valRY(MaxY-LimPY);
flag:=TRUE;
while not eof(Bfile) do
	begin
	readln(Bfile,horv);
	if not( horv in ['H','V']) then
				begin
				writeln(#7,#7);
				goto 200;
				end;

	readln(Bfile,x1,y1);
	readln(Bfile,x2,y2);
	if flag then
		begin
		insx:=insx-x1;
		insy:=insy-y1;
		flag:=FALSE;
		end;
	x2:=x2+insx;
	x1:=x1+insx;
	y2:=y2+insy;
	y1:=y1+insy;
	pxpy(x2,y2);
	movetoxy(px,py);
	lineto(adpx(x1),adpy(y1));
	for i:=1 to 11 do
		begin
		readln(Bfile,x,y);
		case horv of
		'H':	lineto(adpx(x1+x),round(adpy(y1)+y));
		'V':	lineto(round(adpx(x1)+y),adpy(y1+x));
		end;
		end;
	lineto(adpx(x2),adpy(y2));
	end;
200:
c:=readkey;
close(Bfile);
end;

PROCEDURE genLD(fname:string); { TO DISPLAY LOAD DIAGRAM }
label 100,200;
var
	Bfile:text;
	x,y,z:real;
	horv:char;
	insx,insy,insz:real;
	flag:boolean;
	c:char;
	s:string;
begin
pxpy(LimX/2,LimY/2);
Gwrite('Insert point ?  ');
readpoint(insx,insy,insz,0,znp);
setfile(Bfile,s,fname,'R',excode);
if excode=ESC then exit;
{$I-}
readln(Bfile,s);
{$I+}
if (ioresult<>0) or (s<>'LOAD') then goto 200;
z:=valRY(MaxY-LimPY);
flag:=TRUE;
100:
while not eof(Bfile) do
	begin
	read(Bfile,horv);
	if not( horv in ['H','V']) then
				begin
				writeln(#7,#7);
				goto 200;
				end;
	readln(Bfile,x1,y1,x2,y2);
	if flag then
		begin
		insx:=insx-x1;
		insy:=insy-y1;
		flag:=FALSE;
		end;
	x2:=x2+insx;
	x1:=x1+insx;
	y2:=y2+insy;
	y1:=y1+insy;
	pxpy(x1,y1);
	setlinestyle(solidln,0,thickwidth);
	lineto(adpx(x2),adpy(y2));
	setlinestyle(solidln,0,normwidth);
	repeat
	read(Bfile,x,y);
	if not eq(x,maxint) and not eq(y,maxint) then
		begin
		case horv of
			'H':	pxpy(x1+x,y1+valRY(y));
			'V':	pxpy(x1+valRX(y),y1+x);
			else
				goto 200;
			end;
		for i:=1 to 3 do
			begin
			read(Bfile,x,y);
			case horv of
				'H':	lineto(adpx(x1+x),adpy(y1+valRY(y)));
				'V':	lineto(adpx(x1+valRX(y)),adpy(y1+x));
				end;
			end;
		end;
		readln(Bfile);
		until eq(x,maxint) and eq(y,maxint);
       end;
200:
c:=readkey;
close(Bfile);
end;
end.


{
choice[1]:=1;
repeat
if choice[1]<>fno+1 then
	begin
	new(menus);
	box(54,3,68,3+fno+2,single);
	ALT:='';
	for j:=1 to fno do
		menus^[j]:=fixlength(' '+fdir^[j],14,LEFT);
	menus^[fno+1]:=' ALL          ';
	repeat
		scode[1]:=#0;
		boxpix(1,menus,55,4,67,4+fno,1,choice[1],scode[1]);
	until (scode[1]=ENTER) or (scode[1]=ESC);
	dispose(menus);
	end;
i:=choice[1];
if scode[1]=ENTER then
}

{
#
Warning :
Depth assessment in X & Y frames has to be the same
Use of temp file needed for the above
Notes:
1.	deadload 2.5KN/m2 added to slab.
}