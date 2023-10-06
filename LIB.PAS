		       { GENERAL LIBRARY FUNCTIONS }
unit lib;
interface
uses crt,dos;
type
	boxtype=
		record
		x1,y1,x2,y2:integer;
		boxw:array[0..3999] of byte;
		end;
	windrec=record
		x1,y1,x2,y2,cx,cy:byte;
		end;
	string75=string[75];
	videomodes = (low,normal,bright,reversed,flashing);
	windowtype= (winp,wout,wmsg,wglob);
	image=array[0..3999] of byte;
	menu=array[1..125] of string[75];
	menutype=^menu;
	string20=string[20];
	files=array[1..100] of string[12];
	ranger=array[1..5] of integer;
const
	txtmode:boolean=TRUE;
	HighV:boolean=FALSE;
	flags:array[1..2] of boolean=(FALSE,FALSE);
	outdir:string='';
	inpdir:string='';
	SLB:boolean=TRUE;
	LD:boolean=TRUE;
	order:set of 1..100=[];
	M_limit=125;
	h:string=#9;
	format1:integer=1;
	format2:integer=2;
	e:real=1e-3;
	excode  :char=#0;
	Hide    =$00;
	Nunder  =$01;
	Norm    =$07;
	Hunder  =$09;
	High    =$0F;
	Rvse    =$70;
	NBlink  =$87;
	HBlink  =$8F;
	RBlink  =$F0;
	attr:byte    =7;

	insstate= 1;
	capstate= 2;
	numstate= 3;
	scrstate= 4;
	altstate= 5;
	ctlstate= 6;
	letstate= 7;
	ritstate= 8;

	ReadKSbuff:char='E';
	KSBuff:string='';
	Speckey:boolean=FALSE;
	noread=#254;
	pgdn=#81;
	pgup=#73;
	up=#72;
	down=#80;
	left=#75;
	right=#77;
	esc=#27;
	enter=#13;
	space=#32;
	any=#0;
	NOCHECK=#255;
	altkey=#253;
	cls=1;
	inL:integer=2;
	nocls=0;
	single=1;
	highletter:boolean=TRUE;
	rev:boolean=TRUE;
	aborted:boolean=FALSE;
	resp:char='N';
	ALT:string20='                    ';
	TRAP:boolean=FALSE;
	whilecon=-1;
	globalalt:set of #0..#255=[];
	buflen:integer=75;

{ used in ana}
	sdrange:ranger=(80,90,100,110,120);
	bdrange:ranger=(300,350,400,450,500);
	cdrange:ranger=(400,450,500,550,600);
	bfixedb:integer=200;
	cfixedb:integer=200;
	sbc:integer=100;
	liveload:real=3.00;
	wload:real=4.00;
	proname:string='NONAME.CAD';
var
	menus:menutype;
	OldExitProc:pointer;
	REQ:char;
	wind:array[1..4] of windrec;
	boxer:boxtype;
	scode:array[1..10] of char;
	choice:array[1..10] of integer;
	inpname,outname,insname :string[12];
	inp,out,ins:text;
	regs:registers;
	vseg:word;

FUNCTION  PrinterReady:boolean;
FUNCTION  nospace(s:string):string;
FUNCTION  alpha(s:string):boolean;
FUNCTION  p0i(w:integer;x:byte):string;
FUNCTION  scrmem(col,row:integer):integer;
FUNCTION  exist(fname:string75):boolean;
FUNCTION  noise:char;
FUNCTION  fixlength(s:string;x:integer;lor:char):string;
FUNCTION  chklen(s:string;x:integer):string;
FUNCTION  strreal(z:real;x,y:integer):string;
FUNCTION  strint(z,x:integer):string;
FUNCTION  justify(z:real;x,y:integer;lor:char):string;
FUNCTION  keyed(x:integer):boolean;
FUNCTION  yes:boolean;
FUNCTION  eq(x,y:real):boolean;

procedure myval(s:string;var r:real;var error:integer);
function mytrunc(r:real):integer;
function myround(r:real):integer;

PROCEDURE kswrite(x,y:byte;s:string);
PROCEDURE ClearBuffer;
PROCEDURE NextKeys(var b1,b2:byte);
PROCEDURE Full;
PROCEDURE windco(var wind:windrec);
PROCEDURE ksgoto(c,l:byte);
PROCEDURE WhereC(var c,l:byte);
PROCEDURE setfile(var f:text;var n:string;s:string;mode:char;var excode:char);
PROCEDURE hline(x,y,z,pat,attr:integer);
PROCEDURE vline(x,y,z,pat,attr:integer);
PROCEDURE vc(x,y:integer;c:char;atrib:byte);
PROCEDURE fastwrite(ch:char;times,attr:integer);
PROCEDURE sbox(var boxer:boxtype;xL,yL,xR,yR:integer);
PROCEDURE rbox(boxer:boxtype);
PROCEDURE swapitem(var s:string;s1,s2:string);
PROCEDURE readrealbox(hp:integer;x1,y1,x2:integer;prompt:string75;var r:real;var excode:char);
PROCEDURE readintbox(hp:integer;x1,y1,x2:integer;prompt:string75;var r:integer;var excode:char);
PROCEDURE readcharbox(hp:integer;x1,y1,x2:integer;prompt:string75;var r:char;var excode:char);
PROCEDURE readstrbox(hp:integer;x1,y1,x2:integer;prompt:string75;var s:string;var excode:char);
PROCEDURE resetcrt;
PROCEDURE multipix(menus:menutype;hov:char;lastmenu,Nrow,Ncol,colwidth:integer;
   var menustart:integer;x1,y1:integer;var choice:integer;var mpixcode:char);
PROCEDURE upstring(var s:string);
PROCEDURE msg(s:string);
PROCEDURE centre(s:string);
PROCEDURE put(var screenkeep:image);
PROCEDURE get(var screenkeep:image);
PROCEDURE windows(area:windowtype;clear:integer);
PROCEDURE waitfor(upto:char);
{
PROCEDURE help(hp:integer);
}
PROCEDURE help(h:integer);
PROCEDURE video(v:videomodes);
PROCEDURE readreal(hp:integer;prompt:string75;var r:real);
PROCEDURE readint(hp:integer;prompt:string75;var r:integer);
PROCEDURE readchar(hp:integer;prompt:string75;var r:char);
PROCEDURE readstr(hp:integer;prompt:string75;var s:string);
PROCEDURE box(l,t,r,b,pat:integer;x:byte);
PROCEDURE boxpix(hp:integer;menus:menutype;ALT:string20;l,t,r,b:integer;start:integer;
		 var opt:integer;var excode:char;jump:integer);
PROCEDURE KSread(hp:integer;inpname:string;var s:string;var excode:char);
PROCEDURE setc(resp:char);
PROCEDURE CALL_SHELL;
PROCEDURE sw(x:byte);
PROCEDURE rw(x:byte);
FUNCTION conf(fname:string):boolean;
PROCEDURE vs(x,y:integer;s:string;atrib:byte);
procedure ERR(errno,mode:integer);
procedure getfiles(inpdir:string;var dirfiles:files;var numfiles:integer);
procedure selfromdir(xc,yc:integer;inpdir:string;var fname:string;var excode:char);
function UBreak:boolean;
procedure nabt;
function firstname(fname:string):string;
implementation
var
	i:integer;
	s:string;
	c:char;

procedure nabt;
begin
aborted:=FALSE;
end;

function firstname(fname:string):string;
begin
if pos('.',fname)>0 then
		firstname:=copy(fname,1,pos('.',fname)-1)
	else
		firstname:=fname;
end;


procedure ERR(errno,mode:integer);
begin
if mode=0 then
	clrscr
	else
		begin
		{
		restorecrtmode;
		closegraph;
		directvideo:=TRUE;
		}
		clrscr;
		end;

	writeln('Internal error in VCAD.');
	writeln;
case errno of
	1:writeln('Round/trunc error.');
	end;
writeln('Please report the error address to Dosix Software Products.');
end;
function UBreak:boolean;
var
	c:char;
	screen:image;
begin
UBreak:=FALSE;
if keypressed then
	begin
	c:=readkey;
	if c=#0 then c:=readkey;
	if c=^C then
		begin
		put(screen);
		msg('Do you want to break current process (Y/N) ? ');
		if yes then
				Ubreak:=TRUE
			else
				get(screen);
		end;
	end;
end;

{$F+}
PROCEDURE MyExitProc;
begin
ExitProc := OldExitProc; { Restore exit PROCEDURE address }
{
FreeMem(Picker,size);
killgraph(graphrec2);
CloseGraph;
}
	{ Shut down the graphics system }
DirectVideo:=TRUE;
{
restorecrtmode;
}
writeln('GOOD BYE ! ');
end; { MyExitProc }
{$F-}


FUNCTION conf(fname:string):boolean;
begin
if (fname='CON') or (length(fname)=0) or
(length(nospace(fname))=0) or (fname='TEMP') or (fname=inpdir+'CON')
	or (fname=outdir+'CON')
			then conf:=TRUE else conf:=FALSE;
end;

FUNCTION eq(x,y:real):boolean;
begin
if abs(x-y)<e then eq:=TRUE else eq:=FALSE;
end;

PROCEDURE setfile(var f:text;var n:string;s:string;mode:char;var excode:char);
label 100,200;
begin
100:
excode:=#0;
if (not conf(s)) and (s<>'PRN') then
	begin
	if (pos('\',s)=0) and (pos(':',s)=0) then
			if mode='R' then s:=inpdir+s
			else if mode='W' then
			s:=outdir+s;
	end;

if s='PRN' then if not PrinterReady then
	begin
	close(f);
	assign(f,'CON');
	assigncrt(f);
	rewrite(f);
	n:='CON';
	excode:=ESC;
	exit;
	end;
n:=s;
case mode of
	'R':
		begin
		assign(f,s);
		if exist(s)
		then reset(f)
		else
			begin
			msg('File not found.'+noise);
			excode:=ESC;
			end;
		end;
	'W':
		begin
		if (s<>'PRN') and (not conf(s)) and exist(s) then
			begin
			msg('File '+s+' exists. Overwrite it (Y/N) ?');
			if yes then msg('') else goto 200;
			end;
		if conf(s) then
			begin
			close(f);
			assign(f,'CON');
			assigncrt(f);
			n:='CON';
			end
			else assign(f,s);

		{$I-}
		rewrite(f);
		{$I+}
		if (ioresult<>0) then
			begin
			{$I-}
			close(f);
			assign(f,'CON');
			assigncrt(f);
			n:='CON';
			rewrite(f);
                        {$I+}       {# ? }
			{excode:=ESC}
			end;
		end;
	end;
if excode=ESC then
		begin
		sound(500);
		delay(500);
		nosound;
		{
		# Read new file names from user and try again to avoid a halt
		}
200:		msg('Can''t access file '+s+'.'+noise);
		readstr(1,'Enter new filename with PATH ? ',s);
		aborted:=FALSE;
		goto 100;
		end;
end;


(*
PROCEDURE help(hp:integer);
label 100;
type
	hptype=record
		hp:array[1..16] of string;
		end;
var
	hfile:file of hptype;
	hprec:hptype;
	tx,ty,i,j,k:integer;
	screen2:image;
	m:integer;
	NHigh,NPage:integer;
	sx,sy:integer;

begin
sw(1);
hp:=1;		{ change }
put(screen2);
{$I-}
	assign(hfile,'VCAD.HLP');
	reset(hfile);
{$I+}
if ioresult<>0 then
               begin
               msg('Help File not Found.');
               exit;
               end;
m:=hp;

100:
{$I-}
	seek(hfile,m-1);
	read(hfile,hprec);
{$I+}
with hprec do
begin
	hp[1]:= #2+#10+#15+#1 + #3+#12+#18+#1 +#2;
	hp[1][0]:=#2;
	NHigh:=ord(hp[1][0]);
	NPage:=ord(hp[1][NHigh*4+1]);
	rev:=FALSE;
	box(9,4,72,21,single,0);
	window(10,5,71,20);
	clrscr;
k:=1;
repeat
	tx:=9+wherex;
	ty:=4+wherey;
	for i:=2 to 16 do
			begin
			j:=1;
			inc(tx);
		while j<=length(hp[i]) do
		begin
		if (i=ord(hp[1][k])) and (j>=ord(hp[1][k+1])) and (j<=ord(hp[1][k+2]))
				then
					attr:=rvse
				else
					attr:=Norm;
			case hp[i][j] of
				#9:     tx:=tx+7;
				else   	vc(tx,ty,hp[i][j],attr);
				end;
		inc(tx);
		inc(j);
		end;
		ty:=ty+1;
		tx:=10;
		end;
resp:=readkey;
case resp of
	#0:
		begin
		resp:=readkey;
		if resp in [LEFT,UP] then
			if k>1 then
					k:=k-4
				else
					k:=(NHigh-1)*4+1;
		if resp in [RIGHT,DOWN] then
			if k=(NHigh-1)*4+1 then
					k:=1
					else
					k:=k+4;
		{
		if (resp=Pgup) and (m>hp) then
					begin
					m:=m-1;
					goto 100;
					end;
		if (resp=Pgdn) and (m<nohp)
					then
					begin
					m:=m+1;
					goto 100;
					end;
		}
		end;
	ESC:
		begin
		get(screen2);
		rw(1);
		end;
	ENTER:
		begin
		m:=ord(hp[1][k+3]);
		goto 100;
		end;
	end;
until resp=ESC;
end;
close(hfile);
end;
*)

PROCEDURE help(h:integer);
label 100,200;
type
	hptype=record
		hp:array[1..16] of string;
		end;
var
	hfile:file of hptype;
	hprec:hptype;
	tx,ty,i,j,k:integer;
	screen2:image;
	m:integer;
	NHigh,NPage:integer;
	sx,sy:integer;
        sattr:byte;
        scursor:char;
        intx,code:integer;
        noh:integer;  { no. of pages }
        PD:pathstr;

{  max. col = 60 }

begin
PD:='';

sw(1);
{
scursor:=lastcursor; include if possible
sattr:=textattr;
}

put(screen2);
setc('I');
{$I-}
	assign(hfile,PD+'IPM.HLP');
	reset(hfile);
{$I+}
if ioresult<>0 then
   begin
   {smsg(PD+'IPM.HLP not found.'+ESC);}
   msg('Help File Not Found.');
   exit;
   end;

noh:=sizeof(hfile);
textcolor(black);
textbackground(lightcyan);

m:=h;
100:



{$I-}
	seek(hfile,m-1);
	read(hfile,hprec);

if (ioresult<>0) then
                 begin
                 m:=m-1;
                 goto 100;
                 end;
{$I+}
with hprec do
begin

{

hp[1][k]-    line
hp[1][k+1]-  start col
hp[1][k+2]-  start col

}

{
	hp[1]:= #2+#10+#15+#1 + #3+#12+#18+#1 +#2;
	hp[1][0]:=#2;
}

        s:=nospace(hp[1]);
        while pos('*',s)<>0 do delete(s,pos('*',s),1);

        hp[1]:='';
        i:=1;
    while pos(',',s)>0 do
        begin
        val(copy(s,1,pos(',',s)-1), intx, code);
        insert(chr(intx),hp[1],length(hp[1])+1);
        inc(i);
        delete(s,1,pos(',',s));
        write(intx);
        end;

        val(s, intx, code);
        insert(chr(intx),hp[1],length(hp[1])+1);

	NHigh:=length(hp[1]) div 4;           { No. of high areas }
	NPage:=ord(hp[1][NHigh*4+1]);     { No. of pages to display
                                            at current F1 }
        if length(hp[1]) mod 4 <> 1 then msg(strint(m,1)+'Error in help file!'+ESC);

	rev:=FALSE;
	box(9,4,72,21,single,75);
        vs(37,4,' Help ',79);
	window(10,5,71,20);
	clrscr;

k:=1;
repeat
	tx:=9+wherex;
	ty:=4+wherey;
	for i:=2 to 16 do
			begin
			j:=1;
			inc(tx);
		while (j<=length(hp[i])) and (j<=60) do
		begin
	        attr:=textattr;

                {       Enable high lighting of keywords
                if NHigh>0 then
                for intx:=1 to Nhigh do
                if (i=ord(hp[1][(intx-1)*4+1])) and (j>=ord(hp[1][(intx-1)*4+2]))
                                        and (j<=ord(hp[1][(intx-1)*4+3])) then
                                            if (intx-1)*4+1=k then
                                                      attr:=106
                                                  else
                                                      attr:=63;
		}

                	case hp[i][j] of
				#9:     tx:=tx+7;
				else   	vc(tx,ty,hp[i][j],attr);
				end;
		inc(tx);
		inc(j);
		end;
		ty:=ty+1;
		tx:=10;
		end;

200:
resp:=readkey;
case resp of
	#0:
		begin
		resp:=readkey;
		if resp in [LEFT,UP] then  { shift b/n high areas }
			if k>1 then
					k:=k-4
				else
					k:=(NHigh-1)*4+1;

		if resp in [RIGHT,DOWN] then
			if k=(NHigh-1)*4+1 then
					k:=1
					else
					k:=k+4;


		if (resp=PgUp) then
                               if (m>h) then
					begin
					m:=m-1;
					goto 100;
					end
                                        else goto 200;

		if (resp=Pgdn) then
                               if (m<noh)
					then
					begin
					m:=m+1;
					goto 100;
					end
                                        else goto 200;
		end;
	ESC:
		begin
		get(screen2);
		rw(1);
		end;
	ENTER:            { goto page no m }
		if NHigh>0 then
                begin
		m:=ord(hp[1][k+3]);
		goto 100;
		end else goto 200;
	end;


{
if resp<>ESC then  msg(' Press PgUp/PgDn/ESC.');
}

until resp=ESC;
end;
close(hfile);
textattr:=sattr;
setc(scursor);
end;

FUNCTION yes:boolean;
begin
if not txtmode then exit;
repeat resp:=upcase(readkey) until resp in ['Y','N'];
if resp='Y' then yes:=TRUE else	yes:=FALSE;
msg('');
end;

PROCEDURE fastwrite(ch:char;times,attr:integer);
var
	reg:registers;
begin
	reg.ah:=$09;
	reg.al:=ord(ch);
	reg.bh:=0;
	reg.bl:=attr;
	reg.cx:=times;
intr($10,reg);
end;

FUNCTION nospace(s:string):string;
var
	i,j:integer;
begin
j:=length(s);
i:=0;
while i<length(s) do
	begin
	i:=i+1;
	if (s[i]=' ') then
		begin
		delete(s,i,1);
		dec(i);
		end;
	end;
nospace:=s;
end;

PROCEDURE setc(resp:char);
var
	reg:registers;
begin
with reg do
	begin
	case resp of
	'F' : ch:=1 ;
	'H' : ch:=7 ;
	'N' : ch:=11;
	'I' : ch:=32;
	else
		ch:=11 ;
	end;
	cl:=12;
	ah:=1;
	end;
intr($10,reg);
end;

FUNCTION keyed(x:integer):boolean;
const
	state:array[1..8] of byte=
	($80,$40,$20,$10,$08,$04,$02,$01);
var
	kbflag:byte absolute $0040:$0017;
	status:array[1..8] of byte;
begin
	status[x]:=kbflag and state[x];
	if status[x]>0 then keyed:=TRUE;
end;

FUNCTION p0i(w:integer;x:byte):string;
var
    i:integer;
    s:string;
begin
	s:=strint(w,x);
	for i:= 1 to x do if s[i]=' ' then s[i]:='0';
	p0i:=s;
end;

FUNCTION scrmem(col,row:integer):integer;
begin
	if (row<1) or (row>25) or (col<1) or (col>80) then halt;	{# debug}
	scrmem:=(row-1)*160+(col-1)*2;
end;

PROCEDURE vc(x,y:integer;c:char;atrib:byte);
begin
	x:=scrmem(x,y);
	mem[Vseg:x]:=ord(c);
	mem[Vseg:x+1]:=atrib;
end;

PROCEDURE vs(x,y:integer;s:string;atrib:byte);
begin
x:=scrmem(x,y);
for i:=1 to length(s) do
	begin
		mem[Vseg:x]:=ord(s[i]);
		mem[Vseg:x+1]:=atrib;
		x:=x+2;
	end;
end;


PROCEDURE upstring(var s:string);
begin
	for i:=1 to length(s) do s[i]:=upcase(s[i]);
	{# range check error}
end;

PROCEDURE backer(c:char;var s:string;var posn:integer);

begin
if c=#8 then
	begin
	if posn=1 then
			exit;
	gotoxy(wherex-1,wherey);
	write(' ');
	gotoxy(wherex-1,wherey);
	dec(posn);
	delete(s,posn,1);
	end;
end;

PROCEDURE KSread(hp:integer;inpname:string;var s:string;var excode:char);
var
	stores:string;
	i,tx,ty:integer;
	flag:boolean;
begin
if aborted then exit;
if not conf(inpname) then
		begin
		s:='';
		if eoln(inp) then readln(inp);
			repeat
			read(inp,c);
			if (c<>#9) and (c<>ENTER) and (c<>#10) then
						insert(c,s,length(s)+1);
			if c=ENTER then readln(inp);
			until (c=#9) or (c=ENTER) or eoln(inp);
			exit;
		end;
case ReadKSbuff of
	NOREAD:
		begin
		s:=KSbuff;
		ReadKSbuff:='E';
		exit;
		end;              {Exit}
	'A'	:flag:=FALSE;     {Add}
	'E',#0  :flag:=TRUE;      {Edit}
	else
		begin
		flag:=FALSE;
		s:='';
		end;              {Other?}
	end;
stores:=s;
i:=length(s)+1;
tx:=wherex;
video(reversed);
write(s);
video(normal);
setc('N');
repeat
c:=readkey;
if c=#0 then
		begin
		c:=readkey;
		case c of
			chr(59) :  help(hp);
			LEFT	:if i>1 then
					begin
					dec(i);
					end;
			RIGHT	:if i<length(s)+1 then
					begin
					inc(i);
					end;
			'G'	:begin
					i:=1;
				end;
			'O'	:begin
					i:=length(s)+1;
				end;
			'S'	:begin
				gotoxy(tx+length(s)-1,wherey);
				write(' ');
				delete(s,i,1);
				end;
			end;
		end
	else
		case c of
			#8	:backer(c,s,i);
			^C	:begin
				excode:=ESC;
				aborted:=TRUE;
				s:=^C;
				end;
			ESC	:
				begin
				if trap then
					begin
					msg('Do you want to abort ? (Y/N) ');
					if yes then aborted:=TRUE;
					msg('');
					end
					else s:=stores;
				end;
			else
		   if (c>#31) then
			begin
				if flag then
				begin
				if length(s)>0 then
					begin
					gotoxy(tx,wherey);
					fastwrite(#32,length(s),norm);
					end;
				s:='';
				i:=1;
				end;
			if length(s)<buflen then
					begin
					insert(c,s,i);
					i:=i+1;
					end
						else
							begin
							sound(1000);
							delay(100);
							nosound;
							end;
				end;
		end;
gotoxy(tx,wherey);
write(s);
gotoxy(tx+i-1,wherey);
flag:=FALSE;
until (c=ENTER) or (c=^C) or (trap and aborted) or (not trap and (c=ESC));
excode:=c;
setc('I');
end;


PROCEDURE windows(area:windowtype;clear:integer);
begin
case area of
  winp:
	begin
	window(2,22,79,24);
	end;
  wout:	begin
	window(2,3,79,20);
	end;
  wglob:
	begin
	window(1,1,80,25);
	end;
end;
if (area<>wmsg) and (clear=cls) then clrscr;
end;

PROCEDURE msg(s:string);
begin
if not txtmode then exit;
sw(2);
window(1,1,80,25);
gotoxy(2,25);
fastwrite(#176,78,Norm);
vs(wherex+40-length(s) div 2,wherey,s,norm);
rw(2);
end;

PROCEDURE centre(s:string);
begin
vs(40-length(s) div 2,wherey,s,norm);
end;


PROCEDURE video(v:videomodes);
begin
CASE V OF
     normal   :
		begin
		normvideo;
		textcolor(white);
		textbackground(black);
                end;
     low      :
		begin
		LOWVIDEO;
		textcolor(white);
		textbackground(black);
        	end;

     bright     :HIGHVIDEO;
     REVERSED : begin
                     textcolor(black);
		     textbackground(white);
                end;
     flashing  : begin
                    textcolor(white+blink);
                    textbackground(black);
                end;
end;
setc('I');
end;


PROCEDURE put(var screenkeep:image);
begin
move(mem[Vseg:$0],screenkeep,4000);
end;

PROCEDURE get(var screenkeep:image);
begin
move(screenkeep,mem[Vseg:$0],4000);
end;

function myround(r:real):integer;
begin
if r<maxint then
	myround:=round(r)
else
	begin
msg('Rounding error due to bad input. Press ESC.'+noise);
waitfor(ESC);
{ Do something to prevent further operations}
	myround:=999;
	end;
end;

procedure myval(s:string;var r:real;var error:integer);
begin
{$i-}
if length(nospace(s))<10 then   {# ?10 : decide}
begin
if (s<>'') then val(s,r,error)
		end
		else
			begin
			msg('High value!.'+noise);
			delay(500);
			r:=999;
			end;
{$I+}
if (ioresult<>0) then error:=1;
end;

function mytrunc(r:real):integer;
begin
if r<maxint then
	mytrunc:=trunc(r)
else
	begin
msg('Truncation error due to bad input. Press ESC.'+noise);
 waitfor(ESC);
{ Do something to prevent further operations}
	mytrunc:=999;
	end;
end;

PROCEDURE waitfor(upto:char);
begin
if aborted or not txtmode then exit;
case upto of
ANY     :
	begin
	c:=readkey;
	if c=#0 then
		c:=readkey;
	end
else
	repeat
	c:=readkey;
	until c=upto;
end;
end;

PROCEDURE resetcrt;
begin
if not conf(inpname) then
{$I-}
    if eof(inp) then
	begin
		msg('End of file '+inpname+'. Press ESC.');
		waitfor(ESC);
		close(inp);
		inpname:='CON';
	end;
{$I+}
if ioresult<>0 then
		inpname:='CON';
end;

FUNCTION noise:char;
begin
sound(1000);
delay(25);
sound(500);
delay(50);
sound(1000);
delay(25);
nosound;
noise:=#255;
end;

FUNCTION justify(z:real;x,y:integer;lor:char):string;
begin
if z>=exp(x*ln(10)) then
			begin
			s:='High!';
			HighV:=TRUE;
			end
		else
			str(z:x:y,s);
case lor of
LEFT:
	begin
	i:=0;
		repeat
		i:=i+1;
		until s[i]<>' ';
	if i>1 then delete(s,1,i-1);
	justify:=fixlength(s,x+y+1,LEFT);
	end;
RIGHT:	justify:=fixlength(s,x+y+1,RIGHT);
end;
end;

FUNCTION fixlength(s:string;x:integer;lor:char):string;
begin
if lor=LEFT
	then
		while length(s)<x do insert(' ',s,length(s)+1)
	else
		while length(s)<x do insert(' ',s,1);
if length(s)>x then
	begin
	delete(s,x+1,length(s)-x);
{# debug aid }
	{
	msg('To VKS > length of string more than fixlength ?! '+noise);
	}
	end;
fixlength:=s;
end;

FUNCTION chklen(s:string;x:integer):string;
begin
if length(s)>x then delete(s,x+1,length(s)-x);
chklen:=s;
end;

FUNCTION strreal(z:real;x,y:integer):string;
begin
if z>=exp(x*ln(10)) then
			begin
			s:='High!';
			HighV:=TRUE;
			end
		else
			str(z:x:y,s);
strreal:=s;
end;

FUNCTION strint(z,x:integer):string;
begin
if (z<maxint) then
	begin
	str(z:x,s);
	strint:=s;
	end
	else strint:=fixlength('High!',x,LEFT);
end;

PROCEDURE readreal(hp:integer;prompt:string75;var r:real);
var
	error:integer;
begin
if aborted then exit;
resetcrt;
repeat
sw(1);
windows(winp,nocls);
inc(inL);
if inL>3 then inL:=3;
gotoxy(1,inL);
writeln;
str(r:format1:format2,s);
if readKSbuff in ['E',#0] then
	write(prompt);
KSread(hp,inpname,s,excode);
rw(1);
upstring(s);
	if s=^C then
		begin
		aborted:=TRUE;
		msg(noise);
		exit;
		end;
myval(s,r,error);
if error <>0 then
begin
if conf(inpname)
	then
		msg('Data error :  "'+s+'" not a real number.'+noise)
	else
	     begin
		     msg('Error in input file. Press ESC.'+noise);
		     waitfor(ESC);
		     resetcrt;
		     exit;
	     end;
end;
until error=0;
if insname<>'' then writeln(ins,s);
msg('');
end;  { Getreal }

PROCEDURE readint(hp:integer;prompt:string75;var r:integer);
var
	error:integer;
	rr:real;
begin
if aborted then exit;
resetcrt;
     repeat
sw(1);
	windows(winp,nocls);
	inc(inL);
        if inL>3 then inL:=3;
	gotoxy(1,inL);
	writeln;
	str(r:format1,s);
	if readKSbuff in ['E',#0] then
		write(prompt);
	KSread(hp,inpname,s,excode);
	upstring(s);
rw(1);
	if s=^C then
		begin
		aborted:=TRUE;
		msg('Current process aborted.');
		exit;
		end;
myval(s,rr,error);
r:=myround(rr);
if (error<>0)
		then
		begin
       if conf(inpname) then
			msg('Data error : "'+s+'" not an integer.'+noise)
		else
		     begin
		     msg('Error in input file. Press ESC.'+noise);
		     resetcrt;
		     exit;
		     end;
		 end;
until error=0;
if insname<>'' then writeln(ins,s);
msg('');
end;  { Getreal }

PROCEDURE readchar(hp:integer;prompt:string75;var r:char);
begin
if aborted then exit;
resetcrt;
sw(1);
windows(winp,nocls);
inc(inL);
if inL>3 then inL:=3;

gotoxy(1,inL);
writeln;
s:=r;
if readKSbuff in ['E',#0] then
     write(prompt);
KSread(hp,inpname,s,excode);
rw(1);
upstring(s);
	if s=^C then
		begin
		aborted:=TRUE;
		msg('Current process aborted.');
		exit;
		end;
r:=s[1];
if insname<>'' then writeln(ins,s);
msg('');
end;

PROCEDURE readstr(hp:integer;prompt:string75;var s:string);
begin
if aborted then exit;
resetcrt;
sw(1);
windows(winp,nocls);
	inc(inL);
if inL>3 then inL:=3;
gotoxy(1,inL);
writeln;
if readKSbuff in ['E',#0] then
	     write(prompt);
KSread(hp,inpname,s,excode);
rw(1);
     upstring(s);
     if s=^C
	 then
		begin
		aborted:=TRUE;
		msg('Current process aborted.');
		exit;
		end;
if insname<>'' then writeln(ins,s);
msg('');
end;

PROCEDURE writexy(var x,y:integer;s:string75);
begin
sw(1);
windows(wglob,nocls);
vs(x,y,s,norm);
y:=y+1;
rw(1);
end;

{
PROCEDURE setout(col:integer;var liner:integer);
begin
gotoxy(col,liner);
liner:=liner+1;
end;
}

PROCEDURE hline(x,y,z,pat,attr:integer);
begin
gotoxy(x,y);
fastwrite(chr(pat),z-x+1,attr);
end;

PROCEDURE vline(x,y,z,pat,attr:integer);
begin
for i:=y to z do vc(x,i,chr(pat),attr);
end;

PROCEDURE rv(x:boolean);
begin
case (rev xor x) of
	TRUE:
		begin
		attr:=rvse;
		video(reversed);
		end;
	FALSE:
		begin
		attr:=Norm;
		video(normal);
		end;
	end;
end;

PROCEDURE box(l,t,r,b,pat:integer;x:byte);
begin
if (pat=-1) and not conf(inpname) then exit;
if x=1 then attr:=rvse;
windows(wglob,nocls);
vc(l,t,#218,attr);
vc(r,t,#191,attr);
vc(l,b,#192,attr);
vc(r,b,#217,attr);
hline(l+1,t,r-1,196,attr);
hline(l+1,b,r-1,196,attr);
vline(l,t+1,b-1,179,attr);
vline(r,t+1,b-1,179,attr);
attr:=Norm;
end;

PROCEDURE sbox(var boxer:boxtype;xL,yL,xR,yR:integer);
var
	size:integer;
begin
sw(3);
with boxer do
begin
x1:=xl;
y1:=yl;
x2:=xr;
y2:=yr;
size:=(x2-x1+1)*2;
 for i:=y1 to y2 do
	move(mem[Vseg:scrmem(x1,i)],boxw[(i-1)*size],size);
end;
end;

PROCEDURE rbox(boxer:boxtype);
var size:integer;
begin
with boxer do
	begin
	size:=(x2-x1+1)*2;
	for i:=y1 to y2 do
		move(boxw[(i-1)*size],mem[Vseg:scrmem(x1,i)],size);
	end;
rw(3);
end;

PROCEDURE swapitem(var s:string;s1,s2:string);
begin
if s=s1 then s:=s2 else s:=s1;
end;

PROCEDURE read1(hp:integer;prompt:string;x1,y1,x2:integer;var s:string;var excode:char);
var c:char;
begin
c:=readksbuff;
readksbuff:='E';
sbox(boxer,x1-1,y1-1,x2+1,y1+1);
windows(wglob,nocls);
box(x1-1,y1-1,x2+1,y1+1,single,0);
gotoxy(x1+(x2-x1+1-length(prompt)) div 2,y1-1);
if readKSbuff in ['E',#0] then	write(prompt);
window(x1,y1,x2,y1);
clrscr;
gotoxy(2,1);
excode:=ESC;
KSread(hp,inpname,s,excode);
upstring(s);
rbox(boxer);
readksbuff:=c;
end;

PROCEDURE readrealbox(hp:integer;x1,y1,x2:integer;prompt:string75;var r:real;var excode:char);
var
	error:integer;
	sr:real;
begin
if aborted then	exit;
sr:=r;
error:=0;
repeat
if error=0 then str(r:format1:format2,s);
read1(hp,prompt,x1,y1,x2,s,excode);
myval(s,r,error);
if error <>0 then
begin
if conf(inpname)
	then
		msg('Data error :  "'+s+'" not a real number.'+noise)
	else
	     begin
		     msg('Error in input file. Press ESC.'+noise);
		     resetcrt;
		     exit;
	     end;
end;
until error=0;
if insname<>'' then writeln(ins,s);
msg('');
end;  { Getreal }

PROCEDURE readintbox(hp:integer;x1,y1,x2:integer;prompt:string75;var r:integer;var excode:char);
var
	error:integer;
	sr:integer;
	rr:real;
begin
if aborted then exit;
sr:=r;
error:=0;
repeat
if error=0 then str(r:format1,s);
read1(hp,prompt,x1,y1,x2,s,excode);
myval(s,rr,error);
r:=myround(rr);
if error <>0
		then
		begin
       if conf(inpname) then
			msg('Data error : "'+s+'" not an integer.'+noise)
		else
		     begin
		     msg('Error in input file. Press ESC.'+noise);
		     resetcrt;
		     exit;
		     end;
		 end;

until error=0;
if insname<>'' then writeln(ins,s);
msg('');
end;  { Getreal }

PROCEDURE readcharbox(hp:integer;x1,y1,x2:integer;prompt:string75;var r:char;var excode:char);
begin
if aborted then exit;
s[1]:=r;
s[0]:=#1;
read1(hp,prompt,x1,y1,x2,s,excode);
r:=s[1];
if insname<>'' then writeln(ins,s);
msg('');
end;

PROCEDURE readstrbox(hp:integer;x1,y1,x2:integer;prompt:string75;var s:string;var excode:char);
begin
if aborted then exit;
read1(hp,prompt,x1,y1,x2,s,excode);
if insname<>'' then writeln(ins,s);
msg('');
end;


PROCEDURE boxpix(hp:integer;menus:menutype;ALT:string20;l,t,r,b:integer;start:integer;
		 var opt:integer;var excode:char;jump:integer);
label 100,200;
var
	x,y,j,temp,tx,ty:integer;
	tempcode:char;
	key:char;
	sc1:integer;
	s:string;
	error:integer;
	rr:real;

PROCEDURE writealt(opt:integer);
begin
{
if highletter then
		begin
		rv(TRUE);
		vc(l+pos(alt[sc1],menus^[sc1])-1,t+opt-1,
		menus^[sc1][pos(alt[sc1],menus^[sc1])],attr);
		end;
}
end;


begin
attr:=norm;
if aborted then exit;
if not conf(inpname) then
	begin
	{$I-}
	KSread(1,inpname,s,excode);
	{$I+}
	myval(s,rr,error);
	opt:=myround(rr);
	if (ioresult<>0) or (error<>0) then
		begin
		msg('End of file . Press ESC.'+noise);
		waitfor(ESC);
		end;
		case opt of
			-1 :excode:=ESC;
			 0 :goto 100;
			 else
				excode:=ENTER;
		 end;
	end
	else
begin
100:
y:=t;
if excode=#222 then
		begin
			sc1:=start+opt-1;
			rv(FALSE);
			vs(l,t+(opt-1)*jump,menus^[sc1],attr);
			writealt(opt);
			exit;
		end;	{ used in multipix }

if excode in [#0,NOREAD,NOCHECK,#250] then
			for j:=1 to (b-t) div jump+1 do
					begin
						sc1:=start+j-1;
						rv(FALSE);
						vs(l,y,menus^[sc1],attr);
						y:=y+jump;
						writealt(j);
					end;
windows(wglob,nocls);
gotoxy(l,t+(opt-1)*jump);
if excode=#250 then exit;
repeat
if opt<1 then opt:=1;
if opt>(b-t) div jump +1 then opt:=1;
sc1:=start+opt-1;
rv(TRUE);
			vs(l,t+(opt-1)*jump,menus^[sc1],attr);
			writealt(opt);
rv(FALSE);
			if excode=NOREAD then exit;
key:=readkey;
if key=#0
	then
		begin
		Speckey:=TRUE;
		key:=readkey;
		if (key in globalalt) then
			begin
			REQ:=key;
			excode:=chr(altstate);
			exit;
			end
				else req:=#0;
		end
	else
		Speckey:=FALSE;

if not Speckey and highletter then
			begin
			temp:=pos(upcase(key),alt);
			if (temp>0) and (temp<=length(alt)) then
				begin
				vs(l,t+(opt-1)*jump,menus^[sc1],attr);
				writealt(opt);
				gotoxy(wherex,t+(temp-1)*jump);
				key:=ENTER;
				goto 200;
				end;
			end;

if Speckey then
case key of
	up      :
		begin
			gotoxy(l,wherey);
			if (wherey=t)
				then
					gotoxy(1,b)
				else
					gotoxy(1,wherey-jump);
				{ # range check error }
		end;
	down 	:
		begin
			gotoxy(l,wherey);
			if (wherey=b)
				then
					gotoxy(1,t)
				else
					gotoxy(1,wherey+jump);
		end;
	chr(59): 	begin
			sw(1);
			help(hp);
			end;

end
else
	if (key=ESC) and trap then
		begin
		if trap then
			begin
			tx:=wherex;
			ty:=wherey;
			msg('Do you want to abort ? (Y/N) ');
			if yes then aborted:=TRUE else key:=#250;
			msg('');
			gotoxy(tx,ty);
			end;
		end;
200:
if not ((key=ENTER) or (key=ESC)) then
			begin
			vs(l,t+(opt-1)*jump,menus^[sc1],attr);
			writealt(opt);
			end;
opt:=(wherey-t) div jump +1;
if (key=ENTER) or (key=ESC) then
			begin
			rv(TRUE);
			vs(l,t+(opt-1)*jump,menus^[start+opt-1],attr);
				{# range check error<inpfile error}
			rv(FALSE);
			end;
until (key in [ENTER,ESC]) or (excode=NOCHECK);
{     ((excode=NOCHECK) and (key in [LEFT, RIGHT, PGUP, PGDN]) and Speckey))
}
excode:=key;
gotoxy(l,wherey);
end;
{
if insname<>'' then
	writeln(ins,opt);
}
end;

FUNCTION alpha(s:string):boolean;
var i:integer;
begin
alpha:=FALSE;
if length(s)<>0 then
	for i:=1 to length(s) do
		if (s[i]<>' ') then alpha:=TRUE;
end;

FUNCTION exist(fname:string75):boolean;
var
	f:file;
	error:integer;
begin
if not alpha(fname) then
		begin
		exist:=FALSE;
		exit;
		end;
{$I-}
assign(f,fname);
reset(f);
close(f);
error:=ioresult;
if error<>0 then exist:=FALSE else exist:=TRUE;
{$I+}
end;



PROCEDURE multipix(menus:menutype;hov:char;lastmenu,Nrow,Ncol,colwidth:integer;
  var menustart:integer;x1,y1:integer;var choice:integer;var mpixcode:char);
var
  excode,tempcode:char;
  col,tempchoice,start:integer;
  sexcode:char;
  minus:integer;
PROCEDURE initwrite(Nrow,Ncol,colwidth,menustart,x1,y1:integer;var choice:integer);
var
	i,colx:integer;
begin
rv(FALSE);
i:=menustart-1;
repeat
if ((i-menustart+1) mod Nrow=0) then
		begin
		colx:=(i-menustart+1) div Nrow+1;
		window(x1+(colx-1)*colwidth,y1,x1+colx*colwidth-1,y1+Nrow);
		end;
	i:=i+1;
	lowvideo;
	write(menus^[i]);
until i=menustart+Nrow*Ncol-1;
windows(wglob,nocls);
end;

begin
col:=choice div Nrow;
if (choice mod Nrow)<>0 then col:=col+1;
if (mpixcode in [NOREAD,#0]) then
		box(x1-1,y1-1,x1+Ncol*colwidth,y1+Nrow,single,0);
repeat
if (mpixcode in [NOREAD]) or (excode in [PGUP,PGDN]) then
	begin
	initwrite(Nrow,Ncol,colwidth,menustart,x1,y1,choice);
	if mpixcode=NOREAD then exit;
	end;
start:=(col-1)*Nrow+menustart;
choice:=choice mod Nrow;
if choice=0 then choice:=Nrow;
excode:=NOCHECK;
if (hov='H') and ((Nrow-1)*Ncol+col>lastmenu)
		then
			begin
			minus:=lastmenu div Ncol-Nrow+1;
			if (lastmenu mod Ncol)<col then minus:=minus-1;
			end
		else minus:=0;
boxpix(1,menus,ALT,x1+(col-1)*colwidth,y1,x1+col*colwidth,y1+Nrow-1+minus,start,choice,excode,1);

if excode in [LEFT,RIGHT] then
		begin
		sexcode:=excode;
		excode:=#222;
	boxpix(1,menus,alt,x1+(col-1)*colwidth,y1,x1+col*colwidth,y1+Nrow-1+minus,start,choice,excode,1);
		excode:=sexcode;
		end;
	case excode of
		LEFT:	if (col>1) then col:=col-1;
		RIGHT:  if (col<Ncol) then col:=col+1;
		ALTKEY:	begin
			col:=choice div Nrow;
			if (choice mod Nrow)<>0 then col:=col+1;
			end;
		PGUP:	begin
				menustart:=menustart-Nrow*Ncol;
				if menustart<=0 then menustart:=1;
			end;
		PGDN:	begin
				if (menustart+Nrow*Ncol<M_limit) and
					(menustart+Nrow*Ncol<lastmenu)
					 then
					menustart:=menustart+Nrow*Ncol;
			end;
		end;
		if (hov='H') then
		begin
		if ((choice-1)*Ncol+col<=lastmenu) { ALTKEY deleted }
			then
				choice:=(col-1)*Nrow+choice
			else
				if col>1 then col:=col-1;
		end
		else
			choice:=(col-1)*Nrow+choice;
until (excode in [ESC,ENTER,altkey])
      or (mpixcode=NOCHECK);
mpixcode:=excode;
{
if excode in [UP, DOWN, LEFT, RIGHT, ALTKEY]
	then
	    begin
		tempcode:=NOREAD;
		tempchoice:=choice;
		col:=choice div Nrow;
		if (choice mod Nrow)<>0 then col:=col+1;
		initwrite(Nrow,Ncol,colwidth,menustart,x1,y1,tempchoice);
		boxpix(1,menus,alt,x1+(col-1)*colwidth,
			y1,x1+col*colwidth,y1+Nrow-1,start,tempchoice,tempcode,1);
	    end;
}
end;

PROCEDURE CALL_SHELL;
var
	screen:array[1..1] of image;
begin
  put(screen[1]);
  clrscr;
  writeln('Passing control to DOS, Type EXIT to return to CASEPRO.');
    SwapVectors;
    Exec(GetEnv('COMSPEC'),'');
    SwapVectors;
    if DosError <> 0 then
	msg('Could not activate COMMAND.COM. Press ESC.');
    get(screen[1]);
  end;
PROCEDURE ClearBuffer;
var C:Char;
begin
while KeyPressed do C:=ReadKey;
end;

FUNCTION PrinterReady;
Var Ch:Char;
Begin
Repeat
	Regs.ah:=2;
	Regs.dx:=0;
	Intr($17,Regs); { OBTAIN PRINTER STATUS, 144 INDICATES PRINTER READY }
	If Regs.ah<>144 Then  msg('Printer Not Ready. Retry/Abort ? '+noise);
   repeat
   ch:=upcase(readkey);
   until ch in ['R','A'];
   msg('');
   If Ch='A' Then
		begin  { ABORT }
		  PrinterReady:=False;
                  Exit;
		End;
Until Regs.ah=144; { EITHER ABORT MIDWAY, OR REPEAT TILL REGS.AH=44 }
PrinterReady:=True;
End;

PROCEDURE NextKeys;
begin
repeat until keypressed;
B1:=mem[$0040:lo(mem[$0040:$001A])];
B2:=mem[$0040:lo(mem[$0040:$001A])+1];
end;

(*
FUNCTION FileExists;
Var Sr:SearchRec;
Begin
Findfirst(Fn,Archive,Sr); { LOOK FOR NORMAL AND R/O FILES }
FileExists:=DosError=0;
End;
*)

PROCEDURE Full;
Begin
Window(1,1,80,25);
End;

PROCEDURE windco(var wind:windrec);
Begin
with wind do
	begin
	x1:=Lo(Windmin)+1;
	y1:=Hi(Windmin)+1; { WINDMIN & WINDMAX ARE TURBO }
	x2:=Lo(Windmax)+1;
	y2:=Hi(Windmax)+1; { PASCAL SUPPLIED FUNCTIONS }
	end;
End;

PROCEDURE sw(x:byte);		{ Stores wx,wy with window }
Begin
windco(wind[x]);
wind[x].cx:=wherex;
wind[x].cy:=wherey;
End;

PROCEDURE rw(x:byte);           { Resores sw's }
Begin
with wind[x] do
	begin
	window(x1,y1,x2,y2);
	gotoxy(cx,cy);
	end;
End;


PROCEDURE KSgoto; { goto absolute _ location }
Begin
Regs.bh:=0;
Regs.ah:=2; Regs.bh:=0; Regs.dh:=L-1; Regs.dl:=C-1; Intr($10,Regs);
End;

PROCEDURE WhereC;
Begin
Regs.bh:=0;
Regs.ah:=3; Intr($10,Regs); { Find Cursor Location And Mode. }
C:=Regs.dl+1; L:=Regs.dh+1;
End;

PROCEDURE kswrite(x,y:byte;s:string);
begin
ksgoto(x,y);
write(s);
end;

procedure getfiles(inpdir:string;var dirfiles:files;var numfiles:integer);
var
	count:integer;
	reg:registers;
	DTA : array[0..127] of byte;
PROCEDURE oneEntry;
var
	j:integer;
begin
msdos(reg);
{
if (count mod 4)=0 then writeln;
if reg.al=0
	then
		gotoxy(17+(count mod 4)*15,wherey)
	else
		writeln;
}
count:=count+1;
j:=30;
for i:=1 to 12 do
if reg.al=0 then
if dta[j]=0
	then
		{write(' ')}
	else
		begin
		{write(chr(dta[j]));}
		insert(chr(dta[j]),dirfiles[numfiles],length(dirfiles[numfiles])+1);
		j:=j+1;
		end;
end;

PROCEDURE initialize;
label 100;
var
	indir:string;
	s:string;
begin
count:=0;
indir:=inpdir;
i:=length(inpdir);
100:	if (indir[i]='\') or (indir[i]=' ') then
				begin
				delete(indir,i,1);
				dec(i);
				goto 100;
				end;
s:=indir+'\*.*';
s:=s+chr(0);
with reg do
	begin
		ah:=$1A;
		ds:=seg(dta);
		dx:=ofs(dta);
		msdos(reg);
		ah:=$4E;
		al:=0;
		cx:=$01;
		ds:=seg(s);
		dx:=ofs(s[1]);
	end;
end;

begin
	initialize;
	numfiles:=0;
	with reg do
	    while al=0 do
		begin
			inc(numfiles);
			oneentry;
			ah:=$4F;
		end;
dec(numfiles);
end;

procedure selfromdir(xc,yc:integer;inpdir:string;var fname:string;var excode:char);
var
	j:integer;
	screen2:image;
	dirfiles:files;
	numfiles:integer;
	menustart:integer;
	i,i10:integer;
begin
put(screen2);
for i:=1 to 100 do dirfiles[i]:='';
getfiles(inpdir,dirfiles,numfiles);
menustart:=1;
for i:=1 to 100 do menus^[i]:='             ';
for i:=1 to numfiles do
	menus^[i]:=fixlength(' '+dirfiles[i],13,LEFT);
{
i10:=numfiles div 4 +1 ;
for i:=1 to (numfiles div 4+1)*4 do
if (i mod 10<>0) then
	menus^[i div i10+1 +(i mod i10 -1)*4]:=fixlength(' '+dirfiles[i],13,LEFT)
	else
	menus^[i div i10+(i10-1)*4]:=fixlength(' '+dirfiles[i],13,LEFT);
j:=0;
while j<=numfiles do
begin
menus^[j]:=fixlength(' '+dirfiles[],13,LEFT);
}

ALT:='';
scode[4]:=NOREAD;
multipix(menus,'H',numfiles,10,4,13,menustart,xc,yc,choice[4],scode[4]);
scode[4]:=#0;
multipix(menus,'H',numfiles,10,4,13,menustart,xc,yc,choice[4],scode[4]);
if scode[4]<>ESC
	then fname:=menus^[menustart-1+choice[4]]
	else excode:=scode[4];
       fname:=nospace(fname);
scode[1]:=#0;
get(screen2);
end;



Begin  { Initialisation }
 OldExitProc := ExitProc;                { save previous exit proc }
 ExitProc := @MyExitProc;                { insert our exit proc in chain }

Intr($11,Regs); { Equipment Determination. Bytes 4 & 5 Indicate Video Card }

If ((Regs.al And $30)=$30)
	Then VSeg:=$b000 {MonoCard}
	Else VSeg:=$b800;
video(normal);
clrscr;
inpname  :='CON';
outname  :='CON';
insname  :='';
assign(out,outname);
assigncrt(out);
rewrite(out);
rev:=FALSE;
highletter:=TRUE;
for i:=1 to 10 do
		begin
		choice[i]:=1;
		scode[i]:=#0;
		end;
end.
