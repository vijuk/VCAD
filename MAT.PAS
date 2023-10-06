unit  mat;
interface
procedure mat_ana;
implementation
{PROGRAM MATRIX;}
{    THIS PROGRAM CAN ANALYSE FIVE BASIC TYPES OF CIVIL ENGG STRUCTURES     }
{    ie.PLANE FRAME ,CONTINUOUS BEAM ,GRID ,PLANE TRUSS AND SPACE TRUSS     }
uses crt,lib,alib;
const
     PFrame=1;
     CBeam=2;
     Grid=3;
     PTruss=4;
     STruss=5;
     E:real=2e3;
     toper=12;
type
	ap=^NMbyNM;
	NMbyNM=array[1..toper,1..toper] of real;
	NMby1=array[1..toper] of real;
	NMby3=array[1..toper,1..3] of real;
	NMby6i=array[1..toper,1..6] of integer;
	NMby6r=array[1..toper,1..6] of real;
var
	fem1,fem2:real;
	i:integer;
	J:real;
	joint1,joint2:integer;
	stype:integer;
	SMm,SMs	:array[1..6,1..6] of real;
	jno:integer;
	mno:integer;
	dof:integer;
	AD:NMby1;
	cx,cy,cz,cxz:real;
	SA:NMby1;
	SMI:NMby1;
	G,L:real;
	meu      : real;
	sbw:integer;

var
	ch:char;
	x,y,m,n,p,k,q,r:integer;
	c:real;
	no_dir:integer;
	dx,dy,dz:real;
	xof,yof,zof,SL:NMby1;
	mlr:array[1..toper,1..2] of integer;
	ND      : integer;
	Nsink      : integer;
	NENF      : integer;
	Lj,Rj:integer;
	nz,col:integer;
AM1 	:array[1..toper,1..6] of real;
AM,ax,al,ami,ag,scx,scy,acz	:NMby1;
D,DR,AR      :NMby1;
mdir:NMby6i;
ENFdir,sinkdir:NMby1;
SR:NMbyNM;
JDIR:NMby6i;
OJSM:ap;
FEAm,Dms,Ds,FEAs:NMby6r;
sumr1,sumr2:real;

PROCEDURE local_to_global(var gforce:real ;var FEAm:NMby6r;mno:integer;LR:char;tx,ty,tz:real);
begin
	if LR='L' then
	gforce:=tx*FEAm[mno,1]+ty*FEAm[mno,2]+tz*FEAm[mno,3]
		       else
	gforce:=tx*FEAm[mno,4]+ty*FEAm[mno,5]+tz*FEAm[mno,6];
end;

PROCEDURE global_to_local(var lforce:real ;Ds:NMby6r;mno:integer;LR:char;tx,ty,tz:real);
begin
	if LR='L' then
	lforce:=tx*Ds[mno,1]+ty*Ds[mno,2]+tz*Ds[mno,3]
		       else
	lforce:=tx*Ds[mno,4]+ty*Ds[mno,5]+tz*Ds[mno,6];
end;

PROCEDURE multiply(var c:NMby1;a:ap;b:NMby1;n,l,m:integer);
var
	i,j,k:integer;
	sum:real;
begin
for i:=1 to n do
for j:=1 to m do
	begin
	sum:=0.0;
	for k:=1 to L do
		sum:=sum+a^[i,k]*b[k];
	c[i]:=sum;
	end;
end;

PROCEDURE disp(OJSM:ap);
var i,j:integer;
begin
{
for i:=1 to dof do
	begin
	for j:=1 to dof do
		write(OJSM^[i,j]:10:2);
	write('     ',ad[i]:10:6);
	writeln;
	end;
}
end;

PROCEDURE inverse(var a:ap;n:integer);
var 	z:real;
	i,j,k:integer;
begin
for i:=1 to n do
    begin
	 z:=a^[i,i];
	{ writeln(z);}
         a^[i,i]:=1.0;
	 for j:=1 to n do
		   a^[i,j]:=a^[i,j]/z;
         for k:=1 to n do
              begin
                  if k<>i then
                      begin
                      z:=a^[k,i];
                      a^[k,i]:=0.0;
                      for j:=1 to n do a^[k,j]:=a^[k,j]-z*a^[i,j];
                      end;
               end;
        end;
{
for i:=1 to n do
    begin
    for j:=1 to n do
    write(a^[i,j]);
    writeln;
    end;
}
end;

PROCEDURE call_SMs_GLOB(var FEAs,FEAm:NMby6r);
var
	EIbyL,GJbyL,EAbyL,EIbyL2:real;
	i,j:integer;
begin
case stype of
   PTruss,Struss  :
                        begin
                        cxz:=sqrt(sqr(cx)+sqr(cz));
                        if cxz<>0
                           then
                               begin
local_to_global(FEAs[mno,1],FEAm,mno,'L',  cx, cx*cy/cxz, cz/cxz  );
local_to_global(FEAs[mno,2],FEAm,mno,'L',  cy,       cxz,      0  );
local_to_global(FEAs[mno,3],FEAm,mno,'L',  cz, cy*cz/cxz, cx/cxz  );

local_to_global(FEAs[mno,4],FEAm,mno,'R',  cx, cx*cy/cxz, cz/cxz  );
local_to_global(FEAs[mno,5],FEAm,mno,'R',  cy,       cxz,      0  );
local_to_global(FEAs[mno,6],FEAm,mno,'R',  cz, cy*cz/cxz, cx/cxz  );
                               end
                           else
                               begin
local_to_global(FEAs[mno,1],FEAm,mno,'L',     0,    cy,    0  );
local_to_global(FEAs[mno,2],FEAm,mno,'L',   -cy,     0,    0  );
local_to_global(FEAs[mno,3],FEAm,mno,'L',     0,     0,    1  );

local_to_global(FEAs[mno,4],FEAm,mno,'R',     0,    cy,    0  );
local_to_global(FEAs[mno,5],FEAm,mno,'R',   -cy,     0,    0  );
local_to_global(FEAs[mno,6],FEAm,mno,'R',     0,     0,    1  );
                               end;

EAbyL:=SA[mno]*E/L;
SMs[1,1] :=   cx * cx * EAbyL;
SMs[1,2] :=   cx * cy * EAbyL;
SMs[1,3] :=   cx * cz * EAbyL;

SMs[1,4] :=  -SMs[1,1]     ;
SMs[1,5] :=  -SMs[1,2]     ;
SMs[1,6] :=  -SMs[1,3]     ;

SMs[2,1] :=   0.0;
SMs[2,2] :=   cy * cy * EAbyL;
SMs[2,3] :=   cy * cz * EAbyL;

SMs[2,4] :=   SMs[1,5]     ;
SMs[2,5] :=  -SMs[2,2]     ;
SMs[2,6] :=  -SMs[2,3]     ;

SMs[3,1] :=   0.0;
SMs[3,2] :=   0.0;
SMs[3,3] :=   cz * cz * EAbyL;

SMs[3,4] :=   SMs[1,6]     ;
SMs[3,5] :=   SMs[2,6]     ;
SMs[3,6] :=  -SMs[3,3]     ;

SMs[4,1] :=  0.0;
SMs[4,2] :=  0.0;
SMs[4,3] :=  0.0;

SMs[4,4] :=  SMs[1,1]      ;
SMs[4,5] :=  SMs[1,2]      ;
SMs[4,6] :=  SMs[1,3]      ;

SMs[5,3] :=  0.0;
SMs[5,1] :=  0.0;
SMs[5,2] :=  0.0;

SMs[5,3] :=  0.0;
SMs[5,5] :=  SMs[2,2]     ;
SMs[5,6] :=  SMs[2,3]     ;

SMs[6,1] :=  0.0;
SMs[6,2] :=  0.0;
SMs[6,3] :=  0.0;

SMs[6,4] :=  0.0;
SMs[6,5] :=  0.0            ;
SMs[6,6] :=  SMs[3,3]     ;

      end;

   Grid   :
                   begin
{
		   change(Lforce^[mno,2],Lforce^[mno,3]);
		   change(Lforce^[mno,5],Lforce^[mno,6]);
}

local_to_global(FEAs[mno,1],FEAm,mno,'L',    cx,    cy,    0  );
local_to_global(FEAs[mno,2],FEAm,mno,'L',   -cy,    cx,    0  );
local_to_global(FEAs[mno,3],FEAm,mno,'L',     0,     0,    1  );

local_to_global(FEAs[mno,4],FEAm,mno,'R',    cx,    cy,    0  );
local_to_global(FEAs[mno,5],FEAm,mno,'R',   -cy,    cx,    0  );
local_to_global(FEAs[mno,6],FEAm,mno,'R',     0,     0,    1  );

EAbyL:=SA[mno]*E/L;
G:=E/(2*(1+meu));
GJbyL:=G*J/L;
EIbyL:=E*SMI[mno]/L;

SMs[1,1] :=  cx * cx * GJbyL + cy * cy * 4 * EIbyL;
SMs[1,2] :=  cx * cy * GJbyL - cx * cy * 4 * EIbyL;
SMs[1,3] :=                    cy * cy * 6 * EIbyL;

SMs[1,4] := - cx * cx * GJbyL + cy * cy * 2 * EIbyL;
SMs[1,5] := - cx * cy * GJbyL - cx * cy * 2 * EIbyL;
SMs[1,6] := - SMs[1,3];

SMs[2,1] :=   0.0;
SMs[1,4] := - cy * cy * GJbyL + cx * cx * 4 * EIbyL;
SMs[1,5] :=                   - cx * cy * 2 * EIbyL;
SMs[1,6] := - SMs[1,3];

SMs[2,2] :=   cy * cy * EAbyL;
SMs[2,3] :=   cy * cz * EAbyL;

SMs[2,4] :=   SMs[1,5]     ;
SMs[2,5] :=  -SMs[2,2]     ;
SMs[2,6] :=  -SMs[2,3]     ;

SMs[3,1] :=   0.0;
SMs[3,2] :=   0.0;
SMs[3,3] :=   cz * cz * EAbyL;

SMs[3,4] :=   SMs[1,6]     ;
SMs[3,5] :=   SMs[2,6]     ;
SMs[3,6] :=  -SMs[3,3]     ;

SMs[4,1] :=  0.0;
SMs[4,2] :=  0.0;
SMs[4,3] :=  0.0;

SMs[4,4] :=  SMs[1,1]      ;
SMs[4,5] :=  SMs[1,2]      ;
SMs[4,6] :=  SMs[1,3]      ;

SMs[5,3] :=  0.0;
SMs[5,1] :=  0.0;
SMs[5,2] :=  0.0;

SMs[5,3] :=  0.0;
SMs[5,5] :=  SMs[2,2]     ;
SMs[5,6] :=  SMs[2,3]     ;

SMs[6,1] :=  0.0;
SMs[6,2] :=  0.0;
SMs[6,3] :=  0.0;

SMs[6,4] :=  0.0;
SMs[6,5] :=  0.0            ;
SMs[6,6] :=  SMs[3,3]     ;

                               end;

   PFrame,CBeam  :
                   begin
local_to_global(FEAs[mno,1],FEAm,mno,'L',    cx,   -cy,    0  );
local_to_global(FEAs[mno,2],FEAm,mno,'L',    cy,    cx,    0  );
local_to_global(FEAs[mno,3],FEAm,mno,'L',     0,     0,    1  );

local_to_global(FEAs[mno,4],FEAm,mno,'R',    cx,   -cy,    0  );
local_to_global(FEAs[mno,5],FEAm,mno,'R',    cy,    cx,    0  );
local_to_global(FEAs[mno,6],FEAm,mno,'R',     0,     0,    1  );

EAbyL:=SA[mno]*E/L;
EIbyL:=E*SMI[mno]/L;
EIbyL2:=E*SMI[mno]/(L*L);

SMs[1,1] :=   cx * cx * EAbyL + 12 * cy * cy * EIbyL2/L ;
SMs[1,2] :=   cx * cy * EAbyL - 12 * cx * cy * EIbyL2/L ;
SMs[1,3] :=    -6 * cy * EIbyL2 ;

SMs[1,4] :=  -SMs[1,1]     ;
SMs[1,5] :=  -SMs[1,2]     ;
SMs[1,6] :=   SMs[1,3]     ;

SMs[2,1] :=   0.0;
SMs[2,2] :=   cy * cy * EAbyL + 12 * cx * cx * EIbyL2/L ;
SMs[2,3] :=   6 * cx * EIbyL2 ;

SMs[2,4] :=   SMs[1,5]     ;
SMs[2,5] :=  -SMs[2,2]     ;
SMs[2,6] :=   SMs[2,3]     ;

SMs[3,1] :=   0.0;
SMs[3,2] :=   SMs[2,3];
SMs[3,3] :=   4 * EIbyL;

SMs[3,4] :=  -SMs[1,6]     ;
SMs[3,5] :=  -SMs[2,6]     ;
SMs[3,6] :=  SMs[3,3]/2    ;

SMs[4,1] :=  -SMs[1,1];
SMs[4,2] :=  0.0;
SMs[4,3] :=  0.0;

SMs[4,4] :=  SMs[1,1]      ;
SMs[4,5] :=  SMs[1,2]      ;
SMs[4,6] :=  SMs[3,4]      ;

SMs[5,1] :=  0.0;
SMs[5,2] :=  0.0;
SMs[5,3] :=  0.0;

SMs[5,4] :=  0.0;
SMs[5,5] :=  SMs[2,2]     ;
SMs[5,6] :=  SMs[3,5]     ;

SMs[6,1] :=  0.0;
SMs[6,2] :=  0.0;
SMs[6,3] :=  0.0;

SMs[6,4] :=  0.0;
SMs[6,5] :=  0.0            ;
SMs[6,6] :=  SMs[3,3]     ;
                   end;
end;

{*********** Generation of second symmetrical half of the matrix *******}

for i:=1 to 6 do
	 for j:=1 to 6 do
		begin
		if (SMs[i,j]=0.0) then
			SMs[i,j]:=SMs[j,i];
		end;

{
for i:=1 to 6 do
	begin
	for j:=1 to 6 do
		write(SMs[i,j]:10:4);
	writeln;
	end;
}
end;

PROCEDURE solve_equations(var OJSM:ap);
var
	n,p,i:integer;
	c:real;
	d:NMby1;
begin
(*
for n:=1 to dof do
begin
i:=n;
for p:=2 to sbw do
	begin
	i:=i+1;
	if (OJSM^[n,1]<>0.0) then
		begin
		c:=OJSM^[n,p]/OJSM^[n,1];
{		writeln(OJSM^[n,p]:4:2,'/',OJSM^[n,1],'  =  ',c:4:2);
}
		j:=0;
{
	disp(OJSM);
}
		for k:=p to sbw do
			begin
			j:=j+1;
			if OJSM^[n,k]<>0.0 then

			if i<=dof then
				begin
				OJSM^[i,j]:=OJSM^[i,j]-c*OJSM^[n,k];
{
		writeln(i,' ',j,' ',OJSM^[i,j],'-',c:4:2,' x ',OJSM^[n,k]);
}
				end;
			end;

			OJSM^[n,p]:=c;
			AD[i]:=AD[i]-c*AD[n];
{
			writeln('AD ',i,' =  ',AD[i]);
}
		end;
	end;
	{
	if OJSM^[n,1]<>0.0 then
	}
		AD[n]:=AD[n]/OJSM^[n,1];   {%CHECK}
{		writeln('AD ',n,' = ',AD[n]);
}
end;

	for n:=dof downto 1 do
	begin
	p:=n;
	for k:=2 to sbw do
		begin
			p:=p+1;
			if OJSM^[n,k]<>0.0 then
			AD[n]:=AD[n]-OJSM^[n,k]*AD[p];
		end;
	end;

{&}
{
disp(OJSM);
}
*)
inverse(OJSM,dof);
multiply(d,OJSM,AD,dof,dof,1);
for i:=1 to dof do AD[i]:=d[i];
end;

PROCEDURE call_SMm;
var
	EIbyL,EIbyL2,EAbyL,GJbyL:real;
	i,j:integer;
begin
EIbyL:=E*SMI[mno]/L;
EIbyL2:=E*SMI[mno]/(L*L);
EAbyL:=E*SA[mno]/L;

case stype of

   PTruss,Struss  :
		   begin
			SMm[1,1]:=EAbyL;
			SMm[1,4]:=-EAbyL;
			SMm[4,1]:=-EAbyL;
			SMm[4,4]:=EAbyL;
                   end;
   Grid :
                   begin
			SMm[1,1]:=GJbyL;
			SMm[1,4]:=-GJbyL;
			SMm[2,2]:=4*EIbyL;
			SMm[2,3]:=-6*EIbyL2;
			SMm[2,5]:=SMm[2,2]/2;
			SMm[2,6]:=-SMm[2,3];
			SMm[3,3]:=12*EIbyL2/L;
			SMm[3,5]:=SMm[2,3]/2;
			SMm[3,6]:=-SMm[3,3];
			SMm[4,4]:=SMm[1,1];
			SMm[5,5]:=SMm[2,2];
			SMm[5,6]:=SMm[2,6];
               end;
    PFrame,CBeam :
                  begin
			SMm[1,1]:=EAbyL;
			SMm[1,4]:=-EAbyL;
			SMm[2,2]:=12*EIbyL2/L;
			SMm[2,3]:=6*EIbyL2;
			SMm[2,5]:=-SMm[2,2];
			SMm[2,6]:=SMm[2,3];
			SMm[3,3]:=4*EIbyL;
			SMm[3,5]:=-SMm[2,3];
			SMm[3,6]:=SMm[3,3]/2;
			SMm[4,4]:=SMm[1,1];
			SMm[5,5]:=SMm[2,2];
			SMm[5,6]:=SMm[3,5];
			SMm[6,6]:=SMm[3,3];
              end;
end;

{********* Generation of second symmetrical half of SMm ***********}
for i:=1 to 6 do
	for j:=1 to 6 do
		if SMm[i,j]=0.0 then SMm[i,j]:=SMm[j,i];

{
for i:=1 to 6 do
	begin
	for j:=1 to 6 do
		write(SMm[i,j]:10:4);
	writeln;
	end;
}
end;

PROCEDURE dis_mem2str(Ds:NMby6r;var Dms:NMby6r);
begin
case stype of
   PTruss,Struss  :
                        begin
                        cxz:=sqrt(sqr(cx)+sqr(cz));
                        if cxz<>0
                           then
                               begin
global_to_local(Dms[mno,1],Ds,mno,'L', cx,         cx,     cz  );
global_to_local(Dms[mno,2],Ds,mno,'L', -cx*cy/cxz, cxz,    -cy*cz/cxz  );
global_to_local(Dms[mno,3],Ds,mno,'L', -cz/cxz,    cx/cxz, 0  );

global_to_local(Dms[mno,4],Ds,mno,'L', cx,         cx,     cz  );
global_to_local(Dms[mno,5],Ds,mno,'L', -cx*cy/cxz, cxz,    -cy*cz/cxz  );
global_to_local(Dms[mno,6],Ds,mno,'L', -cz/cxz,    cx/cxz, 0  );
                               end
                           else
                               begin
global_to_local(Dms[mno,1],Ds,mno,'L',     0,    cy,    0  );
global_to_local(Dms[mno,2],Ds,mno,'L',   -cy,     0,    0  );
global_to_local(Dms[mno,3],Ds,mno,'L',     0,     0,    1  );

global_to_local(Dms[mno,4],Ds,mno,'R',     0,    cy,    0  );
global_to_local(Dms[mno,5],Ds,mno,'R',   -cy,     0,    0  );
global_to_local(Dms[mno,6],Ds,mno,'R',     0,     0,    1  );
			       end;
			end;
   PFrame,Grid,Cbeam  :
                        begin
global_to_local(Dms[mno,1],Ds,mno,'L',    cx,    cy,    0  );
global_to_local(Dms[mno,2],Ds,mno,'L',   -cy,    cx,    0  );
global_to_local(Dms[mno,3],Ds,mno,'L',     0,     0,    1  );

global_to_local(Dms[mno,4],Ds,mno,'R',    cx,    cy,    0  );
global_to_local(Dms[mno,5],Ds,mno,'R',   -cy,    cx,    0  );
global_to_local(Dms[mno,6],Ds,mno,'R',     0,     0,    1  );
			end;

	end;
end;


PROCEDURE numberdir(	var jdir:NMby6i;
			var xof,yof,zof:NMby1;
			var dof,joint1,joint2:integer);
var
	t,j3,i:integer;
	remap1,remap2:string;
	sup:char;
	dirno:integer;
	s:string;
begin
remap1:='';
remap2:='';
sup:=' ';
stype:=PFrame;
{
NM :=3;
dof:=6;
sbw:=dof;
E:=2e3;
nj:=4;
nenf:=0;
nsink:=0;
meu:=0.30;
joint1:=0;
joint2:=3;
}
repeat
case sup of
	'H':sup:='R';
	'C':sup:='H';
	'F':sup:='C';
	' ':sup:='F';
	end;
i:=1;
while i<=NJ do
	begin
		if supmap[i]=sup then
			begin
			insert(sup,remap1,length(remap1)+1);
			insert(chr(i),remap2,length(remap1)+1);
			end;
			inc(i);
	end;
until length(remap1)=NJ;
joint1:=0;

joint2:=0;
joint1:=pos('H',remap1);

s:=remap1;

j3:=0;
repeat
t:=pos('F',s);
delete(s,t,1);
if t<>0 then inc(j3);
until t=0;

s:=remap1;
repeat
t:=pos('C',s);
delete(s,t,1);
if t<>0 then inc(j3);
until t=0;

s:=remap1;
while pos('H',s)<>0 do
	begin
	joint2:=pos('H',s);
	delete(s,pos('H',s),1);
	end;

{********** Number all the directions **********}

for jno:=1 to NJ do
         begin
              jdir[jno,1]:=3*jno-2;
              jdir[jno,2]:=3*jno-1;
              jdir[jno,3]:=3*jno;
         end;
i:=1;
while i<=NJ do
	begin
		search(ord(remap2[i]));
		point^.idm:=i;
		xof[i]:=point^.x;
		yof[i]:=point^.y;
		{zof[i]:=point^.z;}
		inc(i);
	end;
dirno:=j3*3;
i:=joint1;
if i<>0 then
repeat
	case point^.sup of
		'H':begin
		    jdir[point^.idm,3]:=dirno+1;
		    dirno:=dirno+1;
		    end;
		 end;
inc(i);
until (i>=joint2);

dof:=dirno;
i:=joint1;
repeat
	case point^.sup of
		'H':begin
		    jdir[point^.idm,1]:=dirno+1;
		    jdir[point^.idm,2]:=dirno+1;
		    dirno:=dirno+2;
		    end;
		end;
inc(i);
until i>=joint2;   {# error posssible routine }
end;


  {*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$}

PROCEDURE mat_ana;
var j:integer;
	{****     MATRIX ANALYSIS USING DISPLACEMENT METHOD     ****}

begin
clrscr;
makeframe(hpx,hpy,hpz);
numberdir(jdir,xof,yof,zof,dof,joint1,joint2);
markfems;
new(OJSM);
{************ Reading General Data about the Structure *********}

(*
read(SBW);                { Semi Band Width ( default is dof ) }
read(NENF);               { Number of Directions where Nodal Forces act }
read(Nsink);              { Number of Directions which sinks }
read(meu);                { Poisson's Ratio }
*)

stype:=PFrame;
{
NM:=3;
dof:=6;
}
sbw:=dof;
nenf:=0;
nsink:=0;
meu:=0.30;
{********* Reading/writing coordinates of each joint *********}

	     { Note : Z co-ordinate should be discarded for plane problems }
(*
for jno:=1 to NJ do
	readln(xof[jno],yof[jno],zof[jno]);
*)

{
for jno:=1 to NJ do
	writeln('X,Y,Z for ',jno,' ',xof[jno],' ',yof[jno],' ',zof[jno]);
}

{********** Read Fixed End Reactions from Pre-processor *********}

for mno:=1 to NM do
		begin
		data:=DM^[mno];
		with data do
		begin
		if (dir='R') or (dir='U') then
			begin
			search(name[1]);
			Mlr[mno,1]:=point^.idm;
			search(name[2]);
			Mlr[mno,2]:=point^.idm;
			end
			else
			begin
			search(name[2]);
			Mlr[mno,1]:=point^.idm;
			search(name[1]);
			Mlr[mno,2]:=point^.idm;
			end;
		SA[mno]:={b*d;}160;
		SMI[mno]:={b*d*d*d/12;}5400;
		tot_fems(name[1],name[2],fem1,fem2);
		tot_react(name[1],name[2],sumr1,sumr2);

		{ Equivalent joint forces = - FEMs & - R1 & -R2 }
		{ conversion to right handed system convention }

		FEAm[mno,1]:=0;
		FEAm[mno,2]:=-sumr1;
		FEAm[mno,3]:=-fem1;
		FEAm[mno,4]:=0;
		FEAm[mno,5]:=-sumr2;
		FEAm[mno,6]:=-fem2;
		end;
	end;

{********** Compute total number of directions *******}
ND:=jdir[NJ,3];

fillchar(OJSM^,sizeof(OJSM^),0);
fillchar(AD,sizeof(AD),0);
fillchar(SR,sizeof(SR),0);
fillchar(DR,sizeof(DR),0);

{******* Allocation of direction numbers to both ends of each member ***}

for mno:=1 to NM do
begin
Lj:=Mlr[mno,1];
Rj:=Mlr[mno,2];

mdir[mno,1]:=jdir[Lj,1];
mdir[mno,2]:=jdir[Lj,2];
mdir[mno,3]:=jdir[Lj,3];

mdir[mno,4]:=jdir[Rj,1];
mdir[mno,5]:=jdir[Rj,2];
mdir[mno,6]:=jdir[Rj,3];

{********* Initialize SMs to ZERO *******}

fillchar(SMs,sizeof(SMs),0);

{******** Compute projections of length of members in x,y,z directions ********}

dx:=xof[Rj]-xof[Lj];
dy:=yof[Rj]-yof[Lj];
dz:=0.0;
{zof[Rj]-zof[Lj];}

{******** Compute length of member *********}

L:=sqrt(sqr(dx)+sqr(dy)+sqr(dz));

{******** Compute cosines of direction of member with axes *******}

cx:=dx/L; {%}
cy:=dy/L; {%}
cz:=dz/L;

SL[mno]:=L;
scx[mno]:=cx;
scy[mno]:=cy;

call_SMs_GLOB(FEAs,FEAm);

{********* Generation of overall joint stiffness matrix *********}

		{ by placing then elements in the SMs in the positon corresponding to }
		{ the same direction number in the OJSM }

for i:=1 to 6 do
   for j:=1 to 6 do
begin
	OJSM^[mdir[mno,i],mdir[mno,j]]:=OJSM^[mdir[mno,i],mdir[mno,j]]+SMs[i,j];
end;

end;

  { %%%%%%%%%%% END OF LOOP (MEMBER NO) }

{***********   Seperating matrix SR (corresponding to reactions) from OJSM **************}

for i:=dof+1 to ND do
	for j:=1 to ND do
		begin
		SR[i-dof,j]:=OJSM^[i,j];
		OJSM^[i,j]:=0.0;
		end;
{********** Banding stiffness matrix **********}

(*
{
eg :
sbw=2
Elements below the diagonal are discarded being repeatitions

		      | x * 0 0 0 0 |      nz=0 >   | x * |
		      | * x * 0 0 0 |      nz=1 >   | x * |
		      | 0 * x * 0 0 |       .   >   | x * |
		      | 0 0 * x * 0 |       .   >   | x * |
		      | 0 0 0 * x * |       .   >   | x * |
		      | 0 0 0 0 * x |      nz=5 >   | x 0 |
}
*)

(*
for i:=1 to dof do
	for j:=1 to sbw do
	begin
	nz:=i-1;	{ Number of elements to the L of diagonal  }
	col:=nz+j;
	if (col<=dof)
		then
			OJSM^[i,j]:=OJSM^[i,col]
		else
			OJSM^[i,j]:=0.0;
end;
*)

{********** Reading External Nodal Force dirctions & Magnitudes ***********}

(*
for i:= 1 to NENF do
	begin
	read(ENFdir[i]);
	read(AD[ENFdir[i]]);
	end;
*)
{*********** Creating Full Action Matrix **********}

for i:= 1 to NM do
	for j:=1 to 6 do
		AD [mdir[i,j]]:=AD[mdir[i,j]]+FEAs[i,j];

{********** Reading Sinking dirctions & Magnitudes ***********}

(*
for i:= 1 to Nsink do
	begin
	read(sinkdir[i],DR[sinkdir[i]-dof]);
	{
	sinkdir[i]:=sinkdir[i]-dof;
	}
	end;
*)

for i:=1 to ND do
	for j:= 1 to ND-dof do
		AD[i]:=AD[i]-SR[j,i]*DR[j];

for i:=dof+1 to ND do
	begin
	AR[i-dof]:=-AD[i];
	AD[i]:=0;
	end;

for i:=1 to ND-dof do
	for j:=dof+1 to ND do
			SR[i,j]:=0.0;
   {******** Solution of simultaneous equations by coefficient matrix ****}

disp(OJSM);
solve_equations(OJSM);
{
ad[2]:=0.009059986;
ad[5]:=0.0029700069;
}
writeln('Deflections');
writeln(' Member    1         2         3         4         5         6');
{
for y:=1 to NM  do
		writeln(Mlr[y,1],'-',Mlr[y,2]);
}
gotoxy(1,3);
for y:=1 to dof do
begin
for k:= 1 to NM do
	for j:=1 to 6 do
		if mdir[k,j]=y then
			begin
			{gotoxy(j*10,3+k);}
{		writeln(Mlr[y,1],'-',Mlr[y,2],' ',j,' ',AD[y]:10:5);}
		writeln(k,' ',j,' ',AD[y]:10:5);
			end;
writeln;
end;
writeln;
writeln;
{******* Recieving varialbes from stored data ********}

writeln('    No       Member    1         2         3         4         5         6');
fastwrite(#196,80,norm);
writeln;
for mno:=1 to NM do
begin
	L:=sl[mno];
	cx:=scx[mno];
	cy:=scy[mno];
	{for truss}
	G:=ag[mno];
	cz:=0.0;
	{
	acz[mno];
	}
	for j:=1 to 6 do
		for k:=1 to 6 do
			SMm[j,k]:=0.0;
{******** Generation of SMm for various structure types ********}
call_SMm;
{********* Transformation of displacements to members on structure axes ****}
for j:=1 to 6 do
	begin
	Ds[mno,j]:=AD[mdir[mno,j]];
	Dms[mno,j]:=0.0;
	end;
{****** Transformation of Member Displacements from Structure Axis
						to Member Axis ********}
dis_mem2str(Ds,Dms);
{********** Calculations for member end actions ***********}
write(mno:6,'       ',DM^[mno].name[1],'-',DM^[mno].name[2]);
for j:=1 to 6 do
	begin
	AM[j]:=-FEAm[mno,j];
	for k:=1 to 6 do
		AM[j]:=AM[j]+SMm[j,k]*Dms[mno,k];
	AM1[mno,j]:=AM[j];
	write(AM1[mno,j]:10:2);
	end;
	writeln;
end; { SECOND MEMBER LOOP}
fastwrite(#196,80,norm);
writeln;

{********* Calculation of reactions in the restrained directions ******}
for i:=  dof+1 to ND do
	begin
	c:=0.0;
	for j:=1 to dof do
		c:=c+SR[i-dof,j]*AD[j];
	AR[i-dof]:=AR[i-dof]+c;
	{writeln(i,' ',AR[i-dof]:10:4);}
	end;
ch:=readkey;
end;
			   { MAIN PROGRAM }
(*
begin
{
soker:='M';
new(menus);
for i:=1 to 50 do DM^[i]:=data;
fillchar(choice,sizeof(choice),1);
inpname:='CON';
assign(inp,inpname);
reset(inp);
readln(inp,hpx);
readln(inp,hpy);
readln(inp,hpz);
NM:=0;
datano:=1;
readinput(datano);
inpname:='CON';
assign(inp,inpname);
reset(inp);
hpx:=0;
hpy:=0;
hpz:=0;
}
{
dispose(menus);
}
*)
end.

Explanation for Variables used
컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴
ARRAY             SIZE    Type         PURPOSE

SMs	       D x D	 	Member Stiffness Matrix on member axes
SMm	       D x D	 	Member stiffness Matrix on structure axes
AD 	       ND x 1	 	Actions corresponding to unknown displacements
Dms             NM x D	  	Unknown joint displacemments for each member
				on member axes
Ds             NM x D	 	Unknown joint displacements for each member
				on structure axes
FEAm	       NM x D          Restrained member actions due to applied loads
				for each directions of each member on
				member axes
FEAs           NM x D          Restrained member actions due to applied loads
				for each directions of each member on
				structure axes
OJSM           ND x ND 	Overall joint stiffness matrix
SA             NM x 1		store Area of each member
SMI    		NM x 1		store MI of each member
MLR   		NM x 2		store Left & Right joint names of each
				member in order
AM1
ENFDIR
SINKDIR
DR  		ND-dof x 1	Vector containing magnitudes of support yields
SR              ND-dof x SBW    Submatrix of OJSM that contains actions corresponding
				to support restraints
XOF,YOF,ZOF	NJ x 1		x,y,z co-ordinates of each joint
AM
AX
AL
AMI
AG
SCX
SCY
ACZ
MDIR           NM x D 	  Int	Member direction numbers for each member
JDIR           NJ x D/2	  Int	Joint direction numbers for each joint

