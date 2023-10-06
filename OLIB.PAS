{ OPERATING SYSTEM LIBRARY }

unit olib;
interface

Uses Crt,lib,Dos;

Function  GetLoggedDrive:Char;
Function  CurrentDirectory(Drive:Char):String;
{
Procedure Shell(Parent:String);
Function  Lead0(W:Word):String;
Function  FileName(DirInfo:Searchrec; ShowSize,ShowDate:Boolean):String;
}

PROCEDURE call_shell(parent:string);
PROCEDURE copyf;
PROCEDURE renamef;
PROCEDURE deletef;
PROCEDURE dirf;

implementation

type 	block=array[1..128] of byte;
const
	months:array[1..12] of string[9]=
       ('January  ',
	'February ',
	'March    ',
	'April    ',
	'May      ',
	'June     ',
	'July     ',
	'Augest   ',
	'September',
	'October  ',
	'November ',
	'December '
	);

PROCEDURE copyf;
var
	source,target:string;
	sf,tf:file;
	startingblock:longint;
	buf:array[1..40] of block;
	NumRead, Numwritten: Word;

PROCEDURE verifyblocks(numblocks,startingblock:integer);
var
	testblock:block;
	i,j:integer;
	svalue:string;
begin
str(numblocks,svalue);
write('Verifying '+svalue+' blocks');
{$I-}
seek(sf,startingblock);
for i:=1 to numblocks do
	begin
		blockread(tf,testblock,i);
		for j:=1 to 128 do
			if (testblock[j] <> buf[i,j]) then
			begin
			msg('Copy failed. Press any key to resume ....');
			waitfor(any);
			end;
	end;
{$I+}
end;

begin
source:='';
target:='';
{	readstr(52,'Source file name  ?   ',source);}
readstrbox(1,5,7,40,'Source file name',source,excode);
if excode=ESC then exit;
	upstring(source);
	if aborted then exit;
	if not exist(source) then
		begin
		msg('File '+source+' does not exist. Process aborted.');
		aborted:=TRUE;
		exit;
		end;


{	readstr(53,'Target file name  ?   ',target);}
readstrbox(1,5,7,40,'Copy file name',target,excode);
if excode=ESC then exit;
	upstring(target);
	if aborted then exit;
	if exist(target) then
		begin
			readchar(54,'File '+target+' exists. Overwrite ? (Y/N)  ',resp);
				if resp='Y' then
					begin
					windows(wmsg,cls);
					{$I-}
					assign(tf,target);
					erase(tf);
					{$I+}
					if ioresult<>0 then
						msg('Invalid command.');
					end
					else aborted:=TRUE;
		end;
	if not aborted then
		   begin
		   {$I-}
			assign(sf,source);
			assign(tf,target);
			reset(sf,1);
			rewrite(tf,1);
		   {$I+}
		if ioresult=0 then
			begin
			msg('Copying...');
			repeat
			   startingblock:=filepos(tf);
	{ Input error zone }
			   blockread(sf,buf,sizeof(buf),Numread);
			   if Numread>0 then
				begin
				blockwrite(tf,buf,Numread,Numwritten);
				{
				verifyblocks(Numwritten,startingblock);
				}
				end;
		       until (Numread =0) or (Numread<>Numwritten);
		       msg(source+' copied to  '+target);
		       close(sf);
		       close(tf);
		       end
				else msg('Invalid command.');

		end;
	end;

PROCEDURE renamef;
var
	source,target:string;
	sf,tf:file;
begin
source:='';
target:='';
{    readstr(55,'Source file name  ?   ',source);}
readstrbox(1,5,7+1,40,'Present file name',source,excode);
if excode=ESC then exit;
    upstring(source);
    if aborted then exit;
	    if not exist(source) then
		begin
		msg('File '+source+' not exists. Process aborted.');
		aborted:=TRUE;
		end;
{    readstr(56,'Target file name  ?   ',target);}
readstrbox(1,5,7+1,40,'New file name',target,excode);
if excode=ESC then exit;
    upstring(target);
if aborted then exit;
	if exist(target) then
	begin
	readchar(57,'File '+target+' exists . Erase it ? (Y/N) ',resp);
	if resp='Y' then
		begin
			{$I-}
			assign(tf,target);
			erase(tf);
			{$I+}
			if ioresult=0 then
				msg('File '+source+' renamed as '+target)
				else
					msg('Invalid command.');
		end
		else aborted:=TRUE;
	end;

if not aborted
	then
		begin
		windows(wmsg,cls);
		{$I-}
		assign(sf,source);
		rename(sf,target);
		{$I+}
		if ioresult=0 then
				msg('File '+source+' renamed as '+target)
			else
				msg('Invalid command.');
		end;

	end;

PROCEDURE deletef;
var
	f:file;
	filename:string[12];
begin
filename:='';
readstrbox(1,5,7+2,40,'Delete file name',filename,excode);
if excode=ESC then exit;
{     readstr(58,'Delete file name  ?   ',filename);}
     upstring(filename);
     if aborted then exit;
if not exist(filename)
     then
		msg('File '+filename+' does not exist. Process aborted.')
     else
     begin
     readchar(59,'File '+filename+' will be deleted. Are you sure ? (Y/N) ',resp);
if resp='Y'
	   then
		begin
		     windows(wmsg,cls);
		     assign(f,filename);
		     erase(f);
		     msg('File  '+filename+' deleted .');
		end;
     end;
end;

(*
PROCEDURE dirf;
var
	count:integer;
	reg:registers;
	DTA : array[0..127] of byte;
	s:string;


PROCEDURE oneEntry;
var
	i,j:integer;
begin
msdos(reg);
if (count mod 4)=0 then writeln;
if reg.al=0
	then
		gotoxy(17+(count mod 4)*15,wherey)
	else
		writeln;
count:=count+1;
j:=30;
for i:=1 to 12 do
if reg.al=0 then
if dta[j]=0
	then
	{	write(blank)      }
	else
		begin
		fastwrite(chr(dta[j]),1,norm);
		j:=j+1;
		end;
end;

PROCEDURE initialize;

begin
count:=0;

readstr(60,'Path    ?  ',s);
if aborted then exit;
windows(wmsg,cls);
s:=s+'\*.*';
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
	if aborted then exit;
	box(16,4,76,19,SINGLE,0);
	gotoxy(39,4);
	write(' DIR : ',s);
	windows(wout,nocls);
	gotoxy(1,4);
	with reg do
	    while al=0 do
		begin
			oneentry;
			ah:=$4F;
		end;
	windows(wglob,nocls);
	waitfor(esc);
	windows(wout,cls);
end;
*)

Procedure dirf;
var
	inpdir :string;
	dirfiles:files;
	numfiles:integer;
	fname:string[12];
begin
{
inpdir:='';
readstr(60,'Path ?  ',inpdir);
if aborted then exit;
windows(wmsg,cls);
inpdir:=inpdir+'\*.*';
}
inpdir:=GetLoggedDrive+':'+CurrentDirectory(GetloggedDrive);
readstrbox(1,5,7+3,40,'Directory name',inpdir,excode);
if excode=ESC then exit;
{inpdir:='A:';}
selfromdir(6,10,inpdir,fname,excode);
end;

Function GetLoggedDrive:char;
Begin
Regs.ah:=$19; Msdos(Regs); GetLoggedDrive:=Chr(65+Regs.al);
End;

Function  CurrentDirectory(Drive:Char):String;
Var P:Array[1..64] Of Char; J:Byte; S:String;
Begin
Regs.ah:=$47;
Regs.ds:=Seg(P); Regs.si:=Ofs(P);
Drive:=Upcase(Drive); Regs.dl:=Ord(Drive)-64;
{ IN MSDOS INTERRUPTS DRIVE 0 IS LOGGED DRIVE WHILE A=1, B=2 etc }
Msdos(Regs);
S:='\'; J:=1; While P[J]<>#0 Do Begin S:=S+P[J]; Inc(J); End;
CurrentDirectory:=S;
End;


Procedure call_Shell(parent:string);
Var Path,Fncc:String; Drive:Char;
	Label ExitShell;
Begin
Drive:=GetLoggedDrive;
Path:=Drive+':\';
Fncc:=GetEnv('COMSPEC');
While Not Exist(Fncc) Do Begin
Writeln(Fncc,' Not Found. Type In Path Or ','<',#196,#196,#217,' To Exit.. ');
Readln(Path);
If Path='' Then Goto ExitShell;
If Path[Length(Path)]<>'\' Then Path:=Path+'\';
Fncc:=Path+'Command.com';
End;
windows(wglob,cls);
Writeln('DOS Shell. Type EXIT to return to ',Parent);
SwapVectors;
Exec(Fncc,'');
SwapVectors;
If Doserror=8 Then Begin
		   Writeln('Not enough memory. Press ESC.');
		   waitfor(ESC);
                   End;
ExitShell:
End;

Function  FileName(DirInfo:Searchrec; ShowSize,ShowDate:Boolean):String;
Var J:Byte; Dt:Datetime; Monthstr,S1,S2:String; D:Dirstr; N:Namestr; E:Extstr;
Begin
Fsplit(Dirinfo.name,D,N,E);
While Length(N) < 8 Do N:=' '+N;
While Length(E) < 4 Do E:=E+' ';
S1:=N+E;

if DirInfo.Attr=Directory then S1:=S1+'  <Dir>  '
                          else S1:=S1+'         ';
if ShowSize then begin
                 Str(Dirinfo.size:6,S2);
                 S1:=S1+S2;
                 end;

If ShowDate Then
	Begin
	Unpacktime(Dirinfo.time,Dt);
	Str((Dt.year-1900):2,S2);
	Monthstr:=Copy(Months[Dt.month],1,3);
	S1:=S1+'   '+p0i(Dt.day,2)+'-'+Monthstr+'-'+S2+'  '+p0i(Dt.hour,2)+':'+p0i(Dt.min,2);
	End;
FileName:=S1;
End;
end.