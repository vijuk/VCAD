{       y       *******    PROGRAM FOR SLAB DESIGN            }

unit slab;
interface
procedure slab_selread(datano,choice:integer);
PROCEDURE slab_read(datano:integer);   { main input for slab design }
procedure slab_prompts(var fno:integer);
procedure slab_values;
PROCEDURE slab_des(datano:integer);

implementation

uses  crt,lib,dlib;

const
     b=1000;
procedure readtype(var dtype:char);
var screen:image;
begin
put(screen);
windows(winp,nocls);
inc(inL);
if inL>3 then
	inL:=3;
gotoxy(1,inL);
writeln;
write('Type of panel   :  ');
choice[3]:=1;
scode[3]:=#0;

box(13,3,68,19,whilecon,0);
menus^[61]:=' A. Two way  : Interior panel                         ';
menus^[62]:=' B. Two way  : 1 Short  edge   discontinuous          ';
menus^[63]:=' C. Two way  : 1 Long            edge   discontinuous ';
menus^[64]:=' D. Two way  : 1 Long & 1 Short  edges  discontinuous ';
menus^[65]:=' E. Two way  : 2 Short  edges  discontinuous          ';
menus^[66]:=' F. Two way  : 2 Long            edges  discontinuous ';
menus^[67]:=' G. Two way  : 1 Long & 2 Short  edges  discontinuous ';
menus^[68]:=' H. Two way  : 2 Long & 1 Short  edges  discontinuous ';

menus^[69]:=' I. Two way  : All edges discontinuous                ';
menus^[70]:=' J. Two way  : All edges simply supported             ';
menus^[71]:=' K. One way  : Continuous - Interior panel            ';
menus^[72]:=' L. One way  : Continuous - End panel                 ';
menus^[73]:=' M. One way  : Cantilever slab                        ';
menus^[74]:=' N. One way  : Simply supported at both ends          ';
menus^[75]:=' O. One way  : Fixed at both ends                     ';
boxpix(1,menus,'ABCDEFGHIJKLMNO',14,4,67,18,61,choice[3],scode[3],1);
dtype:=chr(64+choice[3]);

windows(winp,nocls);
gotoxy(1,inL);
writeln('Type of panel   :  ',
	copy(menus^[60+choice[3]],5,length(menus^[choice[3]])-4));
inL:=inL+1;
get(screen);
end;

procedure slab_selread(datano,choice:integer);
var
	c:char;
	screen:array[1..1] of image;
begin
put(screen[1]);
with datamat[datano] do
	case choice of
		1:	readstr(1,'Name of slab   ? ',dname);
		2:      begin
			readchar(1,'Slab type  ? ',dtype);
			if not (dtype in ['A'..'O']) then
						readtype(dtype);
			end;
		3:	readreal(1,'Live load   (KN/m2) ? ',dload);
		4:	readreal(1,'Short span  (m) ? ',dlx);
		5:	readreal(1,'Long span   (m) ? ',dly);
		6:	readreal(1,'Total Depth (mm)    ? ',doverd);
	end;
get(screen[1]);
end;

PROCEDURE slab_read(datano:integer);   { main input for slab design }
begin
with datamat[datano] do
begin
readstr(1,'Name of panel     ?   ',dname);
if dname='END' then exit;
readchar(1,'Slab type  ? ',dtype);
if not (dtype in ['A'..'O']) then
		readtype(dtype);
readreal(1,'Live load  (KN/m2)  <'+strreal(dload,4,2)+'>  ? ',dload);
{,'B','C','D','E','F','G','H','I','J' }
case dtype of
	'A'..'J':     		{ TWO WAY }
		begin
		   readreal(1,'Short span  (m)  ?   ',dlx);
		   readreal(1,'Long span  (m)  ?   ',dly);
		end;
	'K'..'O' :                             { ONE WAY }
		     readreal(1,'Effective span  (m)  ?   ',dlx);
end;
readreal(1,'Total Depth (mm)    ? ',doverd);
if not aborted then inc(NM);
end;

{
with datamat[datano] do
begin
dname:='DEMO.SLAB';
dload:=3;
dtype:='B';
dlx:=4;
dly:=8;
doverd:=0;
end;
}

end;

procedure slab_prompts(var fno:integer);
begin
menus^[51]:='Name of slab                      : ';
menus^[52]:='Type of slab              (A..O)  : ';
menus^[53]:='Live load                  (KNm)  : ';
menus^[54]:='Short span                   (m)  : ';
menus^[55]:='Long span                    (m)  : ';
menus^[56]:='Overall depth               (KN)  : ';
fno:=6;
end;

procedure slab_values;
var s:string;
begin
with datamat[datano] do
	begin
	if length(dname)=0 then	dname:='NONAME        ';
	s[0]:=#1;
	s[1]:=dtype;
	menus^[1]:=fixlength(dname,14,LEFT);
	menus^[2]:=fixlength(s,14,LEFT);
	menus^[3]:=justify(dload,11,2,LEFT);
	menus^[4]:=justify(dlx,11,2,left);
	menus^[5]:=justify(dly,11,2,left);
	if eq(doverd,0) then
		menus^[6]:='0.00 =Suggest '
		else
		menus^[6]:=justify(doverd,11,2,left);
	end;
end;

		{          Master program for slab design         }
PROCEDURE slab_des(datano:integer);
label 200,300;
const
	first:boolean=FALSE;
	flag:boolean=FALSE;
var
	lowd,userd:real;
	screen:image;
	name,svalue:string;
	i:integer;
	sv:integer;
	slabtype:char;
	ly,lx,ratio:real;
	d,overd,momd,defd:real;
	k,q:real;
	p,ps,vu:real;
	ast,minast:real;
	w,wdead,wlive:real;
	nmx,nmy,pmx,pmy,nx,ny,px,py:real;
	ndmc,nlmc,pdmc,plmc:real;
	wlx2:real;
	tauv:real;
	op:array[1..10] of string[80];
	grfout:text;
	wliver:real;

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
if sv<dia then
	begin
	msg('Unusual spacing (Error?) !.Check your input.'+noise);
	delay(500);
	sv:=dia;
	end;
end;

PROCEDURE coeff(i:integer);
const
alpha:array [1..18,1..9] of integer =
((32,37,43,47,51,53,60,65,32),
(24,28,32,36,39,41,45,49,24),
(37,43,48,51,55,57,64,68,37),
(28,32,36,39,41,44,48,52,28),
(37,44,52,57,63,67,77,85,37),
(28,33,39,44,47,51,59,65,28),
(47,53,60,65,71,75,84,91,47),
(35,40,45,49,53,56,63,69,35),
(45,49,52,56,59,60,65,69,00),
(35,37,40,43,44,45,49,52,35),
(00,00,00,00,00,00,00,00,45),
(35,43,51,57,63,68,80,88,35),
(57,64,71,76,80,84,91,97,00),
(43,48,53,57,60,64,69,73,43),
(00,00,00,00,00,00,00,00,57),
(43,51,59,65,71,76,87,96,43),
(56,64,72,79,85,89,100,107,56),
(00,00,00,00,00,00,00,00,00));

var
	i1,i2,rat1,rat2:integer;
	rat:real;
begin

i1:=2*i-1;
i2:=2*i;
if ratio<1.75 then
    begin
	rat:=(ratio-1)*10+1;
	rat1:=mytrunc(rat);
	rat2:=rat1+1;
	nx:=(alpha[i1,rat1]+(alpha[i1,rat2]-alpha[i1,rat1])*(rat-rat1))/1000;
	px:=(alpha[i2,rat1]+(alpha[i2,rat2]-alpha[i2,rat1])*(rat-rat1))/1000;
    end
else if (ratio>=1.75) and (ratio<=2) then
    begin
	rat:=ratio*4;
	rat1:=mytrunc(rat);
	rat2:=rat1+1;
	nx:=(alpha[i1,rat1]+(alpha[i1,rat2]-alpha[i1,rat1])*(rat-rat1))/1000;
	px:=(alpha[i2,rat1]+(alpha[i2,rat2]-alpha[i2,rat1])*(rat-rat1))/1000;
    end
else
	msg('ERR...');
ny:=alpha[i1,9]/1000;
py:=alpha[i2,9]/1000;
end;


begin
if not flags[1] then put(screen);
{slab_read(datano);}
with datamat[datano] do
	begin
	name:=dname;
	slabtype:=dtype;
	wliver:=dload;
	userd:=doverd;
	lx:=dlx;
	ly:=dly;
	end;
if (lx<=e) or not(slabtype in ['A'..'O']) or ((slabtype in ['A'..'J'])
	and (ly<lx)) or (HighV) then
			begin
			msg('Data No.'+p0i(datano,3)+' unsuitable for design.Press ESC');
			waitfor(ESC);
			msg('');
			exit;
			end;
{msg('Designing Slab... ');}
	p:=0.0;
	      k:=0.0035/(0.0055+0.87*fy/es);
	      q:=0.36*fck*k*(1-0.416*k);
	      defd:=(lx*1000/(mft(0.12)*26));
				  { assuming min. steel & max. l/d ratio }
	      overd:=defd+dia div 2 +cdt;
	      KSround(overd,5);
	      d:=(overd-dia/2-cdt);
	flag:=TRUE;
	first:=TRUE;
	op[1]:='Name of slab                        :  '+name;
200:    if UBreak then exit;
	wdead:=1.5*(overd*wself/1000+finish);
	wlive:=1.5*wliver;
	w:=(wlive+wdead);
	for i:=2 to 10 do op[i]:='';
	op[2]:='Overall depth                       :  '
			+justify(overd,5,0,LEFT)+' mm';

	repeat
	{
	writeln(overd,'  ',d);readln;
	}
	case slabtype of
	'A'..'J' :		{ TWO WAY }
		begin
			ratio:=ly/lx;
			if (slabtype<>'J') and (ly/lx>2.0) then ratio:=2;
			wlx2:=w*lx*lx;
		if slabtype<>'J' then
					coeff(ord(slabtype)-64)
		else
		begin
		   nx:=0.0;
		   ny:=0.0;
		   px:=(1/8)*sqr(ratio)*sqr(ratio)/(1+sqr(ratio)*sqr(ratio));
                   py:=(1/8)           *sqr(ratio)/(1+sqr(ratio)*sqr(ratio));
		end;
		nmx:=nx*wlx2;
		pmx:=px*wlx2;
		nmy:=ny*wlx2;
		pmy:=py*wlx2;
		{windows(wout,cls);}
		momd:=sqrt(nmx*1e6/(q*b));
		if d<momd then goto 300;    { nmx is largest }
		steel(nmx,1);
		op[3]:='Shortspan reinforcement at support  :  '
			+strreal(ast,5,2)+' mm2 - '
			+strint(dia,2)+' í bars @ '+strint(sv,5)+' mm c/c';
		steel(pmx,1);
		op[4]:='Shortspan reinforcement at middle   :  '
			+strreal(ast,5,2)+' mm2 - '
			+strint(dia,2)+' í bars @ '+strint(sv,5)+' mm c/c';
		p:=(pi*dia*dia/4)*100/(sv*d);
		steel(nmy,2);
		op[5]:='Longspan reinforcement at support   :  '
			+strreal(ast,5,2)+' mm2 - '+strint(dia,2)
			+' í bars @ '+strint(sv,5)+' mm c/c';
		steel(pmy,2);
		op[6]:='Longspan reinforcement at middle    :  '
			+strreal(ast,5,2)+' mm2 - '+strint(dia,2)
			+' í bars @ '+strint(sv,5)+' mm c/c';
		end;

'K'..'O'   :   { ONE WAY }

begin
case slabtype of
	'K':        	{ Interior Panel }
		begin
			ndmc:=1/12*wdead*lx*lx;  {interior supports}
			nlmc:=1/9*wlive*lx*lx;
			pdmc:=1/24*wdead*lx*lx;  {middle of interior span}
			plmc:=1/12*wlive*lx*lx;
		end;
	'L':      	{ End Panel }
		begin
			ndmc:=1/10*wdead*lx*lx;  {next to end support}
			nlmc:=1/9*wlive*lx*lx;
			pdmc:=1/12*wdead*lx*lx;   {middle of end span}
			plmc:=1/10*wlive*lx*lx;
		end;
	'M':             { Cantelever }
		begin
			ndmc:=1/2*wdead*lx*lx;  {fixed end}
			nlmc:=1/2*wlive*lx*lx;
			pdmc:=0.0;
			plmc:=0.0;
		end;
	'N':             { Simply Supported }
		begin
			ndmc:=0;  {next to end support}
			nlmc:=0;
			pdmc:=1/8*wdead*lx*lx;   {middle of end span}
			plmc:=1/8*wlive*lx*lx;
		end;
	'O':             { Fixed both ends }
		begin
			ndmc:=1/12*wdead*lx*lx;  {interior supports}
			nlmc:=1/12*wlive*lx*lx;
			pdmc:=1/24*wdead*lx*lx;  {middle of interior span}
			plmc:=1/24*wlive*lx*lx;
		end;
	end;
	momd:=sqrt((ndmc+nlmc)*1000000.0/(q*b));
	steel(ndmc+nlmc,1);
	op[3]:='Reinforcement at support            :  '
		+strreal(ast,5,2)+' mm2 - '+strint(dia,2)
		+' í bars @ '+strint(sv,5)+' mm c/c';
	ps:=(pi*dia*dia/4)*100/(sv*d);
	steel(pdmc+plmc,1);
	op[4]:='Reinforcement at midspan            :  '
		+strreal(ast,5,2)+' mm2 - '+strint(dia,2)
		+' í bars @ '+strint(sv,5)+' mm c/c';
	p:=(pi*dia*dia/4)*100/(sv*d);
	steel(0.0,2);
	op[5]:='Transverse reinforcement            :  '
		+strreal(ast,5,2)+' mm2 - '+strint(sdia,2)
		+' í bars @ '+strint(sv,5)+' mm c/c';
	vu:=0.6*(wdead+wlive)*lx*1000;
		 { % Shear coefficient is taken as 0.6 for all conditions }
	tauv:=vu/(b*d);
	shearcheck(ps);
	end;
end;
300:
defd:=(lx*1000/(mft(p)*26));{ # floating point overflow}
if defd>momd then
		momd:=defd;
{
overd:=momd+dia div 2+cdt;
KSround(overd,5);
}
if (momd>d) and flag then
	begin
	overd:=overd+5;
	d:=overd-dia div 2-cdt;
	goto 200;
	end
		else
		if ((momd>d) and not flag) or first then
		begin
		if flag then
			lowd:=overd;
		str(lowd:5,svalue);
		if not flag then msg('Depth not adequate.');
		if (userd<overd) then
readreal(1,'Overall depth of slab  (mm) <'+strreal(lowd,4,0)+'min.>  ? ',overd)
			else
			       overd:=userd;
		flag:=FALSE;
		first:=FALSE;
		d:=overd-dia div 2-cdt;
		goto 200;
		end;
{
assign(grfout,'slab.grf');
rewrite(grfout);
writeln(grfout,'Rectangle 4,4 5,5');
writeln(grfout,'circle 4.2,4.2 0.2');
writeln(grfout,'circle 4.8,4.8 0.2');
close(grfout);
}
until (d>=momd) and (d>=defd);
prewrite;
for i:=1 to 7 do writeln(out,op[i]);
if not flags[1] then postwrite;
end;

{
begin
new(menus);
destype:='S';
slab_des(1);
dispose(menus);
}
end.


