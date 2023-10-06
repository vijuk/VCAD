							     {
*****************************************************************************
Software              	   :    VCAD

Programmer's Name          :	Viju.K.S.
Address                    : 	Kothuvady house,
                                Kizhakkepram,
				N.Paravur-683513,
                                Kerala.
                                Ph:04851-42391.

Contents of package        :	A.Analysis
                                	1.Substitute frame
                                	2.Kani's method
                                	3.Matrix method
                                        	 i) Plane frame
                                                ii) Continuos beam
                                               iii) Plane truss
                                                iv) Space truss
                                                 v) Grid
                                                vi) Space frame(not started)
                                2.Design
                                	1.Slab
                                        2.Beam
                                        3.Column
                                        4 Footing
                                        5.Staircase
                                3.Graphics
                                	1.Pre-processor
                                        2.Post-processor
                                4.Text editor

Additional features	   :    1.Pull-down/Pop-up menus
				2.On-line help
				3.Electronic manual
                                4.Hot keys
                                5.User interactive
                                6.System commands/Dos shell

Starting date of project   : 	1-1-91
ompletion date            : 	1-3-95
Starting date of dubugging : 	1-3-95

*****************************************************************************}


PROGRAM VCAD;
uses
	crt,dos,Overlay,lib,plib,olib,{ana,}des,dlib{,graphics};
label
	100,200,300;
var
	screen:image;
	head:headtype;
	lasto:array[1..6] of integer;
	i,j:integer;
	scode2,scode3:char;
const
	choice2:integer=1;
	choice3:integer=1;
	hchoice:integer=1;
	hpixcode:char=#0;

	sconfigfile:string='CONFIG.CAD';
	rconfigfile:string='DEFCONFIG.CAD';

procedure drawsetup;
begin
sideborder;
bottombar;
if wset=On then
	begin
	window(1,1,80,25);
	gotoxy(2,2);
	fastwrite(#196,78,High);
	centre('VCAD 1.01: REC CALICUT');
	windows(wout,nocls);
	end;
end;
function srange(a:ranger):string;
var s:string;
	flag:boolean;
	i:integer;
begin
flag:=TRUE;
s:='';
for i:=1 to 5 do
	if a[i]>0 then
		begin
		insert(strint(a[i],1)+',',s,length(s)+1);
		flag:=TRUE;
		end;
if flag then delete(s,length(s),1);
srange:=s;
end;

procedure resrange(sa:string;var a:ranger);
var
	s:string;
	error:integer;
	i:integer;
begin
for i:=1 to 5 do
	begin
	if i<5 then
		begin
		s:=copy(sa,1,pos(',',sa)-1);
		delete(sa,1,pos(',',sa));
		end
	else
		s:=sa;
	val(s,a[i],error);
	end;
end;

procedure execmenu(var screen1:image);
label 300;
var
	temp:string;
	i:integer;
	c:char;
	s:string;
	screen,screen3:image;
	fname:string[13];
begin
choice2:=1;
repeat
setc('N');

scode2:=NOCHECK;
case hchoice of
1:
	begin
	box(2,3,12,9,single,0);
	menus^[1]:=' System  ';
	menus^[2]:=' Copy    ';
	menus^[3]:=' Rename  ';
	menus^[4]:=' Erase   ';
	menus^[5]:=' Display ';
	boxpix(1,menus,'SCRED',3,4,11,8,1,choice2,scode2,1);
{*1}
	if scode2=ENTER then
	case choice2 of
		1	: 	begin
				call_shell('VCAD');
				get(screen1);
				end;
		2	: copyf;
		3	: renamef;
		4	: deletef;
		5   	: dirf;
		end;
{*1}

	aborted:=FALSE;
end;
2:     {scode2:=RIGHT;} {anapro(scode2) viju-};
3:     {scode2:=RIGHT} despro(scode2);

{4:scode2:=RIGHT;}
4:     begin
	slb:=TRUE;
	LD:=TRUE;
	      box(32,3,57,8,single,0);
	      menus^[1]:=' Graphics               ';
	      menus^[2]:=' Text editor            ';
	      menus^[3]:=' Windows            '+wset+' ';
	      menus^[4]:=' Status bars        '+sbset+' ';
	      boxpix(1,menus,'GTWS',33,4,56,7,1,choice2,scode2,1);
	if scode2=ENTER then
	      begin
	      case choice2 of
		1:
				begin

	put(screen);
	choice3:=1;
	repeat
	box(45,5,73,11,single,0);
	menus^[1]:=' Create Drawing            ';
	menus^[2]:=' Generate analysis input   ';
	menus^[3]:=' view Load diagram         ';
	menus^[4]:=' view Bm/sf diagram        ';
	menus^[5]:=' view Structure            ';
	scode3:=#0;
	boxpix(1,menus,'CGLBS',46,6,72,10,1,choice3,scode3,1);
	if scode3=ENTER then
	case choice3 of
		1	:
			begin
readstrbox(1,40,7+choice3,75,'Drawing name',proname,excode);

{if excode<>ESC then grapher(0,proname); viju- }

	end;
		2	:
			begin
readstrbox(1,40,7+choice3,75,'Drawing name',proname,excode);

{if excode<>ESC then 		grapher(1,proname); viju-}

	end;
		3	:
			begin
fname:='';
readstrbox(1,40,7+choice3,75,'Drawing name',fname,excode);

{if excode<>ESC then grapher(2,fname);viju-}

	end;
		4	:
				begin
fname:='';
readstrbox(1,40,7+choice3,75,'Drawing name',fname,excode);

{if excode<>ESC then grapher(3,fname);viju-}

				end;
		5	:
				begin
readstrbox(1,40,7+choice3,75,'Drawing name',proname,excode);

{if excode<>ESC then grapher(4,proname); viju-}

				end;

		end;
	get(screen);
	aborted:=FALSE;
	until scode3=ESC;
	get(screen);
end;
		2:begin
			msg('Not Enough Memmory.'+noise);
			delay(500);
			msg('');
		  end;
		3:if wset=On then wset:=Off
				else if wset=Off then wset:=On;
		4:if sbset=On then sbset:=Off
				else if sbset=Off then sbset:=On;
		      end;
	      if (choice2 in [3,4])
		     then
			begin
			drawsetup;
			windows(wout,cls);
			put(screen1);
			end;
		end;
		end;
5:
	      begin
	box(42,3,70,7,single,0);
	menus^[1]:=' Configuration             ';
	menus^[2]:=' Automated Building Design ';
	menus^[3]:=' Save all options          ';
	boxpix(1,menus,'CAS',43,4,69,6,1,choice2,scode2,1);
{sbox(boxer,22,4,79,18);}
put(screen3);
if scode2=ENTER then
	case choice2 of
		1	:
			begin
{
	box(42,3,70,7,single,0);
	menus^[1]:=' Loads           ';
	menus^[2]:=' Dimensions      ';
	menus^[3]:=' Output          ';


	Earth Quake Load On
	Wind Load        On
	Dead Load        On
	Live load        On

	Frames required       All
	Slab design file      On
	Load diagram file     On


	boxpix(1,menus,'SCRED',43,4,69,6,1,choice2,scode2,1);
}
	box(23,5,78,17,single,0);
	choice3:=1;
	repeat
	menus^[1]:=' Project name                     '
				+fixlength(proname,20,LEFT);
	menus^[2]:=fixlength(' Parameters',54,LEFT);
	menus^[3]:=' Live load on slabs               '
				+fixlength(strreal(liveload,2,3),20,LEFT);
	menus^[4]:=' Safe bearing capacity of soil    '
				+fixlength(strreal(sbc,3,2),20,LEFT);
	menus^[5]:=' Breadth of beams                 '
				+fixlength(strint(bfixedB,3),20,LEFT) ;
	menus^[6]:=' Breadth of columns               '
				+fixlength(strint(cfixedB,3),20,left);
	menus^[7]:=' Range of depth for slabs         '
				+fixlength(srange(sdrange),20,LEFT);
	menus^[8]:=' Range of depth for beams         '
				+fixlength(srange(bdrange),20,LEFT);
	menus^[9]:=' Range of depth for columns       '
				+fixlength(srange(cdrange),20,LEFT);
	menus^[10]:=' Save configuration               '
				+fixlength(sconfigfile,20,LEFT);
	menus^[11]:=' Restore configuration            '
				+fixlength(rconfigfile,20,LEFT);
	scode3:=#0;
	boxpix(1,menus,'',24,6,77,16,1,choice3,scode3,1);

if scode3=ENTER then
	case choice3 of
1:readstrbox(1,40,7+choice3,75,'Project name',proname,excode);
2:
	begin
{*2}
	destype:='S';
	setdefconstants;
	constants(20,7+choice3);
{*2}
	end;
3:readrealbox(1,40,7+choice3,75,'Live load on slabs',liveload,excode);
4:readintbox(1,40,7+choice3,75,'Safe bearing capacity',sbc,excode);
5:readintbox(1,40,7+choice3,75,'Breadth of beams',bfixedB,excode);
6:readintbox(1,40,7+choice3,75,'Breadth of columns',cfixedB,excode);
7:
	begin
	s:=srange(sdrange);
	readstrbox(1,40,7+choice3,75,'Slab depth range',s,excode);
	if excode<>ESC then resrange(s,sdrange);
	end;
8:
	begin
	s:=srange(bdrange);
	readstrbox(1,40,7+choice3,75,'Beam depth range',s,excode);
	if excode<>ESC then resrange(s,bdrange);
	end;
9:
	begin
	s:=srange(cdrange);
	readstrbox(1,40,7+choice3,75,'Column depth range',s,excode);
	if excode<>ESC then resrange(s,cdrange);
	end;
10:
	begin
	readstrbox(1,40,7+choice3,75,'Save config file',sconfigfile,excode);
	end;
11:
	begin
	readstrbox(1,40,7+choice3,75,'Restore config file',rconfigfile,excode);
	end;
end;
aborted:=FALSE;
until scode3=ESC;
{	rbox(boxer);}
get(screen3);

		end;
		end;
		end;
	      6:
	      begin
	box(52,3,65,8,single,0);
	gotoxy(56,3);
	write('Help on');
	menus^[1]:=' Menus      ';
	menus^[2]:=' Design     ';
	menus^[3]:=' Analysis   ';
	menus^[4]:=' Graphics   ';
	boxpix(1,menus,'MDAG',53,4,64,7,1,choice2,scode2,1);
		end;
	end;
aborted:=FALSE;
until (scode2 in [ESC,LEFT,RIGHT,chr(altstate)]);

300:
{if req in globalalt then scode2hpixcode:=ESC;}
case req of
	#33:hchoice:=1;
	#30:hchoice:=2;
	#32:hchoice:=3;
	#24:hchoice:=4;
	#22:hchoice:=5;
	#35:hchoice:=6;
	end;
windows(wglob,nocls);
end;

procedure copyright;
var
	i,x,k:integer;
	notice:string;
	c:char;
begin
notice:='WELCOME to VCAD... Warning :- VCAD is now under debugging. At this stage ';
insert('use of the output results for practical ',notice,length(notice)+1);
insert('problems without cross-checking is not recommended. ',notice,length(notice)+1);
insert('If you have any suggestions or comments please call 04851-42391. ',notice,length(notice)+1);
{insert(' ',notice,length(notice)+1);}
randomize;
window(19,4,62,17);
video(reversed);
clrscr;
box(18,3,63,17,single,1);
window(19,4,62,17);
{write('같같같같같같같같같같같같같같같같같같같같같같');
}
write('栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢栢');
write('                                            ');
write('                     VCAD                   ');
{write('            Dosix Software Products         ');}
write('                                            ');
write('              All Rights Reserved           ');
write('                  Release 1.01              ');
write('컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
write(' Report problems to :                       ');
write('                 Viju K.S., Kothuvady House,');
write('             Kizhakkepram, N.Paravur-683513.');
write('                       Phone : 04851-442391.');
write('같같같같같같같같같같같같같같같같같같같같같같');
video(flashing);
write('         PRESS ANY KEY TO CONTINUE          ');
video(normal);
windows(wglob,nocls);

x:=81;
k:=1;
if keypressed then c:=readkey else c:=#0;
repeat
dec(x);
gotoxy(x,20);
if k>length(notice) then k:=1;
i:=k;
while (wherex<80) and (i<=length(notice)) do
	begin
	write(notice[i]);
	inc(i);
	end;
if (wherex<80) then
	begin
	i:=1;
	while (wherex<80) do
		begin
		write(notice[i]);
		inc(i);
		end;
	end;

if x=1 then
	begin
{
gotoxy(1,19);
write('컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
gotoxy(1,21);
write('컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴');
}
	inc(k);
	inc(x);
	end;
if upcase(c)='S' then sound(random(1000));

{*** Adjust speed for different processors}
delay(300);
until keypressed;
nosound;
end;

procedure lastwarning;
begin
{
windows(wglob,cls);
gotoxy(1,1);
fastwrite(#178,80,rvse);
writeln;
video(flashing);
centre('Caution !!! For copy protection some errors have been included in this demo.');writeln;
video(normal);
for i:=1 to 80 do write(#176);
writeln;
writeln('      VCAD is now under debugging stage. The programmer will not be responsible');
writeln('for any mishappening due to  the direct application of the results to practical');
writeln('problems.  If you have any difficulties  or suggestions please call 04851-42391');
writeln('or write to Dosix Software Products.');
writeln;
fastwrite(#176,80,rvse);
writeln;
centre('Thank YOU for being the user of VCAD.'); writeln;
for i:=1 to 80 do write(#178);
write('A:\>');
readln;
}
windows(wglob,cls);
gotoxy(1,25);
write('Thank you for using VCAD . ');
end;

  procedure initcheck;
  begin
  if OvrResult <> ovrOk then
  begin
    case OvrResult of
      ovrError:
        WriteLn('Program has no overlays.');
      ovrNotFound:
        WriteLn('Overlay file not found.');
    end;
    Halt(1);
  end;
  end;

   procedure initemscheck;
   begin
   case OvrResult of
     ovrIOError:
       WriteLn('Overlay file I/O error.');
     ovrNoEMSDriver:
       WriteLn('EMS driver not installed.');
     ovrNoEMSMemory:
       WriteLn('Not enough EMS memory.');
   else
     WriteLn('Using EMS for faster overlay swapping.');
   end;
   end;

{****************         MAIN PROGRAM       ***********************}
begin
setc('N');
{
  OvrInit('c:\tp\ANA.tpu');
  initcheck;
  OvrInitEMS;
  initEMScheck;

  OvrInit('c:\tp\GRAPHICS.tpu');
  initcheck;
  OvrInitEMS;
  initEMScheck;

  writeln('Press ESC');
waitfor(ESC);
}

HN:=6;
new(menus);
head[1]:='File';
head[2]:='Analyse';
head[3]:='Design';
head[4]:='Options';
head[5]:='Utils';
head[6]:='Help';


globalalt:=[#33,#30,#32,#24,#22,#35];
for i:=1 to HN do lasto[i]:=1;
copyright;
video(normal);
drawsetup;
hpixcode:=NOREAD;
hchoice:=0;
hpix(1,1,80,head,hchoice,hpixcode);
video(normal);
hchoice:=1;
windows(wout,cls);
scode2:=ESC;
repeat
if scode2=ESC then
		hpixcode:=ENTER
		else
		hpixcode:=NOREAD;
hpix(1,1,80,head,hchoice,hpixcode);
put(screen);
if hpixcode<>ESC then
	begin
	repeat
	choice2:=lasto[hchoice];
	execmenu(screen);
	get(screen);
	case scode2 of
		left:
			begin
			lasto[hchoice]:=choice2;
			hchoice:=hchoice-1;
			if hchoice=0 then hchoice:=HN;
			end;
		right:
			begin
			lasto[hchoice]:=choice2;
			hchoice:=hchoice+1;
			if hchoice=HN+1 then hchoice:=1;
			end;
	       ENTER: lasto[hchoice]:=choice2;
	     end;
        aborted:=FALSE;
	until (scode2 in [ESC,LEFT,RIGHT,chr(altstate)]);
end;
aborted:=FALSE;
until hpixcode=ESC;

lastwarning;
dispose(menus);
setc('N');
end.

excode

#0	 - ENTER,ESC
NoCHECK  - ANYKEY
#1	 - ENTER,ESC,RIGHT,LEFT
#2	 - ENTER,ESC,RIGHT,LEFT,PGUP,PGDN
NOREAD   - NOKEY
#250     - Initwrite
#255	 - delete highlight

ALT,GLOBALALT ;



