
unit des;
interface

uses crt,lib,dlib,slab,beam,col,foot,stair;

procedure despro(var excoder:char);
implementation


const
	destyper:string[5]='SBCFT';
	destypes:array[1..5] of string[10]=
	       ('Slab      ',
		'Beam      ',
		'Column    ',
		'Footing   ',
		'sTaircase ');
	cdestype:integer=1;

procedure getfieldvalues;
begin
HighV:=FALSE;
case destype of
	'S':slab_values;
	'B':beam_values;
	'C':col_values;
	'F':foot_values;
	'T':stair_values;
	end;
end;

procedure getfieldprompts(var fno:integer);
begin
case destype of
	'S':slab_prompts(fno);
	'B':beam_prompts(fno);
	'C':col_prompts(fno);
	'F':foot_prompts(fno);
	'T':stair_prompts(fno);
	end;
end;

procedure selectread(datano,choice:integer);
begin
case destype of
	'S':slab_selread(datano,choice);
	'B':beam_selread(datano,choice);
	'C':col_selread(datano,choice);
	'F':foot_selread(datano,choice);
	'T':stair_selread(datano,choice);
	end;
end;

procedure fullread(datano:integer);
var s:string;
begin
s:='';
if not conf(inpname) then
begin
{$I-}
readln(inp,s);
{$I+}
if (ioresult<>0) or (upcase(s[1])<>destype) then
		begin
msg('Input file does not confirm to requested design type.Press ESC.'+noise);
		waitfor(ESC);
		msg('');
		aborted:=TRUE;
		exit;
		end;
end;

case destype of
	'S':slab_read(datano);
	'B':beam_read(datano);
	'C':col_read(datano);
	'F':foot_read(datano);
	'T':stair_read(datano);
	end;
end;

procedure design(datano:integer);
var screen:image;
begin
if not flags[1] then put(screen);
case destype of
	'S':slab_des(datano);
	'B':beam_des(datano);
	'C':col_des(datano);
	'F':foot_des(datano);
	'T':stair_des(datano);
	end;
if not flags[1] then get(screen);
end;


procedure copyrec;
begin
if NM=50 then
	begin
		msg('No more records allowed.Press ESC');
		waitfor(ESC);
		exit;
	end;
inc(NM);
datamat[NM]:=datamat[datano];
msg('Data copied to record no: '+p0i(NM,3));
scode[1]:=#250;
end;

procedure delrec;
begin
if datano<1 then exit;
	msg('Record no: '+p0i(datano,3)+' will be deleted. Sure ? (Y/N) ');
		if yes then
			begin
			for i:=datano to NM-1 do
				datamat[i]:=datamat[i+1];
			dec(NM);
			scode[1]:=#250;
			end;
		msg('');
end;

procedure editrec;
var
	i:integer;
	flag:boolean;
	screen:image;
	s:string;
begin
buflen:=14;
if not flags[1] then put(screen);
windows(wout,cls);
choice[1]:=1;
getfieldprompts(fno);
box(5,3,57,3+fno+1,single,0);
for i:=1 to 6 do
	box(61,3+(i-1)*3,74,5+(i-1)*3,single,0);
menus^[11]:='   Design   ';
menus^[12]:='  Variables ';
menus^[13]:='    Copy    ';
menus^[14]:='   Remove   ';
menus^[15]:='  Previous  ';
menus^[16]:='    Next    ';
scode[2]:=#250;
boxpix(1,menus,'DVCRPN',62,4,73,19,11,choice[2],scode[2],3);
choice[2]:=1;
scode[2]:=LEFT;
window(7,4,57,4+fno);
for i:=1 to fno do
	begin
	write(menus^[50+i]);
	fastwrite(' ',14,Norm);
	writeln;
	end;
scode[1]:=#250;
repeat
disppar;
repeat
windows(wglob,nocls);
gotoxy(6,5+fno);
write('Total = ',p0i(NM,3));
gotoxy(46,5+fno);
write('Rec No: ',p0i(datano,3));
if scode[2]=LEFT then scode[1]:=NOCHECK;
getfieldvalues;
if scode[1]=#250 then
	for i:=1 to fno do
			menus^[i]:=fixlength(menus^[i],14,LEFT);
if flags[1] then
		begin
		scode[1]:=NOREAD;
                boxpix(1,menus,'',43,4,56,4+fno-1,1,choice[1],scode[1],1);
		exit;
		end;

		boxpix(1,menus,'',43,4,56,4+fno-1,1,choice[1],scode[1],1);
	if (scode[1] in [#32..#127]) and not Speckey
		then
			begin
			fastwrite(' ',14,Norm);
			readksbuff:='A';
			KSbuff:=scode[1];
			KSread(29,'CON',KSBuff,excode);
			readKSbuff:=NOREAD;
			selectread(datano,choice[1]);
			readKSbuff:=#0;
			if choice[1]<fno then inc(choice[1]);
			end
		else
		if scode[1]=ENTER then
			begin
			readKSbuff:='E';
			selectread(datano,choice[1]);
			readKSbuff:=#0;
			gotoxy(42,choice[1]+3);
			fastwrite(' ',14,Norm);
			end;
if speckey then
	begin
	if scode[1]=pgup then
		if (datano>1) then dec(datano) else msg(noise);
	if scode[1]=pgdn then
		if (datano<NM) then inc(datano)	else msg(noise);
	end;
aborted:=FALSE;
until (scode[1] in [ESC,RIGHT,#250]);
if (scode[1] in [RIGHT,#250]) then
	repeat
	scode[2]:=NOCHECK;
	boxpix(1,menus,'DVCRPN',62,4,72,19,11,choice[2],scode[2],3);
	msg('');
	if scode[2]=ENTER then
	case choice[2] of
	1:      design(datano);
	2:	constants(6,4);
	3:      copyrec;
	4:      delrec;
	5:
		begin
		if (datano>1) then dec(datano) else msg(noise);
		scode[1]:=#250;
		end;
	6:
		begin
		if (datano<NM) then inc(datano)	else msg(noise);
		scode[1]:=#250;
		end;
	end;
	aborted:=FALSE;
	until (scode[2] in [ESC,LEFT]) or (scode[1]=#250);
until (scode[1]=ESC) or (scode[2]=ESC);
get(screen);
buflen:=78;
end;

procedure saveto(savefile:string);
var
	sf:text;
	i:integer;
begin
if aborted or conf(savefile) then exit;
msg('Saving '+savefile+'...');
setfile(sf,savefile,savefile,'W',excode);
if excode=ESC then exit;
case destype of
	'S':writeln(sf,'S (Slab Input)');
	'B':writeln(sf,'B (Beam Input)');
	'C':writeln(sf,'C (Column Input)');
	'F':writeln(sf,'F (Footing Input)');
	'T':writeln(sf,'T (sTaircase Input)');
	end;

for i:=1 to NM do
	with datamat[i] do
	case destype of
	'S':writeln(sf,dname,h,dtype,h,dload:10:3,h,dlx:10:3,h,dly:10:3,h,
			doverd:10:3);
	'B':
	begin
	writeln(sf,dname,h,dtype,h,db:10:3,h,doverd:10:3,h,dmu[1]:10:3,h,dmu[2]:10:3,h,dmu[3]:10:3,h,
			dvu:10:3);
	if dtype<>'R' then  writeln(sf,tbf:10:3,h,tdf:10:3);
	end;
	'C':writeln(sf,dname,h,dbreadth:10:3,h,ddepth:10:3,h,dmux:10:3,h,
			dmuy:10:3,h,dside:10,h,dlxc:10:3,h,dlyc:10:3);
	'F':writeln(sf,dname,h,dmuxf:10:3,h,dmuyf:10:3,h,dq0:10:3,h,
			dy:10:3,h,dx:10:3);
	'T':writeln(sf,dname,h,dl:10:3,h,dbw:10:3,h,dg:10:3,h,dtd:10:3,h,
			dr:10:3);
	end;
writeln(sf,'END');
close(sf);
msg('');
end;

procedure seldestype;
var i:integer;
begin
scode[3]:=#0;
choice[3]:=1;
	box(42,5,54,11,single,0);
	for i:=1 to 5 do menus^[i]:=' '+destypes[i];
boxpix(1,menus,'SBCFT',43,6,53,10,1,choice[3],scode[3],1);
if scode[3]=ENTER then
	begin
	destype:=destyper[choice[3]];
	cdestype:=choice[3];
	end;
end;

procedure despro(var excoder:char);
var
	savefile:string;
	screen:image;
begin
savefile:='';
destype:='S';
setdefconstants;
NM:=1;{# DEBUG}
datano:=1;
data.mtype:=destype;
for i:=1 to 50 do datamat[i]:=data;
box(19,3,55,12,single,0);
choice[4]:=1;
scode[4]:=#0;
repeat
windows(winp,cls);
menus^[31]:=' Design of            '+fixlength(destypes[cdestype],13,LEFT);
menus^[32]:=' Output to            '+fixlength(outname,13,LEFT);
menus^[33]:=' Read input           '+fixlength('',13,LEFT);
menus^[34]:=' Edit input           '+fixlength('',13,LEFT);
menus^[35]:=' Save input to        '+fixlength(insname,13,LEFT);
menus^[36]:=' Variables            '+fixlength('',13,LEFT);
menus^[37]:=' Bar selection        '+fixlength(bartypes[barsel],13,LEFT);
menus^[38]:=' design All           '+fixlength('',13,LEFT);
scode[4]:=NOCHECK;
boxpix(1,menus,'DORESVBA',20,4,54,11,31,choice[4],scode[4],1);
if scode[4]=ENTER
     then
	case choice[4] of
		1:	seldestype;
		2:
			begin
			readstrbox(1,22,5+choice[4],70,'Output file name',outname,excode);
			if excode<>ESC then setfile(out,outname,outname,'W',excode);
			end;
		3:
			begin
                	readstrbox(1,22,5+choice[4],70,'Input file name',inpname,excode);
			if excode<>ESC then
			begin
			if not conf(inpname) then
				begin
				setfile(inp,inpname,inpname,'R',excode);
				NM:=0;
				repeat
					fullread(datano);
					if not aborted then inc(datano);
				until (datamat[datano-1].dname='END') or aborted;
				if inpname<>'CON' then
							begin
							close(inp);
							inpname:='CON';
							end;
                                datano:=1;
				end
				else
					fullread(datano);

			end;
			end;
		4:      editrec;
		5:
			begin
			readstrbox(1,22,5+choice[4],70,'Save input to',savefile,excode);
			if excode<>ESC then saveto(savefile);
			end;
		6:	constants(22,5+choice[4]);
		7:	setpar;
		8:	begin
			put(screen);
			flags[1]:=TRUE;
			windows(wout,cls);
			for datano:=1 to NM do
					begin
					if UBreak then exit;
					editrec;
					design(datano);
					if (outname='CON') and (datano<NM)
							then postwrite;
					end;
			flags[1]:=FALSE;
			msg('Design complete. Press ESC.'+noise);
			waitfor(ESC);
                        close(out);

                        outname:='CON';
                       {
                        setfile(out,outname,outname,'W',excode);
		        }
                        get(screen);
			datano:=1;
			end;
	end;
     aborted:=FALSE;
     video(normal);
until (scode[4] in [ESC,LEFT,RIGHT,chr(altstate)]);
excoder:=scode[4];
end;

{Include this para for independant existance}

{
begin
new(menus);
despro(excode);
dispose(menus);
}

end.

{
Notes:
1.	flags[1] = 1   > Design all selected;
2.	choices 1..4 are used.
}