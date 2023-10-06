


{***************************  Column Design ******************************}


unit col;
interface

PROCEDURE col_values;
PROCEDURE col_prompts(var fno:integer);
PROCEDURE col_read(datano:integer);
PROCEDURE col_selread(datano,choice:integer);
PROCEDURE col_des(datano:integer);

implementation

uses crt,lib,dlib;
const
     no=20;
var
     name,svalue:string[25];
     lx,ly,b,d,pu,mux,muy:real;
     p,ast:real;
     i,side:integer;
     ratio:real;
     ano:integer;
     eminx,eminy:real;
     min,max:real;
     casetype:byte;

FUNCTION fs(est:real):real;
const
	e:array[1..9] of real =
     (0.00144,0.00154,0.00163,0.00178,0.00192,0.00217,0.00241,0.00276,0.00380);
var  i:integer;
     f:real;
     fs1,fs2:real;
begin
if abs(est)<=0.00144
   then
       f:=abs(est)*es/(0.87*fy)
   else
       if abs(est)>=0.00380 then f:=1
          else
             begin
               i:=0;
               repeat
               i:=i+1;
               until abs(est)<e[i];
               fs1:=0.775+(i-1)*0.025;
               fs2:=0.775+(i)*0.025;
               f:=fs1+0.025/(e[i]-e[i-1])*(abs(est)-e[i-1]);
             end;
if est>0.0
   then
        fs:=f*0.87*fy
   else
       fs:=-f*0.87*fy;
end;

FUNCTION fc(ec:real):real;
var
	tfc:real;
begin
if ec<=0
        then
            tfc:=0.0
        else
            if ec<0.002
               then
		   tfc:=0.446*fck*(2*(ec/0.002)-exp(2*ln(ec/0.002)))
		   { # invalid floating point operation. OK ?}
               else
                   tfc:=0.446*fck;
fc:=tfc;
end;

PROCEDURE colcap(p,b,d:real;var mucap:real);
var
     k,pucap,z,g,c1,c2,er,el:real;
     kmin,kmax:real;
     fsr,fsl,fcr,fcl,y:array[1..5]of real;
     i:integer;
begin
ast:=p*b*d/100;
kmin:=0.0;
kmax:=4;
 repeat
   k:=(kmin+kmax)/2.0;
       if k>1
         then
            begin
                 z:=0.002/(k*d-3/7*d);
                 g:=0.446*exp(2*ln(4.0/(7.0*k-3.0)));
                 c1:=0.446-4.0/21.0*g;
                 c2:=(0.446/2-8.0/49.0*g)/c1;
            end
          else
              begin
                   z:=0.0035/(k*d);
                   g:=0.446;
              c1:=(0.446-4.0/21.0*g)*k;
              c2:=((0.446/2-8.0/49.0*g)/c1)*k*k;
              end;
   for i:=1 to 3 do
       begin
         y[i]:=(2*i-1)*(d-2*dt)/(no/2);
         er:=z*(k*d-d/2+y[i]);
         el:=z*(k*d-d/2-y[i]);
         fsr[i]:=fs(er);
         fsl[i]:=fs(el);
         fcr[i]:=fc(er);
	  fcl[i]:=fc(el);
       end;
   for i:=4 to 5 do
       begin
         y[i]:=y[3];
         fsr[i]:=fsr[3];
         fsl[i]:=fsl[3];
         fcr[i]:=fcr[3];
         fcl[i]:=fcl[3];
       end;
  if (side=2) then
    for i:=1 to 2 do
       begin
          y[i]:=y[3];
          fsr[i]:=fsr[3];
          fsl[i]:=fsl[3];
          fcr[i]:=fcr[3];
          fcl[i]:=fcl[3];
       end;
  pucap:=0.0;
  mucap:=0.0;
  for i:=1 to 5 do
    begin
         pucap:=pucap+ast/(no/2)*(fsr[i]-fcr[i]+fsl[i]-fcl[i]);
         mucap:=mucap+ast/(no/2)*((fsr[i]-fcr[i])-(fsl[i]-fcl[i]))*y[i];
    end;
  pucap:=c1*fck*b*d+pucap;
  mucap:=c1*fck*b*d*d*(0.5-c2)+mucap;
  if pu>pucap
		then
			kmin:=k
		else
			kmax:=k;
  if (kmax-kmin)<1e-10 then
				msg('Possible error detected.'+noise);
until (pu<=0.0) or ((abs(pu-pucap)/pu)<0.01) or (kmax-kmin<1e-10);
end;

FUNCTION alpha:real;
var puz:real;
begin
     puz:=0.45*fck*(b*d-ast)+0.75*fy*ast;
     if (pu/puz)<=0.2
        then
            alpha:=1.0
        else
            if (pu/puz)>=0.8
               then
                   alpha:=2.0
               else
                   alpha:=1.0+1/(0.8-0.2)*(pu/puz-0.2);
end;

PROCEDURE ties;
var pitch:integer;
begin
     if (b<(16*dia)) and (b<(48*sdia))
                                       then pitch:=mytrunc(b);
     if ((16*dia)<(48*sdia)) and ((16*dia)<b)
                                       then pitch:=mytrunc(16*dia);
     if ((48*sdia)<(16*dia)) and ((48*sdia)<b)
                                       then pitch:=mytrunc(48*sdia);
     pitch:=mytrunc(pitch/10)*10;
writeln(out,'Lateral ties                =  ',sdia,'mm bars ',' @ ',pitch,' mm c/c');
end;

PROCEDURE nobar(ast:real);
begin
     ano:=mytrunc(ast/(pi*dia*dia/4)+1);
     if ano<=4 then ano:=4;
end;


FUNCTION axialp:real;
begin
p:=0.75;
repeat
    p:=p+0.05;
until (pu<(0.4*fck*(b*d-p*b*d/100)+0.67*fy*p*b*d/100)) or (p>6.0);
axialp:=p;
end;

function uniaxialp(b,d,mu:real):real;
var
	mucap:real;
begin
  min:=axialp;
  max:=6.00;
  if (min<=6.0) then
	      begin
		colcap(6.00,b,d,mucap);
	      if mucap<mu
			then
				p:=6.05
			else
			      repeat
				 p:=(min+max)/2;

				 str(p:4:2,svalue);
				 msg('Please wait  ..... '+svalue+' % ');

				 colcap(p,b,d,mucap);
				 if mucap>mu
					then
						max:=p
					else
						min:=p;
			      until abs(max-min)<0.005;
	      end;
uniaxialp:=p;
end;

FUNCTION biaxialp:real;
var
	mux1,muy1:real;
begin
min:=axialp;
max:=6.00;
if (min<6.0) then
     begin
      colcap(6.00,b,d,mux1);
      colcap(6.00,d,b,muy1);
      ratio:=exp(alpha*ln(mux/mux1))+exp(alpha*ln(muy/muy1));
      if (ratio>1)
		then
			p:=6.05
		else
	      repeat
		p:=(min+max)/2;

		str(p:4:2,svalue);
		msg('Please wait  ..... '+svalue+' % ');

		colcap(p,b,d,mux1);
		colcap(p,d,b,muy1);
		ratio:=exp(alpha*ln(mux/mux1))+exp(alpha*ln(muy/muy1));
		if ratio<=1
			then
				max:=p
			else
				min:=p;
	      until abs(max-min)<0.005;
end;
biaxialp:=p;
end;


PROCEDURE col_selread(datano,choice:integer);
var
	c:char;
begin
with datamat[datano] do
case choice of
1:readstr(1,'Name of column     ?   ',dname);
2:readreal(1,'Breadth (mm)  ?   ',dbreadth);
3:readreal(1,'Depth   (mm)  ?    ',ddepth);
4:readreal(1,'Axial Load  (KN) ?    ',dload);
5:readreal(1,'Moment (X-direction) (KNm)  ?   ',dmux);
6:readreal(1,'Moment (Y-direction) (KNm)  ?   ',dmuy);
7:readint(1,'Reinforcement on Two sides or Four sides  < 2/4 >  ?  ',dside);
8:readreal(1,'Length (X-direction)  (m) ?   ',dlxc);
9:readreal(1,'Length (Y-direction)  (m) ?   ',dlyc);
end;
end;

PROCEDURE col_read(datano:integer);
begin
if aborted then exit;
col_selread(datano,1);
if datamat[datano].dname='END' then
			begin
			dec(datano);
			exit;
			end;
inc(NM);
for i:=2 to 9 do col_selread(datano,i);
{
with datamat[datano] do
	begin
	dname:='COL.DEMO';
	dbreadth:=400;
	ddepth:=600;
	dload:=1600/1.5;
	dmux:=120/1.5;
	dmuy:=90/1.5;
	dside:=4;
	dlxc:=0;
	dlyc:=0;
	end;
}
end;

PROCEDURE col_prompts(var fno:integer);
begin
menus^[51]:='Name of column                    : ';
menus^[52]:='Breadth                      (m)  : ';
menus^[53]:='Depth                        (m)  : ';
menus^[54]:='Axial Load                  (KN)  : ';
menus^[55]:='Moment (X-direction)       (KNm)  : ';
menus^[56]:='Moment (Y-direction)       (KNm)  : ';
menus^[57]:='Reinforcement        (2/4 sides)  : ';
menus^[58]:='Length (X-direction)         (m)  : ';
menus^[59]:='Length (Y-direction)         (m)  : ';
fno:=9;
end;

procedure col_values;
begin
with datamat[datano] do
begin
	if length(dname)=0 then	dname:='Noname';
	menus^[1]:=chklen(dname,14);
	menus^[2]:=justify(dbreadth,11,2,LEFT);
	menus^[3]:=justify(ddepth,11,2,left);
	menus^[4]:=justify(dload,11,2,left);
	menus^[5]:=justify(dmux,11,2,LEFT);
	menus^[6]:=justify(dmuy,11,2,left);
	menus^[7]:=strint(dside,1);
	menus^[8]:=justify(dlxc,11,2,LEFT);
	menus^[9]:=justify(dlyc,11,2,left);
	if eq(dlxc,0) then menus^[8]:='0.00(=Short)  ';
	if eq(dlyc,0) then menus^[9]:='0.00(=Short)  ';
end;
end;


{******************** MAIN PROGRAM  FOR COLUMN DESIGN          }

PROCEDURE col_des(datano:integer);
var
	min,max:real;
	i:integer;

begin

{col_read(datano);}
with datamat[datano] do
	begin
		name:=dname;
		b:=dbreadth;
		d:=ddepth;
		pu:=abs(1.5*dload*1e3);
		mux:=abs(1.5*dmux*1e6);
		muy:=abs(1.5*dmuy*1e6);
		side:=dside;
		lx:=dlxc;
		ly:=dlyc;
	lx:=3;
	ly:=3;
	end;
if (b<=0) or (d<=0) or not(side in [2,4]) or HighV then
			begin
			msg('Datano.'+p0i(datano,3)+' unsuitable for design.Press ESC.'+noise);
			waitfor(ESC);
			exit;
			end;
dt:=cdt+dia div 2;
p:=0.75;
ast:=p*b*d/100;
eminx:=lx*100/500+d/10/30;
eminy:=ly*100/500+b/10/30;
	if eq(mux,0) and not eq(muy,0) then casetype:=2
else
	if eq(muy,0) and not eq(mux,0) then casetype:=3
else
	if eq(pu,0) and eq(mux,0) and eq(muy,0) then casetype:=4
else
	casetype:=1;
   if (mux<eminx*pu) then mux:=eminx*pu;
   if (muy<eminy*pu) then muy:=eminy*pu;
case casetype of
1:	p:=biaxialp;
2:     	p:=uniaxialp(d,b,muy);
3:	p:=uniaxialp(b,d,mux);
4:      p:=0.8;
end;
if (p>6.0) then
   begin
   msg('Percentage of steel exceeds permissible limit.Press ESC.'+noise);
   waitfor(ESC);
   end
else
begin
str(p:4:2,svalue);
prewrite;
writeln(out,'Name of column              :  ',name);
writeln(out,'Length of column            =  ',lx:4:2,' m'); {# lx,ly &/? }
writeln(out,'Breadth                     =  ',mytrunc(b),' mm');
writeln(out,'Depth                       =  ',mytrunc(d),' mm');
writeln(out,'Area of main bars           =  ',svalue,'% (',ast:6:2,' mm2)');
nobar(ast);
writeln(out,'Main bars                   =  ',ano,'-',dia,'í on  ',side,' sides');
ties;
if not flags[1] then postwrite;
end;
end;
end.


{
Notes:
1. Input values are multiplied with 1.5.
}


