
{***********************************    BEAM DESIGN   ***********************}

unit beam;
interface
uses lib,dlib,crt,bars;

procedure beam_des(datano:integer);
procedure beam_selread(datano,choice:integer);
procedure beam_read(datano:integer);
procedure beam_prompts(var fno:integer);
procedure beam_values;
implementation
procedure readtype(var dtype:char);
var screen:image;
begin
readchar(1,'Type of beam ? ',dtype);
if dtype in ['R','T','L'] then exit;
put(screen);
box(41,6,59,10,whilecon,0);
menus^[1]:=' Recangular beam ';
menus^[2]:=' Tee beam        ';
menus^[3]:=' L beam          ';
choice[1]:=1;
scode[1]:=#0;
boxpix(1,menus,'RTL',42,7,58,9,1,choice[1],scode[1],1);
case choice[1] of
	1:      dtype:='R';
	2:	dtype:='T';
	3:	dtype:='L';
      end;
get(screen);
end;

procedure beam_selread(datano,choice:integer);
begin
with datamat[datano] do
begin
case choice of
1:readstr(1,'Name of beam ? ',dname);
2:readtype(dtype);
3:readreal(1,'Breadth (mm) ? ',db);
4:readreal(1,'Total Depth (mm) ? ',doverd);
5:readreal(1,'Left Moment (KNm) ? ',dmu[1]);
6:readreal(1,'Middle Moment (KNm) ? ',dmu[2]);
7:readreal(1,'Right Moment (KNm) ? ',dmu[3]);
8:readreal(1,'Shear force (KN) ? ',dvu);
9:readreal(1,'Breadth of flange (mm) ? ',tbf);
10:readreal(1,'Depth of flange (mm) ? ',tdf);
end;
end;
end;

procedure beam_read(datano:integer);
begin
if aborted then exit;
with datamat[datano] do
begin
readstr(1,'Name of beam   ?    ',dname);
if dname='END' then
		begin
		dec(datano);
		exit;
		end;
inc(NM);
readtype(dtype);
if dtype in ['T','L'] then
   begin
	readreal(1,'Breadth of flange  (mm)  ?   ',tbf);
	readreal(1,'Breadth of web (mm)   ?   ',db);
	readreal(1,'Depth of flange  (mm)  ?   ',tdf);
   end
   else
       begin
       readreal(1,'Breadth  (mm)  ?   ',db);
       end;
readreal(1,'Total Depth   (mm)  ?   ',doverd);
if dtype='R'
  then
    for i:=1 to 3 do
       case i of
	  1 : readreal(1,'Left Moment (KNm) ?   ',dmu[i]);
	  2 : readreal(1,'Middle Moment (KNm) ?   ',dmu[i]);
	  3 : readreal(1,'Right Moment (KNm) ?   ',dmu[i]);
       end
   else
     readreal(1,'Moment (KNm)   ?   ',dmu[2]);
readreal(1,'Shear force  (KN)   ?   ',dvu);
{datano:=datano+1;}
end;

{
with datamat[datano] do
begin
dname:='BEAM.DEMO';
dtype:='R';
db:=230;
doverd:=500;
dmu[1]:=142.82;
dmu[2]:=86.5;
dmu[3]:=127;
dvu:=127;
end;
}
end;

procedure beam_prompts(var fno:integer);
begin
menus^[51]:='Name of beam                      : ';
menus^[52]:='Type of beam                (RTL) : ';
menus^[53]:='Breadth                      (mm) : ';
menus^[54]:='Overall Depth                (mm) : ';
menus^[55]:='Left Moment                 (KNm) : ';
menus^[56]:='Middle Moment               (KNm) : ';
menus^[57]:='Right Moment                (KNm) : ';
menus^[58]:='Shear force                  (KN) : ';
menus^[59]:='Breadth of flange            (mm) : ';
menus^[60]:='Depth   of flange            (mm) : ';
fno:=10;
end;

procedure beam_values;
var
	flag:boolean;
	s:string;
begin
with datamat[datano] do
begin
if length(dname)=0 then dname:='NONAME';
menus^[1]:=chklen(dname,14);
case upcase(datamat[datano].dtype) of
	'T':s:='Tee';
	'L':s:='L';
	'R':s:='Rectangular';
	else
		begin
		datamat[datano].dtype:='?';
		s:='?';
		end;
	end;
menus^[2]:=chklen(s,14);
menus^[3]:=justify(db,11,2,LEFT);
menus^[4]:=justify(doverd,11,2,left);
menus^[5]:=justify(dmu[1],11,2,left);
menus^[6]:=justify(dmu[2],11,2,left);
menus^[7]:=justify(dmu[3],11,2,left);
menus^[8]:=justify(dvu,11,2,left);
if dtype<>'R' then
	begin
	if flag then
		begin
		gotoxy(43,12);
		fastwrite(' ',14,Norm);
		gotoxy(43,13);
		fastwrite(' ',14,Norm);
		flag:=FALSE;
		end;
	menus^[9]:=justify(tbf,11,2,left);
	menus^[10]:=justify(tdf,11,2,left);
	end
	else
	begin
	menus^[9]:='Not Applicable';
	menus^[10]:='Not Applicable';
	flag:=TRUE;
	end;
end;
end;


procedure beam_des(datano:integer);
var
	no,i:integer;
	btype:char;
	nomenu,n1,d1,n2,d2:integer;
	name:string;
	v1,v2:real;
	jd,yf,az,bz,cz,mul,xu,xul:real;
	bf,df:real;
      mulim,sf,vu,k,q,fsc,fcc,ec,d:real;
      mu:array[1..3] of real;
      ast,asc,ast1,ast2,minast,p:real;
      vus:real;
      pts:real;
      dcbyd:real;
      tc:array[1..7] of real;
      mub,ratio,vd,pt,pc:real;
      b,overd:real;
      s:string;

procedure sheardesign(vu,b,d,p:real);
var
	tauv,asv:real;
	minsv,sv:integer;
begin
     vu:=1.5*vu*1e3;
     tauv:=vu/(b*d);
     asv:=2*pi*sdia*sdia/4;
     minsv:=mytrunc(asv*fy/(0.4*b)/10)*10;
if tauv>tmax(fck) then
     writeln(out,'Depth provided is not adequate to take shear.',noise)
     else
     begin
	{writeln(tmax(fck),tauv,tauc(p));}
           if tauv<tauc(p) then sv:=minsv
                    else sv:=mytrunc((0.87*fy*asv*d/((tauv-tauc(p))*b*d))/10)*10;
           if minsv>0.75*d then minsv:=mytrunc(0.75*d/10)*10;
           if sv>0.75*d then sv:=mytrunc(0.75*d/10)*10;
           if sv>450 then sv:=450;
           if minsv>450 then minsv:=450;
     end;
writeln(out,'Stirrups at support  |  ',sdia,'í two legged @ ',sv:3,' mm c/c');
writeln(out,'Stirrups at middle   |  ',sdia,'í two legged @ ',minsv:3,' mm c/c');
end;

procedure nobar(as:real;var no,n1,d1,n2,d2:integer;s:string);
begin
if (barsel=2) then
	begin
	selectbar('Select bar diametres',as,n1,d1,n2,d2);
	writeln(out,s,as:7:2,'mm2 - ',n1,'-',d1,'í + ',n2,'-',d2,'í ');
	end
else
	begin
	no:=mytrunc(as/(pi*dia*dia/4))+1;
	if no<=2 then no:=2;
	writeln(out,s,as:7:2,'mm2 - ',no,'-',dia,'í ');
	n1:=no;
	d1:=dia;
	n2:=0;
	d2:=0;
	end;
end;

function fs(est:real):real;
const
e:array[1..9] of real =
     (0.00144,0.00154,0.00163,0.00178,0.00192,
     0.00217,0.00241,0.00276,0.00380);
var
     f:real;
     fs1,fs2:real;
     i:integer;
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
var
	tfc:real;
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

    {                      MAIN PROGRAM FOR BEAM                      }

begin

{beam_read(datano);}
with datamat[datano] do
	begin
		name:=dname;
		b:=abs(db);
		overd:=abs(doverd);
		mu[1]:=abs(dmu[1]);
		mu[2]:=abs(dmu[2]);
		mu[3]:=abs(dmu[3]);
		vu:=abs(dvu);
		bf:=abs(tbf);
		df:=abs(tdf);
		btype:=dtype;
if not(btype in ['R','L','T']) or eq(b,0) or eq(overd,0) or
		((btype in ['T','L']) and (eq(bf,0) or eq(df,0))) or HighV then
		begin
	msg('Data no.'+p0i(datano,3)+' unsuitable for design.Press ESC');
		waitfor(ESC);
		exit;
		end;
	end;
  dt:=cdt+dia div 2;
prewrite;
  pts:=0.0;
  d:=overd-dt;
  k:=0.0035/(0.0055+0.87*fy/es);
  xul:=k*d;
  jd:=(1-0.416*k)*d;
  q:=0.36*fck*k*(1-0.416*k);
if btype='R' then
  begin
  mulim:=q*b*d*d;
  for i:=1 to 3 do
    begin
       mu[i]:=1.5*mu[i]*1e6;
       if mulim>mu[i]      { SINGLY REINFORCED SECTION }
           then begin
                     ast:=0.5*fck/fy*(1-sqrt(1-4.6*mu[i]/(fck*b*d*d)))*b*d;
                     minast:=0.85*b*d/fy;
                     if ast<minast then  ast:=minast;
                     pt:=ast/(b*d)*100;
                     pc:=0.0;
                     asc:=0.0;
                 end
           else  { DOUBLY REINFORCED SECTION }
                begin
                    ec:=0.0035*(xul-dc)/(xul);
                    fsc:=fs(ec);
                    fcc:=fc(ec);
                    ast1:=mulim/(0.87*fy*jd);
                    ast2:=(mu[i]-mulim)/(0.87*fy*(d-dc));
                    ast:=ast1+ast2;
                    asc:=(mu[i]-mulim)/((fsc-fcc)*(d-dc));
                    pt:=ast/(b*d)*100;
                    pc:=asc/(b*d)*100;
              end;
mu[i]:=mu[i]*1e-6;		{ # ? }
case i of
1:
	begin
case upcase(datamat[datano].dtype) of
	'T':s:='Tee';
	'L':s:='L';
	'R':s:='Rectangular';
	end;
	writeln(out,'Name of beam        :   ',name,' (',s,')');
	writeln(out,'Breadth             =   ',mytrunc(b),' mm');
	writeln(out,'Depth               =   ',mytrunc(overd),' mm');
	nobar(ast,no,n1,d1,n2,d2,'Main bars at left support  (top)     | ');
	pts:=(n1*pi*sqr(d1)/4+n2*pi*sqr(d2)/4)/b*d*100;
	nobar(asc,no,n1,d1,n2,d2,'Main bars at left support  (bottom)  | ');
	end;
2:
	begin
	nobar(ast,no,n1,d1,n2,d2,'Main bars at middle  (bottom)        | ');
	nobar(asc,no,n1,d1,n2,d2,'Main bars at middle  (top)           | ');
	end;
3:
	begin
	if (pts>pt) then pts:=pt;
	nobar(ast,no,n1,d1,n2,d2,'Main bars at right support  (top)    | ');
	if pts<(n1*pi*sqr(d1)/4+n2*pi*sqr(d2)/4)/b*d*100
		then pts:=(n1*pi*sqr(d1)/4+n2*pi*sqr(d2)/4)/b*d*100;
	nobar(asc,no,n1,d1,n2,d2,'Main bars at right support  (bottom) | ');
	end;
end;
if (ast+asc)>(0.04*b*overd) then
         writeln(out,'Percentage of steel exceeds permissible limit .',noise);
end;
end;
if btype in ['T','L']
   then
       begin
       exit;
       mu[2]:=1.5*mu[2]*1e6;
case upcase(datamat[datano].dtype) of
	'T':s:='Tee';
	'L':s:='L';
	'R':s:='Rectangular';
	end;        { avoid duplication }

	writeln(out,'Name of beam        :   ',name,' (',s,')');
	writeln(out,'Breadth             =   ',mytrunc(b),' mm');
	writeln(out,'Depth               =   ',mytrunc(overd),' mm');
             yf:=0.15*k*d+0.65*df;
             if yf>df then yf:=df;
	{     writeln('yf   =   ',yf:5:2);}
             mulim:=q*b*d*d +0.446*fck*(bf-b)*yf*(d-0.5*yf) ;
	{     writeln('mulim   =   ',mulim:5:2);}
	     if mu[2]<mulim
                then
                  begin
                      mul:=0.36*fck*bf*df*(d-0.416*df);
{	     writeln('mul   =   ',mul:5:2);}
		      if mu[2]<mul
                         then     { Neutral axis in flange }
                           begin
			    xu:=(1.2019231+sqrt(1.4446191-6.6773504*mu[2]/(fck*bf*d*d))) *d ;
			    { # ? error }
	{     writeln('xu   =   ',xu:5:2);}
                            jd:=d-0.416*xu;
	{     writeln('jd   =   ',jd:5:2);}
			    ast:=mu[2]/(0.87*fy*jd);
{	writeln('ast  =   ',ast:5:2);}
	nobar(ast,no,n1,d1,n2,d2,'Main bars at tension side     | ');
	pts:=(n1*pi*sqr(d1)/4+n2*pi*sqr(d2)/4)/b*d*100;
                            end
                         else
                           begin
                             az:= -0.41976*fck*b-0.0050175*fck*(bf-b);
                             bz:=0.36*fck*b*d+0.0669*fck*(bf-b)*(d-0.65*df);
			     cz:=0.2899*fck*df*(bf-b)*(d-0.325*df)-mu[2];
                             xu:= (-bz+sqrt(bz*bz-4*az*cz))/(2*az);
	{     writeln('xu   =   ',xu:5:2);}
                             v1:=0.36*fck*b*xu;
                             v2:=0.446*fck*(bf-b);
                             jd:=(v1*0.416*xu+v2*yf*yf/2)/(v1+v2);
{	     writeln('jd   =   ',jd:5:2);  }
			     ast:=mu[2]/(0.87*fy*jd);
	nobar(ast,no,n1,d1,n2,d2,'Main bars at tension side     | ');
	pts:=(n1*pi*sqr(d1)/4+n2*pi*sqr(d2)/4)/b*d*100;
                             end;
                  end
              else
                  begin
                       ast1:=mulim/(0.87*fy*jd);
		       ast2:=(mu[2]-mulim)/(0.87*fy*(d-dc));
{	     writeln('ast1   =   ',ast1:5:2);}
                       ast:=ast1+ast2;
	nobar(ast,no,n1,d1,n2,d2,'Main bars at tension side     | ');
	pts:=(n1*pi*sqr(d1)/4+n2*pi*sqr(d2)/4)/b*d*100;
{	     writeln('ast   =   ',ast:5:2);  }
		       asc:=(mu[2]-mulim)/((fsc-fcc)*(d-dc));
{	     writeln('asc   =   ',asc:5:2);}
	nobar(asc,no,n1,d1,n2,d2,'Main bars at compression side | ');
                  end;
end;
                                {  SHEAR DESIGN   }
sheardesign(vu,b,d,pts);
if not flags[1] then postwrite;
end;

end.