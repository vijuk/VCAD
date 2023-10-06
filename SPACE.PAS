
{

	Project    	: 	SPACE FRAME ANALYSIS PROGRAM.
	Language   	:	Turbo Pascal.
	Programmer 	: 	Viju.K.S.,
                                M.Tech(Structural Engg).

	Starting Date 	: 	27/11/95.

}

unit  mat;
interface
procedure mat_ana;
implementation
uses crt,lib,alib;
const
     E:real=2e3;
     toper=12;
     Space=1;
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
	SMm,SMs	:array[1..12,1..12] of real;
	jno:integer;
	mno:integer;
	dof:integer;
	AD:NMby1;
	cx,cy,cz,cxz:real;
	SA:NMby1;
	SMI:NMby1;
	G,L:real;
	meu: real;
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
	NdirNF      : integer;
	Lj,Rj:integer;
	nz,col:integer;
AM1 	:array[1..toper,1..6] of real;
AM,ax,al,ami,ag,scx,scy,scz	:NMby1;
D,DR,AR      :NMby1;
mdir:NMby6i;
NFdir,sinkdir:array[1..toper] of integer;
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
	EIbyL,GJbyL,EAbyL,EIbyL2,EIzbyL2:real;
	i,j:integer;
begin
{ 	Rotaion matrix      }

case stype of
   1 {PTruss,Struss}  :
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
SMs[1,1] :=  cx * cx * EAbyL;
SMs[1,2] :=  cx * cy * EAbyL;
SMs[1,3] :=  cx * cz * EAbyL;

SMs[1,4] :=  -SMs[1,1];
SMs[1,5] :=  -SMs[1,2];
SMs[1,6] :=  -SMs[1,3];

SMs[2,1] :=  0.0;
SMs[2,2] :=  cy * cy * EAbyL;
SMs[2,3] :=  cy * cz * EAbyL;

SMs[2,4] :=   SMs[1,5];
SMs[2,5] :=  -SMs[2,2];
SMs[2,6] :=  -SMs[2,3];

SMs[3,1] :=   0.0;
SMs[3,2] :=   0.0;
SMs[3,3] :=   cz * cz * EAbyL;

SMs[3,4] :=   SMs[1,6];
SMs[3,5] :=   SMs[2,6];
SMs[3,6] :=  -SMs[3,3];

SMs[4,1] :=  0.0;
SMs[4,2] :=  0.0;
SMs[4,3] :=  0.0;

SMs[4,4] :=  SMs[1,1];
SMs[4,5] :=  SMs[1,2];
SMs[4,6] :=  SMs[1,3];

SMs[5,3] :=  0.0;
SMs[5,1] :=  0.0;
SMs[5,2] :=  0.0;

SMs[5,3] :=  0.0;
SMs[5,5] :=  SMs[2,2];
SMs[5,6] :=  SMs[2,3];

SMs[6,1] :=  0.0;
SMs[6,2] :=  0.0;
SMs[6,3] :=  0.0;

SMs[6,4] :=  0.0;
SMs[6,5] :=  0.0;
SMs[6,6] :=  SMs[3,3];

      end;

   2 {Grid}   :
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

SMs[2,4] :=   SMs[1,5];
SMs[2,5] :=  -SMs[2,2];
SMs[2,6] :=  -SMs[2,3];

SMs[3,1] :=   0.0;
SMs[3,2] :=   0.0;
SMs[3,3] :=   cz * cz * EAbyL;

SMs[3,4] :=   SMs[1,6];
SMs[3,5] :=   SMs[2,6];
SMs[3,6] :=  -SMs[3,3];

SMs[4,1] :=  0.0;
SMs[4,2] :=  0.0;
SMs[4,3] :=  0.0;

SMs[4,4] :=  SMs[1,1];
SMs[4,5] :=  SMs[1,2];
SMs[4,6] :=  SMs[1,3];

SMs[5,3] :=  0.0;
SMs[5,1] :=  0.0;
SMs[5,2] :=  0.0;

SMs[5,3] :=  0.0;
SMs[5,5] :=  SMs[2,2];
SMs[5,6] :=  SMs[2,3];

SMs[6,1] :=  0.0;
SMs[6,2] :=  0.0;
SMs[6,3] :=  0.0;

SMs[6,4] :=  0.0;
SMs[6,5] :=  0.0;
SMs[6,6] :=  SMs[3,3];

                               end;

   3 {PFrame,CBeam}  :
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
EIzbyL2:=0; {##}

SMs[1,1] :=   cx * cx * EAbyL + 12 * cy * cy * EIbyL2/L;
SMs[1,2] :=   cx * cy * EAbyL - 12 * cx * cy * EIbyL2/L;
SMs[1,3] :=    -6 * cy * EIbyL2;

SMs[1,4] :=  -SMs[1,1];
SMs[1,5] :=  -SMs[1,2];
SMs[1,6] :=   SMs[1,3];

SMs[2,1] :=   0.0;
SMs[2,2] :=   cy * cy * EAbyL + 12 * cx * cx * EIbyL2/L;
SMs[2,3] :=   6 * cx * EIbyL2;

SMs[2,4] :=   SMs[1,5];
SMs[2,5] :=  -SMs[2,2];
SMs[2,6] :=   SMs[2,3];

SMs[3,1] :=   0.0;
SMs[3,2] :=   SMs[2,3];
SMs[3,3] :=   4 * EIbyL;

SMs[3,4] :=  -SMs[1,6];
SMs[3,5] :=  -SMs[2,6];
SMs[3,6] :=  SMs[3,3]/2;

SMs[4,1] :=  -SMs[1,1];
SMs[4,2] :=  0.0;
SMs[4,3] :=  0.0;

SMs[4,4] :=  SMs[1,1];
SMs[4,5] :=  SMs[1,2];
SMs[4,6] :=  SMs[3,4];

SMs[5,1] :=  0.0;
SMs[5,2] :=  0.0;
SMs[5,3] :=  0.0;

SMs[5,4] :=  0.0;
SMs[5,5] :=  SMs[2,2];
SMs[5,6] :=  SMs[3,5];

SMs[6,1] :=  0.0;
SMs[6,2] :=  0.0;
SMs[6,3] :=  0.0;

SMs[6,4] :=  0.0;
SMs[6,5] :=  0.0;
SMs[6,6] :=  SMs[3,3];
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
	EIbyL,EIbyL2,EAbyL,EIzbyL2,GJbyL,EIybyL2,EIybyL,EIzbyL:real;
	i,j:integer;
begin
EIbyL:=E*SMI[mno]/L;
EIbyL2:=E*SMI[mno]/(L*L);
EAbyL:=E*SA[mno]/L;
EIzbyL2:=0; {##} EIybyL2:=0; {##} EIybyL:=0;EIzbyL:=0;

			SMm[1,1]:=EAbyL;
			SMm[1,7]:=-EAbyL;

			SMm[2,2]:=12*EIzbyL2/L;
			SMm[2,6]:=6*EIzbyL2;
			SMm[2,8]:=-SMm[2,2];
			SMm[2,12]:=SMm[2,6];

			SMm[3,3]:=12*EIybyL2/L;
			SMm[3,5]:=-6*EIybyL2;
			SMm[3,9]:=-SMm[3,3];
			SMm[3,11]:=SMm[3,5];

			SMm[4,4]:=GJbyL;
			SMm[4,10]:=-SMm[4,4];

			SMm[5,5]:=4*EIybyL;
			SMm[5,9]:=-SMm[3,11];
			SMm[5,11]:=SMm[5,5]/2;

			SMm[6,6]:=4*EIzbyL;
			SMm[6,8]:=-SMm[2,6];
			SMm[6,12]:=SMm[6,6]/2;

			SMm[7,7]:=SMm[1,1];

			SMm[8,8]:=SMm[2,2];
			SMm[8,12]:=SMm[6,8];
            		SMm[9,9]:=SMm[3,3];
			SMm[9,11]:=SMm[5,9];
			SMm[10,10]:=SMm[4,4];
			SMm[11,11]:=SMm[5,5];
			SMm[12,12]:=SMm[6,6];

{********* Generation of second symmetrical half of SMm ***********}

for i:=1 to 12 do
	for j:=1 to 12 do
		if SMm[i,j]=0.0 then SMm[i,j]:=SMm[j,i];

for i:=1 to 12 do
	begin
	for j:=1 to 12 do
		write(SMm[i,j]:10:4);
	writeln;
	end;

end;

PROCEDURE dis_mem2str(Ds:NMby6r;var Dms:NMby6r);
begin
case stype of
   1 {PTruss,Struss}  :
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
   2 {PFrame,Grid,Cbeam}  :
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
{
NM :=3;
dof:=6;
sbw:=dof;
E:=2e3;
nj:=4;
NdirNF:=0;
nsink:=0;
meu:=0.30;
joint1:=0;
joint2:=3;
}

{********** Number all the directions **********}
for jno:=1 to NJ do
         for k:=1 to 6 do jdir[jno,k]:=6*jno-(6-k);

{ read direction numbers at partially restrained joints }
dof:=dirno;
for jno:=joint1 to joint2 do
		for k:=1 to 6 do
                        read(jdir[jno,k]);
end;


{*$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$*}


PROCEDURE mat_ana;
var j:integer;
    NdirNF,j1,j2,sincos
    :integer;
    xps,yps,zps,xp,yp,zp,xpv,ypv,zpv:real;
    salpha,calpha:real;
    R:array[1..6,1..6] of real; { check size }

{ ****   SPACE FRAME ANALYSIS USING DISPLACEMENT METHOD     **** }

begin
clrscr;
{
makeframe(hpx,hpy,hpz);
}

numberdir(jdir,xof,yof,zof,dof,joint1,joint2);

{
markfems;
}

new(OJSM);
{************ Reading General Data about the Structure *********}
(*
read(SBW);                { Semi Band Width ( default is dof ) }
read(NdirNF);             { Number of Directions where Nodal Forces act }
read(Nsink);              { Number of Directions which sinks }
read(meu);                { Poisson's Ratio }
*)
{
stype:=PFrame;
NM:=3;
dof:=6;
}
sbw:=dof;
NdirNF:=0;
nsink:=0;
meu:=0.30;

readln(NM,dof,ND,SBW,E,NJ,NdirNF,meu,j1,j2);

{ ** Reading/writing coordinates of each joint *********}

for jno:=1 to NJ do
	readln(xof[jno],yof[jno],zof[jno]);

for jno:=1 to NJ do
	writeln('X,Y,Z for ',jno,' ',xof[jno],' ',yof[jno],' ',zof[jno]);

{ ** Read Fixed End Reactions from Pre-processor *********}

for mno:=1 to NM do
		begin
		{
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
                }

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

ND:=jdir[NJ,6];

fillchar(OJSM^,sizeof(OJSM^),0);
fillchar(AD,sizeof(AD),0);
fillchar(SR,sizeof(SR),0);
fillchar(DR,sizeof(DR),0);

{******* Allocation of direction numbers to both ends of each member ***}

for mno:=1 to NM do
begin
Lj:=Mlr[mno,1];
Rj:=Mlr[mno,2];
for k:=1 to 6 do
    begin
    mdir[mno,k]:=jdir[Lj,k];
    mdir[mno,6+k]:=jdir[Rj,k];
    end;

{********* Initialize SMs to ZERO *******}

fillchar(SMs,sizeof(SMs),0);

{******** Compute projections of length of members in x,y,z directions ********}

dx:=xof[Rj]-xof[Lj];
dy:=yof[Rj]-yof[Lj];
dz:=zof[Rj]-zof[Lj];
{zof[Rj]-zof[Lj];}

{******** Compute length of member *********}

L:=sqrt(sqr(dx)+sqr(dy)+sqr(dz));

{******** Compute cosines of direction of member with axes *******}

cx:=dx/L;
cy:=dy/L;
cz:=dz/L;

SL[mno]:=L;
scx[mno]:=cx;
scy[mno]:=cy;
scz[mno]:=cz;

{
  P(xp,yp,zp) s the extra point along the Y-axis of the member
  used to define orientation of the member
}
if sincos=0 then
	begin
		salpha:=0;
		calpha:=1;
	end
    else
	begin
		xps:=xp-xof[Lj];
		yps:=yp-yof[Lj];
		zps:=zp-zof[Lj];

		ypv:=-cx*cy/cxz*xps+cxz*yps-cy*cz/cxz*zps;
		xpv:=cx*xps*cy*yps+cz*zps;
		zpv:=-cz/cxz*xps+x/cxz*zps;
		salpha:=zpv/sqrt(ypv*ypv+zpv*zpv);
		calpha:=ypv/sqrt(ypv*ypv+zpv*zpv);
	end;

R[1,1]:=cx;
R[1,2]:=cy;
R[1,3]:=cz;
R[2,1]:=(-cx*cy*calpha-cz*salpha)/cxz;
R[2,2]:=cxz*calpha;
R[2,3]:=(-cy*calpha+cx*salpha)/cxz;
R[3,1]:=(cx*cy*salpha-cz*calpha)/cxz;
R[3,2]:=-cxz*salpha;
R[3,3]:=(cy*cz*salpha+cx*calpha)/cxz;





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

for i:= 1 to NdirNF do
	begin
	read(NFdir[i]);
	read(AD[NFdir[i]]);
	end;

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
soker:='O';
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

ND    - No. of Directions.
dof 	Degrees of freedom
MB	semi band width
NM	(M) No of members
meu	(V) Poisson's ratio
	KHD	No of dir in which nodal forces act
NJ      No of joints
J1	Lowest joint no for partially restrained joints
J2 	Highest joint no for partially restrained joints

ARRAY          SIZE     Type    PURPOSE

SMs	       D x D	 	Member Stiffness Matrix on member axes
SMm	       D x D	 	Member stiffness Matrix on structure axes
AD 	       ND x 1	 	Actions corresponding to unknown displacements
Dms            NM x D	  	Unknown joint displacemments for each member
				on member axes
Ds             NM x D	 	Unknown joint displacements for each member
				on structure axes
FEAm	       NM x D           Restrained member actions due to applied loads
				for each directions of each member on
				member axes
FEAs           NM x D           Restrained member actions due to applied loads
				for each directions of each member on
				structure axes
OJSM           ND x ND 	        Overall joint stiffness matrix
SA             NM x 1		store Area of each member
SMI    		NM x 1		store MI of each member
MLR   		NM x 2		store Left & Right joint names of each
				member in order
AM1

NFdir                           No of directions where nodal forces act
Nsink
SINKDIR
DR  		ND-dof x 1	Vector containing magnitudes of support yields
SR              ND-dof x SBW    Submatrix of OJSM that contains actions corresponding
				to support restraints

XOF,YOF,ZOF	NJ x 1		x,y,z co-ordinates of each joint
MDIR           NM x D 	  Int	Member direction numbers for each member
JDIR           NJ x D/2	  Int	Joint direction numbers for each joint

AM
AX
AL
AMI
AG
SCX
SCY
SCY
ACZ
