
unit dlib;
interface
uses crt,lib;
const
	wself = 25;
	es=2e5;
type
	rectype=record
		dname:string;
		dtype:char;
		doverd:real;
		dload:real;
		case mtype:char of
		'B':
			(
				dmu:array[1..3] of real;
				dvu:real;
				db:real;
				tbf:real;
				tdf:real
			);
		'C':
			(
				dbreadth:real;
				ddepth:real;
				dmux:real;
				dmuy:real;
				dside:integer;
				dlxc:real;
				dlyc:real
			);
		'F':
			(
				dmuxf:real;
				dmuyf:real;
				dq0:real;
				dy:real;
				dx:real
			);
		'T':
			(	dl:real;
				dbw:real;
				dg:real;
				dtd:real;
				dr:real;
			);
		'S':	(
				dlx:real;
				dly:real
			);
	     end;
const
	data:rectype=(
			dname:'Noname';
			dtype:'?';
			doverd:0;
			dload:0.0;
			mtype:' ';

			dmu:(0,0,0);
			dvu:0;
			db:0;
			tbf:0;
			tdf:0

{			dwlive:0;
			dlx:0;
			dly:0.0;

}		     );

	rangedia:array[0..15] of integer=
		(0,6,8,10,12,16,20,0,0,0,0,0,0,0,0,0);
	barsel:integer=1;
	bartypes:array[1..3] of string[11]=
	(
	 'Auto       ',
	 'Semi-manual',
	 'Manual     ');

var
	drange:string[10] absolute rangedia;
	el1,el2:real;
var
	datamat:array[0..50] of rectype;
	i,NM,datano:integer;
	fno:integer;
var
	fck,fy,sfy,dia,sdia,dc,dt,cdt,ode,pr,f:integer;
	finish:real;
	destype:char;

procedure setdefconstants;
procedure disppar;
PROCEDURE constants(xc,yc:integer);
FUNCTION tauc(pt:real):real;
FUNCTION tmax(fck:integer):real;
FUNCTION mft(p:real):real; {  modification factor for tension reinforcement }
FUNCTION mfc(pc:real):real;{modification factor for compression reinforcement}
FUNCTION mff(bw,bf:real):real; { Reduction factor for l/d of flanged beams  }
PROCEDURE KSround(var x:real;y:integer);
PROCEDURE setpar;
procedure prewrite;
procedure postwrite;
implementation
procedure prewrite;
begin
window(2,1,79,25);
gotoxy(1,12);
fastwrite('Û',78,Norm);
gotoxy(1,13);
for i:=1 to 13 do
		begin
		fastwrite(' ',78,Norm);
		if i<>13 then gotoxy(wherex,wherey+1);
		end;
if not conf(outname) then
		begin
		gotoxy(1,18);
		centre('Output redirected to '+outname);
		end;
gotoxy(1,14);
end;

procedure postwrite;
begin
msg('<HOLD>');
waitfor(any);
end;

PROCEDURE KSround(var x:real;y:integer);
begin
x:=mytrunc(x/y)*y+y;
end;

procedure setdefconstants;
begin
fck:=15;          { % store in file }
fy:=415;
sfy:=415;
dia:=12;
sdia:=8;
finish:=0;
case destype of
    'S','T':cdt:=15;
	'B':cdt:=25;
	'C':cdt:=40;
	'F':cdt:=60;
	end;
ode:=150;
pr:=350;
f:=10;
end;

procedure disppar;
begin
windows(wglob,nocls);
gotoxy(2,17);
writeln('     Fck            = '+strreal(fck,3,0)+' N/mm2');
gotoxy(2,18);
writeln('     Fy (main)      = '+strreal(fy,3,0)+' N/mm2');
gotoxy(2,19);
writeln('     Fy (secondary) = ',strreal(sfy,3,0)+' N/mm2');
end;

PROCEDURE constants(xc,yc:integer);
label 100;
var
	i,no:integer;
	s:string[15];
	prt:array[1..10] of string[50];
	c:char;
	screen:image;
procedure selectread;
begin
case choice[10] of
     1  :  begin
	   readint(44,prt[1]+' ? ',fck);
	   if not ((fck=15) or (fck=20) or (fck=25) or (fck=30)
	   or (fck=35) or (fck=40)) then
		msg('Unusual grade of concrete!'+noise);
           end;
     2  :  begin
	   readint(45,prt[2]+' ? ',fy);
	   if not ((fy=250) or (fy=415) or (fy=500)) then
		msg('Unusual grade of steel!'+noise);
           end;
     3  :  begin
	   readint(46,prt[3]+' ? ',sfy);
	   if not((sfy=250) or (fy=415) or (fy=500)) then
		msg('Unusual grade of steel!'+noise);
           end;
     4    :   readint(47,prt[4]+' ? ',dia);
     5    :   readint(48,prt[5]+' ? ',sdia);
     6    :   readint(49,prt[6]+' ? ',cdt);
     7    :if destype='F' then
			readint(1,'Overall depth at edge ? ',ode)
		else
			readreal(50,prt[7]+' ? ',finish);
     8    :readint(1,'Projection from column at top ? ',pr);
     9    :readint(1,'Weight of footing as % axial load ? ',f);
   end;
end;

begin
buflen:=14;
dec(xc);
dec(yc);
put(screen);
case destype of
	'S','F','T':s:='distribution';
	'C':s:='lateral';
	'B':s:='shear';
	end;
if destype='F' then no:=9 else no:=7;
c:=s[1];
delete(s,1,1);
choice[10]:=1;
prt[1]:=' Fck for concrete';
prt[2]:=' Fy for main reinforcement';
prt[3]:=' Fy for '+c+s+' reinforcement';
prt[4]:=' Main reinforcement í';
prt[5]:=' '+upcase(c)+s+' reinforcement í';
prt[6]:=' Cover for main reinforcement';
if destype='F' then
	begin
		prt[7]:=' Overall depth at edge';
		prt[8]:=' Projection from column at top';
		prt[9]:=' Weight of footing as % axial load';
	end
	else
		prt[7]:=' Extra dead load';

window(xc+1,yc+1,xc+40,yc+10);
for i:=1 to no do
		writeln(fixlength(prt[i],36,LEFT)+': ');
100:
repeat
scode[10]:=NOCHECK;
box(xc,yc,xc+52,yc+no+1,single,0);
menus^[85]:=strint(fck,6)      +' N/mm2  ';
menus^[86]:=strint(fy,6)       +' N/mm2  ';
menus^[87]:=strint(sfy,6)      +' N/mm2  ';
menus^[88]:=strint(dia,6)      +' mm     ';
menus^[89]:=strint(sdia,6)     +' mm     ';
menus^[90]:=strint(cdt,6)      +' mm     ';
if destype='F' then
	begin
		menus^[91]:=strint(ode,6)+' mm     ';
		menus^[92]:=strint(pr,6)+' mm     ';
		menus^[93]:=strint(f,6)+' %      ';
	end
	else
		menus^[91]:=justify(finish,3,2,RIGHT)+' KN/m2  ';

boxpix(1,menus,'',xc+38,yc+1,xc+51,yc+no,85,choice[10],scode[10],1);
	if (scode[10] in [#32..#127]) and not Speckey
		then
			begin
			fastwrite(#32,6,Norm);
			readksbuff:='A';
			KSbuff:=scode[10];
			KSread(29,'CON',KSBuff,excode);
			readKSbuff:=NOREAD;
			selectread;
			readKSbuff:=#0;
			if choice[10]<7 then inc(choice[10]);
			end
		else
		if scode[10]=ENTER then
			begin
			readKSbuff:='E';
			selectread;
			readKSbuff:=#0;
			{
			gotoxy(32,choice[10]+3);
			fastwrite(' ',5,Norm);
			}
			end;
until (scode[10]=ESC) or aborted;
if (fck<=0) or (fy<=0) or (sfy<=0) or (dia<=0) or (sdia<=0) then
		begin
		msg('Invalid data'+noise);
		delay(500);
		aborted:=FALSE;
		goto 100;
		end;
if insname<>'' then writeln(ins,choice[10]);
get(screen);
buflen:=78;
end;





FUNCTION tauc(pt:real):real;
var beta:real;
begin
if pt<=0 then
		begin
		msg('Debug aid : ERROR...'+noise);
		beta:=1;
		exit;
		end;
 beta:=0.8*fck/(6.89*pt);
if beta<1.0 then beta:=1.0;
tauc:=0.85*sqrt(0.8*fck)*(sqrt(1.0+5*beta)-1)/(6*beta);
end;

FUNCTION tmax(fck:integer):real;
begin
tmax:=0.85*0.83*sqrt(0.8*fck) ;
end;

FUNCTION mft(p:real):real; {  modification factor for tension reinforcement }
var mf:real;
begin
mft:=1.0;
if p<=0 then
	begin
	{# msg('VCAD > Possible error in your input'+noise);}
	end
else
	begin
	mf:=1/(0.225+0.00322*0.58*fy-0.625*ln(1/p)/exp(1));
	if mf<2.0 then mft:=mf else mft:=2.0;
	end;
end;

FUNCTION mfc(pc:real):real;{modification factor for compression reinforcement}
var mf:real;
begin
mf:=1.6*pc/(pc+0.275);
mfc:=mf;
if mf<1.0 then mfc:=1.0;            { #approx }
if mf>1.5 then mfc:=1.5;
end;

FUNCTION mff(bw,bf:real):real; { Reduction factor for l/d of flanged beams  }
begin
if bw/bf <0.3 then mff:=0.80;
if ((bw/bf)>0.3) and ((bw/bf)<1.0) then mff:=0.8+(1.0-0.8)/(1-0.3)*(bw/bf-0.3);
if (bw/bf)>1.0 then mff:=1.0;
end;

PROCEDURE setpar;
label 100;
var
	s1,s2:string[10];
	sdrange:string;
	i,j:integer;
	screen:image;
const
	TotalBar=7;
begin
put(screen);
sdrange:='';
el1:=25;
el2:=0.5;
for i:=0 to TotalBar-1 do
		begin
		str(rangedia[i],s1);
		if i<>TotalBar-1 then s1:=s1+',';
		sdrange:=concat(sdrange,s1);
		end;

choice[9]:=1;
repeat
for j:=1 to 3 do menus^[j]:=fixlength(' '+bartypes[j],13,LEFT);
box(40,12,54,16,single,0);
scode[9]:=#0;
boxpix(1,menus,'BFLH',41,13,53,15,1,choice[9],scode[9],1);
if scode[9]=ENTER then barsel:=choice[9];
if scode[9]=ENTER then
case choice[9] of
	1,3:goto 100;
	2:
		begin
		choice[8]:=1;
repeat
menus^[1]:=' Fix diameter range   '+sdrange;
s1:=strreal(el2,3,2);
s2:=strreal(el1,3,2);
menus^[2]:=' Low  error limit     '+s1+'%';
menus^[3]:=' High error limit     '+s2+'%';
for i:=1 to 3 do menus^[i]:=fixlength(menus^[i],44,LEFT);
box(20,15,65,19,single,0);
scode[8]:=#0;
boxpix(1,menus,'BFLH',21,16,64,18,1,choice[8],scode[8],1);
if scode[8]=ENTER then
	case choice[8] of
	1:;
	2: readreal(1,'Low  error limit ? ',el2);
	3: readreal(1,'High error limit ? ',el1);
	end;
NABT;
until (scode[8]=ESC);
	goto 100;
	end;
	end;
until scode[9]=ESC;
100: get(screen);
end;
end.


{
1.	choices 8..10 are used
}