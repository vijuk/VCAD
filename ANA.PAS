{$F+}
unit ana;
interface
procedure anapro(var excoder:char);
implementation

uses
     crt,lib,dos,alib,kani,sub,mat;

type
    files=array[1..100] of string[12];

const h=#9;

var
loaded:boolean;
afilename:string75;
dirfiles:files;
numfiles:integer;
dirfile:text;
s:string;
found:boolean;
i:integer;
screen:image;
xc,yc:integer;
const
	method:array[1..7] of string[27]=
		 ('Plane frame      (Matrix) ',
		  'Continuous beam  (Matrix) ',
		  'Grid             (Matrix) ',
		  'pLane truss      (Matrix) ',
		  'Space truss      (Matrix) ',
		  'plAne frame      (Kani)   ',
		  'sUbstitute frame          ');
	cmethod:integer=1;


PROCEDURE loadfile(fname:string;excode:char;var loaded:boolean);
var scheck:string;
begin
menustart:=1;

if excode='R'
then
	begin
	if conf(fname) then
		begin
			hpx:=0;
			hpy:=0;
			hpz:=0;
			loaded:=TRUE;
			exit;
		end;
	msg('Reading file '+fname+'...   ');
	setfile(inp,inpname,fname,'R',excode);
	readln(inp,scheck);
	upstring(scheck);
	if scheck<>'FRAME' then
		begin
		msg('Input file does not confirm to VCAD format. Press ESC.');
		waitfor(ESC);
		msg('');
		close(inp);
		loaded:=FALSE;
		exit;
		end;

	readln(inp,hpx,hpy,hpz);
	loaded:=TRUE;
	if ioresult<>0 then
		begin
		msg('Invalid numeric format.Press ESC');
		waitfor(ESC);
		close(inp);
		loaded:=FALSE;
		exit;
		end;
	end
else
if excode='W' then
	begin
		if not conf(fname) then
			begin
			setfile(inp,inpname,fname,'W',excode);
			writeln(inp,'FRAME');
			writeln(inp,0,h,0,h,0,h,'END');
			close(inp);
			setfile(inp,inpname,fname,'R',excode);
			end;
		loaded:=TRUE;
		{if conf(inpname) then assigncrt(inp);}
	end;
NM:=0;
datano:=1;
for i:=1 to 75 do DM^[i]:=cdata;
readinput;
inpname:='CON';
end;

procedure checkfile(var fname:string;var excode:char);
begin
excode:=#0;
if not exist(fname) then
	if not alpha(fname) then
		begin
			excode:=#0;
			selfromdir(1,1,inpdir,fname,excode);
			excode:=#0;
		end
	else
		begin
			msg('Invalid path or file not exist.');
			excode:=ESC;
		end;
end;

procedure editfile(fname:string);
var
	screen2:image;
begin
put(screen2);
excode:='R';
checkfile(fname,excode);
if excode=#0 then
		loadfile(fname,'R',loaded)
	     else
		exit;
if not loaded then exit;
repeat
scode[2]:=#0;
get(screen2);
box(7,6,21,12,single,0);
menus^[1]:=' Add         ';
menus^[2]:=' Remove      ';
menus^[3]:=' Copy        ';
menus^[4]:=' Modify      ';
menus^[5]:=' List        ';
scode[2]:=#0;
boxpix(1,menus,'ARCML',8,7,20,11,1,choice[2],scode[2],1);
if scode[2]=ENTER
     then
	case choice[2] of
	{Add}   	1:
				begin
				datano:=NM+1;
				readinput;
				end;
	{Remove}	2:	delete_data;
	{Copy}          3:      copy_data;
	{Modify}        4:      modify_data;
	{List}          5:      display_data;
	end;
if aborted then	aborted:=FALSE;
until scode[2]=ESC;
scode[1]:=#0;
end;

{***********}

procedure setoptions;
var i:integer;
begin
box(7,10,59,21,single,0);
choice[3]:=1;
scode[3]:=#0;
repeat
menus^[1]:=' Method of analysis     '+fixlength(method[cmethod],27,LEFT);
menus^[2]:=' Type of input          '+fixlength(inptype,27,LEFT);
menus^[3]:=' Input  Directory       '+fixlength(inpdir,27,LEFT);	{ school\*.inp }
menus^[4]:=' Output Directory       '+fixlength(outdir,27,LEFT);	{ school\*.out }
menus^[5]:=' File output            '+fixlength(outtype[1],27,LEFT);	{ Compact }
menus^[6]:=' Console output         '+fixlength(outtype[2],27,LEFT);	{ detailed }
menus^[7]:=' Printer output         '+fixlength(outtype[3],27,LEFT);	{ Compact }
menus^[8]:=' Design input files     '+fixlength(interstatus,27,LEFT);	{ on/off }
menus^[9]:=' BMD,SFD,DD files       '+fixlength(graphstatus,27,LEFT);	{ on/off }
menus^[10]:=' Accuracy required      '+fixlength(strreal(accuracy,7,6),27,LEFT); { 0.001 }
scode[3]:=#0;
boxpix(1,menus,'MTIOFCPDBAG',8,11,58,20,1,choice[3],scode[3],1);
if scode[3]=ENTER then
	case choice[3] of
		1:
			begin
	      box(30,12,58,20,single,0);
		scode[4]:=#0;
		for i:=1 to 7 do menus^[i]:=' '+method[i];
		boxpix(1,menus,'PCGLSAU',31,13,57,19,1,choice[4],scode[4],1);
		if scode[4]=ENTER then
				begin
				cmethod:=choice[4];
				case cmethod of
					1..5:soker:='M';
					6:soker:='K';
					7:soker:='S';
					end;
				end;
	      end;

		2:	swapitem(inptype,'Single frame','Structure');
		3:      readstrbox(1,10,12+choice[3],70,'Input directory',inpdir,excode);
		4:      readstrbox(1,10,12+choice[3],70,'Output directory',outdir,excode);
		5:	swapitem(outtype[1],'Compact','Detailed');
		6:	swapitem(outtype[2],'Compact','Detailed');
		7:	swapitem(outtype[3],'Compact','Detailed');
		8:      swapitem(interstatus,'On ','Off');
		9:      swapitem(graphstatus,'On ','Off');
	       10:
		begin
		format2:=5;
		readrealbox(1,10,12+choice[3],70,'New accuracy',accuracy,excode);
		format2:=2;
		end;
	end;
{if aborted then aborted:=FALSE;}
until (scode[3]=ESC);
scode[1]:=#0;
end;

procedure callxycols(afilename:string);
var
	c1,c2,c3,c4,c5:char;
	xfile,yfile,cfile:text;
	afilename1,afilename2:string;
	q1,q2,p1,p2:integer;
	af1,af2,m1,m2:real;
	flag:boolean;
	x1,y1,z1,x2,y2,z2:real;
	footfile:text;
	found:boolean;
	b,d:real;
	s:string;
begin
setfile(xfile,s,'X.CNI','R',excode);
setfile(yfile,s,'Y.CNI','R',excode);
setfile(cfile,s,firstname(afilename)+'.CNI','W',excode);
if excode=ESC then exit;
setfile(footfile,s,firstname(afilename)+'.FGI','W',excode);
if excode=ESC then exit;
writeln(cfile,'C (Column Input)');
writeln(footfile,'F (Footing Input)');
while not eof(xfile) do
	begin
	readln(xfile,x1,y1,z1,q1,p1,af1,m1,b,d,afilename1);
	found:=FALSE;
	reset(yfile);
while not eof(yfile) and not found do
	begin
	readln(yfile,x2,y2,z2,q2,p2,af2,m2,d,b,afilename1);
	if eq(x1,x2) and eq(y1,y2) and eq(z1,z2) then
		begin
		found:=TRUE;
writeln(cfile,
'COL No.',afilename1,':',q1,'/',p1,' ':10,h
,b:10:3,h
,d:10:3,h
,(af1+af2):15:3,h
,m1:15:3,h
,m2:15:3,h
,4,h
,0,h
,0
);
		if q1=1 then
			begin
writeln(footfile,'FOOTING No.',afilename1,':',q1,'/',p1,h
,(af1+af2):15:3,h
,m1:15:3,h
,m2:15:3,h
,sbc,h
,b:10:3,h
,d:10:3
);
			end;
		end;
	end;
	if not found then
		begin
		msg('Connectivity error in colfiles.ESC ');
		waitfor(ESC);
		end;
end;
writeln(cfile,'END');
writeln(footfile,'END');
close(xfile);
close(yfile);
close(cfile);
close(footfile);
end;

procedure analysefile;
var
	tempfile:text;
	i:integer;
begin
if inptype='Structure' then
	begin
	setfile(tempfile,s,'X.CNI','W',excode);
	if excode<>ESC then close(tempfile);
	setfile(tempfile,s,'Y.CNI','W',excode);
	if excode<>ESC then close(tempfile);
	end;
begin
	if inptype='Structure' then
		begin
		setfile(dirfile,s,profile,'R',excode);
		readln(dirfile,s);
	if s<>'PROJECT' then
	begin
		msg('File does not confirm to VCAD project file format.Press ESC.'+noise);
		waitfor(ESC);
		msg('');
		exit;
	end;
		i:=0;
		while not eof(dirfile) do
		begin
		i:=i+1;
		readln(dirfile,afilename);
		dirfiles[i]:=afilename;
		if exist(afilename) then
			begin
			loadfile(afilename,'R',loaded);
			if not loaded then exit;
			case soker of
			'K':kani_ana(afilename);
			'S':{sub_ana(afilename)};
				else
			msg('Method not installed'+#7);
			end;
			end
			else
			begin
			msg('File '+afilename+' not found. Process aborted.');
			exit; {#}
			end;
		end;
		callxycols(profile);
		end
		else
			begin
			excode:='R';
			checkfile(profile,excode);
			if excode=ESC then exit;
			if not conf(profile) then
				begin
				loadfile(profile,'R',loaded);
				if not loaded then exit;
				end;
			afilename:=profile;
			case soker of
			'K':kani_ana(afilename);
			'S':{sub_ana(afilename)};
{			'M':mat_ana;}
{
			else
				msg('Method not installed'+#7);
}
			end;
			end;
		end;
end;

procedure anapro(var excoder:char);
label
	EXIT_ANA;
begin
new(DM);
cmethod:=6;
soker:='K';
fname:='CON';
{
outname:='CON';
assign(out,outname);
assigncrt(out);
rewrite(out);
}
NM:=0;
datano:=1;
for i:=1 to 75 do DM^[i]:=cdata;
{highletter:=FALSE;}
{
rev:=FALSE;
for i:=1 to 5 do choice[i]:=1;
for i:=1 to 5 do scode[i]:=#0;
gotoxy(1,1);for i:=1 to 80 do write('Û');
}
put(screen);
scode[1]:=#0;
repeat
aborted:=FALSE;
if scode[1]=#0 then
	begin
		get(screen);
menus^[2]:=' Name of Project/file   '+fixlength(profile,16,LEFT);
box(5,3,27,11,single,0);
menus^[1]:=' New input           ';
menus^[2]:=' Edit input          ';
menus^[3]:=' Save as             ';
menus^[4]:=' List files          ';
menus^[5]:=' Print input         ';
menus^[6]:=' Change settings     ';
menus^[7]:=' start Analysing ... ';
	end;
scode[1]:=NOCHECK;
boxpix(1,menus,'NESLPCA',6,4,26,10,1,choice[1],scode[1],1);
if (scode[1] in [ESC,LEFT,RIGHT,chr(altstate)]) then
					begin
						excoder:=scode[1];
						goto exit_ana;
					end;
if scode[1]=ENTER then
case choice[1] of
			1:	begin
				loadfile('CON','W',loaded);
				end;
			2:
				begin
				readstrbox(1,8,5+choice[1],30,'Edit file name',fname,excode);
				if (excode<>ESC) then
							editfile(fname);
				end;
			3:
				begin
				readstrbox(1,8,5+choice[1],30,'Save file name',fname,excode);
				if excode<>ESC then save_data(fname);
				scode[1]:=#0;
				end;
			4:      begin
				excode:=NOREAD;
				selfromdir(8,5+choice[1],inpdir,fname,excode);
				end;
			5:      save_data('PRN');
			6:      setoptions;
			7:
				begin
			readstrbox(1,10,5+choice[1],70,'Enter Structure/Frame name',profile,excode);
			if excode<>ESC then
				begin
				excode:='R';
				checkfile(profile,excode);
				analysefile;
				end;
				end;
		end;
until scode[1]=ESC;

EXIT_ANA:
	dispose(DM);
end;

{Include this para for independant existance }

{
begin
new(menus);
anapro(excode);
dispose(menus);
}

end.

{ # Too many open files error }
{ # Error in SUB.PAS "1" enterd for "i" in place of writevalues }
{ # line 222 data.m[j] eq. - check }

