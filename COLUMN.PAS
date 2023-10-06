
{***************************  Column Design ******************************}
{
unit column;
interface
procedure col_des;
implementation
}
uses lib,dlib;
const
     es=2e5;
     no=20;
var
	name:string[25];
	l,b,d,pu,mux,muy,emin:real;
	svalue:string;
     p,ast:real;
     side:integer;
     mux1,muy1:real;
     ratio:real;
     i:integer;
     ano:integer;
     x1:char;x2:integer;
     pr:char;
     eminx,eminy:real;

function fs(est:real):real;
const  e:array[1..9] of real =
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

function fc(ec:real):real;
var tfc:real;
begin
if ec<0
        then
            tfc:=0.0
        else
            if ec<0.002
               then
                   tfc:=0.446*fck*(2*(ec/0.002)-exp(2*ln(ec/0.002)))
               else
                   tfc:=0.446*fck;
fc:=tfc;
end;

procedure colcap(p,b,d:real;var mucap:real);
var  k,pucap,z,g,c1,c2,er,el:real;
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
  if pu>pucap then kmin:=k;
  if pu<pucap then kmax:=k;
until (pu<=0.0) or ((abs(pu-pucap)/pu)<0.01);
end;

function alpha:real;
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

procedure ties;
var pitch:integer;
begin
     if (b<(16*dia)) and (b<(48*sdia))
                                       then pitch:=trunc(b);
     if ((16*dia)<(48*sdia)) and ((16*dia)<b)
                                       then pitch:=trunc(16*dia);
     if ((48*sdia)<(16*dia)) and ((48*sdia)<b)
                                       then pitch:=trunc(48*sdia);
     pitch:=trunc(pitch/10)*10;
writeln(out,'Lateral ties                :   ',sdia,'mm bars ',' @ ',pitch,' mm c/c');
end;

procedure nobar(ast:real);
begin
     ano:=trunc(ast/(pi*dia*dia/4)+1);
     if ano<=4 then ano:=4;
end;

procedure readcolumn;
begin
     readstr(1,'Name of column     ?   ',name);

     readreal(1,'Breadth - b (mm) ?   ',b);
     readreal(1,'Depth  -  d (mm) ?    ',d);
     readreal(1,'Axial Load - Pu (KN) ?    ',pu);
     readreal(1,'Moment in X direction - Mux (KNm)  ?   ',mux);
     readreal(1,'Muy  (KNm)  ?   ',muy);
     readint(1,'Reinforcement on Two sides or four sides  < 2/4 >  ?  ',side);
end;

{             MAIN PROGRAM  FOR COLUMN DESIGN          }
procedure col_des;
var min,max:real;

begin
     fck:=15;
     fy:=415;
     sfy:=250;
     dia:=20;
     sdia:=6;
     cdt:=24;
     l:=3.0;
repeat
     constants;
     pu:=0;
     mux:=0;
     muy:=0;
     readcolumn;
     if aborted then
	begin
	msg('Current process aborted');
	exit;
	end;
     dt:=cdt+dia div 2;
     pu:=pu*1e3;
     mux:=mux*1e6;
     muy:=muy*1e6;
     p:=0.75;
     ast:=p*b*d/100;

if (mux=0) and (muy<>0)
       then
           begin
           eminx:=l*100/500+d/10/30;
           mux:=eminx*pu;
           if pu>(0.4*fck*(b*d-p*b*d/100)+0.67*fy*p*b*d/100) then
              begin
                repeat
                p:=p+0.05;
                until (pu<(0.4*fck*(b*d-p*b*d/100)+0.67*fy*p*b*d/100)) or (p>6.0);
                p:=p-0.05;
	      end;
	  min:=p+0.05;
	  max:=6.00;
	  if (min<6.0) then
	      begin
	      colcap(6.00,d,b,muy1);
	      if muy1<muy then
		p:=6.05
	      else
	      repeat         { % substitute by bisection }
		 p:=(min+max)/2;
		 str(p:4:2,svalue);
		 msg('Please wait  ..... '+svalue+' % ');
		 colcap(p,d,b,muy1);
		 if muy1>muy
			then
				max:=p
			else
				min:=p;
		until (max-min<0.05);
	      end;
	end
else
	   if (mux<>0) and (muy=0) then
              begin
              eminy:=l*100/500+b/10/30;
              muy:=eminy*pu;
              if pu>(0.4*fck*(b*d-p*b*d/100)+0.67*fy*p*b*d/100) then
                begin
                  repeat
                  p:=p+0.05;
                  until (pu<(0.4*fck*(b*d-p*b*d/100)+0.67*fy*p*b*d/100))
                                                              or (p>6.0);
                  p:=p-0.05;
		end;
	  min:=p+0.05;
	  max:=6.00;
	  if (min<6.0) then
	      begin
		      colcap(6.00,d,b,muy1);
		      if muy1<muy
				then
					p:=6.05
				else
				 repeat
				   p:=(min+max)/2;
				   str(p:4:2,svalue);
				   msg('Please wait  ..... '+svalue+' % ');
				   colcap(p,b,d,mux1);
			 if muy1>muy
					then
						max:=p
					else
						min:=p;
				 until (mux1>mux) or (p>6.0);
			end;
end
else
    if (mux=0) and (muy=0) then
       begin
           eminx:=l*100.0/500.0+d/10.0/30.0;
           eminy:=l*100.0/500.0+b/10.0/30.0;
           mux:=eminx*pu;
           muy:=eminy*pu;
           if pu>(0.4*fck*(b*d-p*b*d/100)+0.67*fy*p*b*d/100) then
              begin
                    repeat
                    p:=p+0.05;
                    until (pu<(0.4*fck*(b*d-p*b*d/100)+0.67*fy*p*b*d/100))
                                                                or (p>6.0);
                    p:=p-0.05;
	      end;
           if (p<6.0) then
              if ((eminx/(d/10))<0.05) and ((eminy/(b/10))<0.05)
                 then
                     p:=(pu/(b*d)-0.4*fck)*100/(0.67*fy-0.4*fck)
                 else
                     repeat
                       p:=p+0.05;
			str(p:4:2,svalue);
			msg('Please wait  ..... '+svalue+' % ');
                       colcap(p,b,d,mux1);
                       colcap(p,d,b,muy1);
                       ratio:=exp(alpha*ln(mux/mux1))+exp(alpha*ln(muy/muy1));
		 until (ratio<=1.0) or (p>6.0);
     end
else
             if (mux>0) and (muy>0) then
                begin
                  if pu>(0.4*fck*(b*d-p*b*d/100)+0.67*fy*p*b*d/100) then
                    begin
                      repeat
                      p:=p+0.05;
                      until (pu<(0.4*fck*(b*d-p*b*d/100)+0.67*fy*p*b*d/100))
                                                                  or (p>6.0);
                      p:=p-0.05;
                    end;
               if (p<6.0) then
                  repeat
                    p:=p+0.05;
		 str(p:4:2,svalue);
		 msg('Please wait  ..... '+svalue+' % ');
                    colcap(p,b,d,mux1);
                    colcap(p,d,b,muy1);
                    ratio:=exp(alpha*ln(mux/mux1))+exp(alpha*ln(muy/muy1));
		  until (ratio<=1.0) or (p>6.0);
end;
msg('');
if (p>6.0) then
   msg('Percentage of steel exceeds permissible limit.'+noise)
else
begin
windows(wout,cls);
writeln(out,'Name of column              :  ',name);
writeln(out,'Length of column            =  ',l:4:2,' m');
writeln(out,'Breadth                     =  ',trunc(b),' mm');
writeln(out,'Depth                       =  ',trunc(d),' mm');
writeln(out,'Area of main bars           =  ',ast:6:2,' mm2');
nobar(ast);
writeln(out,'Main bars  :  ',ano,' number ',dia,' mm dia bars on  ',side,' sides');
ties;
end;
readchar(1,'Design another column  ?  ',pr);
until pr='N';
end;
{$I startup.inc}
begin
startup;
col_des;
end.
