

{********************************* Stair Design  *****************************}
unit stair;
interface
procedure stair_read(datano:integer);
procedure stair_selread(datano,choice:integer);
procedure stair_des(datano:integer);
procedure stair_prompts(var fno:integer);
procedure stair_values;
implementation

uses crt,lib,dlib;
const
	b=1000;
var
name,svalue:string;
l,bw:real;
wu,mu,height,stepno,r,t,g:real;
edgecon:integer;
d,overd,momd,defd,fixd:real;
k,q:real;
tauv,ast,minast,p:real;
ps,vu:real;
distsv,sv:integer;
w,wdead,wlive:real;
d_dia,dist:boolean;
pr:char;
finish:real;

PROCEDURE shearcheck(p:real);
begin
	if overd>300 then k:=1.00;
	if overd<=150 then k:=1.30;
	if (overd>150) and (overd<300) then
	k:=1.30-0.30/(300-150)*(overd-150);
	if (tauv>(k*tauc(p))) or (tauv>tmax(fck)/2) then
	writeln(out,'Depth provided is not adequate to take shear.',noise);
end;

PROCEDURE steel(mu:real;span:byte);
var
   dx,diax:real;
   temp:real;
begin
if span=2
   then
       begin
       dx:=d-(dia+sdia)/2;
       diax:=sdia;
       end
   else
       begin
       dx:=d;
       diax:=dia;
       end;

repeat
temp:=1-4.6*mu*1e6/(fck*b*dx*dx);
if temp<0 then
	begin
	d:=d+5;
	dx:=d;
	d:=d+cdt+dia/2;
	KSround(overd,5);
	end;
until temp>=0;

ast:=0.5*fck/fy*(1-sqrt(temp))*b*dx;
if (fy=415) or (fy=500)
		then
			minast:=0.12*b*overd/100
		else
			minast:=0.15*b*overd/100;
if ast<minast then ast:=minast;
sv:=mytrunc((pi*diax*diax/4)*b/ast/10)*10;   { % sv&distsv combine }
if (span=1) and (sv>3*dx) then sv:=mytrunc(3*dx/10)*10;
if (span=2) and (sv>5*dx) then sv:=mytrunc(5*dx/10)*10;
if sv>450 then sv:=450;
if sv<diax then sv:=mytrunc(diax);    { # to prevent sv very low or 0 (=means error)}
end;

procedure stair_selread(datano,choice:integer);
begin
with datamat[datano] do
case choice of
	1:readstr(1,'Name of stair ? ',dname);
	2:readchar(1,'Type of stair ? ',dtype);
	3:readreal(1,'Effective span ? ',dl);
	4:readreal(2,'Width ? ',dbw);
	5:readreal(3,'Going length ? ',dg);
	6:readreal(4,'Tread ? ',dtd);
	7:readreal(5,'Rise ? ',dr);
	8:readreal(6,'Live load ? ',dload);
	9:readreal(7,'Overall depth ? ',doverd);
end;
end;

procedure stair_read(datano:integer);
begin
if aborted then exit;
stair_selread(datano,1);
if datamat[datano].dname='END' then
			begin
			dec(datano);
			exit;
			end;
inc(NM);
for i:=2 to 9 do
stair_selread(datano,i);
end;

procedure stair_prompts(var fno:integer);
begin
menus^[51]:='Name of stair                     : ';
menus^[52]:='Type of stair                     : ';
menus^[53]:='Effective span               (m)  : ';
menus^[54]:='Width                        (m)  : ';
menus^[55]:='Going length                 (m)  : ';
menus^[56]:='Tread                       (mm)  : ';
menus^[57]:='Rise                        (mm)  : ';
menus^[58]:='Live load                  (KNm)  : ';
menus^[59]:='Overall depth               (KN)  : ';
fno:=9;
end;

procedure stair_values;
begin
with datamat[datano] do
	begin
	if length(dname)=0 then dname:='NONAME';
	menus^[1]:=chklen(dname,14);
	menus^[2]:=fixlength(dtype,11,LEFT);
	menus^[3]:=justify(dl,11,2,left);
	menus^[4]:=justify(dbw,11,2,left);
	menus^[5]:=justify(dg,11,2,left);
	menus^[6]:=justify(dtd,11,2,left);
	menus^[7]:=justify(dr,11,2,left);
	menus^[8]:=justify(dload,11,2,LEFT);
	menus^[9]:=justify(doverd,11,2,left);
	end;
end;

		{ 	MAIN PROGRAM	}

procedure stair_des(datano:integer);
begin
with datamat[datano] do
	begin
		l:=dl;
		bw:=dbw;
		g:=dg;
		t:=dtd;
		r:=dr;
		wlive:=dload;
		overd:=doverd;
	end;
if (l<0) or (bw<=0) or (g<0) or (t<=0) or (r<=0) or (overd<=0) or HighV then
			begin
			msg('Datano.'+p0i(datano,3)+'unusable for design.Press ESC'+noise);
			waitfor(ESC);
			exit;
			end;

prewrite;
dt:=cdt+dia div 2;
stepno:=g/t;
height:=stepno*r;
k:=0.0035/(0.0055+0.87*fy/es);
q:=0.36*fck*k*(1-0.416*k);

{
writeln(out,'    Fck  =  ',fck:2,' N/mm2 ');
writeln(out,'     Fy  =  ',fy:3,' N/mm2 ');
writeln(out,'Bar Dia. =  ',dia:2,' mm ');
writeln(out,'xumax/d  =  ',k:3:2);
writeln(out,'      Q  =  ',q:2:3);
}
defd:=0.0;
d:=(overd-dia/2.0-15);
writeln(out,'Overall depth     =  ',overd:3:0,' mm ');
wdead:=((r*t/2)/t+overd*sqrt(r*r+t*t)/t)*25/1000;
{
writeln(out,'    Live load  = ',wlive:5:2,' KN/m2 ');
writeln(out,'    Dead load  = ',wdead:5:2,' KN/m2 ');
writeln(out,'       Finish  = ',finish:5:2,' KN/m2 ');
}
wdead:=wdead+finish;
wu:=1.5*(wdead+wlive);
mu:=wu*l*l/8;
d_dia:=false;
steel(mu,1);
writeln(out,' At mid span (+ve)  =  ',ast:6:2,' mm2');
if ast<minast then
	writeln(out,'Provide min. steel  =  ',minast:6:2,' mm2');
writeln(out,'           Spacing  =  ',sv:3,' mm');
p:=(pi*dia*dia/4)*100/(sv*d);
d_dia:=true;
dist:=true;
steel(0,2);		{ # added this line with no caution }
writeln(out,'Distribution steel  =  ',minast:6:2,' mm2');
writeln(out,'           Spacing  =  ',distsv:3,' mm');
vu:=0.5*(wu)*l*1000;
tauv:=vu/(b*d);
{writeln(out,'CHECK FOR SHEAR');}
shearcheck(p);
{writeln(out,'CHECK FOR DEFLECTION');
writeln(out,'  Percentage steel at midspan  =  ',p:2:3,'%');
writeln(out,'          Modification factor  =  ',mft(p):2:1);
}
defd:=(l*1000/(mft(p)*26));
writeln(out,'Effective depth required for deflection  =  ',defd:3:0,' mm');
if ((defd<=d) and (momd<=d)) then
writeln(out,'Design is safe. ')
else
	writeln(out,'Depth provided is not adequate',noise);
if not flags[1] then postwrite;
end;
end.
