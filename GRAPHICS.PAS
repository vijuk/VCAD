
unit graphics;
interface
uses mouse;
PROCEDURE grapher(pro:integer;graphname:string);
implementation

uses crt,lib,graph,glib,clib,agi,illiz;

var
	M_no:integer;
	heap:^integer;
	i,error:integer; {temp need}

{
PROCEDURE typematic(rate,wait:byte);
var
	reg:registers;
begin
reg.ah:=$03;
reg.al:=$05;
reg.bl:=rate;
reg.bh:=wait;
intr($16,reg);
end;

PROCEDURE writekeybuf(ScanCode,AsciiCode:byte;var full:boolean);
var
	reg:registers;
begin
reg.ah:=$05;
reg.ch:=ScanCode;
reg.cl:=AsciiCode;
intr($16,reg);
end;
}
PROCEDURE grapher(pro:integer;graphname:string);
label 100;
var
	mycomno:integer;
	c:char;
			 {**********   MAIN PROGRAM  ***********}
begin
txtmode:=FALSE;
Lfix:=3;
M_no:=1;
inpname:='CON';
Layerno:=1;
Layerdir[1]:='Z'+strreal(pfix,5,3);
incr:=1.0;
bsd2:=bsize div 2;
ksinit;
{
savegraph(graphrec2,LimpX+2*tw,12*th,MaxX-2*tw,MaxY-2*th);
}
makepicker(cross);
skelton;
    newcom:=TRUE;
    px:=pixX(0.0);
    py:=pixY(0.0);
new(dbase);
dbase^.p:=nil;
dbase^.a:=nil;
first:=dbase;
first^.d0:=0;
first^.d[1]:=0;
first^.d[2]:=0;
first^.d[3]:=0;
Layerdir[1]:='';
Layerdir[2]:='END';
sbase:=dbase;
new(fbase);
fbase^.a:=NIL;
fbase^.p:=NIL;
start:=fbase;
last:=fbase;
disp(#32);      { initialize disp }
mp(1);
mycomno:=0;
comm:='';
repeat
inc(mycomno);
wco_ord;
mp(2);
if inpname<>'CON' then
if eof(inp) then
	begin
	inpname:='CON';
	assign(inp,inpname);
	reset(inp);
	end;
{
if newcom then
    begin
    Gwrite('Command : ');
    Gread(comm);
    upstring(comm);
    newcom:=TRUE;
    end;
}

{
Gread(comm);
upstring(comm);
newcom:=TRUE;
}

if (pro=0) then
begin
newcom:=TRUE;
if newcom then
	begin
	menubar(menu,M_no,icom);
	comm:=menu[M_no,icom];
	end;
end;

icom:=255;
if comm='EXIT' 	     then goto 100;
if comm='ORTHO'      then icom:=0;
if comm='LINE'       then icom:=1;
if comm='RECT'       then icom:=2;
if comm='CIRCLE'     then icom:=3;
if comm='ARC' 	     then icom:=4;
if comm='ELLIPSE'    then icom:=5;
if comm='PLINE'      then icom:=6;
if comm='POINT'      then icom:=7;
if comm='FUSE'       then icom:=8;
if comm='GRID' 	     then icom:=9;
if comm='SELECT'     then icom:=10;
if comm='DELETE'     then icom:=11;
if comm='FILL'       then icom:=12;
if comm='SETKEY'     then icom:=13;
if comm='FUSE'       then icom:=14;
if comm='TEXT'       then icom:=15;
if comm='WSELECT'    then icom:=16;
if comm='AREA'       then icom:=17;
if comm='COPY'       then icom:=18;
if comm='MOVE'       then icom:=19;
if comm='CHANGE'     then icom:=20;
if comm='ROTATE'     then icom:=21;
if comm='MIRROR'     then icom:=22;
if comm='EXIT'       then icom:=23;
if comm='BLOCK'      then icom:=24;
if comm='INSERT'     then icom:=25;
if comm='REDRAW'     then icom:=26;
if comm='CLEAR'      then icom:=27;
if comm='DIST'       then icom:=28;
if comm='LENGTH'     then icom:=29;
if comm='SCALE'      then icom:=30;
if comm='LIMITS'     then icom:=31;
if comm='APERTURE'   then icom:=32;
if comm='ARRAY'      then icom:=33;
if comm='AXIS'       then icom:=34;
if comm='SNAP'       then icom:=35;
if comm='BPOINT'     then icom:=36;
if comm='DIVIDE'     then icom:=37;
if comm='DRAGMODE'   then icom:=38;
if comm='ZOOM'       then icom:=39;
if comm='PAN'        then icom:=40;
if comm='TRIM'       then icom:=41;
if comm='SAVE'       then icom:=42;
if comm='POLYGON'    then icom:=43;
if comm='OFFSET'     then icom:=44;
if comm='SLAYER'     then icom:=45;
if comm='VLAYER'     then icom:=46;
if comm='MDATA'      then icom:=47;
if comm='LIST'	     then icom:=48;
if comm='3DVIEW'     then icom:=49;
if comm='WNORMAL'    then icom:=50;

if pro=1 then
case mycomno of
	1:icom:=25;
	2:icom:=49;
	3:icom:=47;
	4:goto 100;
	end;

if pro=2 then icom:=51;
if pro=3 then icom:=52;
if pro=4 then
	case mycomno of
		1:icom:=25;
		2:icom:=49;
		end;
if icom in [1..6] then newbase(dbase,first,sbase);
{
result('');
}
aborted:=FALSE;
with dbase^ do
begin
case icom of
{ORTHO}	    	 0 : call_DRAW;
{LINE}	    	 1 : call_LINE;
{RECTANGLE}    	 2 : call_RECT;
{CIRCLE}   	 3 : call_CIRC;
{ARC}	    	 4 : call_ARC ;
{ELLIPSE}   	 5 : call_ELIP;
{PLINE}	    	 6 : call_PLIN;
{SETPOINT} 	 7 : call_SETP;
{FUSE}      	 8 :          ;
{GRID}	    	 9 : call_GRID;
{SELECT}        10 : call_SELE;
{DELETE}        11 : call_DELE;
{FILL}	     	12 : call_FILL;
{SETKEY}    	13 : call_SETK;
{FUSE}       	14 :          ;
{TEXT}	     	15 : call_TEXT;
{BOXSELECT} 	16 : call_WSEL;
{COPY}      	18 : call_COPY;
{MIRROR}        22 : call_MIRR;
{MOVE}     	19 : call_ILLI; {call_COPY;}
{REDRAW}        26 : redraw;
{CLS}	        27 :  ;
{DISTANCE}      28 : call_DIST;
{LENGTH}        29 : call_LENG;
{CHANGE}        20 : call_CHAN;
{HIDE}	        23 : call_HIDE;
{BLOCK}         24 : call_BLOC;
{INSERT}        25 : call_INSE(pro);
{AREA}		17 : call_AREA;
{ROTATE}        21 : call_ROTO(0);
{SCALE}         30 : call_SCAO;
{LIMITS}        31 : call_LIMI;
{APERTURE}      32 : call_APER;
{ARRAY}         33 : call_ARRA;
{AXIS}          34 : call_AXIS;
{SNAP}          35 : call_SNAP;
{BASE}          36 : call_BASE;
{DIVIDE}        37 : {call_DIVI};
{DRAGMODE}      38 : {call_DRAG};
{ZOOM}          39 : call_ZOOM;
{PAN}           40 : call_PAN;
{TRIM}          41 : {call_TRIM};
{SAVE}          42 : {call_SAVE;};
{POLYGON}       43 : {call_POLY;};
{OFFSET}        44 : {call_OFFS;};
{SLAYER}	45 : call_LAYE;
{VLAYER}	46 : call_LAYE;
{MDATA}     	47 : graph2data(graphname);
{LIST}   	48 : call_list;
{3DVIEW}   	49 : call_ROTO(pro);
{WNORMAL}	50 : call_WSEL;
		51:  genLD(graphname);
		52:  genBMD(graphname);
end;
end;
if pro in [2,3] then goto 100;
if (pro=4) and (mycomno=3) then goto 100;
until comm='EXIT';
100:
restorecrtmode;
closegraph;
directvideo:=TRUE;
txtmode:=TRUE;
exit;
end;

{ Include para below for ind. existance with COMMAND line parameters }

{
begin
val(paramstr(1),i,error);
grapher(i,paramstr(2));
}
end.

Notes :-
ÄÄÄÄÄ

d[1],d[2],d[3] of first^ contains base point x,y,z of figure
PRO dbase2scr	- Convert 3D co_ordinates of dbase to screen co_ordinates .

