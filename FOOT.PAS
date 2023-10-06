
{*******************************  Footing Design  ***************************}
unit foot;
interface
procedure foot_des(datano:integer);
procedure foot_selread(datano,choice:integer);
procedure foot_read(datano:integer);
procedure foot_prompts(var fno:integer);
procedure foot_values;
implementation
uses crt,lib,dlib;
procedure foot_selread(datano,choice:integer);
begin
with datamat[datano] do
case choice of
	1:readstr(1,'Name of footing  ?  ',dname);
	2:readreal(1,'Axial Load  (KN)   ?  ',dload);
	3:readreal(1,'Moment (X-direction)  (KNm)    ?  ',dmuxf);
	4:readreal(1,'Moment (Y-direction)  (KNm)    ?  ',dmuyf);
	5:readreal(1,'Safe Bearing Capacity (KN/m2)  ?  ',dq0);
	6:readreal(1,'Column breadth (mm) ?  ',dy);
	7:readreal(1,'Column depth   (mm) ?  ',dx);
	end;
end;

procedure foot_read(datano:integer);
begin
if aborted then exit;
foot_selread(datano,1);
if datamat[datano].dname='END' then
			begin
			dec(datano);
			exit;
			end;
inc(NM);
for i:=2 to 7 do foot_selread(datano,i);
{
with datamat[datano] do
begin
dname:='FOOT.DEMO';
dload:=1000;
dmuxf:=200;
dmuyf:=0;
dq0:=90;
dy:=600;
dx:=600;
end;
}
end;

procedure foot_prompts(var fno:integer);
begin
menus^[51]:='Name of footing                   : ';
menus^[52]:='Axial Load                  (KN)  : ';
menus^[53]:='Moment (X-direction)       (KNm)  : ';
menus^[54]:='Moment (Y-direction)       (KNm)  : ';
menus^[55]:='Safe bearing capacity    (KN/m2)  : ';
menus^[56]:='Column breadth               (m)  : ';
menus^[57]:='Column depth                 (m)  : ';
fno:=7;
end;

procedure foot_values;
begin
with datamat[datano] do
	begin
	if length(dname)=0 then
			dname:='NONAME';
		menus^[1]:=chklen(dname,14);
		menus^[2]:=justify(dload,11,2,LEFT);
		menus^[3]:=justify(dmuxf,11,2,LEFT);
		menus^[4]:=justify(dmuyf,11,2,LEFT);
		menus^[5]:=justify(dq0,11,2,LEFT);
		menus^[6]:=justify(dy,11,2,LEFT);
		menus^[7]:=justify(dx,11,2,LEFT);
	end;
end;



{****************MAIN****************}

procedure foot_des(datano:integer);
var
   dt,z,tem:real;
   name:string[25];
   x,y,q1,q2,k,pu,mux,muy,pmax,p,pmin,q0,w,pz,l,b:real;
   ddby2,eqb,v,ld,d,overd,dd,bd,bna,bm:real;
   per,pcd,de,pcf,taucx,tauv,ks:real;
   pcon,ast,mu,minast:real;
   depth,astl,midast,remast:real;
   j,p0,p02:real;
   svl,midsv,remsv:integer;
   distsv,sv:integer;
   i,p1,p2:integer;
   dist,d_dia:boolean;
   factor:real;
   row:char;
   col:integer;
   result:array[1..10]of real;
   lors,pse:char;

procedure shearcheck(p:real);
begin
     if overd>300 then k:=1.00;    { % check }
     if overd<=150 then k:=1.30;
     if (overd>150) and (overd<300)
           then k:=1.30-0.30/(300-150)*(overd-150);

     if (tauv>k*tauc(p)) or (tauv>tmax(fck)/2) then
        writeln(out,'Depth provided is not adequate to take shear.',noise);
end;

procedure design(y,x,l,b,mux:real;var ast:real);
begin
pmax:=pu/(l*b)+6*mux/(l*l*b);
pmin:=pu/(l*b)-6*mux/(l*l*b);
p:=(pmax+pmin)/2;
pcf:=pmin+(pmax-pmin)/l*((l-x)/2+x);
bm:=1.5*b*(pcf*(l-x)/2.0*(l-x)/4.0+(pmax-pcf)/2.0*2.0/3.0*(l-x)/2.0*(l-x)/2.0);
d:=sqrt(bm/((q1-q2)*(x+2*pr)+b*q2));
eqb:=(2*pr+y)+q2/q1*(b-(2*pr+y));
overd:=mytrunc((d+dt)/10)*10+10;
d:=overd-dt;
{
writeln(out,'Overall depth   =   ',overd:6:2);
inc(line);
}
if not d_dia then
begin
{
readchar(1,'Change depth   <Y/N>  ?   ',resp);
}
resp:='N';
if resp='Y' then
   begin
   readreal(1,'Overall depth  (mm)  ?   ',overd);
   windows(wout,nocls);
{
   writeln(out,'New Overall depth    =  ',mytrunc(overd),' mm');
}
{
inc(line);
}
d:=overd-dt;
   end;
end
else if depth>d then d:=depth;

{  CHECK ONEWAY SHEAR
d:=d-10;
repeat
      d:=d+10;
      pcd:=pmin+(pmax-pmin)/l*((l+x)/2+d);
      v:=1.5*(pmax+pcd)/2*b*((l-x)/2-d);
      dd:=de+(d-de)/((l-x)/2)*((l-x)/2-d);
      bd:=y+(b-y)/(d-de)*(d-dd);
      bna:=bd+(b-bd)/(dd-de)*k*dd;
      tauv:=v/(bna*dd);
      shearcheck(tauc));
until tauv<tauc;
   CHECK TWO WAY SHEAR   }
d:=d-10;
repeat
      d:=d+10;
      v:=1.5*p*(l*b-(x+d)*(y+d));
      per:=2*(x+d+y+d);
      if pr>(d/2) then
                      ddby2:=d
                  else
                  ddby2:=de+(d-de)*((l-x)/2-(d/2))/((l-x)/2-pr);
      tauv:=v/(per*ddby2);
      ks:=0.5+y/x;  { # floating point overflow error }
      if ks>1 then ks:=1;
      taucx:=ks*0.25*sqrt(fck);
until tauv<taucx;
                         {    AREA OF STEEL    }
      p0:=0.414*805/(1265+fy);
      p02:=0.234*k*k;
{
ast:=((p0-p02)*(2*pr+x)+p02*b)*d*fck/fy;
}
      j:=1-0.42*k;
      ast:=1.15*bm/(j*d*fy);
{
ast:=0.5*fck/fy*(1-sqrt(1-4.6*bm/(fck*eqb*d*d)))*eqb*d;
}
     if d_dia=true then
        begin
{ast:=0.5*fck/fy*(1-sqrt(1-4.6*bm/(fck*eqb*(d-dia)*(d-dia))))*eqb*(d-dia);}
        ast:=1.15*bm/(j*(d-dia)*fy);
        end;
     minast:=0.12*b*overd/100;
     if ast<minast then
              ast:=minast;
end;

procedure spacing(b:real;as:real;var sv:integer);
begin
sv:=mytrunc(((pi*dia*dia/4.0)*b/as)/10.0)*10;
if sv>(3*d) then sv:=mytrunc(3*d/10)*10;
if sv>450 then sv:=450;
if sv<dia then sv:=dia;
end;




		{ MAIN PROGRAM FOR FOOT DESIGN }


begin
{foot_read(datano);}
with datamat[datano] do
	begin
		name:=dname;
		pu:=abs(dload*1e3);
		mux:=abs(dmuxf*1e6);
		muy:=abs(dmuyf*1e6);
		q0:=dq0;
		y:=dy;
		x:=dx;
	end;
if (x<1) or (y<1) or (q0<1) or (pu<1) or HighV then
		begin
		msg('Datano '+p0i(datano,3)+' unsitable for design.Press ESC.'+noise);
		waitfor(ESC);
		exit;
		end;
{put(screen);}
      dt:=cdt+dia;
      de:=ode-dt;
      w:=pu+pu*f/100;
      q0:=q0*1e-3;
      k:=0.0035/(0.0055+0.87*fy/es);
      q1:=0.36*fck*k*(1-0.416*k);
      q2:=0.15*fck*k*k*(1-0.565*k);
z:=0;
repeat
   z:=z+10;
   pz:=z;
   tem:=w/q0+6.0*mux/(q0*(x+z))+6.0*muy/(q0*(y+z))-x*z+y*z+x*y;
   if tem>=0 then z:=sqrt(tem) else exit;
until abs((z-pz)/z)<0.1;

      z:=mytrunc(z/10)*10;
      l:=x+z;
      b:=y+z;
{
writeln(out,'Breadth   =  ',mytrunc(b),' mm');
inc(line);
}
{
writeln(out,'Length    =  ',mytrunc(l),' mm');
}
{
inc(line);

readchar(1,'Change Breadth  ? Y/N  ',resp);
}
resp:='N';
if resp='Y' then
   begin
      readreal(1,'New breadth  (mm)  ?  ',b);
      windows(wout,nocls);
      writeln(out,'New breadth   =  ',mytrunc(b),' mm');
{
      inc(line);
}
      l:=(w/b+sqrt(sqr(w/b)+4*q0*6*(mux+muy)/b))/(2*q0);
      l:=mytrunc(l/10)*10+10;
      writeln(out,'New length    =  ',mytrunc(l),' mm');
{
      inc(line);
}
   end;
{
readchar(1,'Change Length  ? Y/N  ',resp);
}
resp:='N';
if resp='Y' then
begin
     readreal(1,'New length  (mm)  ? ',l);
     windows(wout,nocls);
     writeln(out,'New length    =  ',mytrunc(l),' mm');
{
     inc(line);
}
{
     b:=w/(q0*l)+6*(mux+muy)/(q0*l*l);
     b:=mytrunc(b/10)*10+10;
     }
end;
     d_dia:=false;
     design(y,x,l,b,mux,ast);
     depth:=d;
     astl:=ast;
     spacing(b,ast,svl);
     d_dia:=true;
     design(x,y,b,l,muy,ast);
     if d<depth then d:=depth;
if (l-b)>100
   then
       begin
             midast:=2.0/(l/b+1.0)*ast;
             spacing(b,midast,midsv);
             remast:=ast-midast;
             spacing(l-b,ast-midast,remsv);
       end
   else
       begin
            spacing(l,ast,midsv);
	    remsv:=midsv;  { # cautionless change-check }
       end;
depth:=d+dt;
{
  write(out,'                         ÄÄÄÄÄÄÄÄÄÄ');
for i:=1 to length(name) do write('Ä');
writeln(out);
}
prewrite;

writeln(out);
writeln(out,'     Footing   ',name);
writeln(out,'     Breadth                       =  ',b:10:2,' mm');
writeln(out,'     Length                        =  ',l:10:2,' mm');
writeln(out,'     Depth                         =  ',depth:10:2,' mm');
writeln(out,'     Ast in Longer direction       =  ',astl:10:2,' mm2');
writeln(out,'     Reinforcement                 =  ',dia,'í @ ',svl,' mm c/c');
if (l-b)>100
then
   begin
writeln(out,'     Ast (mid of long span)        =  ',midast:10:2,'  mm2');
writeln(out,'     Reinforcement                 =  ',sdia,'í @ ',midsv,' mm c/c');
writeln(out,'     Ast (remainder of long span)  =  ',remast:10:2,' mm2');
writeln(out,'     Reinforcement                 =  ',sdia,'í @ ',remsv,' mm c/c');
   end
else
  begin
writeln(out,'     Ast in Shorter direction      =  ',astl:10:2,' mm2');
writeln(out,'     Reinforcement                 =  ',dia,'í @ ',svl,' mm c/c');
  end;
if not flags[1] then postwrite;
{get(screen);}
end;
end.

{ Notes:
1.	 Design values ( BM & SF ) are multiplied wih 1.5.
}