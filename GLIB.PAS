		       { GENERAL LIBRARY FUNCTINS }
unit Glib;
interface
uses
    lib,Graph,crt,mouse;
var
 size:word;
 c:char;
 s:string;
 i:integer;
 pon:integer;
 th,tw:integer;
 j1,j2:real;
 xasp,yasp:word;

 Xm,Ym:integer;
 M_Status,No_of_Buttons:integer;
const
        mouseread:boolean=FALSE;
	dragmode:boolean=TRUE;
	cLfix:string[3]='XYZ';
	pageno:byte=0;
	pfix:real=0.0;
	Lfix:byte=3;
	lastM_no=5;
	cross=1;
	square=2;
	prechoice:array [1..LastM_no] of integer=(1,1,1,1,1);
	MaxX:integer=719;
	MaxY:integer=347;
	LimX:real=24.0;
	LimY:real=16.0;
	user_choice:boolean=TRUE;
	urgent:boolean=FALSE;
	got:boolean=FALSE;
	bsize:integer=5;
	drawhard:boolean=FALSE;
	pstat:integer=1;
	LowX:integer=1;
	LowY:integer=1;
	statco:boolean=TRUE;
type
	ar3=array[1..3] of real;
	ar6=array[1..6] of real;
	link=^db;
	db=record
		d0:integer;
		ID:char;
		d:ar6;
		ed:real;
		p,a:link;
		end;
	dat=record
		d0:integer;
		ID:char;
		ix:ar6;
	     end;
	mct=array[1..lastM_no,0..15] of string[12];
	grec= record
		oldx1,oldx2,oldy1,oldy2,gsize:integer;
		p:pointer;
		{
		viewport:viewporttype;
		}
		end;
const
	menu:mct=
	(
	(
	'DRAW'              {
	-------             }
	,'LINE'
	,'RECT'
	,'CIRCLE'
	,'ARC'
	,'ELLIPSE'

{
	,'POLYGON'
}

	,'PLINE'
	,'TEXT'
	,'INSERT'
	,'EXIT'
	,'','','','','',''),
	(
	'EDIT'               {
	--------             }
	,'POINT'
	,'SELECT'
	,'WSELECT'
	,'WNORMAL'
	,'DELETE'
	,'COPY'

	,'MOVE'

	,'ROTATE'
	,'MIRROR'
	,'ARRAY'

{
	,'CHANGE'
	,'SCALE'
	,'OFFSET'
	,'TRIM'
	,'DIVIDE'
}

	,'','','','',''),
	(
	'SETTINGS'            {
	------------          }
	,'ORTHO'

{
	,'SETKEY'
}
	,'GRID'
	,'LIMITS'
	,'MOVE'

{
	,'APERTURE'
}
	,'AXIS'
	,'SNAP'

{
	,'DRAGMODE'
}

	,'SLAYER'
	,'','','','','','','',''),
	(
	'OPTIONS'           {
	---------           }

	,'VLAYER'

	,'REDRAW'

{
	,'PAN'
	,'ZOOM'
}
	,'FILL'
	,'BLOCK'
	,'BPOINT'
	,'MDATA'
	,'SAVE'
	,'3DVIEW'

{	,'HIDE'
	,'CLEAR'
}
	,'','','','','','',''),
	(
	 'INFO'             {
	-------             }
	,'LIST'
	,'AREA'
	,'DIST'
	,'LENGTH'
	,'','','','','','','','','','',''));

var
	LimPX,LimPY:integer;
	graphrec1,graphrec2:grec;
	nopage:boolean;         { nopage=TRUE means only one videopage }
	choices:array[1..16] of string[12];  { Level-2 menus }
	dx,dy:integer;
picker:pointer;	{ pointer to picker image }
bx,by:real;
incr:real;      { jump spacing for picker }
exactx,exacty:real;
icom:integer;
comm:string[15];
newcom:boolean;
znp:boolean;

  vpfull,vpin,vpout,vpxy,vpmes : ViewPortType;
  px,py:real;
  x1,x2,x3,y1,y2,y3,z1,z2,z3:real;
    bsd2:integer;
    dbase,first,sbase,fbase,start,last:link;

PROCEDURE skelton;
PROCEDURE wco_ord;
PROCEDURE startgraphics;
PROCEDURE  ksinit;
FUNCTION  GDRY(y:integer):integer;
FUNCTION  GDRX(x:integer):integer;
PROCEDURE ksfont(x,y:integer;s:string;fonttype:integer);
PROCEDURE FullPort;
PROCEDURE killGraph(var graphrec:grec);
PROCEDURE putgraph(var graphrec:grec);
PROCEDURE menutitle(menu:mct;M_no:integer;dec:boolean);
PROCEDURE savegraph(var graphrec:grec;x1,y1,x2,y2:integer);
PROCEDURE popupmenu(menu:mct;x,y:integer;var M_no:integer;var choice:integer;var excode:char);
PROCEDURE MENUBAR(menu:mct;var M_no,icom:integer);
PROCEDURE setport(vp:viewporttype);
FUNCTION pix(y:real):real;
FUNCTION pixRX(y:real):real;
FUNCTION pixRY(y:real):real;
FUNCTION pixX(y:real):real;
FUNCTION pixY(y:real):real;
FUNCTION adx(x:real):integer;

FUNCTION adpx(z:real):integer;
FUNCTION ady(y:real):integer;
FUNCTION adpy(y:real):integer;

PROCEDURE pxpy(x,y:real);
FUNCTION valR(x:real):real;
FUNCTION valX(x:real):real;
FUNCTION valY(x:real):real;
FUNCTION valRX(x:real):real;
FUNCTION valRY(x:real):real;
PROCEDURE movetoxy(px,py:real);
PROCEDURE makepicker(picktype:byte);
{PROCEDURE MakeWheel;}
procedure mp(bit:byte);
PROCEDURE select(var pic:link;opt:boolean);
PROCEDURE move_around(var p1,p2,p3:real;fos:byte);
PROCEDURE newbase(var dbase,first,sbase:link);
PROCEDURE redraw;
FUNCTION xy2xyz(x,y,z:real;xy:byte):real;
FUNCTION xyz2xy(x,y,z:real;xy:byte):real;
FUNCTION dbase2scr(var dbase:link;xy:byte):real;
PROCEDURE cvp;
PROCEDURE changepicker(picktype:byte);
PROCEDURE  disp(c:char);
PROCEDURE xy3d(var dbase:link;x,y,z:real;fos:byte;znp:boolean);
PROCEDURE drawline(dbase:link);      { TO DRAW ISOMETRIC PROJECTION OF LINE }
PROCEDURE drawusing(dbase:link);
PROCEDURE SetIncr_IfNum(var c:char);
PROCEDURE cancel_select(pic:link);
PROCEDURE  result(s:string);
PROCEDURE men(c:char;var p1,p2,p3:real);
PROCEDURE FigLength(var measure:real);
PROCEDURE Greadreal(var angle:real);
PROCEDURE movepxpy(c:char);
PROCEDURE backer(c:char;var s:string;var posn:integer);
PROCEDURE  Gwrite(wstring:string);
PROCEDURE  Gread(var  s:string);
PROCEDURE  Greadint(var  rint:integer);
PROCEDURE  readpoint(var p1,p2,p3:real;fos:byte;var znp:boolean);
PROCEDURE regen;
PROCEDURE LAYERregen;
PROCEDURE interchange(var x,y:real);
PROCEDURE dele(var dbase,first,sbase:link);
PROCEDURE clear;
procedure getmouse(var p1,p2,p3:real;stat:integer);
implementation

PROCEDURE Startgraphics;
var
	gd,gm,errorcode:integer;
{ Initialize graphics and report any errors that may occur }
var
  InGraphicsMode : boolean; { Flags initialization of graphics mode }
  PD   : string;  { Stores the DOS path to *.BGI & *.CHR }
begin
  { when using Crt and graphics, turn off Crt's memory-mapped writes }
  DirectVideo := False;

PD :='D:\VKS\TP7\BGI\';     { % should be detected by software }
  repeat
(*
{$IFDEF HERC}
	graphdriver:=HercMono;
{$ELSE}
{$IFDEF Use8514}                          { check for Use8514 $DEFINE }
    GraphDriver := IBM8514;
    GraphMode   := IBM8514Hi;
{$ELSE}
{$IFDEF CGA}
   GraphDriver :=CGA ;
{$ELSE}
   GraphDriver := Detect ;                { use autodetection }
{$ENDIF}
{$ENDIF}
{$ENDIF}
*)

{
GD:=CGA;
GM:=CGAHi;

GD:=HercMono;
GM:=HercMonoHi;
}

GD:=EGA;
GM:=EGAMonoHi;
DetectGraph(GD,GM);

    InitGraph(GD, GM, PD);
    ErrorCode := GraphResult;             { preserve error return }
    if ErrorCode <> grOK then             { error? }
    begin
      Writeln('Graphics error: ', GraphErrorMsg(ErrorCode));
      if ErrorCode = grFileNotFound then  { Can't find driver file }
      begin
        Writeln('Enter full path to BGI driver or type <Ctrl-Break> to quit:');
	Readln(PD);
        Writeln;
      end
      else
        Halt(1);                          { Some other error: terminate }
    end;
  until ErrorCode = grOK;
SetBkColor(LightGray);
end;

PROCEDURE storeto(var po:ar3;p1,p2,p3:real);
begin
po[1]:=p1;
po[2]:=p2;
po[3]:=p3;
end;

PROCEDURE relpo(po:ar3;var p1,p2,p3:real);
begin
p1:=po[1];
p2:=po[2];
p3:=po[3];
end;

procedure ksinit;
begin
startgraphics;
  Randomize;                { init random number generator }
  MaxX := GetMaxX;          { Get screen resolution values }
  MaxY := GetMaxY;
LimPX:=round(MaxX*(600/720));
LimPY:=round(MaxY*(300/348));
getaspectratio(xasp,yasp);
{
xasp:=xasp * ( 720 div 648 );
yasp:=yasp * ( 348 div 200 );
}
setaspectratio(xasp,yasp);
tw:=textwidth('Û');
th:=textheight('Û');
with vpin do
	begin
	x1:=1;
	y1:=LimPY+2;
	x2:=LimPX;
	y2:=MaxY-1;
	Clip:=ClipOn;
	end;
with vpout do
	begin
	x1:=LowX;
	y1:=LowY;
	x2:=LimPX;
	y2:=LimPY;
	Clip:=ClipOn;
	end;
with vpxy do
	begin
	x1:=1;
	y1:=1;
	x2:=LimPX;
	y2:=GDRY(12);
	Clip:=ClipOn;
	end;
{if (graphdriver=HERCmono) then nopage:=FALSE else } nopage:=TRUE;
end; { Initialize }

FUNCTION GDRX(x:integer):integer;
begin
GDRX:=trunc(x*MaxX/720);
end;

FUNCTION GDRY(y:integer):integer;
begin
GDRY:=trunc(y*MaxY/348);
end;

PROCEDURE ksfont(x,y:integer;s:string;fonttype:integer);
begin
{
setusercharsize(12,9,18,14);
}
outtextxy(x,y,s);
{
if (fonttype=smallfont) then outtextxy(x+1,y,s);
}
end;

PROCEDURE FullPort;
{ Set the view port to the entire screen }
begin
  SetViewPort(0, 0, MaxX, MaxY, ClipOn);
end; { FullPort }

PROCEDURE putgraph(var graphrec:grec);
begin
with graphrec do
	begin
	{
	setviewport(oldx1,oldy1,oldx2,oldy2,clipon);
	}
	fullport;
	Putimage(oldx1,oldy1,p^,normalput);
	{
	freemem(p,gsize);
	}
	setport(vpout);
	end;
end;

FUNCTION proper(m:integer):integer;
var
	a:real;
begin
a:=getmaxY/479;
proper:=round(a*m);
proper:=m;
end;


PROCEDURE menutitle(menu:mct;M_no:integer;dec:boolean);
var
	x,y:integer;
	st,col:integer;
begin
col:=LimPX+3*tw;
x:=9*tw;
y:=th+2;
st:=th*3;
fullport;
{settextstyle(smallfont,horizdir,1);
setusercharsize(9,6,14,8);
}
	if dec=TRUE then
		begin
			setfillstyle(solidfill,white);
			bar(LimPX+4,st+(M_no-1)*y-2,MaxX-2,st+(M_no)*y-2);
			setcolor(black);
			ksfont(col,st+(M_no-1)*y,menu[M_no,0],defaultfont);
		end
	    else
		begin
			setfillstyle(solidfill,black);
			bar(LimPX+4,st+(M_no-1)*y-2,MaxX-2,st+(M_no)*y-2);
			setcolor(Yellow);
			ksfont(col,st+(M_no-1)*y,menu[M_no,0],defaultfont);
		end;
setcolor(white);
end;

PROCEDURE killgraph(var graphrec:grec);
begin
with graphrec do if dragmode then freemem(p,gsize);
end;


PROCEDURE savegraph(var graphrec:grec;x1,y1,x2,y2:integer);
begin
if x1<0 then x1:=0;
if x1>maxX then x1:=maxX;
if y1<0 then y1:=0;
if y1>maxX then y1:=maxY;

if x2<0 then x2:=0;
if x2>maxX then x2:=maxX;
if y2<0 then y2:=0;
if y2>maxX then y2:=maxY;

with graphrec do
	begin
	{
	getviewsettings(viewport);
	}
	fullport;
	gsize:=imagesize(x1,y1,x2,y2);
	oldx1:=x1;
	oldy1:=y1;
	oldx2:=x2;
	oldy2:=y2;
	if maxavail>gsize then
		begin
		getmem(p,gsize);
		getimage(x1,y1,x2,y2,p^);
		end
		else
			begin
			sound(500);
			delay(100);
			nosound;
			dragmode:=FALSE;
			end;
	setport(vpout);
	end;
end;

PROCEDURE popupmenu(menu:mct;x,y:integer;var M_no:integer;var choice:integer;var excode:char);
var
	let:char;
	x1,x2,y1,y2,count,maxchoice:integer;
	menuwidth,menuht,i:integer;
	sc:integer;
begin
setcolor(red);
Gwrite('1:Line 2:Sel/Norm 3:WSel 4:WNorm 5:Copy 6:Layer 7:Redraw');
setcolor(white);
menuwidth:=tw*10;
sc:=2;
excode:=#0;
count:=1;
maxchoice:=15;                      { # Limit for menu }
while (menu[M_no,count]<>'') and (count<maxchoice) do
		count:=count+1;
maxchoice:=count-1;
menuht:=count*(th+sc);
x1:=x;
x2:=x1+menuwidth;

y1:=y-4;

 moveto(x1+2*sc,y1+sc);
 setfillstyle(closedotfill,white);
 bar(x1,y1,x2,y1+(th+sc));
 setfillstyle(solidfill,black);
 y2:=y1+menuht+th-2;
 bar(x1-4,y1-4,x2+4,y2+4);
 setcolor(Yellow);
 rectangle(x1-1,y1,x2+1,y1+1+(th+sc));
 rectangle(x1-2,y1-1,x2+2,y1+2+(th+sc));
 settextjustify(CenterText,TopText);
 outtextxy((x1+x2) div 2,y1+sc,menu[M_no,0]);
 settextjustify(LeftText,TopText);

y1:=y1+4;

 y1:=y1+th+2*sc;
setcolor(BLUE);
y:=y1+2*sc;
for i:=1 to count do
	begin
	ksfont(x+2*sc,y,menu[M_no,i],defaultfont);
	y:=y+th+sc;
	end;

setcolor(Yellow);
rectangle(x1-1,y1-1,x2+1,y2+1+2);
rectangle(x1-2,y1-2,x2+2,y2+2+2);
setcolor(white);

y1:=y1+sc;
{
setviewport(x1,y1,x2,y2,clipon);
}
count:=prechoice[M_no];
moveto(x1+2*sc,(y1+sc+(count-1)*(th+sc)));
setfillstyle(solidfill,white);
bar(x1,y1+1+(count-1)*(th+sc),x2,(y1+count*(th+sc)));
setcolor(BLUE);
ksfont(x1+2*sc,y1+sc+(count-1)*(th+sc),menu[M_no,count],defaultfont);

mouseread:=FALSE;
repeat
if mouseread then let:=DOWN else let:=readkey;
if let=#0 then
begin
let:=readkey;
case ord(let) of          { Hot keys }
	59:
		begin
		icom:=1;
		M_no:=1;
		result('Line');
		end;
	60:
		begin
		icom:=2;
		M_no:=2;
		result('Select');
		end;
	61:
		begin
		icom:=3;
		M_no:=2;
		result('Wselect');
		end;
	62:
		begin
		icom:=4;
		M_no:=2;
		result('Wnormal');
		end;
	63:
		begin
		icom:=6;
		M_no:=2;
		result('Copy');
		end;
	64:
		begin
		icom:=7;
		M_no:=3;
		result('Setlayer');
		end;
	65:
		begin
		icom:=2;
		M_no:=4;
		result('Redraw');
		end;
	67:     statco:=not(statco);
	end;
if ord(let) in [59..65] then
				begin
				excode:=ENTER;
				exit;
				end;
moveto(x1+2*sc,(y1+sc+(count-1)*(th+sc)));
setfillstyle(solidfill,black);
bar(x1,y1+1+(count-1)*(th+sc),x2,(y1+count*(th+sc)));
setcolor(BLUE);
ksfont(x1+2*sc,y1+sc+(count-1)*(th+sc),menu[M_no,count],defaultfont);

if mouseread then
begin
Graph_M_Pos(Button,Xm,Ym);
if (Button=1) and (Ym>100) then let:=DOWN;
end;


	case let of
			UP:    if count=1
					then count:=maxchoice
				else
				 count:=count-1;
			DOWN:  if count=maxchoice
					then count:=1
				else
					count:=count+1;
			LEFT:
				begin
					excode:=LEFT;
				end;
			RIGHT:
				begin
				excode:=RIGHT;
				end;
		 end;
		 end
		 else
		 case let of
		 #27:	begin
			 excode:=ESC;
			 end;
		 #13,#32:
			begin
			excode:=ENTER;
			end;
		 end;
		moveto(x1+2*sc,(y1+sc+(count-1)*(th+sc)));
		setfillstyle(solidfill,white);
		bar(x1,y1+1+(count-1)*(th+sc),x2,(y1+count*(th+sc)));
		setcolor(BLUE);
		ksfont(x1+2*sc,y1+sc+(count-1)*(th+sc),menu[M_no,count],defaultfont);

until excode in [left,right,ESC,ENTER,SPACE];
choice:=count;
prechoice[M_no]:=choice;
setcolor(white);
end;

PROCEDURE MENUBAR(menu:mct;var M_no,icom:integer);
var
	x,y,z,k:integer;
	excode:char;
begin
repeat
x:=(LimPX+MaxX) div 2 - tw*5;
y:=trunc(th*10.5);
z:=(th+2)*17;
fullport;
putgraph(graphrec2);
	menutitle(menu,M_no,TRUE);
	k:=M_no;
	popupmenu(menu,x+1,y+1,M_no,icom,excode);
	if k=M_no then
		menutitle(menu,M_no,FALSE)
		else
		menutitle(menu,k,FALSE);
	if excode=LEFT then
			begin
				if M_no>1 then
					M_no:=M_no-1
					else
					M_no:=LastM_no;
			end;
		if excode=RIGHT then
			begin
				if M_no<LastM_no then
					M_no:=M_no+1
					else
					M_no:=1;
			end;
{
putgraph(graphrec);
}
until (excode=ENTER) or (excode=SPACE);
setport(vpout);
end;


{**********************      CPGraphics starts here ***********************}



PROCEDURE setport(vp:viewporttype);      	{ Sets current viewport }
begin
with vp do
	setviewport(x1,y1,x2,y2,clipon);
end;

FUNCTION pix(y:real):real;
begin
pix:=y*((LimPX-LowX)/LimX+(LimPY-LowY)/LimY)/2;
end;

FUNCTION pixRX(y:real):real;
begin
j1:=y*(LimPX-LowX)/LimX;
pixRX:=j1;
end;


FUNCTION pixRY(y:real):real;
begin
j2:=y*(LimPY-LowY)/LimY;
pixRY:=j2;
end;


FUNCTION pixX(y:real):real;
begin
j1:=LowX+y*(LimPX-LowX)/LimX;
if not eq(valX(j1),y) then
			halt;
pixX:=j1;
end;

FUNCTION pixY(y:real):real;
begin
j2:=LimPY-y*(LimPY-LowY)/LimY;
if not eq(valY(j2),y) then
			halt;
pixY:=j2;
end;

FUNCTION adx(x:real):integer;
var a:real;
begin
{
a:=maxX/719;
}
if abs(x)<maxint then adx:=round(x) else adx:=0;
end;

FUNCTION ady(y:real):integer;
var a:real;
begin
{
a:=maxY/347*0.75;
}
a:=1;
if abs(y*a)<maxint then ady:=round(y*a) else ady:=0;
end;

FUNCTION adpx(z:real):integer;
var
	a:real;
begin
{
a:=maxX/719;
}
a:=pixX(z);
if abs(a)<maxint then adpx:=round(a) else adpx:=0;
end;

FUNCTION adpy(y:real):integer;
var a:real;
begin
{
a:=maxY/347*0.75;
}
a:=1;
if abs(pixY(y)*a)<maxint then adpy:=round(pixY(y)*a) else adpy:=0;
end;

PROCEDURE pxpy(x,y:real);
begin
if (x>abs(maxint)) or (y>abs(maxint)) then
			begin
				Gwrite('Error found');
				x:=0;
				y:=0;
			end;
px:=pixX(x);
py:=pixY(y);
movetoxy(px,py);
end;

FUNCTION valR(x:real):real;
begin
valR:=x/(((LimPX-LowX)/LimX+(LimPY-LowY)/LimY)/2);
end;

FUNCTION valX(x:real):real;
begin
valX:=(x-LowX)*LimX/(LimPX-LowX);
end;

FUNCTION valY(x:real):real;	{ value of an absolute pixel rel.to user co.}
begin
valY:=(LimPY-x)*LimY/(LimPY-LowY);    {# CHECK }
end;

FUNCTION valRX(x:real):real;
begin
valRX:=valX(x)-valX(0);
end;

FUNCTION valRY(x:real):real;
begin
valRY:=valY(0)-valY(x);
end;


PROCEDURE movetoxy(px,py:real);
begin
moveto(adx(px),ady(py));
end;

PROCEDURE makepicker(picktype:byte);
var
  ulx, uly  : word;
  lrx, lry  : word;
  startx,starty:integer;
begin
fullport;
startx:=LimPX div 2;{MaxX-40;}
starty:=2;{MaxY-20;}
case picktype of
cross:
	begin
        setcolor(red);
	line(startx,starty+(bsize+1) div 2,startx+bsize+1,starty+(bsize+1) div 2);
	line(startx+(bsize+1) div 2,starty,startx+(bsize+1) div 2,starty+bsize+1);
	line(startx+(bsize+1) div 2+1,starty,startx+(bsize+1) div 2+1,starty+bsize+1);
	end;
square:
	begin
        setcolor(red);
        rectangle(startx,starty,startx+bsize+1,starty+bsize+1);
        end;
     end;
  { ReadImage }
  setcolor(white);
  ulx := StartX;
  uly := StartY;
  lrx := StartX+bsize+1;
  lry := StartY+bsize+1;
  Size := ImageSize(ulx, uly, lrx, lry);
  GetMem(Picker, Size);
  GetImage(ulx, uly, lrx, lry, Picker^);
PutImage(ulx, uly, Picker^, XORput);               { erase image }
bx:=ulx+bsd2+1;
by:=uly+bsd2+1;
setport(vpout);
end;


procedure mp(bit:byte);
begin
setcolor(white);
if (bit=0) or (bit=2)
	then
		PutImage(round(adx(bx)-bsd2-1), round(ady(by)-bsd2-1), Picker^, XORput);  { erase image }
if (bit=1) or (bit=2)
	then
		PutImage(round(adx(px)-bsd2-1), round(ady(py)-bsd2-1), Picker^, XORput);  { draw  image }
bx:=px;
by:=py;
end;

PROCEDURE cvp;
begin
clearviewport;
end;

PROCEDURE changepicker(picktype:byte);
begin
mp(0);
FreeMem(Picker,size);
makepicker(picktype);
mp(1);
end;

PROCEDURE  disp(c:char);
var
	x,y,loop:integer;
	s:string;
begin
exit;
if (c=#0) then exit;
if (c=#8) and (dx>10*textwidth(#219)) then
	begin
	dx:=dx-textwidth('Û');
	exit;
	end;
if (c=#27) or (c=#13) or (c=#32) then
	begin
	dy:=MaxY-GDRY(30);
	dx:=20*textwidth(#219);
{
	setport(vpout);
	movetoxy(px,py);
}
	exit;
	end;
Fullport;
settextstyle(defaultfont,horizdir,0);
moveto(dx,dy);
if (c<>#13) then
	begin
	outtext(c);
	dx:=dx+textwidth('Û');
	end;
setport(vpout);
movetoxy(px,py);
end;

FUNCTION xy2xyz(x,y,z:real;xy:byte):real;
{ TRANSFORMS XY values to actual x,y,z co_ordinates according to FIX (z) }
var
	cosx:array[1..3] of ar3;
begin
fillchar(cosx,sizeof(cosx),0);
case Lfix of
3:	begin
		cosx[1,1]:=1;  {Z=C   XY Plane}
		cosx[2,2]:=1;
		cosx[3,3]:=1;
	end;
2:	begin
		cosx[1,1]:=1;  {Y=C   XZ Plane}
		cosx[2,3]:=1;
		cosx[3,2]:=1;
	end;
1:	begin
				{X=C   YZ Plane}
		cosx[1,3]:=1;
		cosx[2,1]:=1;
		cosx[3,2]:=1;
	end;
end;
xy2xyz:=(x*cosx[xy,1]+y*cosx[xy,2]+z*cosx[xy,3]);
end;

FUNCTION xyz2xy(x,y,z:real;xy:byte):real;
{ TRANSFORMS xyz values to XY screen co_ordinates according to FIX }
var
	cosx:array[1..3] of ar3;

begin
fillchar(cosx,sizeof(cosx),0);
case Lfix of
3:	begin
		cosx[1,1]:=1;  {Z=C   XY Plane}
		cosx[2,2]:=1;
		cosx[3,3]:=1;
	end;
2:	begin
		cosx[1,1]:=1;  {Y=C   XZ Plane}
		cosx[2,3]:=1;
		cosx[3,2]:=1;
	end;
1:	begin
				{X=C   YZ Plane}
		cosx[1,2]:=1;
		cosx[2,3]:=1;			{ #check }
		cosx[3,1]:=1;
	end;
end;
xyz2xy:= x*cosx[xy,1] + y*cosx[xy,2] + z*cosx[xy,3];
end;

FUNCTION dbase2scr(var dbase:link;xy:byte):real;
{ TRANSFORMS xyz values to XY screen co_ordinates according to FIX }
begin
with dbase^ do
case xy of
	1:	dbase2scr:= xyz2xy(d[1],d[2],d[3],1);
	2:	dbase2scr:= xyz2xy(d[1],d[2],d[3],2);
	4:	dbase2scr:= xyz2xy(d[4],d[5],d[6],1);
	5:	dbase2scr:= xyz2xy(d[4],d[5],d[6],2);
     end;
end;

PROCEDURE xy3d(var dbase:link;x,y,z:real;fos:byte;znp:boolean);
		{ Transforms XY to xyz co-ordinates and assigns it
			to corresponding database fields }
var
	po:ar3;
begin
storeto(po,x,y,z);
with dbase^ do
case fos of
	1:
	if znp
		then
			for pon:=1 to 3 do d[pon]:=xy2xyz(po[1],po[2],pfix,pon)
		else
			for pon:=1 to 3 do d[pon]:=po[pon];
	2:
	if znp
		then
			for i:=1 to 3 do d[i+3]:=xy2xyz(po[1],po[2],pfix,i)
		else
			for pon:=1 to 3 do d[pon+3]:=po[pon];
	end;
end;

PROCEDURE drawline(dbase:link);      { TO DRAW ISOMETRIC PROJECTION OF LINE }
begin
mp(0);
Line(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),adpx(dbase2scr(dbase,4)),adpy(dbase2scr(dbase,5)));
mp(1);
pxpy(dbase2scr(dbase,4),dbase2scr(dbase,5));
movetoxy(px,py);
end;

PROCEDURE drawusing(dbase:link);
label 100;
const
	flag:boolean=FALSE;
begin
if dbase^.d0=ord('S')  then
		begin
		setlinestyle(solidln,0,thickwidth);
		end;

if dbase^.d0=ord('E') then
		begin
		setcolor(black);
		setlinestyle(solidln,0,thickwidth);
		flag:=TRUE;
		end;
100:
with dbase^ do
case ID of
    'L' :
	begin
	Line(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),adpx(dbase2scr(dbase,4)),adpy(dbase2scr(dbase,5)));
	end;
    'R' :
	begin
	Rectangle(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),
	adpx(dbase2scr(dbase,4)),adpy(dbase2scr(dbase,5)));
	end;
    'C' :
	begin
	Circle(adpx(dbase2scr(dbase,1)), adpy(dbase2scr(dbase,2)),
					round(pix(d[3])));
	end;
    'A' :
	begin
	Arc(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),round(d[3]),
				round(d[4]),round(pix(d[5])));
	end;
    'E':Ellipse(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),round(d[3]),round(d[4]),
				round(pixRX(d[5])),round(pixRY(d[6])));
	else
		result('Error: Unknown entity found!'); { #debug aid }
    end;
setcolor(white);
setlinestyle(solidLn,0,normwidth);
if flag=TRUE then
	begin
	flag:=FALSE;
	if dbase^.d0=ord('E') then dbase^.d0:=0;
	goto 100;
	end;
end;

PROCEDURE SetIncr_IfNum(var c:char);
var
	gout:boolean;
	i,error:integer;
	s:string;
begin
error:=0;
gout:=TRUE;
s:='';
i:=1;
repeat
if (c in ['0','1','2','3','4','5','6','7','8','9']) or ((i=1) and (c='-'))
	or ((c='.') and (pos('.',s)=0))
	then
		begin
		gout:=FALSE;
		insert(c,s,i);
		i:=i+1;
		c:=readkey;
		disp(c);
		end
		else
			gout:=TRUE;
until gout;
if length(s)>0 then
	val(s,incr,error);
if error<>0 then
	begin
	outtext('Error');
	exit;
	end;
end;

PROCEDURE cancel_select(pic:link);
begin
if pic=NIL then
		exit;
if (pic=first) then
begin
pic:=first^.a;
while pic<>NIL do
	begin
	if pic^.d0=ord('S') then
			pic^.d0:=ord('E');
	mp(0);
	drawusing(pic);
	mp(1);
	pic:=pic^.a;
	end;
end
	else
		begin
		if pic^.d0=ord('S') then pic^.d0:=ord('E');
		mp(0);
		drawusing(pic);
		mp(1);
		end;
end;

PROCEDURE  result(s:string);
var
	x,y:integer;
	s1,s2:string;
begin
settextstyle(defaultfont,horizdir,0);
setviewport(1,MaxY-th,LimPX-1,MaxY-1,clipon);
cvp;
outtext(s);
setport(vpout);
movetoxy(px,py);
settextstyle(defaultfont,horizdir,0);
fullport;
end;

PROCEDURE men(c:char;var p1,p2,p3:real);
		{ # near & perpendicular has to be updated;'C' also.}
var
	sx,sy,m,ax,ay:real;
	po:ar3;
	pic:link;
begin
c:=upcase(c);
case c of
'M':
	begin
	select(pic,urgent);
	if got then
	with pic^ do
		case ID of
		'L':
			for pon:=1 to 3 do
			 po[pon]:=(d[pon]+d[pon+3])/2;
		end;
	end;
'E':                             { correction needed }
	begin
	select(pic,urgent);
	if got then
	with pic^ do
	case ID of
		'L':
			begin
			if abs(px-pixX(dbase2scr(pic,1))+py-pixY(dbase2scr(pic,2)))>
				abs(pixX(dbase2scr(pic,4))-px+pixY(dbase2scr(pic,5))-py)
				then
				for pon:=1 to 3 do po[pon]:=d[pon+3]
				else
				for pon:=1 to 3 do po[pon]:=d[pon]
		       end;
		'C':   begin
			pxpy(dbase2scr(pic,1),dbase2scr(pic,2));
			end;
		end;
	end;
'N':
	begin
	select(pic,urgent);
	if got then
		begin
			px:=exactx;
			py:=exacty;
		end;
	end;
'P':
	begin
	sx:=px;
	sy:=py;
	select(pic,user_choice);
	if got then
	begin
	x1:=pixX(dbase2scr(pic,1));
	y1:=pixY(dbase2scr(pic,2));
	x2:=pixX(dbase2scr(pic,4));
	y2:=pixY(dbase2scr(pic,5));
	px:=sx;
	py:=sy;
	with pic^ do
		if ((x2-x1)<>0) and ((y2-y1)<>0) then
			begin
			m:=(y2-y1)/(x2-x1);
			ax:=(m*x1+px/m+py-y1)/(m+1/m);
			ay:=y1-m*(x1-ax);
			end
			else
				if (x2-x1)=0 then
				  begin
				  ax:=x1;
				  ay:=py;
				  end
			else
				if (y2-y1)=0 then
				  begin
				  ax:=px;
				  ay:=y1;
				  end;
			px:=px+(ax-px);
			py:=py+(ay-py);
		end;
		end;
	end;
pxpy(xyz2xy(po[1],po[2],po[3],1),xyz2xy(po[1],po[2],po[3],2));
relpo(po,p1,p2,p3);
movetoxy(px,py);
mp(2);
end;

PROCEDURE FigLength(var measure:real);
var pic:link;
begin
select(pic,user_choice);
with pic^ do
case ID of
	'L':
		begin
			measure:=sqrt(sqr(dbase2scr(pic,1)-dbase2scr(pic,4))+sqr(dbase2scr(pic,2)-dbase2scr(pic,5)));
		end;
	'C':    begin
			measure:=2*pi*dbase2scr(pic,2);
		end;
      end;
end;
PROCEDURE Greadreal(var angle:real);
var
	gout:boolean;
	s:string;
	i,error:integer;
	p1,p2,p3:real;
	fos:byte;
	c:char;
	pic:link;
begin
gout:=TRUE;
s:='';
i:=1;
repeat
if inpname<>'CON'
	then
		read(inp,c)
	else
		c:=readkey;
disp(c);
if (i=1) and ((c=enter) or (c=space)) then
	begin
	move_around(p1,p2,p3,fos);
angle:=sqr(px-adpx(dbase2scr(pic,1)))+sqr(py-adpy(dbase2scr(pic,2)));
			{ PiXX(d[1]) ,PiXY(D4) initially >dbase2scr}
	angle:=valR(sqrt(angle));
	exit;
	end;

if c=#8 then
	backer(c,s,i)
	else
	if (c in ['0','1','2','3','4','5','6','7','8','9','.'])
				or  ((i=1) and (c='-')) then
		begin
		gout:=FALSE;
		insert(c,s,i);
		outtext(c);
		i:=i+1;
		end
		else
			gout:=TRUE;
if c=ESC then
	begin
	exit;
	end;
until gout;
val(s,angle,error);
if error<>0 then
	begin
	angle:=0;
	exit;
	end;
end;

PROCEDURE movepxpy(c:char);
begin
case c of
	up      :
		begin
		py:=py-pixRY(incr);
		end;
	down 	:
		begin
		py:=py+pixRY(incr);
		end;
	left    :
		begin
		px:=px-pixRX(incr);
		end;
	right   :
		begin
		px:=px+pixRX(incr);
		end;
end;
movetoxy(px,py);
end;

PROCEDURE select(var pic:link;opt:boolean);
LABEL 100;
var
	sum:integer;
	c:char;
	block:array[1..20,1..20] of integer;
	i,j,x,y:integer;
begin
changepicker(square);
if opt=user_choice
	then
	repeat
		wco_ord;
		movetoxy(px,py);
		mp(2);      { draw image }
		c:=readkey;
		disp(c);
		SetIncr_IfNum(c);
		if ord(c)=0 then
			c:=readkey;
		movepxpy(c);
	until (c=enter) or (c=space) or (c=ESC);
exactx:=valX(getx);
exacty:=valY(gety);
got:=FALSE;
if c=ESC then goto 100;
pic:=first^.a;
x:=adx(px);
y:=ady(py);

x1:=x-bsd2;
x2:=x+bsd2;
y1:=y-bsd2;
y2:=y+bsd2;

mp(0);
repeat
sum:=0;
	for i:=0 to bsd2 do
		for j:=0 to bsd2 do
		begin
		block[bsd2+1-i,bsd2+1-j]:=getpixel(x-i,y-j);
		block[bsd2+1+i,bsd2+1+j]:=getpixel(x+i,y+j);
		block[bsd2+1+i,bsd2+1-j]:=getpixel(x+i,y-j);
		block[bsd2+1-i,bsd2+1+j]:=getpixel(x-i,y+j);
		if sum=0 then
			begin
			sum:=sum+getpixel(x-i,y-j)+
			getpixel(x+i,y+j)+
			getpixel(x+i,y-j)+
			getpixel(x-i,y+j);
			end;
		end;
	if sum=0 then
		begin
		got:=FALSE;
		mp(1);
		goto 100;
		end;
repeat
sum:=1;
with pic^ do
	case ID of
		'L':
			begin
			if   ((adpx(dbase2scr(pic,1))<x1) and (adpx(dbase2scr(pic,4))<x1))
			  or ((adpx(dbase2scr(pic,1))>x2) and (adpx(dbase2scr(pic,4))>x2))
			  or ((adpy(dbase2scr(pic,2))<y1) and (adpy(dbase2scr(pic,5))<y1))
			  or ((adpy(dbase2scr(pic,2))>y2) and (adpy(dbase2scr(pic,5))>y2))
			   then
				begin
				sum:=0;
				pic:=pic^.a;
				end;
			end;
		'C':    begin
			if   (adpx(dbase2scr(pic,1))+adpx(d[3])<x1)
			  or (adpx(dbase2scr(pic,1))-adpx(d[3])>x2)
			  or (adpy(dbase2scr(pic,2))+adpy(d[3])<y1)
			  or (adpy(dbase2scr(pic,2))-adpy(d[3])>y2) then
				begin
				sum:=0;
				pic:=pic^.a;
				end;
			end;
		end;
if pic=NIL then
	begin
	got:=FALSE;
	mp(1);
	goto 100;
	end;
until (sum<>0);

	for i:=0 to bsd2 do
		for j:=0 to bsd2 do
		begin
		putpixel(x+i,y+j,black);
		putpixel(x-i,y-j,black);
		putpixel(x+i,y-j,black);
		putpixel(x-i,y+j,black);
		end;
	drawusing(pic);
	i:=-1;
	got:=FALSE;
	while (not got) and (i<bsd2)  do
		begin
		i:=i+1;
		j:=-1;
		repeat
			j:=j+1;
			if not got then
			 begin
			 if getpixel(x+i,y+j)<>0 then
				begin
				got:=TRUE;
				exactx:=px+i;
				exacty:=py+i;
				end;
			if getpixel(x-i,y-j)<>0 then
				begin
				got:=TRUE;
				exactx:=px-i;
				exacty:=py-j;
				end;
			 if getpixel(x-i,y+j)<>0 then
				begin
				got:=TRUE;
				exactx:=px-i;
				exacty:=py+i;
				end;
			if getpixel(x+i,y-j)<>0 then
				begin
				got:=TRUE;
				exactx:=px+i;
				exacty:=py-j;
				end;
			 end;
until (j=bsd2);
end;
if not got then pic:=pic^.a;
for i:=0 to bsd2 do
	for j:=0 to bsd2 do
		begin
		putpixel(x+i,y+j,block[bsd2+1+i,bsd2+1+j]);
		putpixel(x-i,y-j,block[bsd2+1-i,bsd2+1-j]);
		putpixel(x+i,y-j,block[bsd2+1+i,bsd2+1-j]);
		putpixel(x-i,y+j,block[bsd2+1-i,bsd2+1+j]);
		end;
until ((got) or (pic=NIL));
if pic=NIL then got:=FALSE;
mp(1);
100:
changepicker(cross);
exit;
end;    { Select }

PROCEDURE move_around(var p1,p2,p3:real;fos:byte);
var
	re,re1,re2,angle:real;
	po:ar3;
	c:char;
{        tdbase:link;}
begin
c:=#0;
repeat
wco_ord;
movetoxy(px,py);

mp(2);                 { draw image }
if fos=2 then
	with dbase^ do
begin
case ID of
	'L','R':
		begin
		if adpx(dbase2scr(dbase,1))<px then
			begin
			x1:=adpx(dbase2scr(dbase,1));
			x2:=px;
			end
			else
			begin
			x2:=adpx(dbase2scr(dbase,1));
			x1:=px;
			end;
		if adpy(dbase2scr(dbase,2))<ady(py) then
			begin
			y1:=adpy(dbase2scr(dbase,2));
			y2:=py;
			end
			else
			begin
			y2:=adpy(dbase2scr(dbase,2));
			y1:=py;
			end;
		end;
	'C':
		begin
		re1:=py-adpy(dbase2scr(dbase,2));
		re1:=re1*(py-adpy(dbase2scr(dbase,2)));
		re2:=px-pixX(d[1]);
		re2:=re2*(px-adpx(dbase2scr(dbase,1)));
		re:=re1+re2;
		re:=sqrt(re);

		x1:=adpx(dbase2scr(dbase,1))-re;
		x2:=adpx(dbase2scr(dbase,1))+re;
		y1:=adpy(dbase2scr(dbase,2))-re;
		y2:=adpy(dbase2scr(dbase,2))+re;
		end;
	end;
savegraph(graphrec1,adx(x1-1),ady(y1-1),adx(x2+1),ady(y2+1));
setport(vpout);
if ID='L' then line(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),adx(px),ady(py));
if ID='R' then rectangle(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),adx(px),ady(py));
if ID='C' then circle(adpx(dbase2scr(dbase,1)),adpy(dbase2scr(dbase,2)),round(re));
end;
{
if mouseread then c:=#255 else}
c:=readkey;
if fos=2 then
		begin
		putgraph(graphrec1);
		killgraph(graphrec1);
		end;
disp(c);
c:=upcase(c);
if c in ['M','E','N','P']
	then
	begin
	men(c,p1,p2,p3);
	exit;
	end;
if c='A' then
	begin
	Greadreal(angle);
	angle:=angle/180*pi;
	px:=px+pixX(incr)*cos(angle);
	py:=py+pixY(incr)*cos(angle);
	end
else
if c=ESC then
	begin
	aborted:=TRUE;
	exit;
	end
else
if (c<>enter) and (c<>space) then
		begin
		if ord(c)=0 then
			begin
			c:=readkey;
			Movepxpy(c);
			end;
		SetIncr_IfNum(c);
		end;

{
if mouseread then
            begin
            getmouse(p1,p2,p3,0);
            delay(100);
            new(tdbase);
            tdbase^.d[1]:=p1;
            tdbase^.d[2]:=p2;
            tdbase^.d[3]:=p3;
            px:=dbase2scr(tdbase,1);
            py:=dbase2scr(tdbase,2);
            dispose(tdbase);
            end
   else
}
       if c=#0 then c:=readkey;

until (c=enter) or (c=space);

for i:=1 to 3 do po[i]:=xy2xyz(valX(px),valY(py),pfix,i);
relpo(po,p1,p2,p3);
exit;
end;
			{ Move around }

PROCEDURE backer(c:char;var s:string;var posn:integer);
var
	i,j:integer;
	x,y:integer;

begin
if c=#8 then
	begin
	x:=tw;
	y:=th;
	if posn=1 then
			exit;
	moveto(getx-x,gety);
	for i:=0 to x do
	for j:=0 to y do
	putpixel(getx+i,gety+j,black);
	posn:=posn-1;
	delete(s,posn,1);
	end;
end;

PROCEDURE  Gwrite(wstring:string);
var
	x,y,loop:integer;
	gols,s:string;
begin
upstring(wstring);
begin
settextstyle(defaultfont,horizdir,1);
gols:=wstring;
setviewport(1,LimPY+gdry(20)-1,LimPX,MaxY-th-1,clipon);
cvp;
FullPort;
x:=15;
y:=LimPY+gdry(20);
moveto(x,y);
{
setcolor(black);
}
s:='';
if wstring<>'' then
	begin
{
		for loop:=1 to length(wstring) do s:=s+'Û';
		outtext(s);
}
{		setcolor(white);}
		outtext(wstring);
		{ksfont(x,y,wstring,smallfont);}
	end;
end;
end;

PROCEDURE  Gread(var  s:string);
var
	i,j:integer;
	x,y:integer;
begin
if inpname<>'CON' then
	begin
	readln(inp,s);
	exit;
	end;
s:='';
i:=1;
repeat
if inpname<>'CON'
	then
		begin
		if eof(inp)
			then
				begin
				inpname:='CON';
				assign(inp,inpname);
				reset(inp);
				end
			else
				read(inp,c);
		end
	else
		c:=readkey;
disp(c);
if c=#0 then
	begin
	c:=readkey;
	c:=#0;
	end;
if c=ESC then exit;
if c=#8 then backer(c,s,i)
else
if (c<>enter) and ((c>space) or (comm[1]='T')) and (ord(c)<=126) then
begin
insert(c,s,i);
outtext(c);
i:=i+1;
end;
until (c=enter) or ((comm[1]<>'T') and (c=space));
setport(vpout);
movetoxy(px,py);
end;

PROCEDURE  Greadint(var  rint:integer);
var
	i,error:integer;
	p:real;
	p1,p2,p3:real;
        fos:byte;
        po:ar3;

begin
s:='';
i:=1;
repeat
if inpname<>'CON'
	then
		read(inp,c)
	else
                begin

		c:=readkey;
                end;
if c=ESC then exit;
disp(c);
if (i=1) and ((c=enter) or (c=space)) then
	begin
	move_around(p1,p2,p3,fos);
	p:=sqr(px-adpx(dbase2scr(dbase,1)))+sqr(py-adpy(dbase2scr(dbase,2)));
	rint:=round(valR(sqrt(p)));
	exit;
	end;
backer(c,s,i);
if c=#0
	then
		c:=readkey
	else
	if ((c>='0') and (c<='9')) or ((i=1) and (c='-')) then
			begin
			insert(c,s,i);
			outtext(c);
			i:=i+1;
			end;
until (c=enter) or (c=space);
val(s,rint,error);
if error<>0 then halt;
setport(vpout);
movetoxy(px,py);
end;

PROCEDURE  readpoint(var p1,p2,p3:real;fos:byte;var znp:boolean);
var
	i:integer;
	sint:array[1..3] of string;
	commapos:integer;
	error:array[1..3] of integer;
	angle:real;
        po:ar3;
	c:char;
begin
znp:=TRUE;
if inpname<>'CON' then
		begin
		readln(inp,p1,c,p2,c,p3);
		exit;
		end;
s:='';
i:=1;
c:=#0;

repeat

{
mouseread:=TRUE;
if mouseread then
begin
}
{if fos=1 then }getmouse(p1,p2,p3,1);
{if fos=2 then move_around(p1,p2,p3,fos);}
{
end;
}

if not mouseread then c:=readkey else c:=ENTER;
if c=#0 then
		begin
		c:=readkey;
		movepxpy(c);
		move_around(p1,p2,p3,fos);
		exit;
		end;
if c=ESC then
	begin
	aborted:=TRUE;
	exit;
	end;
if ((i=1) and (c in [ENTER,SPACE])) then
		begin
		for i:=1 to 3 do po[i]:=xy2xyz(valX(px),valY(py),pfix,i);
		relpo(po,p1,p2,p3);
		exit;
		end;
if inpname='CON' then
begin
disp(c);
c:=upcase(c);
if c in ['M','E','N','P'] then
	begin
	men(c,p1,p2,p3);
	exit;
	end;
if c='A' then
	begin
	Greadreal(angle);
	angle:=angle/180*pi;
	for pon:=1 to 3 do
	po[pon]:=xy2xyz(valX(px+pixRX(incr)*cos(angle)),valY(py+pixRY(incr)*sin(angle)),pfix,pon);
	relpo(po,p1,p2,p3);
	exit;
	end;
end;

backer(c,s,i);
{
if ord(c)=0
	then
		begin
		c:=readkey;
		movepxpy(c);
	for pon:=1 to 3 do
	po[pon]:=xy2xyz(valX(px),valY(py),pfix,pon);
	relpo(po,p1,p2,p3);
	end
	else
}
	if ((c>='0') and (c<='9')) or (c=',') or (c='.')
		or (((i=1) or (s[i-1]=',')) and (c='-')) then
			begin
			insert(c,s,i);
			outtext(c);
			i:=i+1;
			end;
if c=#0 then c:=readkey;
until (c=enter) or (c=space);

commapos:=pos(',',s);
sint[1]:=copy(s,1,commapos-1);
delete(s,1,commapos);
commapos:=pos(',',s);
sint[2]:=copy(s,1,commapos-1);
delete(s,1,commapos);
sint[3]:=s;
for pon:=1 to 3 do val(sint[pon],po[pon],error[pon]);
if (error[1] and error[2] and error[3])<>0 then
	begin
	outtext('ERROR');
	c:=readkey;
	newcom:=TRUE;
	po[1]:=valX(px);
	po[2]:=valY(py);
	end;

relpo(po,p1,p2,p3);
setport(vpout);
pxpy(po[1],po[2]);
movetoxy(px,py);
znp:=FALSE;
end;


PROCEDURE regen;
var pic:link;
begin
pic:=first^.a;
while pic<>NIL do
	begin
		drawusing(pic);
		pic:=pic^.a;
	end;
end;


PROCEDURE redraw;
begin
mp(0);
setviewport(1,th+4,LimPX,LimPY,clipon);
cvp;
setport(vpout);
regen;
mp(1);
end;

PROCEDURE LAYERregen;
var
	pic:link;
begin
pic:=first^.a;
while pic<>NIL do
begin
if pic^.ID in ['L','R'] then   { # include C,A etc. }
if eq(pic^.d[Lfix],pfix) and
			eq(pic^.d[Lfix+3],pfix)
				then drawusing(pic);
pic:=pic^.a;
end;
end;

PROCEDURE interchange(var x,y:real);
var
	temp:real;
begin
temp:=x;
x:=y;
y:=temp;
end;

PROCEDURE newbase(var dbase,first,sbase:link);
begin
if (maxavail<100) then
		begin
		sound(1000);
		delay(500);
		nosound;
		end;
new(dbase);
inc(first^.d0);
dbase^.p:=sbase;
dbase^.a:=NIL;
sbase^.a:=dbase;
with dbase^ do
begin
d0:=0;
ID:='L';
for pon:=1 to 6 do d[pon]:=0;
ed:=0;
end;
sbase:=dbase;
end;

PROCEDURE dele(var dbase,first,sbase:link);
var
	dummy:link;
	p:^word;
	x:integer;
begin
if  (dbase=first) or (dbase=NIL) then halt;
	dummy:=dbase^.p;
	dummy^.a:=dbase^.a;
	if dummy^.a<>NIL
		then
			dummy^.a^.p:=dummy
		else
			sbase:=dummy;
	dispose(dbase);
	dec(first^.d0);
	dbase:=dummy;
{
	end
	else
		begin
		Gwrite('Trying to destroy system area.Press ESC.');
		c:=readkey;
		end;
}
end;

PROCEDURE clear;
begin
	setviewport(1,th+4,LimPX,LimPY,clipon);
	cvp;
	setport(vpout);
	newcom:=TRUE;
end;

PROCEDURE  wco_ord;
var
	s1,s2,s3:string;
	tx:integer;
	rx,ry:real;
begin
setcolor(red);
if not(statco) then exit;
rx:=valX(px);
ry:=valY(py);
str(rx:8:3,s1);
str(ry:8:3,s2);
str(pfix:8:3,s3);
case Lfix of
	3:	s2:=s1+' X '+s2+' Y ';
	2:	s2:=s2+' Z '+s1+' X ';
	1:	s2:=s1+' Y '+s2+' Z ';
	end;
s1:=' LAYER  '+cLfix[Lfix]+' '+s3;
settextstyle(defaultfont,horizdir,1);
setviewport(2,1,18*tw+2,th+3,FALSE);
cvp;
ksfont(1,3,s1,defaultfont);
setviewport(LimPX-23*tw,1,LimPX,th+3,FALSE);
cvp;
outtextxy(1,3,s2);
setviewport(18*tw+2+1,1,LimPX-23*tw-1,th+3,FALSE);
cvp;
setport(vpout);
movetoxy(px,py);
setcolor(white);
end;

PROCEDURE skelton;
var
	y:integer;
begin
fullport;
setcolor(yellow);
rectangle(0,0,LimPX+1,LimPY+1);
rectangle(0,LimPY+1,LimPX+1,MaxY);
{
rectangle(LimPX+3,0,MaxX,MaxY);
}
setfillstyle(9,cyan);
bar(LimPX+3,th+4,MaxX,MaxY);

setfillstyle(0,cyan);
bar(LimPX+3,1,MaxX-1,th+3);
setcolor(Blue);
ksfont(LimPX+4,3,' KS GRAPHER ',defaultfont);
setcolor(White);
rectangle(LimPX+3,0,MaxX,th+4);
setcolor(white);
y:=th*3;	{ change affect menutittle }
setfillstyle(0,white);
bar(LimPX+4,y-3,MaxX-1,y+(th+2)*5-1);
savegraph(graphrec2,LimpX+4,trunc(10.5*th),MaxX,MaxY);
fullport;
setcolor(yellow);
for i:=1 to 5 do
		begin
		 OutTextXY(LimPX+tw*3,y,menu[i,1]);
		 inc(y,th+2);
		end;
setport(vpout);
setcolor(white);
end;

procedure getmouse(var p1,p2,p3:real;stat:integer);
label     label1;
var j:integer;
    po:ar3;
begin
                { Added on 2/11/96 }
                Reset_M(M_Status,No_of_Buttons);
                Locate_M(adx(px),adx(py));
                Show_M;

                repeat
                mouseread:=FALSE;
                Graph_M_Pos(Button,Xm,Ym);
                if ((stat=0) and (Button=0)) or
                  ((stat=1) and (Button=1)) then
                   begin
                   px:=Xm; py:=Ym;
                   for j:=1 to 3 do po[j]:=xy2xyz(valX(px),valY(py),pfix,j);
                   relpo(po,p1,p2,p3);
                   mouseread:=TRUE;
                   Hide_M;
                   if stat=1 then delay(100);
                   goto label1; {break;}
                   end;
                 until keypressed;
label1:          Hide_M;
                { End Add }
end;

begin
inpname:='CON';
assign(inp,inpname);
reset(inp);
end.





