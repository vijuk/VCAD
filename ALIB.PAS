{
Debug 13/9/95
Load direction not taken for FEM & Reactions for Kani
}

unit alib;
INTERFACE
uses    crt,lib;
{************** ALIB ***********}
const	maxdata=200;
type
	range=0..255;
	ar4=array[1..4] of real;
	ar2=array[1..2] of real;
	jointset = set of range;
	load =
	      record
		ldir:char;
		weild:char;	{ wind,EQ,impact,Live or Dead }
		case loadtype:char of
	 '.','V','U' : ( w1,w2,pos1,pos2:real);		{var dis load}
		 'C' : ( w,posn:real);			{con load}
		 'P' : ( wmax:real);			{parabolic}
		 'M' : ( m,mpos:real);			{moment}
		 'D' : ( d:real);				{displacement}
	      end;
	datatype =
		record
		 name: array[1..10] of integer;
		   dir:char;
		   sups:string[2];
		   l,b,d,e:real;
		   loads:array[1..10] of load;
		   {
		   fm:ar4;
                   move to another datatype
		   r1,r2:real;
			   case boolean of
			   TRUE:(name: array[1..10] of integer);
			   FALSE:(sname:array[1..10] of char)
		    }
		 end;

matfiletyper = array[1..maxdata] of datatype;
matfiletype=^matfiletyper;
{atype=array[1..75,1..75] of integer;}
	link = ^joint;
	joint =
              record
		id:integer;
		idm:integer;
		x,y,z:real;
		rlud:array[1..4] of link;
		sup:char;			{sup type}
		u4,mt:ar4;
		level :integer;			{rotfacts}
		af:real;
    case sok:char of		{storey no:}
    'S':	(
		mm:array[1..4,1..6] of real;{rotation moment}
		max,mtotal:ar4;
		);
    'K','M':	(mx:ar4;		{rotation moment}
		sumfem,mr:real;		 	{mr is story shear}
		fem:ar4;	{fixed moments}
		ud:real;			{disfacts}
		pmx:ar4;
		pumd,pdmd:real;	{pre-rotation moment}
		umd:real;			{displacement moment}
		)
     end;
const
	supmap:string='';
	subj:integer=1;
	subk:integer=1;
	accuracy:real=0.001;
	fname:string='';
	profile:string[12]='';
	inpdir:string='A:\';
	outdir:string='A:\';
	outtype:array[1..3] of string[8]=('Detailed','Compact','Compact');
	inptype:string[12]='Single frame';
	interstatus:string[3]='On ';
	graphstatus:string[3]='On ';
	NM:integer=0;
	cdata:datatype=
		   (
		name:(0,0,0,0,0,0,0,0,0,0);
		   dir:'R';
		   sups:'CC';
		   l:0.0;
		   b:0.0;
		   d:0.0;
		   e:0.0;
		   loads:
(
(ldir:'D'; weild:'L'; loadtype:'.'; w1:0.0; w2:0.0; pos1:0.0; pos2:0.0),
(ldir:'D'; weild:'L'; loadtype:'.'; w1:0.0; w2:0.0; pos1:0.0; pos2:0.0),
(ldir:'D'; weild:'L'; loadtype:'.'; w1:0.0; w2:0.0; pos1:0.0; pos2:0.0),
(ldir:'D'; weild:'L'; loadtype:'.'; w1:0.0; w2:0.0; pos1:0.0; pos2:0.0),
(ldir:'D'; weild:'L'; loadtype:'.'; w1:0.0; w2:0.0; pos1:0.0; pos2:0.0),
(ldir:'D'; weild:'L'; loadtype:'.'; w1:0.0; w2:0.0; pos1:0.0; pos2:0.0),
(ldir:'D'; weild:'L'; loadtype:'.'; w1:0.0; w2:0.0; pos1:0.0; pos2:0.0),
(ldir:'D'; weild:'L'; loadtype:'.'; w1:0.0; w2:0.0; pos1:0.0; pos2:0.0),
(ldir:'D'; weild:'L'; loadtype:'.'; w1:0.0; w2:0.0; pos1:0.0; pos2:0.0),
(ldir:'D'; weild:'L'; loadtype:'.'; w1:0.0; w2:0.0; pos1:0.0; pos2:0.0))
{		   fm:(0,0,0,0);
		   r1:0.0;
		   r2:0.0;
}
		);
	hr=5.0;	{ Standardized column height }
	TMN=10;
var
	NJ:integer;
	idp:array[1..500] of link;
	heap:^integer;
	hpx,hpy,hpz:real;
	data:datatype;
	soker:char;
	loadno:integer;
	point:link;
	first,over :boolean;
	levelmat:array[1..25,1..25]of integer;
	maxlevel,minlevel:integer;
        datano:integer;
	DM:matfiletype;
	pathset,backset:   jointset;
	skip:string;
	root:array[1..250]of integer;
	menustart:integer;
	menualt:boolean;
	positn:integer;
	loadmat:array[1..10,1..10] of integer;
	hpoint:link;
	leftmost,rightmost:link; {# avoid -use hpoint}

FUNCTION  final(FEM,Mab,Mba,md:real;sup:char):real;
PROCEDURE pro1(scode:char);
PROCEDURE delete_data;
PROCEDURE modify_data;
PROCEDURE copy_data;
PROCEDURE display_data;
PROCEDURE list_data(fname:string);
PROCEDURE bendmax(var bmdfile,sfdfile:text;
	dgm:boolean;j1,j2:integer;nemo1,nemo2:real;var maxpo,max,contra1,contra2,sfl,sfr:real);
PROCEDURE disfacts;
PROCEDURE selectread(var datano,loadno,fieldno:integer);
PROCEDURE disprec(var datano:integer;HOT:char);
PROCEDURE refreshmenu(choice:integer);
PROCEDURE makemenu;
PROCEDURE readname(prompt:string);
PROCEDURE distribute(var point:link;var maxerr:real);
PROCEDURE file2mem;
PROCEDURE writemat(var DM:matfiletype;data:datatype);
FUNCTION  eofmat(DM:matfiletype):boolean;
PROCEDURE resetmat(DM:matfiletype);
PROCEDURE readmat(DM:matfiletype;var data:datatype);
FUNCTION  dirname(dir:char):string;
FUNCTION  supname(sup:char):string;
PROCEDURE take(x,y:integer);
PROCEDURE display(var f:text;datano:integer;pause:boolean);
PROCEDURE readinput;
PROCEDURE add2set(var x:jointset;y:integer);
FUNCTION  member(y:jointset;x:integer):boolean;
PROCEDURE init;
PROCEDURE make(var idx:integer;hpz:real);
PROCEDURE search(jt:integer);
PROCEDURE connect(var point1,point2:link);
PROCEDURE back;
PROCEDURE iterate;
FUNCTION  m:real;
PROCEDURE change(var x,y:real);
PROCEDURE fems(j1,j2,loadno:integer;var fem1,fem2:real);
PROCEDURE reaction(j1,j2,loadno:integer;var react1,react2:real);
PROCEDURE tot_fems(j1,j2:integer;var sumfem1,sumfem2:real);
PROCEDURE tot_react(j1,j2:integer;var sumr1,sumr2:real);
PROCEDURE marklevel;
FUNCTION  stiff:real;
PROCEDURE rotfacts;
PROCEDURE markfems;
PROCEDURE err(var fresh,old,maxerr:real);
PROCEDURE makeframe(hpx,hpy,hpz:real);
PROCEDURE disfact;     {SUB}
PROCEDURE save_data(fname:string);


IMPLEMENTATION
var
	zp:byte;
	point1,point2:link;
	i,j,k,q,p:integer;
	{	q = storey number   }
	{	p = position of column in a storey }
	fieldno:integer;
function jzp(zp:byte):byte;
begin
case zp of
	1,3:jzp:=1;
	2,4:jzp:=2;
	end;
end;

PROCEDURE file2mem;
begin
{
datano:=1;
reset(datafile);
while not eof(datafile) do
      begin
           read(datafile,data);
	   DM^[datano]:=data;
           datano:=datano+1;
      end;
DM^[datano].name[1]:=0;
DM^[datano].name[2]:=0;
}
end;

PROCEDURE writemat(var DM:matfiletype;data:datatype);
begin
DM^[datano]:=data;
datano:=datano+1;
end;

FUNCTION eofmat(DM:matfiletype):boolean;
begin
if  (DM^[datano].name[1]=0) and (DM^[datano].name[2]=0)
    then
	eofmat:=TRUE
    else
	eofmat:=FALSE;
end;

PROCEDURE resetmat(DM:matfiletype);
begin
datano:=1;
end;

PROCEDURE readmat(DM:matfiletype;var data:datatype);
begin
if datano>maxdata then
			begin
			msg('No of elements exceeds limit');
			aborted:=TRUE;
			exit;
			end;
data:=DM^[datano];
datano:=datano+1;
end;

PROCEDURE take(x,y:integer);
begin
resetmat(DM);
repeat
readmat(DM,data);
until ((data.name[1]=x) and (data.name[2]=y))
      or ((data.name[1]=y) and (data.name[2]=x));
end;


PROCEDURE refreshmenu(choice:integer);
var tempcode:char;
    tempchoice:integer;
begin
end;

PROCEDURE makemenu;
var
	i:integer;
begin
for i:=1 to NM do
	menus^[i]:=' '+strint(DM^[i].name[1],3)
				+strint(DM^[i].name[2],3)+'   ';
for i:=NM+1 to 50 do menus^[i]:=fixlength('',10,LEFT);
end;

FUNCTION dirname(dir:char):string;
begin
case dir of
	'R'	:dirname:='Right';
	'L'	:dirname:='Left';
	'U'	:dirname:='Up';
	'D'	:dirname:='Down';
	'C'	:dirname:='Clock';
	'A'     :dirname:='A-Clock';
	'P'	:dirname:='Positive';
	'N'	:dirname:='Negetive';
	else
		 dirname:=' ';
	end;
end;

FUNCTION supname(sup:char):string;
begin
case sup of
	'R'	:supname:='Rigid';
	'C'	:supname:='Continuous';
	'H'	:supname:='Hinged';
	'F'	:supname:='Free';
	else
		supname:=' ';
end;
end;

procedure dispstat;
begin
	windows(wglob,nocls);
	vs(60,2,'Rec No: '+p0i(datano,3)+'/'+p0i(NM,3),norm);
end;

PROCEDURE display(var f:text;datano:integer;pause:boolean);
const
	s:string[10]='      ';
var
	tx,ty:integer;
        sup:char;
begin
windows(winp,cls);
window(4,3,52,24);
clrscr;
data:=DM^[datano];
with data do
	begin
writeln(f);
writeln(f,'MEMBER NAME               :  ',name[1],' - ',name[2]);
writeln(f);
writeln(f,'Direction                 :  ',dirname(dir));
	if (dir='R') or (dir='U')
			then
				sup:=sups[1]
			else
				sup:=sups[2];
writeln(f,'Type of Support ',strint(name[1],3),'       :  ',supname(sup));
		if (dir='R') or (dir='U')
			then
				sup:=sups[2]
			else
				sup:=sups[1];
writeln(f,'Type of Support ',strint(name[2],3),'       :  ',supname(sup));
writeln(f,'Length of Member          :  ',justify(l,10,3,LEFT));
writeln(f,'Breadth of Member         :  ',justify(b,10,3,LEFT));
writeln(f,'Depth of Member           :  ',justify(d,10,3,LEFT));
writeln(f);
loadno:=0;
repeat
loadno:=loadno+1;
with loads[loadno] do
begin
if loadtype<>'.' then
begin
writeln(f,'Load  ',loadno);
write(f,s,'Loadtype            :  ',loadtype);
if soker='S' then
		case weild of
			'D': writeln(f,' Dead');
			'L': writeln(f,' Live');
			'W': writeln(f,' Wind');
			'E': writeln(f,' E.Quake');
			end
		else
			writeln(f);
case loadtype of
 'C'	:
	begin
writeln(f,s,'Magnitude           :  ',justify(w,10,3,LEFT));
writeln(f,s,'Position            :  ',justify(posn,10,3,LEFT));
writeln(f,s,'Direction           :  ',dirname(ldir));
	end;

'V'	:
	begin
writeln(f,s,'Starting intensity  :  ',justify(w1,10,3,LEFT));
writeln(f,s,'Ending intensity    :  ',justify(w2,10,3,LEFT));
writeln(f,s,'From                :  ',justify(pos1,10,3,LEFT));
writeln(f,s,'To                  :  ',justify(pos2,10,3,LEFT));
writeln(f,s,'Direction           :  ',dirname(ldir));
	end;

 'U'	:
	begin
writeln(f,s,'Intensity           :  ',justify(w1,10,3,LEFT));
writeln(f,s,'Direction           :  ',dirname(ldir));
		w2:=w1;
		pos1:=0;
		pos2:=data.l;
	end;

'P'	:
	begin
writeln(f,s,'Maximum intensity   :  ',justify(wmax,10,3,LEFT));
writeln(f,s,'Direction           :  ',dirname(ldir));
	end;

'M'	:begin
writeln(f,s,'Magnitude of moment :  ',justify(m,10,3,LEFT));
writeln(f,s,'Position            :  ',justify(mpos,10,3,LEFT));
writeln(f,s,'Direction           :  ',dirname(ldir));
	end;

'D'	:
	begin
writeln(f,s,'Settlement          :  ',justify(d,10,3,LEFT));
writeln(f,s,'Direction           :  ',dirname(ldir));
	end;
else
	 begin
	loadtype:='.';
	 end;
end;
tx:=wherex;
ty:=wherey;
if pause and (loadno<10) and (not odd(loadno)) and (loads[loadno+1].loadtype<>'.') then
	begin
	msg('<HOLD>');
	waitfor(any);
	end
	else
		msg('');
window(4,3,52,24);
gotoxy(tx,ty);
end;
end;
until (loads[loadno].loadtype='.') or (loadno>=10);
writeln(f);
end;
end;

PROCEDURE disprec(var datano:integer;HOT:char);
var
	lsup,rsup:char;
	loadno:integer;
	tms:array[0..9] of string[10];
	outs:array[1..7] of string[50];
begin
if menualt then
	for i:=1 to 125 do menus^[i]:='          ';
data:=DM^[datano];
window(5,3,50,10);
with data do
begin
if hot in ['H','B'] then
	begin
	if (dir='R') or (dir='U')
			then
				begin
				lsup:=sups[1];
				rsup:=sups[2]
				end
			else
				begin
				lsup:=sups[2];
				rsup:=sups[1];
				end;
	tms[1]:=strint(name[1],1)+' - '+strint(name[2],1);
	tms[2]:=dirname(data.dir);
	tms[3]:=supname(lsup);
	tms[4]:=supname(rsup);
	tms[5]:=justify(data.l,10,3,LEFT);
	tms[6]:=justify(data.b,10,3,LEFT);
	tms[7]:=justify(data.d,10,3,LEFT);
outs[1]:='Member Name               :  ';
outs[2]:='Direction                 :  ';
outs[3]:= fixlength('Type of Support '+strint(name[1],1),26,LEFT)+':  ';
outs[4]:= fixlength('Type of Support '+strint(name[2],1),26,LEFT)+':  ';
outs[5]:='Length of Member          :  ';
outs[6]:='Breadth of Member         :  ';
outs[7]:='Depth of Member           :  ';
for i:=1 to 7 do
		begin
		write(outs[i],tms[i]);
		fastwrite(#32,45-wherex,Norm);
		writeln;
		end;
if menualt then
	begin
	menus^[71]:=tms[1];
	menus^[72]:=tms[2];
	menus^[73]:=tms[3];
	menus^[74]:=tms[4];
	menus^[75]:=tms[5];
	menus^[76]:=tms[6];
	menus^[77]:=tms[7];
	end;
    end;
if hot in ['T','B'] then
begin
	box(5,10,76,20,single,0);
	window(6,11,75,19);
loadno:=1;
while (loads[loadno].loadtype<>'.') and (loadno<10) do
	begin
with loads[loadno] do
	begin
	gotoxy(1,loadno);
loadtype:=upcase(loadtype);
if loadtype in ['U','V','C','M','P','S','D'] then
	begin
		tms[0]:=fixlength('Load  '+strint(loadno,1),10,LEFT);
		tms[1]:=fixlength(loadtype,10,LEFT);
		tms[2]:=fixlength(dirname(ldir),10,LEFT);
		for i:=4 to 6 do tms[i]:='          ';
	end;
case loadtype of
 'C'	:
	begin
	tms[3]:=strreal(w,10,3);
	tms[4]:=strreal(posn,10,3);
       end;

'V'	:
	begin
	tms[3]:=strreal(w1,10,3);
	tms[4]:=strreal(w2,10,3);
	tms[5]:=strreal(pos1,10,3);
	tms[6]:=strreal(pos2,10,3);
	end;
 'U'	:
	begin
	tms[3]:=strreal(w1,10,3);
		w2:=w1;
		pos1:=0;
		pos2:=data.l;
	end;
'P'	:
	begin
	tms[3]:=strreal(wmax,10,3);
	end;
'M'	:begin
		tms[3]:=strreal(m,10,3);
		tms[4]:=strreal(mpos,10,3);
	end;
'D'	:
	begin
	tms[3]:=strreal(d,10,3);
	end;
else
	 begin
	 msg('Loadtype "'+loadtype+'" not recognized. Press ESC.');
	 waitfor(ESC);
			loadtype:='.';
			DM^[datano].loads[loadno].loadtype:='.';
			loadno:=loadno-1;
	 msg('');
	 end;
end;
if loadtype in ['U','V','C','M','P','S','D'] then
	begin
	for i:=0 to 6 do
			begin
			if menualt then
				menus^[loadno+i*9]:=tms[i];
			write(tms[i]);
			end;
	end;
end;
loadno:=loadno+1;
end;
	window(6,11+loadno-1,75,19);
	clrscr;
end;
end;
end;

PROCEDURE readname(prompt:string);
var
	s,s1,s2:string;
	error1,error2:integer;
begin
if aborted then exit;
s:='';
repeat
	readstr(1,prompt,s);
	if s[1]='E'
	     then
		begin
		data.name[1]:=0;
		data.name[2]:=0;
		exit;
		end;
	s1:=copy(s,1,pos('-',s)-1);
	s2:=copy(s,pos('-',s)+1,length(s)-pos('-',s));
	val(s1,data.name[1],error1);
	val(s2,data.name[2],error2);
if not aborted and ((error1<>0) or (error2<>0)) then
		msg('Naming rule not satisfied');
until ((error1=0) and (error2=0)) or aborted;
end;

procedure boxread(hp:integer;prompt,ALT:string;x1,y1,x2,y2:integer;var c:char;var excode:char);
label 100,stop;
var
	screen:image;
	s:string;
	error:integer;
begin
s:=c;
if aborted then exit;
if (inpname='CON') or (inpname='') then
		begin
		readchar(1,prompt,c);
		for i:=1 to length(ALT) do
				if c=ALT[i] then
					begin
					choice[7]:=i;
					goto 100;
					end;
		end
		else
		begin
		resetcrt;
		KSread(1,inpname,s,excode);
		c:=s[1];
		exit;
		end;
put(screen);
box(x1,y1,x2,y2,single,0);
scode[7]:=#0;
choice[7]:=1;
boxpix(hp,menus,ALT,x1+1,y1+1,x2-1,y2-1,91,choice[7],scode[7],1);
if scode[7]=ESC then
	begin
	excode:=ESC;
	goto stop;
	end;
c:=alt[choice[7]];
get(screen);
if aborted then exit;
100:
windows(winp,nocls);
gotoxy(length(prompt),inL);
write(menus^[90+choice[7]]);
STOP:
end;

procedure readdir(prompt:string;var dir:char);
begin
if aborted then exit;
menus^[91]:=' Right    ';
menus^[92]:=' Left     ';
menus^[93]:=' Up       ';
menus^[94]:=' Down     ';
dir:='?';
boxread(1,prompt,'RLUD',18,5,29,10,dir,excode);
end;

procedure readsup(prompt:string;var sup:char);
begin
if aborted then exit;
menus^[91]:=' Continuous  ';
menus^[92]:=' Rigid       ';
menus^[93]:=' Free        ';
menus^[94]:=' Hinged      ';
sup:='?';
boxread(1,prompt,'CRFH',18,5,32,10,sup,excode);
end;

procedure readloadtype(prompt:string;var loadtype,weild:char);
begin
if aborted then exit;
menus^[91]:=' Uniform       ';
menus^[92]:=' Concentrated  ';
menus^[93]:=' Variable      ';
menus^[94]:=' Parabolic     ';
menus^[95]:=' Moment        ';
menus^[96]:=' Displacement  ';
menus^[97]:=' End of loads  ';
loadtype:='?';
boxread(1,prompt,'UCVPMDE',18,5,34,13,loadtype,excode);
if loadtype='E' then loadtype:='.';
if (soker='S') and (loadtype<>'.') then
	begin
	if aborted then exit;
	menus^[91]:=' Dead Load     ';
	menus^[92]:=' Live Load     ';
	menus^[93]:=' Wind Load     ';
	menus^[94]:=' E.Quake Load  ';
	weild:='?';
	boxread(1,'Nature of load ? ','DLWE',18,5,34,10,weild,excode);
	end;
end;

procedure readcadir(prompt:string;var dir:char);
begin
if aborted then exit;
	menus^[91]:=' Clockwise       ';
	menus^[92]:=' Anticlockwise   ';
	boxread(1,prompt,'CA',18,10,36,13,dir,excode);
end;

procedure readpndir(prompt:string;var dir:char);
begin
if aborted then exit;
menus^[91]:=' Positive        ';
menus^[92]:=' Negetive        ';
boxread(1,prompt,'PN',18,10,36,13,dir,excode);
end;


PROCEDURE readinput;
label 100;
var
	ch,x,y,blank,lsup,rsup:char;
	s:string;
begin
aborted:=FALSE;
trap:=TRUE;
repeat
with data do
begin
readname('Member name ( joint1 - joint2 ) ? ');
if aborted or ((name[1]=0) and (name[2]=0)) then goto 100;
	readdir('Direction of member ( joint1 -> joint2 ) ?  ',dir);
	readsup('Support Condition of '+strint(name[1],3)+' ? ',lsup);
	readsup('Support Condition of '+strint(name[2],3)+' ? ',rsup);
	readreal(2,'Length of member  :  ',l);
	readreal(3,'Breadth   :  ',b);
	readreal(4,'Depth   :  ',d);
	sups:='CC';
	if (dir='R') or (dir='U')
			then
				sups:=lsup+rsup
			else
				sups:=rsup+lsup;
	name[9]:=ord(lsup);
	name[10]:=ord(rsup);
loadno:=0;
repeat
	loadno:=loadno+1;
with data.loads[loadno] do
	begin
readloadtype('LoadType  ?  ',loadtype,weild);
case loadtype of
'C' :	begin
		readreal(5,'Magnitude    ?  ',w);
		readreal(6,'Position     ?  ',posn);
		readdir('Direction    ?  ',ldir);
	end;
'V' :   begin
		readreal(8,'Starting intensity   ?  ',w1);
		readreal(9,'Ending intensity   ?  ',w2);
		readreal(10,'From   ?  ',pos1);
		readreal(11,'To  ?  ',pos2);
		readdir('Direction  ?  ',ldir);
	end;
'U' :	begin
		readreal(13,'Intensity    ?  ',w1);
		readdir('Direction    ?  ',ldir);
		w2:=w1;
		pos1:=0;
		pos2:=data.l;
	end;
'P' :   begin
		readreal(15,'Maximum intensity  ?  ',wmax);
		readdir('Direction  ?  ',ldir);
	end;
'M' :   begin
		readreal(17,'Magnitude  ?  ',m);
		readreal(18,'Position   ?  ',mpos);
		readcadir('Direction  ? ',ldir);
	end;
'D' :   begin
	readreal(20,'Magnitude of displacement  ?   ',d);
	readpndir('Direction  ? ',ldir);
	end;
else
	if (loadtype<>'.') then
	msg(' Error : Illegal loadtype "'+loadtype+'" ');
end;
end;
until (loads[loadno].loadtype='.') or (loadno>=10) or aborted;
writemat(DM,data);
inc(NM);
end;
until aborted;
100:
	data.name[1]:=0;
	data.name[2]:=0;
	writemat(DM,data);
trap:=FALSE;
if (inpname<>'CON') and (inpname<>'') then close(inp);
end;

PROCEDURE selectread(var datano,loadno,fieldno:integer);
var
	ch,x,y,blank,sup:char;
	s,s1,s2:string;
	target:integer;
begin
data:=DM^[datano];
with data do
case fieldno of
1: 	readname('Name of Member ? ');
2:	readchar(21,'Direction of member   ?  ',dir);
3:	begin
	readchar(22,'Support Condition of '+strint(name[1],3)+' ? ',sup);
		if (dir='R') or (dir='U')
			then
				sups[1]:=sup
			else
				sups[2]:=sup;
	name[9]:=ord(sup);
	end;
4:	begin
	readchar(23,'Support Condition of '+strint(name[2],3)+' ? ',sup);
		if (dir='R') or (dir='U')
			then
				sups[2]:=sup
			else
				sups[1]:=sup;
	name[10]:=ord(sup);
	end;
5:	readreal(1,'Length of member ? ',l);
6:	readreal(1,'Breadth ? ',b);
7:	readreal(1,'Depth ? ',d);
8,9,10,11,12,13,14:
with data.loads[loadno] do
begin
if fieldno=8 then
	begin
	readchar(27,'',resp);
	case resp of
	'C':    begin
		readint(28,'',target);
		if (target>0) and (target<11) then
				loads[target]:=loads[loadno];
		end;
	'D':	loads[loadno].loadtype:='.';
	end;
	end;

if fieldno=9 then readchar(28,'LoadType  ? ',loadtype);
if fieldno=10 then readchar(30,'Direction    ? ',ldir);
case loadtype of
'C' :	if fieldno=11 then
			readreal(31,'Magnitude ? ',w)
	else
	if fieldno=12 then
			readreal(32,'Position ? ',posn);
'V' :   case fieldno of
		11:	readreal(33,'Starting Intensity ? ',w1);
		12:	readreal(34,'Ending Intensity ? ',w2);
		13:	readreal(35,'Starting position ? ',pos1);
		14:	readreal(35,'Ending position ? ',pos2);
		end;
'U' :	if fieldno=11 then
		begin
		readreal(37,'Intensity ? ',w1);
		w2:=w1;
		pos1:=0;
		pos2:=data.l;
		end;
'P' :
	if fieldno=11 then
		readreal(38,'Maximum intensity  ? ',wmax);
'M' :   if fieldno=11 then
		readreal(39,'Magnitude  ? ',m)
	else
	if fieldno=12 then
		readreal(40,'Position   ? ',mpos)
	else
	if fieldno=13 then
		readchar(1,'Direction ? ',ldir);
'D' :   if fieldno=11 then
			readreal(1,'Magnitude of displacement  ? ',d);
end;
end;
end;
DM^[datano]:=data;
end;

PROCEDURE add2set(var x:jointset;y:integer);
begin
x:=x+[y];
end;

FUNCTION member(y:jointset;x:integer):boolean; {#AVOID}
var
	i:integer;
begin
if (x>255) or (x<0) then
		begin
		msg('Range check error'+#7);
		exit;
		end;
if x in y
	then
	     member:=TRUE
	else
	     member:=FALSE;
end;

PROCEDURE init;
begin
point:=hpoint;
fillchar(root,sizeof(root),0);
positn:=1;
root[positn]:=point^.id;
backset:=[];
over:=FALSE;
end;

PROCEDURE make(var idx:integer;hpz:real);
begin
new(point);
inc(NJ);
idp[idx]:=point;
with point^ do
	begin
	for zp:=1 to 4 do rlud[zp]:=nil;
	id:=idx;
	z:=hpz;
	sok:=soker;
	if sok='K' then
		begin
		fillchar(mx,sizeof(mx),0);
		fillchar(pmx,sizeof(pmx),0);
		umd:=0;
		pumd:=0;
		end;
	if soker='M' then
			begin
			if idx=data.name[1] then supmap[idx]:=chr(data.name[9])
			else if idx=data.name[2] then supmap[idx]:=chr(data.name[10])
			else halt;
			end;
        if data.name[1]=idx then
                                point^.sup:=data.sups[1]
                            else
                                point^.sup:=data.sups[2];
	af:=0.0;
	end;
end;

PROCEDURE search(jt:integer);
var
	y:integer;
	FLAG:boolean;
	j,k:integer;
begin
{
point:=hpoint;
y:=0;
repeat
	y:=y+1;
until ( patharray^[y,1]=jt);

k:=0;
repeat
	k:=k+1;
until ( patharray^[y,k]=hpoint^.id );
for j:=k-1 downto 1 do
begin
flag:=FALSE;
zp:=0;
repeat
inc(zp);
if (point^.rlud[zp]<>nil) and (point^.rlud[zp]^.id=patharray^[y,j])		then
		begin
		point:=point^.rlud[zp];
		flag:=TRUE;
		end;
until (flag=TRUE) or (zp=4);
end;
}
point:=idp[jt];
if point^.id<>jt then     {% DEBUG}
		begin
			msg('Search for '+chr(jt)+' Failed. Press ESC');
			waitfor(ESC);
		end;
end;


PROCEDURE connect(var point1,point2:link);
begin
case data.dir of
'R' :begin
	point1^.rlud[1]:=point2;
	point2^.rlud[2]:=point1;
	if member(pathset,point1^.id) and not member(pathset,point2^.id)
		then
			begin
			point2^.level:=point1^.level;
			point2^.x:=point1^.x+data.l;
			point2^.y:=point1^.y;
			end;

	if member(pathset,point2^.id) and not member(pathset,point1^.id)
		then
			begin
			point1^.level:=point2^.level;
			point1^.x:=point2^.x-data.l;
			point1^.y:=point2^.y;
			end;

     end;
'L' :begin
	point1^.rlud[2]:=point2;
	point2^.rlud[1]:=point1;
	if member(pathset,point1^.id) and not member(pathset,point2^.id)
		then
			begin
			point2^.level:=point1^.level;
			point2^.x:=point1^.x-data.l;
			point2^.y:=point1^.y;
			end;

	if member(pathset,point2^.id) and not member(pathset,point1^.id)
		then
			begin
			point1^.level:=point2^.level;
			point1^.x:=point2^.x+data.l;
			point1^.y:=point2^.y;
			end;

     end;
'U' :begin
	point1^.rlud[3]:=point2;
	point2^.rlud[4]:=point1;
	if member(pathset,point1^.id) and not member(pathset,point2^.id)
	     then
		begin
		point2^.level:=point1^.level+1;
		point2^.x:=point1^.x;
		point2^.y:=point1^.y+data.l;

		if (maxlevel<point2^.level) then maxlevel:=point2^.level;

		end
	     else
	if member(pathset,point2^.id) and not member(pathset,point1^.id)
	     then
		begin
		point1^.level:=point2^.level-1;
		point1^.x:=point2^.x;
		point1^.y:=point2^.y-data.l;

		if (minlevel>point1^.level) then minlevel:=point1^.level;
		end;
     end;
'D' :begin
	point1^.rlud[4]:=point2;
	point2^.rlud[3]:=point1;
	if member(pathset,point1^.id) and not member(pathset,point2^.id)
	   then
		begin
		point2^.level:=point1^.level-1;
		point2^.x:=point1^.x;
		point2^.y:=point1^.y-data.l;
		if (minlevel>point2^.level) then minlevel:=point2^.level;
		end
	   else
	if member(pathset,point2^.id) and not member(pathset,point1^.id)
	   then
		begin
		point1^.level:=point2^.level+1;
		point1^.x:=point2^.x;
		point1^.y:=point2^.y+data.l;
		if (maxlevel<point1^.level) then maxlevel:=point1^.level;
		end;
	end
    end;
{
writeln(out,'LINE ');
writeln(out,strreal(point1^.x,10,3),',',strreal(point1^.y,10,3));
writeln(out,strreal(point2^.x,10,3),',',strreal(point2^.y,10,3));
line(adpx(point1^.x),adpy(point1^.y),adpx(point2^.x),adpy(point2^.y));
}
end;

PROCEDURE cstuck(var stuck:boolean);
begin
zp:=0;
stuck:=TRUE;
repeat
inc(zp);
if (not member(backset,point^.rlud[zp]^.id) and (point^.rlud[zp]<>nil))
	then
		stuck:=FALSE;
until (zp=4) or (stuck=FALSE);
end;

PROCEDURE back;
var
	flag,stuck:boolean;
	i:integer;

begin
repeat
zp:=0;
flag:=FALSE;
repeat
inc(zp);
if point^.rlud[zp]^.id=root[positn-1] then
	begin
	point:=point^.rlud[zp];
	flag:=TRUE;
	end;
until (zp=4) or (flag=TRUE);
positn:=positn-1;
cstuck(stuck);
until (stuck=false) or (positn<=1);
if positn<1 then
	begin
	msg('Critical Error.Press ESC');
	waitfor(ESC);
        halt;
	end;
end;

PROCEDURE iterate;
var
	flag,stuck:boolean;
begin
if over=TRUE
    then
	init
    else
begin
cstuck(stuck);
if stuck then
		back;
zp:=0;
flag:=TRUE;
repeat
inc(zp);
if (not member(backset,point^.rlud[zp]^.id)) and (point^.rlud[zp]<>nil) then
		begin
		point:=point^.rlud[zp];
		positn:=positn+1;
		root[positn]:=point^.id;
		flag:=false;
		end
until (zp=4) or (flag=FALSE);
if flag=TRUE then msg('Error');
end;
add2set(backset,point^.id);
if backset=pathset then over:=TRUE;
end;


FUNCTION m:real;
begin
with data do
begin
	if (sups[1] in ['C','R']) and (sups[2] in ['C','R'])
		then m:=1
	else if (sups[1] in ['C','R'])	and (sups[2]='H')
		then m:=3/4
	else if (sups[1]='H') and (sups[2] in ['C','R'])
		then m:=3/4
	else m:=0.0;
end;
end;


PROCEDURE change(var x,y:real);
var
	t:real;
begin
	t:=x;
	x:=y;
	y:=t;
end;

PROCEDURE fems(j1,j2,loadno:integer;var fem1,fem2:real);
var
	lf1,lf2,lf3,lf4,lf5:real;
	rf1,rf2,rf3,rf4,rf5:real;
	a,b:real;
	changed:boolean;
begin
fem1:=0.0;
fem2:=0.0;
take(j1,j2);
with data do
	begin
	if (sups[1]<>'F')  and (sups[2]<>'F') then begin
	with loads[loadno] do begin
	case loadtype of
		'C':	begin
			a:=posn/l;
			fem1:=-w*a*(1-a)*(1-a)*l;
			fem2:=w*(1-a)*a*a*l;
			end;

		'V','U':begin
			a:=pos1/l;
			b:=pos2/l;
			lf1:=-b*b*(6-8*b+3*b*b)*w1*l/12;
			lf2:=(a*a*(6-8*a+3*a*a)*w1*l/12);
			rf1:=b*b*b*(4-3*b)*w1*l/12;
			rf2:=-a*a*a*(4-3*a)*w1*l/12;
			if eq(w1,w2) then
				begin
				lf3:=0;
				lf4:=0;
				lf5:=0;
				rf3:=0;
				rf4:=0;
				rf5:=0;
				end
			else if w1<>w2 then
			begin
			changed:=false;
			if w1>w2 then
				begin
				change(w1,w2);
				changed:=true;
				a:=1-b;
				b:=1-a;
				end;
			a:=1-a;
			b:=1-b;
			lf3:=-a*a*(5-3*a)*(w2-w1)*a*a*l/((a-b)*60);
			lf4:=b*b*(5-3*b)*(w2-w1)*b*b*l/((a-b)*60);
			lf5:=b*b*(4-3*b)*(w2-w1)*b*l/12;
			rf3:=a*(10-10*a+3*a*a)*(w2-w1)*a*a*l/((a-b)*60);
			rf4:=-b*(10-10*b+3*b*b)*(w2-w1)*b*b*l/((a-b)*60);
			rf5:=-b*(6-8*b+3*b*b)*(w2-w1)*b*l/12;
			if changed then
				begin
				change(lf3,rf3);
				change(lf4,rf4);
				change(lf5,rf5);
				lf3:=-lf3;
				lf4:=-lf4;
				lf5:=-lf5;
				rf3:=-rf3;
				rf4:=-rf4;
				rf5:=-rf5;
				end;
			end;
			fem1:=(lf1+lf2+lf3+lf4+lf5)*l;
			fem2:=(rf1+rf2+rf3+rf4+rf5)*l;
			end;

		'P'	:begin
			fem1:=-wmax*l/10;
			fem2:=wmax*l/10;
			end;
		'M'	:begin
                        {
                        fem1:=m;#changed to do assignment
                        fem2:=m;

                        fem1:=-m*(l-mpos)*(2-3*(l-mpos)/l)/l;
			fem2:=-m*mpos*(2-3*mpos/l)/l;
			}
                        end;
		end;
	end;
	end
	else if (sups[1]='F') or (sups[2]='F') then
	begin
	with loads[loadno] do begin
	case loadtype of
		'C':	begin
			a:=posn;
			fem1:=-w*a;
			fem2:=0.0;
			end;
		'V','U':begin
			a:=pos1;
			b:=pos2;
			if w1>=w2 then
		fem1:=-w2*(b-a)*(b+a)/2+(w1-w2)*(b-a)/2*(a+(b-a)/3)
			else
			if w1<w2 then
		fem1:=-w1*(b-a)*(b+a)/2+(w2-w1)*(b-a)/2*(a+2/3*(b-a));
			fem2:=0.0;
			end;
		'P'	:begin
			fem1:=-2/3*wmax*l/2;
			fem2:=0.0;
			end;
		'M'	:begin
			fem1:=-m;
			fem2:=0.0;
			end;
		end;
	if sups[1]='F' then change(fem1,fem2);
	end;
end;

with data.loads[loadno] do
if soker='M' then                              { # abs() ??? }
		begin
		if ldir in ['R','D','C'] then
					fem1:=-abs(fem1)
				else
					fem1:=abs(fem1);
		if ldir in ['R','D','C'] then fem2:=abs(fem2)
				else
					fem2:=-abs(fem2);
		end
		else
			if not(ldir in ['R','D','C']) then
				begin
				fem1:=-fem1;
				fem2:=-fem2;
				end;
end;
end;


PROCEDURE tot_fems(j1,j2:integer;var sumfem1,sumfem2:real);
var
	fem1,fem2:real;
	c:char;
	hj:integer;
begin
sumfem1:=0.0;
sumfem2:=0.0;
take(j1,j2);
loadno:=1;
while ((data.loads[loadno].loadtype<>'.') and                {#}
  ((soker in ['K','M']) or ((soker='S') and (loadmat[subj,subk]=1) or (data.loads[loadno].weild='D')))) do
with data.loads[loadno] do
	begin
		fems(j1,j2,loadno,fem1,fem2);
		sumfem1:=sumfem1+fem1;
		sumfem2:=sumfem2+fem2;
		loadno:=loadno+1;
	end;
{
writeln('Mem : ',j1,'-',j2,' fems > ',sumfem1:6:3,sumfem2:6:3);
waitfor(SPACE);
}
end;

PROCEDURE reaction(j1,j2,loadno:integer;var react1,react2:real);
var l:real;

{  REACTIONS FOR A PARTICULAR LOAD IN THE MEMBER J1-J2 }
{  MEMLOAD IS THE TOTAL LOAD ACTING ON THE MEMBER ie. R1+R2 }
{  REACTIONS ARE +VE WHEN DIRECTION OF MEMBER IS RIGHT OR DOWN }
{  THE PROCEDURE HAS TO BE USED ITERATIVELY TO FIND TOTAL REACTION }

begin
take(j1,j2);
l:=data.l;
with data.loads[loadno] do begin
case loadtype of
'C'	:
	begin
	react1:=w*(l-posn)/l;
	react2:=-w*posn/l;
	end;
'V','U'	:                     { # CHECK FOR CORRECTNESS }
	begin
	if eq(w1,w2) then
		begin
		react1:=w1*(pos2-pos1)*(l-(pos2+pos1)/2)/l;
		react2:=-(w1*(pos2-pos1)*(pos1+pos2)/2)/l;
		end;
	if w1>w2 then
		begin
		react1:=(w1-w2)*(pos2-pos1)/2*(l-(pos1+(pos2-pos1)/3))/l;
		react2:=-(w1-w2)*(pos2-pos1)/2*(pos1+(pos2-pos1)/3)/l;
		react1:=react1+w2*(pos2-pos1)*(l-(pos1+pos2)/2)/l;
		react2:=react2-w2*(pos2-pos1)*(pos1+pos2)/2/l;
		end;
	if w2>w1 then
		begin
		react1:=(w2-w1)*(pos2-pos1)/2*(l-(pos1+(pos2-pos1)*2/3)/l);
		react2:=-(w2-w1)*(pos2-pos1)/2*(pos1+(pos2-pos1)*2/3)/l;
		react1:=react1+w1*(pos2-pos1)*(l-(pos2+pos1)/2)/l;
		react2:=react2-w1*(pos2-pos1)*(pos1+pos2)/2/l;
		end
	end;
'P'	:
	begin
		react1:=wmax*l*2/3*l/2;
		react2:=-wmax*l*2/3*l/2;
	end;
'M'	:
	begin
	react1:=-6*m*mpos*(l-mpos)/(l*l*l);
	react2:=-react1;
	end;
end;

with data.loads[loadno] do
if soker='M' then
		begin
		if data.dir in ['L','D']
			then
			   begin
				react1:=-react1;
				react2:=-react2;
			   end;
		if ldir in ['R','D','C'] then
					react1:=-abs(react1)
				else
					react1:=abs(react1);
		if ldir in ['R','D','C'] then react2:=-abs(react2)
				else
					react2:=abs(react2);
		end
		else
			if (ldir in ['R','D','C']) then
				begin

                                {# changed - > + for Jayadeep }
				react1:=+react1;

				react2:=-react2;
				end;


end;
end;

PROCEDURE tot_react(j1,j2:integer;var sumr1,sumr2:real);
var
	react1,react2:real;
begin
sumr1:=0.0;
sumr2:=0.0;
loadno:=1;
take(j1,j2);
while ((data.loads[loadno].loadtype<>'.') and
      ((soker in ['K','M']) or ((soker='S') and (loadmat[subj,subk]=1) or (data.loads[loadno].weild='D')))) do
with data.loads[loadno] do
begin
	reaction(j1,j2,loadno,react1,react2);
	sumr1:=sumr1+react1;
	sumr2:=sumr2+react2;
	inc(loadno);
end;
{
writeln('Mem : ',j1,'-',j2,' reactions > ',sumr1:6:3,sumr2:6:3);
waitfor(SPACE);
}
end;

PROCEDURE marklevel;
var
	xdist:array[1..25,1..25] of real;
	tx:real;
	ti,i:integer;

begin
fillchar(levelmat,sizeof(levelmat),0);
repeat
		iterate;
		q:=point^.level-minlevel+1;		{q is floorno:}
			p:=0;
			repeat
			p:=p+1;
			until levelmat[q,p]=0;
		levelmat[q,p]:=point^.id;
		xdist[q,p]:=point^.x;
until over;

for q:=1 to maxlevel-minlevel+1 do
	begin
	p:=1;
	while levelmat[q,p]<>0 do
		begin
		i:=p+1;
		while levelmat[q,i]<>0 do
			begin
			if (xdist[q,p]>xdist[q,i]) then
				begin
				tx:=xdist[q,p];
				xdist[q,p]:=xdist[q,i];
				xdist[q,i]:=tx;

				ti:=levelmat[q,p];
				levelmat[q,p]:=levelmat[q,i];
				levelmat[q,i]:=ti;
				end;
			inc(i);
			end;
		inc(p);
		end;
	end;
end;

FUNCTION stiff:real;
var mi :real;
begin
if eq(data.l,0) then
	begin
		msg('Division by zero.Press ESC.');
		aborted:=TRUE;
		exit;
	end;
stiff:=0.0;
with data do
	begin
	mi:=b*d*d*d*1e-12/12;       {# Original units assumed in metres }
	stiff:=m*mi/data.l;         {# division by 0 ? }
	end;
end;

PROCEDURE rotfacts;
var
	rfact:ar4;
	sumk:real;
begin
repeat
	iterate;
	fillchar(rfact,sizeof(rfact),0);
for zp:=1 to 4 do
begin
j:=jzp(zp);
	if (point^.rlud[zp]<>nil) then
		begin
			take(point^.id,point^.rlud[zp]^.id);
			if (data.sups[j]<>'R') then
                        	rfact[zp]:=stiff;
		end;
end;
sumk:=rfact[1]+rfact[2]+rfact[3]+rfact[4];
fillchar(point^.u4,sizeof(point^.u4),0);
for zp:=1 to 4 do
	if (point^.rlud[zp]<>nil) and (sumk<>0.0) then
				begin
                                point^.u4[zp]:=-0.5*rfact[zp]/sumk;
                                {
                                writeln(zp,' : ',point^.u4[zp]:6:3);
                                waitfor(SPACE);
                                }
                                end;

until over;
end;


PROCEDURE disfact;     {SUB}
var
	rfact:ar4;
	sumk:real;
begin
point:=leftmost;
repeat
fillchar(rfact,sizeof(rfact),0);
for zp:=1 to 4 do
begin
case zp of
	1,3:j:=1;
	2,4:j:=2;
	end;
if (point^.rlud[zp]<>nil) then
		begin
		take(point^.id,point^.rlud[zp]^.id);
			if (data.sups[j]<>'R') then rfact[zp]:=stiff;
		end;
end;
sumk:=rfact[1]+rfact[2]+rfact[3]+rfact[4];
fillchar(point^.u4,sizeof(point^.u4),0);
for zp:=1 to 4 do
	if (point^.rlud[zp]<>nil) and (sumk<>0.0) then
		point^.u4[zp]:=rfact[zp]/sumk;
point:=point^.rlud[1];
until point=nil;
end;

PROCEDURE markfems;
var
	tempfem:array[1..2] of real;
        k:integer;
begin
repeat
	iterate;
fillchar(point^.fem,sizeof(point^.fem),0);
for zp:=1 to 4 do
begin
case zp of
	1,3:begin j:=1; k:=2; end;
	2,4:begin j:=2; k:=1; end;
	end;

if (point^.rlud[zp]<>nil) then
			begin
			tot_fems(point^.id,point^.rlud[zp]^.id,tempfem[1],tempfem[2]);
			point^.fem[zp]:=tempfem[j];
                        {
                        writeln('**** ',point^.rlud[zp]^.sup);
                        }
                        if point^.rlud[zp]^.sup='H' then
                           begin
                           point^.fem[zp]:=point^.fem[zp]-tempfem[k]/2.0;
                           {
                           writeln('Reduced FEM used.');
                           }
                           end;
                        {
                        waitfor(SPACE);
			}
                        end;
end;
point^.sumfem:=point^.fem[1]+point^.fem[2]+point^.fem[3]+point^.fem[4];
{
writeln('Total FEM at ',point^.id,' = ',point^.sumfem:6:3);
waitfor(SPACE);
}
until over;
end;

PROCEDURE err(var fresh,old,maxerr:real);
var
	error:real;
begin
if not first then
	begin
		error:=abs(fresh-old);
		if error>maxerr then maxerr:=error;
	end;
old:=fresh;
end;


PROCEDURE addto(var skip:string;x:integer);
begin
insert(chr(x),skip,1);
end;

PROCEDURE delfrom(var skip:string;x:integer);
begin
delete(skip,pos(chr(x),skip),1);
end;

function inskip(skip:string;x:integer):boolean;
begin
if pos(chr(x),skip)<>0 then inskip:=TRUE else inskip:=FALSE;
end;

PROCEDURE initialize;
var i:integer;
begin;
	hpoint:=nil;
	q:=0;
	pathset:=[];
	backset:=[];
	skip:='';
	over:=TRUE;
	positn:=1;
	NJ:=0;
	for i:=1 to 500 do idp[i]:=NIL;
end;

PROCEDURE makeframe(hpx,hpy,hpz:real);
var
	complete,readed:boolean;
	n1,n2:integer;
begin
initialize;
i:=0;
init;
{StartGraphics;}
complete:=FALSE;			{initialisation}
repeat
inc(i);
resetmat(DM);
while (not eofmat(DM)) and (not complete)  do
begin
readed:=FALSE;
if (i=1)
      then
	  begin
	      readmat(DM,data);
	      n1:=data.name[1];
	      n2:=data.name[2];
	  end
       else  				 { READ SKIPPED RECORDS }
while not eofmat(DM) and not readed do
	  begin
		 readmat(DM,data);
		 n1:=data.name[1];
		 n2:=data.name[2];
		 if inskip(skip,n1)
		    and inskip(skip,n2)
			  then
			     begin
			     delfrom(skip,n1);
			     delfrom(skip,n2);
			     readed:=true;
			     end;
		 end;

if member(pathset,n1)
	or member(pathset,n2)
	or (hpoint=nil)
		then
		begin
		   { IF JOINT1 IS ABSENT THEN MAKE ELSE SEARCH }
	if not member(pathset,n1) then
			   begin
			      make(n1,hpz);
			      point1:=point;
			      if hpoint=nil then
				    begin
					hpoint:=point1;
					add2set(pathset,n1);
					hpoint^.level:=0;
                                        minlevel:=0;
					maxlevel:=0;
{
readreal(42,'X coordinate of '+strint(hpoint^.id,3),hpoint^.x);
readreal(43,'Y coordinate of '+strint(hpoint^.id,3),hpoint^.y);
}
hpoint^.x:=hpx;
hpoint^.y:=hpy;
				   end;
			    end
		       else
			    begin
				search(n1);
                                point1:=point;
			    end;
if not member(pathset,n2)
               then
		    begin
		       make(n2,hpz);
                       point2:=point;
                    end
               else
		    begin
                    	search(n2);
                        point2:=point;
                    end;
connect(point1,point2);
if member(pathset,n1)
   and not member(pathset,n2)
       then
	   begin
		 add2set(pathset,n2);
	   end
else
if member(pathset,n2)
   and not member(pathset,n1)
	 then
	     begin
		   add2set(pathset,n1);
	    end
end
     else
	   begin
		addto(skip,n1);
		addto(skip,n2);
		complete:=false;
	   end;
end;
if skip='' then complete:=TRUE;
	      {5}
until complete=true;
{Closegraph;}
end;


{#$%}

FUNCTION disbtn(total,factor:real;sup:char):real;
begin
if sup='C'
	then
		disbtn:=factor*total
	else
		disbtn:=0.0;
end;

PROCEDURE distribute(var point:link;var maxerr:real);
var
	total:real;
begin
total:=point^.sumfem;
for zp:=1 to 4 do
	begin
	case zp of
		1:j:=2;
		2:j:=1;
		3:j:=4;
		4:j:=3;
		end;
	if point^.rlud[zp]<>nil then
		begin
		total:=total+point^.rlud[zp]^.mx[j];
		case zp of
			3:total:=total+point^.umd;
			4:total:=total+point^.rlud[4]^.umd;
			end;
		end;
	end;
for zp:= 1 to 4 do
begin
case zp of
	1,3:j:=1;
	2,4:j:=2;
	end;
if point^.rlud[zp]<>nil then
                 begin
		      take(point^.id,point^.rlud[zp]^.id);
		      point^.mx[zp]:=disbtn(total,point^.u4[zp],data.sups[j]);
		      err(point^.mx[zp],point^.pmx[zp],maxerr);
                 end;
end;
end;

FUNCTION final(FEM,Mab,Mba,md:real;sup:char):real;
begin
final:=0.0;
if sup<>'H' then final:=FEM+2.0*Mab+Mba+md;
end;

PROCEDURE disfacts;
var
	sumk,sumload,floorload,fixshear,c:real;
	react1,react2,sr:real;

begin
	maxlevel:=maxlevel-minlevel+1;
	q:=1;   			    {storey no. for groundfloor is 1}
if maxlevel>1 then     	           { for beams maxlevel = 1 }
repeat				{to find disfacts for columns in each storey}
	p:=1;
	sumk:=0;
	while levelmat[q,p]<>0 do
	   begin
		search(levelmat[q,p]);
		c:=0.0;
		if  (point^.rlud[3]<>nil) then
		    begin
			take(point^.id,point^.rlud[3]^.id);
			c:=hr/data.l;
			if data.sups[1]='H' then c:=c/1.5;
			point^.ud:=c*stiff;	{temp storage}
			sumk:=sumk+m*c*c*stiff;  {denominator}
		    end;
		p:=p+1;
	   end;
	p:=1;
	while levelmat[q,p]<>0 do
	   begin
		search(levelmat[q,p]);
		if sumk=0.0
			then
			     point^.ud:=0.0
			else
			     point^.ud:=(-3.0/2.0)*point^.ud/sumk;
		p:=p+1;
	   end;
	q:=q+1;
until q=maxlevel;

q:=maxlevel-1;
sumload:=0;
if maxlevel>1 then
repeat					{loop2 begin}
	sr:=0;
	sumload:=sumload+floorload;
	floorload:=0.0;
	fixshear:=0.0;
	p:=1;
	while levelmat[q,p]<>0 do
	    begin
		search(levelmat[q,p]);
		react1:=0;
		react2:=0;
		if (point^.rlud[3] <> nil) then
			tot_react(point^.id,point^.rlud[3]^.id,react1,react2);
		fixshear:=fixshear+react2+(point^.fem[3]+point^.rlud[3]^.fem[4])/data.l;
		floorload:=floorload+react1+react2;
		p:=p+1;
	    end;
	sr:=fixshear+sumload;
	p:=1;
	while levelmat[q,p]<>0 do
	     begin
		search(levelmat[q,p]);
		point^.mr:=sr*hr/3;
		p:=p+1;
	     end;
	q:=q-1;
until q=0;
end;

PROCEDURE pro1(scode:char);
begin
				readksbuff:='A';
				KSbuff:=scode;
				KSread(29,'CON',KSBuff,excode);
				readKSbuff:=NOREAD;
				selectread(datano,loadno,fieldno);
				readKSbuff:=#0;
				disprec(datano,'B');
end;

procedure pgupdown;
begin
{
case scode[7] of
	 pgup:	begin
		makemenu;
		if menustart>10 then menustart:=menustart-10;
		end;
	 pgdn:	begin
		makemenu;
		if menustart<=NM-10 then menustart:=menustart+10;
		end;
	end;
}
makemenu;
if scode[7] in [pgup,pgdn] then
	begin
	scode[7]:=NOREAD;
	multipix(menus,'V',NM,5,2,10,menustart,56,4,choice[7],scode[7]);
	end;
end;


PROCEDURE delete_data;
  begin
	repeat
	makemenu;
	menualt:=FALSE;
	disprec(datano,'B');
	dispstat;
	scode[7]:=NOREAD;
	multipix(menus,'V',NM,5,2,10,menustart,56,4,choice[7],scode[7]);
	repeat
		scode[7]:=NOCHECK;
		multipix(menus,'V',NM,5,2,10,menustart,56,4,choice[7],scode[7]);
pgupdown;
{
avoided check		if scode[7]=ENTER then
			begin
				datano:=choice[7]+menustart-1;
				dispstat;
				disprec(datano,'B');
			end;
}

{
		end;
}
	until (scode[7]=ENTER) or (scode[7]=ESC);
	i:=choice[7]+menustart-1;
	if (scode[7]=ENTER) and (i<=NM) then
			begin
			while (DM^[i].name[1]<>0) and (DM^[i].name[2]<>0)
				do
				begin
					DM^[i]:=DM^[i+1];
					inc(i);
				end;
				dec(NM);
			end;
	if aborted then
		aborted:=FALSE;
	until scode[7]=ESC;
	menualt:=TRUE;
end;


PROCEDURE modify_data;
var tmstart:integer;
begin
{
	col:=1;
}
	datano:=1;
	dispstat;
	repeat
		scode[7]:=#0;
		makemenu;
		menualt:=FALSE;
		disprec(datano,'B');
		scode[7]:=NOREAD;
		multipix(menus,'V',NM,5,2,10,menustart,56,4,choice[7],scode[7]);
		repeat
			scode[7]:=NOCHECK;
			multipix(menus,'V',NM,5,2,10,menustart,56,4,choice[7],scode[7]);
pgupdown;
if (scode[7]=ENTER)
{
 and (datano<>choice[7]+menustart-1)
}
			then
				begin
				datano:=choice[7]+menustart-1;
				{disprec(datano,'B');}
				dispstat;
				end;
	until (scode[7]=ENTER) or (scode[7]=ESC);
	menualt:=TRUE;
	if scode[7]=ENTER                                { MEM PROP MENU }
		then
			repeat
				choice[8]:=1;
				disprec(datano,'B');
			repeat
				scode[8]:=NOCHECK;
				boxpix(1,menus,'',34,3,51,9,71,choice[8],scode[8],1);
                        if (scode[8] in [#32..#127]) and not Speckey
			 then
			 begin
				fieldno:=choice[8];
				pro1(scode[8]);
				if choice[8]<7 then inc(choice[8]);
			 end
			else
			if scode[8]=ENTER then
				begin
				fieldno:=choice[8];
				selectread(datano,loadno,fieldno);
				disprec(datano,'B');
			end;
			if aborted then scode[8]:=ESC;
			until (scode[8]=ESC) or
				((choice[8]=1) and (scode[8]=DOWN));
		choice[9]:=1;
		buflen:=10;
                tmstart:=menustart;
		if scode[8] in [ENTER,DOWN] then         { LOAD MENU }
			begin
				disprec(datano,'B');
				repeat
				scode[9]:=NOCHECK;
		menustart:=1;
multipix(menus,'H',100,9,7,10,menustart,6,11,choice[9],scode[9]);
			if (scode[9] in [#32..#127]) and not Speckey
					 then
                                         begin
				loadno:=choice[9] mod 9;
				if loadno=0 then loadno:=9;
				fieldno:=choice[9] div 9;
				if choice[9] mod 9<>0 then fieldno:=fieldno+1;
				fieldno:=fieldno+7;
                                pro1(scode[9]);
                                end
                                else
                                if scode[9]=ENTER then
					begin
					loadno:=choice[9] mod 9;
					if loadno=0 then loadno:=9;
					fieldno:=choice[9] div 9;
					if choice[9] mod 9<>0 then fieldno:=fieldno+1;
					fieldno:=fieldno+7;
					selectread(datano,loadno,fieldno);
					disprec(datano,'B');
					end;
				until (scode[9]=ESC)
				or ((scode[9]=DOWN) and (choice[9] mod 9=1))
				or ((scode[9]=UP) and (choice[9] mod 9=0));
			end;
			buflen:=78;
		until (scode[8]=ESC) or (scode[9]=ESC);
                menustart:=tmstart;
	if aborted then
		aborted:=FALSE;
	until (scode[7]=ESC);
end;

PROCEDURE copy_data;
 begin
	repeat
		makemenu;
		menualt:=FALSE;
		dispstat;
		disprec(datano,'B');
		scode[7]:=NOREAD;
		multipix(menus,'V',NM,5,2,10,menustart,56,4,choice[7],scode[7]);
	repeat
		scode[7]:=NOCHECK;
		multipix(menus,'V',NM,5,2,10,menustart,56,4,choice[7],scode[7]);
pgupdown;
if scode[7]=ENTER then
			begin
				datano:=choice[7]+menustart-1;
				dispstat;
				disprec(datano,'B');
				{dispstat;}
			end;
	until (scode[7]=ENTER) or (scode[7]=ESC);
	if scode[7]=ENTER then
		begin
			DM^[NM+1]:=data;
			inc(NM);
		end;
	if aborted then
		aborted:=FALSE;
until scode[7]=ESC;
	menualt:=TRUE;
	end;

PROCEDURE display_data;
begin
	makemenu;
	menualt:=FALSE;
	scode[7]:=NOREAD;
	multipix(menus,'V',NM,5,2,10,menustart,56,4,choice[7],scode[7]);
	dispstat;
	repeat
		scode[7]:=NOCHECK;
		multipix(menus,'V',NM,5,2,10,menustart,56,4,choice[7],scode[7]);
	pgupdown;
	if scode[7]=ENTER then
			begin
			datano:=choice[7]+menustart-1;
			dispstat;
			display(out,datano,TRUE);
			end;
	if aborted then
		aborted:=FALSE;
until (scode[7]=ESC);
	menualt:=TRUE;
end;

PROCEDURE list_data(fname:string);
var 	f:text;
	pause:boolean;
begin
assign(f,fname); 	{ check PRN status using interrupt for printout}
	rewrite(f);
	datano:=1;
	if fname='CON' then pause:=TRUE else pause:=FALSE;
	while datano<=NM do
		begin
                        dispstat;
			display(f,datano,pause);
			datano:=datano+1;
		end;
	close(f);
end;

PROCEDURE save_data(fname:string);
var
	f:text;
	ch,x,y,blank,lsup,rsup:char;
	s:string;
begin
if conf(fname) then exit;
setfile(f,s,fname,'W',excode); { check PRN status using interrupt }
if excode=ESC then exit;
datano:=1;
if fname<>'PRN' then
			begin
			writeln(f,'FRAME');
			writeln(f,0,h,0,h,0);
			end;
while datano<=NM do
with DM^[datano] do
begin
write(f,name[1],'-',name[2],h,dir,h);
if (dir='R') or (dir='U')
			then
				write(f,sups[1],h,sups[2],h)
			else
				write(f,sups[2],h,sups[1],h);

writeln(f,l:6:3,h,b:6:3,h,d:6:3);
loadno:=0;
repeat
	loadno:=loadno+1;
with DM^[datano].loads[loadno] do
begin
write(f,loadtype,h);
{ if loadtype<>'.' then write(f,weild,h); Include this for EQ,WL etc. }
case loadtype of
'C' :	writeln(f,w:6:3,h,posn:6:3,h,ldir);
'V' :   writeln(f,w1:6:3,h,w2:6:3,h,pos1:6:3,h,pos2:6:3,h,ldir);
'U' :	begin
		writeln(f,w1:6:3,h,ldir);
		w2:=w1;
		pos1:=0;
		pos2:=DM^[datano].l;
	end;
'P' :   writeln(f,wmax:6:3,h,ldir);
'M' :	writeln(f,m:6:3,h,mpos:6:3,h,ldir);
'D' :   writeln(f,d:6:3,h,ldir);
else
	if (loadtype<>'.') then
	msg(' Error : Illegal loadtype "'+loadtype+'" '+noise);
end;
end;
until (loads[loadno].loadtype='.') or (loadno=10);
writeln(f);
inc(datano);
end;
writeln(f,'END');
close(f);
end;

PROCEDURE bendmax(var bmdfile,sfdfile:text;
	dgm:boolean;j1,j2:integer;nemo1,nemo2:real;var maxpo,max,contra1,contra2,sfl,sfr:real);
type	array11=array[1..11] of real;
var
	rn1,rn2:real;
var
	changed:boolean;
	matx,fatx:array11;
	pleftx,leftx,h,x,mx,natx:real;
	maxmo:real;
	i,inti:integer;
	drawn_bmd:boolean;

PROCEDURE diagram(form:char;atx:array11);
var
	x,absmax:real;
	k:integer;
begin
	case form of
	'M' :absmax:=abs(maxmo);
	'F' :if abs(fatx[1])>abs(fatx[11])
			then
				absmax:=abs(fatx[1])
			else
				absmax:=abs(fatx[11]);
	end;
	for k:=1 to 11 do
		begin
		x:=(k-1)*h;
		{
		write(out,x:6:2,'  ',atx[k]:6:2,'  ');
		}
if absmax+30<maxint then atx[k]:=atx[k]/trunc((absmax+30.0)/30.0)
	else
		msg('');
	{ # include & research on Possible Error Detected !.');}
		{
		writeln(j1,' - ',j2,' ',form);
		for j:=1 to (30+round(atx[k])) do  write(' ');
		for j:=1 to round(abs(atx[k])) do write('*');
		writeln;
		readln;
		}
		case form of
			'M':writeln(bmdfile,x:6:2,' ',atx[k]:6:2);
			'F':writeln(sfdfile,x:6:2,' ',atx[k]:6:2);
			end;
		end;
  end;  { END OF DIAGRAM }

begin
drawn_bmd:=FALSE;
max:=0.0;
maxpo:=0.0;
sfl:=0.0;
sfr:=0.0;
take(j1,j2);
with data do
if (data.sups[1]<>'F') and (data.sups[2]<>'F') then
	begin
{
if soker='S' then
	for z:=1 to 3 do
			begin
			loads[z]:=deadload[z];
			loads[z+2]:=liveload[z];
			end;
}
	h:=l;
	leftx:=0.0;
	contra1:=0.0;
	contra2:=0.0;
repeat
	h:=h/10;
	maxpo:=0-maxint;
	x:=leftx;
	for i:=1 to 11 do
		begin
		matx[i]:=0.0;
		fatx[i]:=0.0;
		loadno:=1;
		while loads[loadno].loadtype<>'.' do
			begin
			with loads[loadno] do
			case loadtype of
			'C':if not eq(w,0.0) then
				begin
				reaction(j1,j2,loadno,rn1,rn2);
				if x<=posn then
					begin
					matx[i]:=matx[i]+rn1*x;
					if eq(leftx,0.0)
						then fatx[i]:=fatx[i]+rn1;
					end
					else
					begin
					matx[i]:=matx[i]+rn1*x-w*(x-posn);
					if eq(leftx,0.0) then fatx[i]:=fatx[i]+rn1-w;
					end;
				end;
			'V','U':if not eq(w1,0.0) then
				begin
				reaction(j1,j2,loadno,rn1,rn2);
				matx[i]:=matx[i]+rn1*x-w2*x*x/2;
				fatx[i]:=fatx[i]+rn1-w2*x;
				end;
			{ INCOMPLETE }
			end;
		inc(loadno);
		end;
		natx:=nemo1-(nemo2+nemo1)*(x/l);
		matx[i]:=natx+matx[i];
		if eq(leftx,0.0) then fatx[i]:=fatx[i]-(nemo1+nemo2)/l;
		if matx[i]>maxpo then
					begin
					max:=x;
					maxpo:=matx[i];
					end;
	if abs(matx[i])>maxmo then maxmo:=abs(matx[i]); {FOR SFD&BMD}

if i>1 then
	begin
			if (matx[i]>0.0) and (matx[i-1]<0.0) then
			contra1:=x-h*matx[i]/(abs(matx[i-1])+matx[i]);
			if (matx[i]<0.0) and (matx[i-1]>0.0) then
			contra2:=x-h*abs(matx[i])/(matx[i-1]+abs(matx[i]));
	end;

{ Do this only for the first case }
	if eq(leftx,0.0) and (i>1) then
			begin
{
			if (matx[i]>0.0) and (matx[i-1]<0.0) then
			contra1:=x-h*matx[i]/(abs(matx[i-1])+matx[i]);
			if (matx[i]<0.0) and (matx[i-1]>0.0) then
			contra2:=x-h*abs(matx[i])/(matx[i-1]+abs(matx[i]));
}
			if i=11 then
				begin
				sfl:=fatx[1];
				sfr:=fatx[11];
				end;
		if (i=11) and dgm then
			begin
			diagram('M',matx);
			diagram('F',fatx);
			drawn_bmd:=TRUE;
			end
			else
				msg('');
	end;

		x:=x+h;
		end;
		leftx:=max-h;
		h:=2*h;
	until ((h<0.001) or (leftx>=l)) and (not dgm or drawn_bmd);
{
writeln(data.name[1],'  ',data.name[2],' ',h:6:4,'  ',contra1:4:2,'  ',contra2:4:2);
}
end
else
	begin
	loadno:=1;
	while (loads[loadno].loadtype<>'.') do
		begin
			with loads[loadno] do
			case loadtype of
			'C':    sfl:=sfl+w;
			'V','U':	sfl:=sfl+w2*l;
			end;
			{ INCOMPLETE }
		inc(loadno);
		end;
	if sups[2]='F' then
		begin
		sfr:=sfl;
		sfl:=0.0;
		end;
{# Temporary error preventor below for cantelever case }
writeln(#7,#7,#7);
for inti:=1 to 11 do
		begin
		writeln(bmdfile,0:6,' ',0:6);
		writeln(sfdfile,0:6,' ',0:6);
		end;
		end;
{# End of Temporary error preventor for cantelever case }
end;

begin
data:=cdata;
end.

{ V.V.IMP :  PATHARRAY'S LIMITS ARE 50 x 50 }
{ X,Y values of hpoint is written at the dead of afile }
{ editrec should modify NM }

