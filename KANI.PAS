
unit kani;
interface
PROCEDURE kani_ana(afilename:string);
implementation
{
program kani;
}
uses lib,dos,alib,crt;
var
	i,dx:integer;
procedure getdx(n:integer;maxerr:real;var dx:integer);
label 100;
var
    i:integer;
    rn:word;
begin

dx:=1;
rn:=1;
for i:=1 to n do rn:=rn*10;
if ((maxerr-0.001)*rn<maxint) and ((maxerr-0.001)*rn>0) then dx:=round((maxerr-0.001)*rn)
		else dx:=0;
dx:=dx*10;
if (dx>rn) then goto 100;
repeat
	if (dx div rn)<>0 then
			begin
			dx:=(5-n)*10-dx div rn;
			if dx>41 then dx:=41;
			if dx<0 then dx:=1;
			n:=0;
			end
		else
			begin
			dec(n);
			rn:=rn div 10;
			end;
until n=0;
100:
if (dx>=1) and (dx<=41) then dx:=dx else dx:=1;

end;

PROCEDURE analyse;
var
	dx1:real;
	dx:integer;
	hour,min,sec,sec100:word;
	xhour,xmin,xsec,xsec100:word;
	t:integer;
	dm,ds,estm,ests:byte;
	pcent:integer;
	p,q,i,n:integer;
	c,srotsum:real;
	maxerr:real;

begin

clrscr;
msg(' Analysing ... ');
n:=0;
dx:=0;
windows(wglob,nocls);
gotoxy(20,11);
for i:=1 to 41  do write(#176);
box(18,5,39,8,single,0);
box(41,5,62,8,single,0);
box(18,9,62,13,single,0);
gotoxy(20,5);
write('Accuracy');
gotoxy(43,5);
write('Time');
gotoxy(20,9);
write('Progress');
gettime(hour,min,sec,sec100);

repeat
maxerr:=0.0001;
n:=n+1;
if n=1
    then
	first:=true
     else
	first:=false;
        repeat
		iterate;
		distribute(point,maxerr);
	until over;

	q:=1;
	repeat
		p:=1;
		srotsum:=0.0;
		while levelmat[q,p]<>0 do
		    begin
			search(levelmat[q,p]);
			if point^.rlud[3]<>nil then
			     begin
				take(point^.id,point^.rlud[3]^.id);
				c:=hr/data.l;
				if data.sups[1]='H' then c:=c/1.5;
                                {
                                writeln('VF=',point^.mx[3]:6:3,point^.rlud[3]^.mx[4]:6:3);
                                waitfor(SPACE);
				}
                                srotsum:=srotsum+c*(point^.mx[3]+point^.rlud[3]^.mx[4]);
			     end;
			p:=p+1;
		    end;

		p:=1;
		while levelmat[q,p]<>0 do
		    begin
			search(levelmat[q,p]);
			if point^.rlud[3]<>nil then
			    begin
				point^.umd:=point^.ud*(point^.mr+srotsum);
				err(point^.umd,point^.pumd,maxerr);
			    end;
			p:=p+1;
		   end;

		q:=q+1;
	until q>=maxlevel;

{
if dx<=100000 then
	 begin

		 else
		 if dx div 1000<>0 then dx:=20-dx div 1000
		 else
		 if dx div 100<>0 then dx:=30-dx div 10
		 else
		 if dx div 10<>0 then dx:=40-dx div 1;
		 else
		 if dx div 1<>0 then dx:=50-dx div 1
		 dx:=39;
}

gettime(xhour,xmin,xsec,xsec100);
t:=(xhour*3600+xmin*60+xsec+xsec100 div 100-(hour*3600+min*60+sec+sec100 div 100));
dm:=t div 60;
ds:=t mod 60;
getdx(4,maxerr,dx);
pcent:=trunc(dx/40*100)+1;
if pcent>100 then pcent:=100;
getdx(4,maxerr,dx);

ests:=0;
estm:=ests div 60;
ests:=ests mod 60;
gotoxy(20,11);
{for i:=1 to 41  do write(#176);}
if n<>1 then
	begin
		gotoxy(20,11);
		for i:=1 to dx do write(#178);
	end;
gotoxy(19,6);
write('Present   : ',strreal(maxerr,8,5));
gotoxy(42,6);
write('Elapsed   : 00:',p0i(dm,2),':',p0i(ds,2));
gotoxy(19,7);
write('Required  : ',strreal(0.001,8,5));
gotoxy(42,7);
write('Estimated : 00:',p0i(estm,2),':',p0i(ests,2));
gotoxy(20,12);
write('Iteration Count : ',n);
gotoxy(57,12);
write(pcent:3,'%');

until (maxerr<=accuracy) and not first;

end;

PROCEDURE  writevalues(afilename:string);
var
	maxer:real;
	bmdfile,sfdfile,cfile,beamfile:text;
	maxpo,contra1,contra2,sfl,sfr:real;
	bno:integer;
	q,p:integer;
	dsf:real;
	pout:text;
	s:string;
	found:boolean;
        taf:real;
begin
{
waitfor(ESC);
}
found:=FALSE;
assign(pout,'CON');
rewrite(pout);
window(1,1,80,25);
clrscr;
writeln(pout,'-------------------------------------------------------------------------------');
writeln(pout,'MEMBER    B.M(L)   B.M(M)   B.M(R)   S.F(L)   S.F(R)    S.F=0    B.M=0    B.M=0');
writeln(pout,'-------------------------------------------------------------------------------');
if interstatus='On ' then
	begin
	setfile(beamfile,s,afilename+'.BMI','W',excode);
	writeln(beamfile,'B (Beam Input)');
	end;
bno:=0;
repeat
iterate;
with point^ do
begin
if (rlud[1]<>nil) then
	begin
	inc(bno);
bendmax(bmdfile,sfdfile,FALSE,id,rlud[1]^.id,mt[1],rlud[1]^.mt[2],
		maxpo,maxer,contra1,contra2,sfl,sfr);
	write(pout,id:2,'-',rlud[1]^.id:2,'  ',mt[1]:9:2);
	write(pout,maxpo:9:2,rlud[1]^.mt[2]:9:2,sfl:9:2);
	writeln(pout,sfr:9:2,maxer:9:2,contra1:9:2,contra2:9:2);

	q:=0;
	repeat
	q:=q+1;
	p:=0;

	repeat
	p:=p+1;
	until (levelmat[q,p]=id) or (levelmat[q,p]=0);

	until (levelmat[q,p]=id);

if interstatus='On ' then
	begin
	take(point^.id,point^.rlud[1]^.id);
	writeln(beamfile,'Beam No:',afilename,'/',strint(q-1,1),'/',strint(p,1));
	writeln(beamfile,'R');
	writeln(beamfile,data.b:6:3);
	writeln(beamfile,data.d:6:3);
	writeln(beamfile,mt[1]:6:3);
	writeln(beamfile,maxpo:6:3);
	writeln(beamfile,rlud[1]^.mt[2]:6:3);
	if abs(sfl)>abs(sfr) then dsf:=abs(sfl) else dsf:=abs(sfr);
	writeln(beamfile,dsf:6:3);
	end;

 	if (sfl<0) or (sfr>0) then
		msg('To VKS : Upward force on column detected.');

	af:=af+abs(sfl);
	rlud[1]^.af:=rlud[1]^.af+abs(sfr);  {#assuming all shear force +ve }
{
        writeln(id,'-',rlud[1]^.id,'  =  ',af,'  ',rlud[1]^.af);
        readln;
}
	end;

if rlud[3]<>nil  then
	begin
bendmax(bmdfile,sfdfile,FALSE,id,rlud[3]^.id,mt[3],rlud[3]^.mt[4],
		maxpo,maxer,contra1,contra2,sfl,sfr);
	write(pout,id:2,'-',rlud[3]^.id:2,'  ',mt[3]:9:2);
	write(pout,maxpo:9:2,rlud[3]^.mt[4]:9:2,sfl:9:2);
	writeln(pout,sfr:9:2,maxer:9:2,contra1:9:2,contra2:9:2);
	end;
end;
until over;
if interstatus='On ' then
	begin
	writeln(beamfile,'END');
	close(beamfile);
	end;

if graphstatus='On ' then
	begin
	setfile(bmdfile,s,afilename+'.BMD','W',excode);
	setfile(sfdfile,s,afilename+'.SFD','W',excode);
	writeln(bmdfile,'BMD/SFD');
	writeln(sfdfile,'BMD/SFD');
repeat
iterate;
if point^.rlud[1]<>nil then
	with point^ do
	begin
	writeln(bmdfile,'H');
	writeln(bmdfile,(hpx+x):6:2,' ',(hpy+y):6:2);
	writeln(bmdfile,(hpx+rlud[1]^.x):6:2,' ',(hpy+rlud[1]^.y):6:2);
	writeln(sfdfile,'H');
	writeln(sfdfile,(hpx+x):6:2,' ',(hpy+y):6:2);
	writeln(sfdfile,(hpx+rlud[1]^.x):6:2,' ',(hpy+rlud[1]^.y):6:2);
	bendmax(bmdfile,sfdfile,TRUE,id,rlud[1]^.id,mt[1],rlud[1]^.mt[2],
				maxpo,maxer,contra1,contra2,sfl,sfr);
	end;
if point^.rlud[3]<>nil then
	with point^ do
	begin
	writeln(bmdfile,'V');
	writeln(bmdfile,(hpx+x):6:2,' ',(hpy+y):6:2);
	writeln(bmdfile,(hpx+rlud[3]^.x):6:2,' ',(hpy+rlud[3]^.y):6:2);
	writeln(sfdfile,'V');
	writeln(sfdfile,(hpx+x):6:2,' ',(hpy+y):6:2);
	writeln(sfdfile,(hpx+rlud[3]^.x):6:2,' ',(hpy+rlud[3]^.y):6:2);
	bendmax(bmdfile,sfdfile,TRUE,id,rlud[3]^.id,mt[3],rlud[3]^.mt[4],
			maxpo,maxer,contra1,contra2,sfl,sfr);
	end;
until over;
close(bmdfile);
close(sfdfile);
end;
if interstatus='On ' then
begin
found:=FALSE;
if upcase(afilename[2])='Y' then
			begin
			if exist('X.CNI') then
				begin
				assign(cfile,'X.CNI');
				msg('Writing to X.CNI');
				found:=TRUE;
				end
				else
					begin
					msg('File X.CNI not found'+noise);
					{
					assign(cfile,'X.CNI');
					rewrite(cfile);
					}
					end;
			end
	else
		if upcase(afilename[2])='X' then
			begin
			if exist('Y.CNI') then
				begin
				assign(cfile,'Y.CNI');
				msg('Writing to Y.CNI');
				found:=TRUE;
				end
				else
					begin
					msg('File Y.CNI not found'+noise);
					{
					assign(cfile,'Y.CNI');
					rewrite(cfile);
					}
					end;
			end
	else
			begin
			if exist(afilename+'.CNI') then
				begin
				assign(cfile,afilename+'.CNI');
				msg('Writing to '+afilename+'.CNI');
				found:=TRUE;
				end
				else
				begin
				msg('File '+afilename+'.CNI not found'+noise);
				{
				assign(cfile,afilename+'.CNI');
				rewrite(cfile);
				}
				end;
			end;
if found then append(cfile);
p:=1;
while levelmat[1,p]<>0 do
begin
if (levelmat[1,p]<>0) then
		begin
		q:=1;
		search(levelmat[q,p]);
		while point^.rlud[3]<>NIL do
				begin
				point:=point^.rlud[3];
				inc(q);
				end;
while point^.rlud[4]<>NIL do
begin
	point:=point^.rlud[4];
take(point^.id,point^.rlud[3]^.id);
	dec(q);

with point^ do
	begin
        {####}
	taf:=abs(rlud[3]^.af)+abs(rlud[3]^.y-y)*data.b*data.d*25*1e-6;
if found then
	begin
	if upcase(afilename[2])='X'
		then
			write(cfile,z:6:3,' ',x:6:3,' ',y:6:3,' ')
		else
			write(cfile,x:6:3,' ',z:6:3,' ',y:6:3,' ');

{
        if q in [1,2] then
             begin
             if eq(data.b,220) then
                               begin
                               xd:=450;
                               xb:=220;
                               end
             else
             if eq(data.d,220) then
                               begin
                               xb:=450;
                               xd:=220;
                               end;
             end
        else
             begin
             if eq(data.b,220) then
                               begin
                               xd:=300;
                               xb:=220;
                               end
             else
             if eq(data.d,220) then
                               begin
                               xb:=300;
                               xd:=220;
                               end;
             end;
}

	writeln(cfile,strint(q,1),' ',strint(p,1),' ',taf:6:3,
			' ',mt[3]:6:3,' ',data.b:6:3,' ',data.d:6:3,' ',afilename);
        af:=af+taf;
	end;
	end;
end;
	end;
inc(p);
end;
if found then close(cfile);
end;
writeln(pout,'-------------------------------------------------------------------------------');
close(pout);
msg('HOLD');
waitfor(any);
end;


PROCEDURE near1far2(i:integer;var j:integer);
begin
case i of
	1,3:j:=1;
	2,4:j:=2;
	end;
end;

PROCEDURE nearisfar(i:integer;var k:integer);
begin
case i of
	1:k:=2;
	2:k:=1;
	3:k:=4;
	4:k:=3;
	end;
end;

PROCEDURE results;
var
	{rfile:text;}
	mdisp:real;
	j,k:integer;
begin
{
msg('Enter');
waitfor(anykreadln;
}
windows(wout,cls);
repeat
iterate;
for i:= 1 to 4 do
begin
near1far2(i,j);
nearisfar(i,k);
if point^.rlud[i]<>nil then
     with point^ do
     begin
	take(id,rlud[i]^.id);	{ #avoid with caution }
        case i of
		1,2:mdisp:=0;
		3:mdisp:=umd;
		4:mdisp:=rlud[i]^.umd;
		end;
mt[i]:=final(fem[i],mx[i],rlud[i]^.mx[k],mdisp,data.sups[j]);
{
writeln('Moment of ',id:2,'-',rlud[i]^.id:2,'  =  ',justify(mt[i],10,3,LEFT));
}
     end;
end;
until over;
{
msg('<HOLD>');
waitfor(any);
}
end;


PROCEDURE genLDfile1(var LDfile:text);
begin
loadno:=1;
	with point^ do
	while (data.loads[loadno].loadtype<>'.') and (loadno<10) do
		begin
	with data.loads[loadno] do
		case loadtype of
			'C'     :
				begin
				write(LDfile,posn:6:2,' ',0);
				write(LDfile,posn:6:2,w:6:2);
{
				write('0 0');
				writeln('0 0');
				write(LDfile,posn,w:6:2);
				writeln(LDfile,posn:6:2,' ',0);
				writeln(LDfile,posn,w);
}
			end;
			'V','U' :
				begin
				write(LDfile,pos1:6:2,0.0:6:2);
				write(LDfile,pos1:6:2,w1:6:2);
				write(LDfile,pos2:6:2,w2:6:2);
				writeln(LDfile,pos2:6:2,0.0:6:2);
				end;
			'P'	:
				begin
				end;
			'M'	:
				begin
				end;
			else msg(' Error! ');
			end;
			inc(loadno);
			end;
			writeln(LDfile,maxint,' ',maxint);
end;

PROCEDURE genLDfile(afilename:string);
var LDfile:text;
	s:string;
begin
setfile(LDfile,s,afilename+'.LOD','W',excode);
writeln(LDfile,'LOAD');
repeat
iterate;
with point^ do
begin
if (rlud[1]<>nil) then
	begin
	take(id,rlud[1]^.id);
	writeln(LDfile,'H');
	writeln(LDfile,(hpx+x):6:2,(hpy+y):6:2);
	writeln(LDfile,(hpx+rlud[1]^.x):6:2,(hpy+rlud[1]^.y):6:2);
	genldfile1(LDfile);
	end;
if (rlud[3]<>nil) then
	begin
	take(id,rlud[3]^.id);
	writeln(LDfile,'V');
	writeln(LDfile,(hpx+x):6:2,(hpy+y):6:2);
	writeln(LDfile,(hpx+rlud[3]^.x):6:2,(hpy+rlud[3]^.y):6:2);
	genldfile1(LDfile);
	end;
end;
until over;
close(LDfile);
end;

PROCEDURE kani_ana(afilename:string);
var
	tempfile:text;
	screen:image;
{************************MAIN PROGRAM FOR KANI'S ANALYSIS*******************}
begin
put(screen);
if not conf(afilename) then
begin
if pos('.',afilename)<>0 then
	delete(afilename,pos('.',afilename),length(afilename)-pos('.',afilename)+1);
end
else afilename:='TEMP';
if inptype<>'Structure' then
	begin
	assign(tempfile,afilename+'.CNI');
	rewrite(tempfile);
	close(tempfile);
	end;

{msg('Available '+justify(memavail,10,0,LEFT));
readln;    }
windows(winp,cls);
windows(wout,cls);
msg(' Assembling member data... ');

mark(heap);
makeframe(hpx,hpy,hpz);
if graphstatus='On ' then
		genLDfile(afilename);
msg(' Generating intermediate data... ');
marklevel;
markfems;
rotfacts;
disfacts;
analyse;
results;
msg(' Computing design values... ');
writevalues(afilename);
release(heap);
{
msg('Available '+justify(memavail,10,0,LEFT));
msg('Available '+justify(memavail,10,0,LEFT));
}
get(screen);
end;
end
.



{ Notes :
1.      afilename[2] has been used to differentiate 'X' & 'Y' frames.
	if name is like a:\fx1.asi > ERRRRR... overcome this.
}
