unit clib;
interface
uses
	graph,glib,crt,lib;
var
	layerno:integer;
	layerdir:array[1..50] of string[12];
        outputf:text;

PROCEDURE multiview;
PROCEDURE globalview(var theta1,theta2,theta3:real);
PROCEDURE call_LINE;
PROCEDURE call_RECT;
PROCEDURE call_CIRC;
PROCEDURE call_ARC;
PROCEDURE call_ELIP;
PROCEDURE call_PLIN;
PROCEDURE call_SETP;
PROCEDURE call_GRID;
PROCEDURE call_SELE;
PROCEDURE call_DELE;
PROCEDURE call_FILL;
PROCEDURE call_SETK;
PROCEDURE call_TEXT;
PROCEDURE call_WSEL;      { #Change to 3D action }
PROCEDURE call_COPY;
PROCEDURE call_MIRR;      { # change to 3D action }
PROCEDURE call_DIST;
PROCEDURE call_LENG;
PROCEDURE call_CHAN;
PROCEDURE call_HIDE;
PROCEDURE call_BLOC;
PROCEDURE call_INSE(pro:integer);
PROCEDURE call_AREA;
PROCEDURE copybase(var temp1,temp2:link);
PROCEDURE call_TRAN(d1,d2,d3,d4,d5,d6:real;   var temp1,temp2:link);
PROCEDURE call_ROTA(theta1,theta2,theta3:real;var temp1,temp2:link);
PROCEDURE call_ROTO(pro:integer);
PROCEDURE call_SCAL(sx,sy,sz:real;var temp1,temp2:link);
PROCEDURE call_SCAO;
PROCEDURE call_ARRA;
PROCEDURE call_LIMI;
PROCEDURE call_APER;
PROCEDURE call_AXIS;
PROCEDURE call_SNAP;
PROCEDURE call_BASE;
PROCEDURE call_ZOOM;
PROCEDURE call_TRIM;
PROCEDURE call_PAN;
PROCEDURE call_LAYE;
PROCEDURE Info(dbase:link);
PROCEDURE call_LIST;
PROCEDURE call_DRAW;
implementation

PROCEDURE globalview(var theta1,theta2,theta3:real);
var
	R:word;
	cx,cy,x,y:real;
	p1,p2,p3:real;
	angle:record
		t1,t2,t3:real;
		end;
begin
{
R:=(LimPX+LimPY) div 8;
R:=180;
}
R:=round(pixRX(LimX/4));
cx:=pixX(LimX/2);
cy:=pixY(LimY/2);
clear;
circle(round(cx),round(cy),R);
circle(round(cx),round(cy),R div 2);
line(round(cx),round(cy-R*(maxY/479)),round(cx),round(cy+R*(maxY/479)));
line(round(cx)-R,round(cy),round(cx)+R,round(cy));
mp(1);
movetoxy(px,py);
{
cx:=valX(cx);
cy:=valY(cy);
pxpy(cx,cy);
}
cx:=valx(cx);
cy:=valy(cy);
move_around(p1,p2,p3,0);
x:=p1;
y:=p2;
{
theta2:=((x-cx)/6*180);
theta3:=((y-cy)/6*180);
theta3:=arctan(sqrt(sqr(x-cx)+sqr(y-cy))/sqrt(36-(sqr(x-cx)+sqr(y-cy))));
}
theta3:=sqrt(sqr(x-cx)+sqr(y-cy))/6*pi;
if (y=cy) and (x<>cx)
	then
		theta1:=pi/2
	else
		if x=cx then
			begin
			if y>cy then theta1:=pi
			else theta1:=0;
			end
	else
		theta1:=arctan((x-cx)/(y-cy));
theta2:=0;
theta1:=theta1/pi*180;
if (y-cy>0) and (x-cx>0)
	then
		theta1:=180-theta1
	else
if (y-cy>0) and (x-cx<0)
	then
		theta1:=180-theta1
{
if (y-cy<0) and (x-cx<0)
	then
		theta1:=-theta1
}
	else
		theta1:=-theta1;
{
if (y-cy>0) and (x-cx>0) then
if (y-cy>0) and (x-cx>0) then theta1:=pi-theta1;
	or
   (y-cy>0) and (x-cx<0)
	then
		theta1:= -theta1/pi*180
	else
		theta1:=  theta1;
}
if theta3>pi/2
	then
		theta3:=theta3;
theta2:= theta2/pi*180;
theta3:= theta3/pi*180;

angle.t1:= theta1;
angle.t2:= theta2;
angle.t3:= theta3;
if nopage then clear;
end;

PROCEDURE call_LINE;
begin
with dbase^ do
begin
	ID:='L';
	Gwrite('From point ? ');
	readpoint(d[1],d[2],d[3],1,znp);
	Gwrite('To point ? ');
	readpoint(d[4],d[5],d[6],2,znp);
drawline(dbase);
end;
end;

PROCEDURE call_RECT;
begin
with dbase^ do
begin
	ID:='R';
	Gwrite('From point ? ');
	readpoint(d[1],d[2],d[3],1,znp);
	Gwrite('To point ? ');
	readpoint(d[4],d[5],d[6],2,znp);

	mp(0);
	Rectangle(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),adpx(dbase2scr(dbase,4)),adpy(dbase2scr(dbase,5)));
	mp(1);
	pxpy(d[4],d[5]);
end;
end;

PROCEDURE call_CIRC;
begin
with dbase^ do
begin
	ID:='C';
	Gwrite('Centre point ? ');
	readpoint(d[1],d[2],d[3],1,znp);
	pxpy(d[1],d[2]);
	Gwrite('Radius ? ');
	Greadreal(d[4]);
	mp(0);
	Circle(adpx(dbase2scr(dbase,1)), adpy(dbase2scr(dbase,2)), round(pix(d[4])));
	mp(1);
end;
end;

PROCEDURE call_ARC;
begin
with dbase^ do
begin
	ID:='A';
	Gwrite('Centre point ? ');
	readpoint(d[1],d[2],d[3],1,znp);
	pxpy(d[1],d[2]);
	Gwrite('Start angle ? ');
	Greadreal(d[3]);
	Gwrite('End angle ?   ');
	Greadreal(d[4]);
	Gwrite('Radius  ?     ');
	Greadreal(d[5]);
	Arc(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),round(d[3]),round(d[4]),adpx(d[5]));
end;
end;

PROCEDURE call_ELIP;
begin
with dbase^ do
begin
	ID:='E';
	Gwrite('Centre point ? ');
	readpoint(d[1],d[2],d[3],1,znp);

	Gwrite('Start angle ? ');
	Greadreal(d[3]);
	Gwrite('End angle ?  ');
	Greadreal(d[4]);
	Gwrite('Radius XR ?  ');
	Greadreal(d[5]);
	Gwrite('Radius YR ?  ');
	Greadreal(d[6]);
	mp(0);
	Ellipse(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),round(d[3]),round(d[4]),
				round(pixRX(d[5])),round(pixRY(d[6])));
	mp(1);
	pxpy(d[1],d[2]);
end;
end;

PROCEDURE call_PLIN;
var
	dd:ar6;
begin
if newcom then
	begin
	with dbase^ do
	begin
	ID:='L';
	Gwrite('From point ? ');
	readpoint(d[1],d[2],d[3],1,znp);
	end;
newcom:=FALSE;
repeat
Gwrite('To point ? ');
with dbase^ do
	begin
	readpoint(d[4],d[5],d[6],2,znp);
	dd[1]:=d[4];
	dd[2]:=d[5];
	dd[3]:=d[6];
	end;
if aborted then
	begin
	newcom:=TRUE;
	dele(dbase,first,sbase);
	end
  else
	begin
	drawline(dbase);
	newbase(dbase,first,sbase);
	with dbase^ do
		begin
		ID:='L';
		d[1]:=dd[1];
		d[2]:=dd[2];
		d[3]:=dd[3];
		end;
	end;
until aborted;
end;
end;

PROCEDURE call_SETP;
var rx,ry,rz:real;
begin
rx:=px;
ry:=py;
	Gwrite('Point ID ? ');
	readpoint(rx,ry,rz,0,znp);
	if not aborted then
		begin
			pxpy(rx,ry);
			movetoxy(px,py);
		end
		else
			aborted:=FALSE;
end;

PROCEDURE call_GRID;
var
	xs,ys:real;
	x,y:integer;
begin
xs:=0;
ys:=0;
    Gwrite('Spacing X-dir ? ');
    Greadreal(xs);
    Gwrite('Spacing Y-dir ? ');
    Greadreal(ys);
    if (xs<=0) or (ys<=0) then exit;
    mp(0);
	for x:=1 to trunc(LimX/xs) do
	for y:=1 to trunc(LimY/ys) do
		circle(adpx(x*xs),adpy(y*ys),1);
    mp(1);
end;

PROCEDURE call_TRAN(d1,d2,d3,d4,d5,d6:real;var temp1,temp2:link);
var
	dd:ar6;
begin
with temp1^ do
	begin
	temp2^.d0:=d0;
	temp2^.ID:=ID;
	temp2^.d[1]:=temp1^.d[1]+(d4-d1);
	temp2^.d[2]:=temp1^.d[2]+(d5-d2);
	temp2^.d[3]:=temp1^.d[3]+(d6-d3);
	temp2^.d[4]:=temp1^.d[4]+(d4-d1);
	temp2^.d[5]:=temp1^.d[5]+(d5-d2);
	temp2^.d[6]:=temp1^.d[6]+(d6-d3);
	end;
end;

PROCEDURE call_SELE;
var pic:link;
begin
repeat
	select(pic,user_choice);
	if got then
	begin
		if (pic^.d0=ord('S'))
			then
				pic^.d0:=ord('E')
			else
				pic^.d0:=ord('S');
		mp(0);
		drawusing(pic);
		mp(1);
		end;
	movetoxy(px,py);
until not got;
end;

PROCEDURE call_DELE;
var pic:link;
begin
	pic:=first^.a;
	i:=0;
	while pic<>NIL do
		begin
		i:=i+1;
		if pic^.d0=ord('S') then
			dele(pic,first,sbase);
		pic:=pic^.a;
		end;
{del:=FALSE;}
	redraw;
end;

PROCEDURE call_FILL;
var
	pattern:integer;
	rx,ry,rz:real;

begin
	gwrite('FillType ? ');
	greadint(pattern);
	setfillstyle(pattern,white);
	Gwrite('Inside Point ? ');
	readpoint(rx,ry,rz,0,znp);
	pxpy(rx,ry);
	mp(0);
	floodfill(adx(px),ady(py),white);
	mp(1);
end;

PROCEDURE call_SETK;
begin
(*	if not direct
		then
		begin
		Gwrite('To get COMMAND prompt press ESC.');
		delay(500);
		direct:=TRUE;
		disp(#32);      { initialize disp }
		end
		else
			direct:=FALSE;
*)
end;
{FUSE       14:   ;}
PROCEDURE call_TEXT;
var
	sx:real;
begin
	sx:=px;
	repeat
		Gwrite('TEXT : ');
		Gread(s);
		movetoxy(px,py);
		mp(0);
		settextjustify(Lefttext,bottomtext);
		settextstyle(defaultfont,horizdir,1);
		outtext(s);
		mp(1);
		px:=sx;
		py:=gety+th;
		settextjustify(Lefttext,toptext);
	until length(s)=0;
	py:=gety-th;
end;

PROCEDURE call_WSEL;    { #Change to 3D action }
var
	dx1,dy1,dx2,dy2:real;
	dd:ar6;
	pic:link;
begin
newbase(dbase,first,sbase);
with dbase^ do
	begin
		d0:=0;
		ID:='R';
		Gwrite('First point ? ');
		readpoint(d[1],d[2],d[3],1,znp);
		Gwrite('Second point ? ');
		readpoint(d[4],d[5],d[6],2,znp);
	end;
dd[1]:=dbase2scr(dbase,1);
dd[2]:=dbase2scr(dbase,2);
dd[4]:=dbase2scr(dbase,4);
dd[5]:=dbase2scr(dbase,5);
dele(dbase,first,sbase);

pic:=first^.a;
while pic<>NIL do
begin
dx1:=dbase2scr(pic,1);
dy1:=dbase2scr(pic,2);
dx2:=dbase2scr(pic,4);
dy2:=dbase2scr(pic,5);
     if   ((comm='WSELECT') and (pic^.d0<>ord('S'))) or
	  ((comm='WNORMAL') and (pic^.d0=ord('S')))
	 then
     with pic^ do
	case ID of
		'L','R':
			begin
if  ((dd[1]<=dx1) and (dx2<=dd[4])) or ((dd[1]>=dx1) and (dx2>=dd[4]))  then
if  ((dd[2]>=dy1) and (dy2>=dd[5])) or ((dd[2]<=dy1) and (dy2<=dd[5]))  then
{
if  (dd[7]=d[3]) and (d[6]=x6)  then
# LAYER only
}
				begin
				if   (comm='WSELECT')
					then
						d0:=ord('S')
					else
						d0:=ord('E');
				end;
			end;
		'C':    begin		{ # change needed }
if ((dd[1]<=dx1-d[3]) and (dx1+d[3]<=dd[4])) or
			((dd[1]>dx1-d[3]) and (dx1+d[3]>dd[4]))  then
if ((dd[2]>=dy1-d[3]) and (dd[5]<=dy1+d[3])) or
			((dd[2]<dy1-d[3]) and (dd[5]>dy1+d[3])) then
				begin
				if   (comm='WSELECT')
					then
						d0:=ord('S')
					else
						d0:=ord('E');
				end;
			end;
		end;
if (comm='WSELECT') and (pic^.d0=ord('S')) or
   (comm='WNORMAL') and (pic^.d0=ord('E'))
   then
		begin
			mp(0);
			drawusing(pic);
			mp(1);
		end;
	pic:=pic^.a;
	end;
end;

PROCEDURE call_COPY;
var
	dd:ar6;
	pic:link;
begin
	Gwrite('Base Point ? ');
	readpoint(dd[1],dd[2],dd[3],0,znp);
	Gwrite('Target point ? ');
	readpoint(dd[4],dd[5],dd[6],0,znp);
	pic:=first^.a;
	while pic<>NIL do
	begin
	with pic^ do
	if d0=ord('S') then
		begin
		newbase(dbase,first,sbase);
		case ID of
		'L','R':
			begin
		call_TRAN(dd[1],dd[2],dd[3],dd[4],dd[5],dd[6],pic,dbase);
			dbase^.d0:=0;
			dbase^.ID:=pic^.ID;
			end;
		'C':
			begin
			dbase^.ID:=pic^.ID;
		for i:=1 to 3 do dbase^.d[i]:=pic^.d[i]+(dd[i+3]-dd[i]);
			end;
			else halt;
		end ;
		if comm='MOVE' then
			dele(pic,first,sbase);
		end;
	pic:=pic^.a;
	end;
redraw;
end;

PROCEDURE call_MIRR;      { # change to 3D action }
var
	m,ax,ay:real;
	dd:ar6;
	pic:link;
begin
	Gwrite('First Point ? ');
	readpoint(dd[1],dd[2],dd[3],0,znp);
	Gwrite('Second Point ? ');
	readpoint(dd[4],dd[5],dd[6],0,znp);
	pic:=first^.a;
	while pic<>NIL do
	begin
		with pic^ do
		if pic^.d0=ord('S') then
			begin
			newbase(dbase,first,sbase);
			dbase^.ID:=pic^.ID;
			if ((dd[4]-dd[1])<>0) and ((dd[5]-dd[2])<>0) then
			begin
			m:=(dd[5]-dd[2])/(dd[4]-dd[1]);
			ax:=(m*dd[1]+d[1]/m+d[2]-dd[2])/(m+1/m);
			ay:=dd[2]-m*(dd[1]-ax);
			end
			else
				if (dd[4]-dd[1])=0 then
				  begin
				  ax:=dd[1];
				  ay:=d[2];
				  end
			else
				if (dd[5]-dd[2])=0 then
				  begin
				  ax:=d[1];
				  ay:=dd[2];
				  end;
					dbase^.d[1]:=d[1]+2*(ax-d[1]);
					dbase^.d[2]:=d[2]+2*(ay-d[2]);
					dbase^.d[3]:=d[3];
        				if ((dd[4]-dd[1])<>0) and ((dd[5]-dd[2])<>0) then
			begin
			ax:=(m*dd[1]+d[4]/m+d[5]-dd[2])/(m+1/m);
			ay:=dd[2]-m*(dd[1]-ax);
			end
			else
				if (dd[4]-dd[1])=0 then
				  begin
				  ax:=dd[1];
				  ay:=d[5];
				  end
			else
				if (dd[5]-dd[2])=0 then
				  begin
				  ax:=d[4];
				  ay:=dd[2];
				  end;
			dbase^.d[4]:=d[4]+2*(ax-d[4]);
			dbase^.d[5]:=d[5]+2*(ay-d[5]);
			dbase^.d[6]:=d[6];
			mp(0);
			drawusing(dbase);
			mp(1);
			end;
		pic:=pic^.a;
		end;
end;

PROCEDURE call_DIST;
var
	measure:real;
	dd:ar6;

begin
	Gwrite('From point ? ');
	readpoint(dd[1],dd[2],dd[3],0,znp);
	Gwrite('To point ? ');
	readpoint(dd[4],dd[5],dd[6],0,znp);
	measure:=sqrt(sqr(dd[1]-dd[4])+sqr(dd[2]-dd[5])+sqr(dd[6]-dd[3]));
	str(measure:10:4,s);
	result('Distance = '+s);
end;

PROCEDURE call_LENG;
var	measure:real;
begin
	figlength(measure);
	str(measure:10:4,s);
	result('Length   = '+s);
end;
PROCEDURE call_CHAN;
var
	pic:link;
begin
	Gwrite('Property  ?  ');
	gread(s);
	pic^.d0:=ord(s[1]);
	mp(0);
	drawusing(pic);
	mp(1);
end;

PROCEDURE call_HIDE;
var pic:link;
begin
{
select(pic,user_choice);
pic^.d0:=0;
}
end;

PROCEDURE call_BLOC;
var
	blockname:string;
	blockfile:file of dat;
	dd:ar6;
	data:dat;
	pic:link;
begin
Gwrite('Name of block ? ');
Gread(blockname);
Gwrite('Base Point ? ');
dd[1]:=0;
dd[2]:=0;
dd[3]:=0;
readpoint(dd[1],dd[2],dd[3],0,znp);
	assign(blockfile,blockname);
	rewrite(blockfile);
	pic:=first^.a;
	while pic<>NIL do
		begin
		with pic^ do
		if d0=ord('S') then
			begin
			data.d0:=d0;
			data.ID:=ID;
			data.ix[1]:=pic^.d[1]-dd[1];
			data.ix[2]:=pic^.d[2]-dd[2];
			data.ix[3]:=pic^.d[3]-dd[3];
			data.ix[4]:=pic^.d[4]-dd[1];
			data.ix[5]:=pic^.d[5]-dd[2];
			data.ix[6]:=pic^.d[6]-dd[3];
			write(blockfile,data);
			end;
	pic:=pic^.a;
		end;
		close(blockfile);
end;

PROCEDURE call_INSE(pro:integer);
var
	blockname:string;
	blockfile:file of dat;
	dd:ar6;
	data:dat;
	pic:link;
begin
if pro=0 then
		begin
		Gwrite('Name of block ? ');
		Gread(blockname);
		Gwrite('Insert Point ? ');
		readpoint(dd[1],dd[2],dd[3],0,znp);
		end
	else
		begin                  { *** }
		blockname:=proname;
		dd[1]:=3;
		dd[2]:=3;
		dd[3]:=0;
		end;                   { **** }
if not exist(blockname) then exit;
if (blockname<>'')
	then
		begin
		assign(blockfile,blockname);
		reset(blockfile);
		fbase:=start^.a;
		while fbase<>NIL do
			begin
			dele(fbase,start,last);
			fbase:=fbase^.a;
			end;
		while not eof(blockfile) do
			begin
			read(blockfile,data);
			newbase(fbase,start,last);
			fbase^.d0:=data.d0;
			fbase^.ID:=data.ID;
			for i:=1 to 6 do
				fbase^.d[i]:=data.ix[i];
			end;
		close(blockfile);
		end;
		{ IF ALREADY LOADED }
		fbase:=start^.a;
		while fbase<>NIL do
			begin
			newbase(dbase,first,sbase);
		call_TRAN(0,0,0,dd[1],dd[2],dd[3],fbase,dbase);
			dbase^.ID:=fbase^.ID;
			dbase^.d0:=fbase^.d0;
			fbase:=fbase^.a;
			end;
		setport(vpout);
		redraw;
end;

PROCEDURE call_AREA;
var
	area:real;
	dd:array[1..9] of real;
begin
	Gwrite('First Point ? ');
	readpoint(dd[4],dd[5],dd[6],0,znp);
	Gwrite('Next Point ? ');
	readpoint(dd[7],dd[8],dd[9],0,znp);
	area:=0;
	repeat
	dd[1]:=dd[4];
	dd[2]:=dd[5];
	dd[4]:=dd[7];
	dd[5]:=dd[8];
	Gwrite('Next Point ? ');
	readpoint(dd[7],dd[8],dd[9],0,znp);
	mp(0);
	line(adpx(dd[1]),adpy(dd[2]),adpx(dd[4]),adpy(dd[5]));
	line(adpx(dd[4]),adpy(dd[5]),adpx(dd[7]),adpy(dd[8]));
	line(adpx(dd[1]),adpy(dd[2]),adpx(dd[7]),adpy(dd[8]));

	floodfill(adpx((dd[1]+dd[4]+dd[7])/3),adpy((dd[2]+dd[5]+dd[8])/3),1);
	mp(1);
	area:=area+abs((dd[8]-dd[5])*dd[1]+(dd[2]-dd[8])*dd[4]+(dd[5]-dd[2])*dd[7])/2.0;
	str(area:10:4,s);
	result('Area = '+s);
	until (dd[4]=dd[7]) and (dd[5]=dd[8]);
end;

PROCEDURE copybase(var temp1,temp2:link);
begin
with temp1^ do
	begin
	temp2^.d0:=d0;
	temp2^.ID:=ID;
	for i:=1 to 6 do temp2^.d[i]:=temp1^.d[i];
	end;
end;

PROCEDURE call_ROTA(theta1,theta2,theta3:real;var temp1,temp2:link);
var
	x1,y1,z1,x2,y2,z2:real;
	ax1,ay1,az1,ax2,ay2,az2:real;
begin
theta1:=theta1*pi/180;
theta2:=theta2*pi/180;
theta3:=theta3*pi/180;
with temp1^ do
	begin

	x1:=d[1];
	y1:=d[2];
	z1:=d[3];
	x2:=d[4];
	y2:=d[5];
	z2:=d[6];

{ Rotate about Z axis - XY Plane }
		ax1:= x1*cos(theta1)+y1*sin(theta1);
		ay1:=-x1*sin(theta1)+y1*cos(theta1);
		ax2:= x2*cos(theta1)+y2*sin(theta1);
		ay2:=-x2*sin(theta1)+y2*cos(theta1);
		x1:=ax1;
		y1:=ay1;
		x2:=ax2;
		y2:=ay2;

{ Rotate about Y axis - XZ Plane }

		ax1:= x1*cos(theta2)-z1*sin(theta2);
		az1:= x1*sin(theta2)+z1*cos(theta2);
		ax2:= x2*cos(theta2)-z2*sin(theta2);
		az2:= x2*sin(theta2)+z2*cos(theta2);

		x1:=ax1;
		z1:=az1;
		x2:=ax2;
		z2:=az2;

{ Rotate about X axis - YZ Plane }

		ay1:= y1*cos(theta3)+z1*sin(theta3);
		az1:=-y1*sin(theta3)+z1*cos(theta3);
		ay2:= y2*cos(theta3)+z2*sin(theta3);
		az2:=-y2*sin(theta3)+z2*cos(theta3);

		z1:=az1;
		y1:=ay1;
		z2:=az2;
		y2:=ay2;

		temp2^.d0:=d0;
		temp2^.ID:=ID;
		temp2^.d[1]:=x1;
		temp2^.d[2]:=y1;
		temp2^.d[3]:=z1;
		temp2^.d[4]:=x2;
		temp2^.d[5]:=y2;
		temp2^.d[6]:=z2;
	end;
end;

PROCEDURE call_ROTO(pro:integer);
label 100;
var
	rx,ry,rz:real;
	theta1,theta2,theta3:real;
	temp1,temp2:link;
	pic:link;
	ic:integer;
	c:char;
begin
new(temp1);
new(temp2);
100:
fillchar(temp1^.d,sizeof(temp1^.d),0);
fillchar(temp2^.d,sizeof(temp2^.d),0);
if comm='ROTATE' then
	begin
		Gwrite('Base point ? ');
		readpoint(rx,ry,rz,0,znp);
		Gwrite('Angle  Z ?  ');
		Greadreal(theta1);
		Gwrite('Angle  Y ?  ');
		Greadreal(theta2);
		Gwrite('Angle  X ?  ');
		Greadreal(theta3);
	end
else
	begin
		rx:=first^.d[1];
		ry:=first^.d[2];
		rz:=first^.d[3];

{
		if pro<>0 then
			begin
			rx:=8;
			ry:=8;
			rz:=5.5;
			end;


}
		globalview(theta1,theta2,theta3);
	end;
pic:=first^.a;
while pic<>NIL do
	begin
	if pic^.d0=ord('S') then
		begin
		call_TRAN(rx,ry,rz,0,0,0,pic,temp1);
		call_ROTA(theta1,theta2,theta3,temp1,temp2);
		call_TRAN(0,0,0,rx,ry,rz,temp2,temp1);
	if comm='ROTATE' then
		begin
			newbase(dbase,first,sbase);
			copybase(temp1,dbase);
			dbase^.d0:=0;
			dbase^.ID:=pic^.ID;
		end
		else
		begin
			temp1^.d0:=0;
			temp1^.ID:=pic^.ID;
			drawusing(temp1);
		end;
		end;
	pic:=pic^.a;
	end;
if comm='ROTATE' then
			redraw;
if pro<>0 then
	begin
		c:=readkey;
		if c=#0 then c:=readkey;
		if c<>ESC then goto 100;
	end;
dispose(temp1);
dispose(temp2);
end;

PROCEDURE call_SCAL(sx,sy,sz:real;var temp1,temp2:link);
begin
with temp1^ do
	begin
	temp2^.d0:=d0;
	temp2^.ID:=ID;
	xy3d(temp2,d[1]*sx,d[2]*sy,0,1,TRUE);
	xy3d(temp2,d[4]*sx,d[5]*sy,0,2,TRUE);

end;
end;

PROCEDURE call_SCAO;
var
	sx,sy,sz:real;
	rx,ry,rz:real;
	pic,temp1,temp2:link;
begin
{
if pic=first then
begin
}
Gwrite('Scale X  ? ');
Greadreal(sx);
Gwrite('Scale Y  ? ');
Greadreal(sy);
Gwrite('Scale Z  ? ');
Greadreal(sz);
Gwrite('Base Point ? ');
readpoint(rx,ry,rz,0,znp);
pic:=first^.a;
while pic<>NIL do
	begin
	if pic^.d0=ord('S') then
		begin
		new(temp1);
		new(temp2);

		call_TRAN(rx,ry,rz,0,0,0,pic,temp1);
		call_SCAL(sx,sy,sz,temp1,temp2);
		call_TRAN(0,0,0,rx,ry,rz,temp2,temp1);

		newbase(dbase,first,sbase);
		copybase(temp1,dbase);
		dbase^.ID:=pic^.ID;
		mp(0);
		drawusing(dbase);
		mp(1);
		dispose(temp1);
		dispose(temp2);
		end;
	pic:=pic^.a;
	end;
end;

PROCEDURE call_ARRA;
var
	xd,yd,zd:real;
	x,y,z:integer;
	i,j,k:integer;
	pic,temp1,temp2:link;
begin
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
end;


PROCEDURE call_LIMI;
var x,y:real;
begin
x:=valX(px) ;
y:=valY(py);
Gwrite('Limit X ? ');
Greadreal(LimX);        if LimX<=0 then LimX:=24;
Gwrite('Limit Y ? ');
Greadreal(LimY);        if LimY<=0 then LimX:=16;
pxpy(x,y);
redraw;
end;

PROCEDURE call_APER;
var x:integer;
begin
x:=0;
Gwrite('Size ? ');
Greadint(x);
if (x>1) and (x<11) then
	begin
	bsd2:=x div 2;
	changepicker(square);
	end;
end;

PROCEDURE call_AXIS;
var
	xs,ys:real;
begin
xs:=0;
ys:=0;
Gwrite('X-spacing ? ');
Greadreal(xs);
Gwrite('Y-spacing ? ');
Greadreal(ys);
if (xs<=0) or (ys<=0) then exit;
i:=0;
repeat
i:=i+1;
moveto(adpx(i*xs),LimPY);
Lineto(adpx(i*xs),LimPY-6);
until (adpx(i*xs)>LimPX) or (i=1024);

i:=0;
repeat
i:=i+1;
moveto(1,adpy(i*ys));
Lineto(6,adpy(i*ys));
until (adpy(i*ys)<=0) or (i=1024);

movetoxy(px,py);
end;

PROCEDURE call_SNAP;
begin
Gwrite('Snap spacing ? ');
Greadreal(incr);
end;

PROCEDURE call_BASE;
begin
	Gwrite('Base Point  ?  ');
	with first^ do readpoint(d[1],d[2],d[3],1,znp);
end;

{
PROCEDURE call_DIVI;
begin
end;
PROCEDURE call_DRAG;
begin
end;
}
PROCEDURE call_ZOOM;
var
	sx,sy:real;
	pic,temp1,temp2:link;
        dd:ar6;

begin
Gwrite('First point ? ');
readpoint(dd[1],dd[2],dd[3],0,znp);
Gwrite('Second point ? ');
readpoint(dd[4],dd[5],dd[6],0,znp);

{WSEL}
pic:=first^.a;
     while pic<>NIL do begin
     with pic^ do
	case ID of
		'L','R':
			begin
			if (dd[1]<d[1]) and (d[4]<dd[4])
			  and  (dd[2]>d[2]) and (d[5]>dd[5]) then
				begin
				d0:=ord('S');
				end;
			end;
		'C':    begin
			if (dd[1]<d[1]-d[3]) and (d[1]+d[3]<dd[4])
			  and  (dd[2]>d[2]-d[3]) and (dd[5]<d[2]+d[3]) then
				begin
				d0:=ord('S');
				end;
			end;
		end;
	if pic^.d0=ord('S') then
		begin
		mp(0);
		drawusing(pic);
		mp(1);
		end;
	pic:=pic^.a;
	end;
{WSEL END}
clear;
pic:=first^.a;
while pic<>NIL do
	begin
        if pic^.d0=ord('S') then
		begin
		new(temp1);
		new(temp2);
		call_TRAN(dd[1],dd[2],0,0,0,0,pic,temp1);

		call_SCAL(LimPX/adpx(abs(dd[4]-dd[1])),LimPY/adpy(abs(dd[5]-dd[2])),0,temp1,temp2);

		mp(0);
		drawusing(temp2);
		mp(1);
		dispose(temp1);
		dispose(temp2);
	end;
	pic:=pic^.a;
end;
end;

PROCEDURE call_TRIM;
var
	x,y:real;
	m1,m2,k:real;
	zx1,zx2:real;
	t1,t2,t4,t5:real;
	dd:array[1..9] of real;
	pic:link;
begin
Gwrite('From point ? ');
readpoint(dd[1],dd[2],dd[3],0,znp);
dd[7]:=xyz2xy(dd[1],dd[2],dd[3],1);
dd[8]:=xyz2xy(dd[1],dd[2],dd[3],2);
dd[1]:=dd[7];
dd[2]:=dd[8];
Gwrite('To point ? ');
readpoint(dd[4],dd[5],dd[6],0,znp);
dd[7]:=xyz2xy(dd[4],dd[5],dd[6],1);
dd[8]:=xyz2xy(dd[4],dd[5],dd[6],2);
dd[4]:=dd[7];
dd[5]:=dd[8];
Gwrite('Side To Cut ? ');
readpoint(dd[7],dd[8],dd[9],0,znp);
dd[3]:=xyz2xy(dd[7],dd[8],dd[9],1);
dd[6]:=xyz2xy(dd[7],dd[8],dd[9],2);
dd[7]:=dd[3];
dd[8]:=dd[6];

pic:=first^.a;
	while pic<>NIL do
	begin
		with pic^ do
		if d0=ord('S') then
			begin
			t1:=xyz2xy(d[1],d[2],d[3],1);
			t2:=xyz2xy(d[1],d[2],d[3],2);
			t4:=xyz2xy(d[4],d[5],d[6],1);
			t5:=xyz2xy(d[4],d[5],d[6],2);
		m1:=(dd[5]-dd[2])/(dd[4]-dd[1]);
		m2:=(t5-t2)/(t4-t1);
		x:=(m2*(t4-t5)-(m1*dd[1]-dd[2]))/(m2-m1);
		y:=m1*x+m1*dd[1]-dd[2];
			zx1:=dd[1]-(dd[2]-dd[8])/m1;
			zx2:=dd[1]-(dd[2]-t5)/m1;
			k:=(x-t1)/(t4-x);
			if (zx1>x) and (zx2>x) then
					begin
						d[4]:=d[1]+(d[4]-d[1])*k;
						d[5]:=d[2]+(d[5]-d[2])*k;
						d[6]:=d[3]+(d[6]-d[3])*k;
					end
				else
					begin
						d[1]:=d[1]+(d[4]-d[1])*k;
						d[2]:=d[2]+(d[5]-d[2])*k;
						d[3]:=d[3]+(d[6]-d[3])*k;
					end;
			mp(0);
			drawusing(pic);
			mp(1);
			end;
		pic:=pic^.a;
		end;
end;

PROCEDURE call_PAN;
var
	pic,temp1,temp2:link;
        dd:ar6;

begin
Gwrite('From point ? ');
readpoint(dd[1],dd[2],dd[3],0,znp);
Gwrite('To point ? ');
readpoint(dd[4],dd[5],dd[6],0,znp);
clear;
pic:=first^.a;
while pic<>NIL do
	begin
		new(temp1);
		call_TRAN(dd[1],dd[2],dd[3],dd[4],dd[5],dd[6],pic,temp1);
		mp(0);
		drawusing(temp1);
		mp(1);
		dispose(temp1);
	pic:=pic^.a;
	end;
end;

PROCEDURE call_LAYE;
var
	resp:string[5];
	s3:string;
	newL:boolean;
begin
Gwrite('FIX LAYER (X,Y,Z) ? ');
Gread(resp);
resp[1]:=upcase(resp[1]);
case upcase(resp[1]) of
	'X':resp:='X';
	'Y':resp:='Y';
	'Z':resp:='Z';
	else resp:='Z';
	end;
gwrite(resp[1]+' co-ordinate of layer ? ');
Greadreal(pfix);
for i:=1 to layerno do
	if Layerdir[i]=resp+strreal(pfix,5,3) then newL:=TRUE;
if newL then
	begin
		inc(layerNo);
		layerdir[layerNo]:=resp+strreal(pfix,5,3);
		layerdir[layerno+1]:='END';
	end;
LFIX:=abs(ord('X')-ord(resp[1]))+1;
if comm='SLAYER' then
			redraw
		else
			LAYERregen;
end;

PROCEDURE Info(dbase:link);
begin
with dbase^ do
begin
writeln(outputf,ID,'  ',d0,'  ',d[1]:8:3,d[2]:8:3,d[3]:8:3,d[4]:8:3,d[5]:8:3,d[6]:8:3);
end;
end;

PROCEDURE call_LIST;
var
	i,numdat:integer;
	fixstr:string;
	err:integer;
	Lfix:integer;
	pfix:real;
begin
{multiview;
exit;
}
assign(outputf,'SOMA.SAP');
rewrite(outputf);
RestoreCrtMode;
i:=1;
while layerdir[i]<>'END' do
	begin
	writeln(layerdir[i]);
	Lfix:=ord('X')-ord(layerdir[i][1])+1;
	fixstr:=copy(layerdir[i],2,length(layerdir[i]));
	val(fixstr,pfix,err);
begin
numdat:=0;
dbase:=first^.a;
while dbase<>NIL do
begin
if dbase^.ID in ['L','R'] then   { # include C,A etc. }
{if eq(dbase^.d[Lfix],pfix) and eq(dbase^.d[Lfix+3],pfix) then}
					Info(dbase);
dbase:=dbase^.a;
numdat:=numdat+1;
end;
	i:=i+1;
	end;

writeln('Total number of elements = ',numdat);
readln;
close(outputf);
end;
SetGraphMode(GetGraphMode);
skelton;
regen;
end;

PROCEDURE call_DRAW;
var
	pincr:real;
	p1,p2,p3:real;
begin
repeat
mp(2);
c:=readkey;
disp(c);
c:=upcase(c);
if c in ['M','E','N','P']
	then
		men(c,p1,p2,p3);
SetIncr_IfNum(c);
if ord(c)=0 then
	c:=readkey;
if c in [ENTER,SPACE]   then
		begin
		if drawhard
			then
				drawhard:=FALSE
			else
				drawhard:=TRUE;
		end;
if drawhard and (c in [left,right,up,down]) then
	begin
		newbase(dbase,first,sbase);
		xy3d(dbase,valX(px),valY(py),0,1,TRUE);
	end;
mp(0);
case c of
	up      :
		begin
		if drawhard
			then
				begin
				py:=py-pixRY(incr);
				Lineto(adx(px),ady(py));
				end;
		end;
	down 	:
		begin
		if drawhard
			then
				begin
				py:=py+pixRY(incr);
				LineTo(adx(px),ady(py));
				end;
		end;
	left    :
		begin
		if drawhard
			then
				begin
				px:=px-pixRX(incr);
				LineTo(adx(px),ady(py));
				end;
		end;
	right   :
		begin
		if drawhard
			then
				begin
				px:=px+pixRX(incr);
				LineTo(adx(px),ady(py));
				end;
		end;
	ESC   :
		begin
		newcom:=TRUE;
		end;
	 end;
if not drawhard
	then
		movepxpy(c)
	else
if (c in [left,right,up,down]) then
		xy3d(dbase,valX(px),valy(py),0,2,TRUE);
wco_ord;
mp(1);
until c=ESC;
drawhard:=FALSE;
newcom:=TRUE;
exit;
end;

procedure multiview;
var
	lx,ly,hx,hy:integer;
	t1,t2,t3:real;
begin

lx:=LowX;
ly:=LowY;
hx:=LimPX;
hy:=LimPY;
cvp;

fullport;
LowX:=lx;
LowY:=ly;
LimPX:=hx div 2;
LimPY:=hy div 2;
call_ROTO(0);
regen;


fullport;
LowX:=lx;
LowY:=hy div 2;
LimPX:=hx div 2;
LimPY:=hy;
call_ROTO(0);
regen;

fullport;
LowX:=hx div 2;
LowY:=ly;
LimPX:=hx;
LimPY:=hy div 2;
call_ROTO(0);
regen;

fullport;
LowX:=hx div 2;
LowY:=hy div 2;
LimPX:=hx;
LimPY:=hy;
call_ROTO(0);
regen;


LowX:=lx;
LowY:=ly;
LimPX:=hx;
LimPY:=hy;
end;

end.