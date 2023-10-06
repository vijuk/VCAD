program editor;
{
unit editor;
interface
procedure editf;
implementation
}
uses crt,lib,dos;
const
{
	lasto:array[1..5] of integer=(1,1,1,1,1);
	head:headtype=('File','Edit','Block','Options',
		'','','','');
}
	BL:integer=250;
	w1:integer=1;
	w2:integer=2;
	w3:integer=80;
	w4:integer=24;
	linespb=249;
	maxcol=100;
	tabsize:integer=8;
	finds:string='';
	reps:string='';

type
	a4i=array[1..4] of integer;
	link=^edittype;
	edittype=record
		no:integer;
		buffer:array[0..249] of string[100];
		pd,pu:link;
		end;
var
	screen1:image;
	err:integer;
	bco:a4i;
	hide:boolean;
	fileno:integer;
	startline:integer;
	noline:integer;
	startcol:integer;
	nocol:integer;
	lastno:integer;
	edbuf,first,last:link;
	bufman:array[0..99] of link;
	fileman:array[1..4,0..99] of link;
	maxline:integer;
	xscol,xedcol,nomem:integer;
	pcheck,next:boolean;
	ce,k:integer;
	scrbuf:array[0..5000] of char;
	spaceline:array[0..159] of char;
	hour,min,sec,sec100:word;
	xhour,xmin,xsec,xsec100:word;
	mode:char;
	badcol,outcol:boolean;
	top:integer;
	filename:array[1..4] of string;
	t:real;
	ed,xfile:text;
	letter:char;
	s:string;
	xline,i,j,x:integer;
	tx,ty,line,col:integer;
	sc,sl,topx,topy,x1,y1,x2,y2:integer;
	len:integer;
	filedat:array[1..4,1..8] of integer;
	pfdat:array[1..4,1..8] of integer;

{
procedure drawsetup;
begin
	sideborder;
	bottombar;
end;

procedure execmenu;
var
	menus:menutype;
label 300;
begin
rev:=TRUE;
new(menus);
repeat
scode[2]:=NOCHECK;
case choice[1] of
1:
	begin
	box(2,3,12,9,single,1);
	menus^[1]:=' System  ';
	menus^[2]:=' Copy    ';
	menus^[3]:=' Rename  ';
	menus^[4]:=' Erase   ';
	menus^[5]:=' Display ';
	boxpix(1,menus,'SCRED',3,4,11,8,1,choice[2],scode[2],1);
	if scode[2]=ENTER then
	case choice[2] of
		1	: call_shell('VCAD');
		2	: copyf;
		3	: renamef;
		4	: deletef;
		5   	: dirf;
		end;
end;

2:     begin
	      box(12,3,47,11,single,1);
	      menus^[1]:=' Search                           ';
	      menus^[2]:=' Replace                          ';
	      menus^[3]:='                                  ';
	      menus^[4]:='                                  ';
	      menus^[5]:='                                  ';
	      menus^[6]:='                                  ';
	      menus^[7]:='                                  ';
	      boxpix(1,menus,'SR',13,4,46,10,1,choice[2],scode[2],1);
	if scode[2]=ENTER then
	      case choice[2] of
                   1   :      ;
		   2   :      ;
		   3   :      ;
		   4   :      ;
		   5   :      ;
	      end;

       end;
3:     begin
	      box(22,3,34,9,single,0);
	      menus^[1]:=' Mark      ';
	      menus^[2]:=' Copy      ';
	      menus^[3]:=' mOve      ';
	      menus^[4]:=' Delete    ';
	      menus^[5]:=' Hide      ';
	      boxpix(1,menus,'MCODH',23,4,33,8,1,choice[2],scode[2],1);
	if scode[2]=ENTER then
	      case choice[2] of
		   1   :  ;
		   2   :  ;
		   3   :  ;
		   4   :  ;
		   5   :  ;
	      end;
       end;
	4:scode[2]:=ESC;
end;
until (scode[2]=ESC) or (scode[2]=LEFT) or (scode[2]=RIGHT);
300:
dispose(menus);
rev:=FALSE;
end;


procedure menusystem;
var
	hpixcode:char;
	screen:image;
label 100,200;
begin
drawsetup;
100:
choice[1]:=1;
choice[2]:=1;
scode[1]:=NOCHECK;
scode[2]:=ESC;
repeat
if scode[2]<>ESC then
			hpixcode:=NOREAD
		else
			hpixcode:=#0;
hpix(1,1,80,head,choice[1],hpixcode);
if hpixcode=ESC then exit;
200:
put(screen);
choice[2]:=lasto[choice[1]];
execmenu;
get(screen);
case scode[2] of
	left:
		begin
		lasto[choice[1]]:=choice[2];
		dec(choice[1]);
		if choice[1]=0 then choice[1]:=4;
		end;
       right:
		begin
		lasto[choice[1]]:=choice[2];
		inc(choice[1]);
		if choice[1]=5 then choice[1]:=1;
		end;
       ENTER: lasto[choice[1]]:=choice[2];
	  end;
until hpixcode=ESC;
end;
}

PROCEDURE linkbuf;
begin
i:=-1;
repeat
i:=i+1;
bufman[i]:=NIL;
until i=99;
edbuf:=first;
i:=0;
repeat
bufman[i]:=edbuf;
edbuf:=edbuf^.pd;
i:=i+1;
until edbuf=NIL;
move(bufman,fileman[fileno],sizeof(bufman));
end;

PROCEDURE takefile(fileno:integer);
begin
move(fileman[fileno],bufman,sizeof(fileman[fileno]));
w1:=filedat[fileno,1];
w2:=filedat[fileno,2];
w3:=filedat[fileno,3];
w4:=filedat[fileno,4];
startline:=w2;
noline:=w4-w2-1;
startcol:=w1+1;
nocol:=w3-w1-1;
sc:=startcol-1;
sl:=startline-1;
nomem:=(w3-w1-1)*2;
topx:=filedat[fileno,5];
topy:=filedat[fileno,6];
col:=filedat[fileno,7];
line:=filedat[fileno,8];
end;

PROCEDURE unload(fileno:integer);   { NEVER UNLOAD THE PRESENT FILE }
begin
msg('Unloading '+filename[fileno]+' from memmory . . .');
takefile(fileno);
i:=1;
while bufman[i]<>NIL do
	begin
	dispose(bufman[i]);
	bufman[i]:=NIL;
	i:=i+1;
	end;
filename[fileno]:='';
end;


FUNCTION tline:integer;
begin
tline:=line+topy-1;
end;

FUNCTION tcol:integer;
begin
tcol:=col+topx-1;
end;

FUNCTION tdBL:integer;
begin
tdBL:=tline div BL;
end;

FUNCTION tmBL:integer;
begin
tmBL:=tline mod BL;
end;

PROCEDURE clrline(line:integer);
var t:integer;
begin
move(spaceline,mem[Vseg:(line+sl)*160+(sc)*2],nomem);
end;


PROCEDURE deline(line:integer);
var t:integer;
begin
move(spaceline,mem[Vseg:(line-1)*160],160);
end;

PROCEDURE memcheck;
begin
msg('Checking memmory . Press ESC.');
waitfor(ESC);
if memavail<sizeof(edbuf^) then
begin
x:=fileno;
repeat
x:=x mod 4 +1;
if filename[x]<>'' then
	begin
	assign(xfile,filename[x]);
	msg('Out of memmory. Unload '+filename[x]+' from memmory ?  ');
	readln(resp);
	window(1,1,80,25);
	if upcase(resp)='Y' then unload(x);
	end;
until  (memavail>sizeof(edbuf^)) or (x=(fileno+3) mod 4);
end;

if memavail<sizeof(edbuf^) then
			begin
			msg('Out of memmory . Press ESC.');
			waitfor(ESC);
			window(1,1,80,25);
			aborted:=TRUE;
			linkbuf;
			unload(fileno);
			close(ed);
			exit;
			end;
end;

PROCEDURE appendbuf;
begin
msg('About to append heap space . Press ESC.');
waitfor(ESC);
memcheck;
window(1,1,80,25);
if aborted then exit;
new(edbuf);
last^.pd:=edbuf;
edbuf^.pu:=last;
edbuf^.pd:=NIL;
edbuf^.no:=last^.no+1;
last:=edbuf;
for k:= 0 to linespb do
for j:= 1 to maxcol do  edbuf^.buffer[k,j]:=' ';
linkbuf;
for k:=0 to 99 do fileman[fileno,k]:=bufman[k];
end;

PROCEDURE readfile(fileno:integer);
var
	t,cnt,k:integer;
begin
upstring(filename[fileno]);
msg(' Loading editor file... ');
window(1,1,80,25);
if not exist(filename[fileno]) then halt;
assign(ed,filename[fileno]);
reset(ed);
i:=-1;
while not eof(ed) do
begin
i:=i+1;
if ((i mod BL)=0) then
	begin
	   {
	   memcheck;
	   }
	   if aborted then exit;
	   new(edbuf);
	   edbuf^.pu:=NIL;
	   edbuf^.pd:=NIL;
	   if i<>0 then
	   begin
	   edbuf^.no:=last^.no+1;
	   last^.pd:=edbuf;
	   edbuf^.pu:=last;
	   edbuf^.pd:=NIL;
	   end
	   else
		begin
		edbuf^.no:=0;
                first:=edbuf;
		end;
		for k:= 0 to linespb do
		for j:= 1 to maxcol do  edbuf^.buffer[k,j]:=' ';
	   last:=edbuf;
	   end;
readln(ed,s);
edbuf^.buffer[i mod BL]:=s+chr(13)+chr(10);
end;
maxline:=i+1;
linkbuf;
windows(wmsg,cls);
window(1,1,80,25);
close(ed);
end;

PROCEDURE clrbuf;
var i,j:integer;
begin
{
for i:=w2 to w4-2 do
for j:=w1+1 to w3-1 do
	begin
	scrbuf[(i-1)*160+(j-1)*2]:=' ';
	scrbuf[(i-1)*160+(j-1)*2+1]:=chr(Norm);
	end;
}
move(screen1,scrbuf,sizeof(screen1));
end;

FUNCTION scol(i,col:integer):integer;
var
	len,j,colx:integer;
begin
badcol:=false;
colx:=0;
len:=length(bufman[i div BL]^.buffer[i mod BL]);
j:=0;
repeat
j:=j+1;
colx:=colx+1;
	if j>1 then if chr(9) = bufman[i div BL]^.buffer[i mod BL][j-1]
	then
		begin
		colx:=colx+tabsize-1;
		end;
until (colx>=col) or (j=len);
if (colx>col) then
	begin
	j:=j-1;
	badcol:=TRUE;
	end;
scol:=j;
end;

FUNCTION edcol(i,col:integer):integer;
var
	det,cnt,colx:integer;
	s:string;
begin
if pos(chr(9),bufman[i div BL]^.buffer[i mod BL])=0 then
	begin
	edcol:=col;
	exit;
	end;

s:=bufman[i div BL]^.buffer[i mod BL];
cnt:=0;
repeat
det:=pos(chr(9),s);
if (det<>0) and (det+cnt<col) then
	begin
	delete(s,det,1);
	cnt:=cnt+1;
	end
	else det:=0;
until (det=0);
colx:=col+cnt*(tabsize-1);
edcol:=colx;
end;


PROCEDURE highblock;
var
	bline,bcol:integer;
	c:char;
	i:integer;
begin
	bline:=bco[1];
	bcol:=bco[2];
	if topy>bco[1] then
			bline:=topy;
while  not(bline>bco[3]) and not((bline=bco[3]) and (bcol=bco[4])) and not(bline>topy+noline-1) do
begin
	c:=bufman[bline div BL]^.buffer[bline mod BL][scol(bline,bcol)];
	if (bcol-topx+i>0) then
		scrbuf[(bline+1-topy)*160+(bcol-topx+sc)*2+1]:=chr(rvse);
	case c of
	#13:
			begin
			for i:=1 to 80-(bcol-topx)-startcol-1 do
		scrbuf[(bline+1-topy)*160+(bcol-topx+sc+i)*2+1]:=chr(rvse);
				bline:=bline+1;
				bcol:=0;
			end;
	#9 :
			begin
			for i:=1 to tabsize-1 do
	if bcol-topx+i>=0 then
		scrbuf[(bline+1-topy)*160+(bcol-topx+sc+i)*2+1]:=chr(rvse);
			bcol:=bcol+tabsize-1;
			end;
		end;
	bcol:=bcol+1;
	end;
end;

PROCEDURE writebuf(fromcol,fromline,tocol,toline:integer);
var
	t,i,i1,j1,i2,j2,cnt,x,p,scolj1:integer;
	leftmost,dirflag:boolean;
	s,sd:string;
begin
if (fromline=1) and (toline=noline) then
	begin
	dirflag:=FALSE;
	clrbuf;
	end
		else
		dirflag:=TRUE;
fromline:=fromline-1;
toline:=toline-1;
i1:=topy+fromline;
j1:=topx+fromcol-1;
i2:=topy+toline;
j2:=topx+tocol-1;
xline:=i1;
leftmost:=TRUE;
j:=scol(i1,j1);
k:=fromline*160+(sc)*2+(sl)*160;
repeat
next:=FALSE;
if leftmost then
begin
if  (bufman[xline div BL]^.buffer[xline mod BL,j]=chr(9))
  then
	begin
		p:=(edcol(xline,j+1)-topx+1);
		t:=(p-1)*2;
		if dirflag
			then
				move(spaceline,mem[Vseg:160+k],t)
			else
				move(spaceline,scrbuf[k],t);
		k:=k+t;
		j:=j+1;
	end
	else
	p:=edcol(xline,j)-topx+1;
end;

if (bufman[xline div BL]^.buffer[xline mod BL,j-1]=chr(13)) and (bufman[xline div BL]^.buffer[xline mod BL,j]=chr(10))
  then
	   next:=TRUE
   else
	    if bufman[xline div BL]^.buffer[xline mod BL,j]=chr(9)
		then
		begin
		x:=0;
		t:=nocol-p;
		if t>tabsize then t:=tabsize;
		if t>=0 then
			begin
			p:=p+t;
			t:=t*2;
			if dirflag
				then
					move(spaceline,mem[Vseg:160+k],t)
				else
					move(spaceline,scrbuf[k],t);
			k:=k+t;
			end
			else
				  next:=TRUE;
		end
else
	if (j<=length(bufman[xline div BL]^.buffer[xline mod BL])) and (p<=nocol) then
		begin
		if ((bufman[xline div BL]^.buffer[xline mod BL,j]<>chr(13)) and (bufman[tdBL]^.buffer[xline mod BL,j]<>chr(10)))
			then
			begin
			if dirflag
			   then
				mem[Vseg:160+k]:=ord(bufman[tdBL]^.buffer[xline mod BL,j])

			   else
				scrbuf[k]:=bufman[xline div BL]^.buffer[xline mod BL,j];
			k:=k+2;
			end;
		end
else
	if  (j=length(bufman[xline div BL]^.buffer[xline mod BL])-2) and (p=nocol-1) then
			  next:=TRUE;
j:=j+1;
if (p>=nocol) then next:=TRUE;
if next then
	begin
{
		if (xline mod BL)=0 then
			begin
			edbuf:=edbuf^.pd;
			xline:=0;
			end;
}
		xline:=xline+1;
		j:=scol(xline,j1);
		fromline:=fromline+1;
		k:=fromline mod noline*160+(sc)*2+(sl)*160;
		leftmost:=TRUE;
	end
	else
		leftmost:=FALSE;
p:=p+1;
until (xline>maxline) or (xline>i2)
or ((xline=i2) and (j>=length(bufman[i2 div BL]^.buffer[i2 mod BL])));
if not hide and ((i1<=bco[1]) and (i2>=bco[1]))
	or ((i1<=bco[3]) and (i2>=bco[3]))
	or (i1>bco[1]) and (i2<bco[3])
		then highblock;
if not dirflag then
	move(scrbuf,mem[Vseg:160],4000-160);
setc('N');
gotoxy(2,1);
{video(reversed);}
write(' Line        Col                       ');
gotoxy(8,1);  write('    ');
gotoxy(19,1); write('    ');
gotoxy(8,1);  write(tline+1);
gotoxy(19,1); write(tcol);
{video(low);}
gotoxy(col+sc,line+startline);
end;

PROCEDURE moveright;
var i:integer;
begin
if bufman[tdBL]^.buffer[tmBL,scol(tline,tcol)]=chr(9) then
	begin
		col:=col+tabsize;
		if col>nocol then
			begin
			topx:=topx+col-nocol;
			col:=nocol;
			writebuf(1,1,nocol,noline);
			end
			else
			begin
			end;

	end
	else
	begin
if col>=nocol then
		begin
		topx:=topx+1;
		col:=nocol;
	writebuf(1,1,nocol,noline);
		end
		else
			begin
			col:=col+1;
			end;

	end;
gotoxy(col+sc,line+startline);
end;

PROCEDURE moveleft;

begin
if bufman[tdBL]^.buffer[tmBL,scol(tline,tcol)-1]=chr(9) then
	begin
		col:=col-tabsize;
		if (topx>1) and (col<1) then
			begin
				topx:=topx+col-1;
				col:=1;
				writebuf(1,1,nocol,noline);
			end;
	end
else
	begin
		if col>1 then
		begin
			col:=col-1;
		end
	else
		if topx>1 then
		begin
			topx:=topx-1;
			writebuf(1,1,nocol,noline);
		end;
end;
gotoxy(col+sc,line+startline);
end;

PROCEDURE moveup;
begin
if line>1
    then
    begin
    if bufman[tdBL]^.buffer[(tline-1) mod BL,scol(tline-1,tcol)]=chr(9)
	    then
	    begin
	    if badcol
		then
			col:=edcol(tline-1,scol(tline-1,tcol)+1)
		else
			col:=edcol(tline-1,scol(tline-1,tcol));
		end;
    line:=line-1;
    end
    else
    if  topy>0 then
			begin
			topy:=topy-1;

			{
			gotoxy(startcol,startline);
			insline;
			}

			writebuf(1,1,nocol,noline);
			end;

gotoxy(col+sc,line+startline);

end;

PROCEDURE movedown;
begin
if (tline>=maxline) then
				exit;
if (line<noline)
	then
	begin
	if  (bufman[tdBL]^.buffer[(tline+1) mod BL,scol(tline+1,tcol)]=chr(9)) then
	    begin
	    if badcol
		then
			col:=edcol(tline+1,scol(tline+1,tcol)+1)
		else
			col:=edcol(tline+1,scol(tline+1,tcol));
	    end;
	line:=line+1;
	gotoxy(col+sc,line+startline);
	end
else
	begin
	topy:=topy+1;
	writebuf(1,1,nocol,noline);
	end;
end;

PROCEDURE delchar;
var
	i,t:integer;
begin
gotoxy(col+sc,line+startline);
if length(bufman[tdBL]^.buffer[tmBL])-2 < scol(tline,tcol)
    then
	begin
		delete(bufman[tdBL]^.buffer[tmBL],length(bufman[tdBL]^.buffer[tmBL])-1,2);
		for i:=1 to col-edcol(tline,length(bufman[tdBL]^.buffer[tmBL]))-1 do
		insert(' ',bufman[tdBL]^.buffer[tmBL],length(bufman[tdBL]^.buffer[tmBL])+i);
		s:=concat(bufman[tdBL]^.buffer[tmBL]+bufman[tdBL]^.buffer[(tline+1) mod BL]);
		bufman[tdBL]^.buffer[tmBL]:=s;
for i:=tline+1 to maxline-1 do
bufman[i div BL]^.buffer[i mod BL]:=bufman[(i+1) div BL]^.buffer[(i+1) mod BL];
		(*

		clrline(line);
		writebuf(1,line,nocol,line);
		gotoxy(startcol,line+1+startline);
		{
		delline;
		&
		}
		clrline(line);
		gotoxy(startcol,noline);
		writebuf(1,noline,nocol,noline);
		*)
		writebuf(1,1,nocol,noline);
	end
    else
    begin
if bufman[tdBL]^.buffer[tmBL,scol(tline,tcol)]<>chr(9) then
		delete(bufman[tdBL]^.buffer[tmBL],scol(tline,tcol),1)
	else
		delete(bufman[tdBL]^.buffer[tmBL],scol(tline,tcol),1);
		clrline(line);
		writebuf(1,line,nocol,line);
end;
gotoxy(col+sc,line+startline);
end;

PROCEDURE gohome;
begin
col:=1;
if topx>1 then
	begin
	topx:=1;
	writebuf(1,1,nocol,noline);
	end;
gotoxy(col+sc,line+startline);
end;

PROCEDURE goend;
var t:integer;
begin
col:=edcol(tline,length(bufman[tdBL]^.buffer[tmBL])-1);
if col-topx>nocol then
	begin
	topx:=col-nocol+1;
	col:=nocol;
	clrbuf;
	writebuf(1,1,nocol,noline);
	end
		else col:=col-topx+1;
gotoxy(col+sc,line+startline);
end;

PROCEDURE enterline(block:boolean);
var sl,sr:string;
begin
sr:='';
sl:='';
if mode='I' then
	begin
	if length(bufman[tdBL]^.buffer[tmBL])-2 < scol(tline,tcol)
    then
	begin
	line:=line+1;
	sr:=''+chr(13)+chr(10);
if maxline+1>((last^.no+1)*BL)
	then
		appendbuf;
for i:=maxline downto tline do
	begin
bufman[(i+1) div BL]^.buffer[(i+1) mod BL]:=bufman[i div BL]^.buffer[i mod BL];
	end;
	maxline:=maxline+1;
	bufman[tdBL]^.buffer[tmBL]:=sr;
	end
	else
	begin
	gotoxy(col+sc,line+startline);
	line:=line+1;
	if scol(tline-1,tcol) > 1
		then
		   begin
		   sl:=copy(bufman[tdBL]^.buffer[(tline-1) mod BL],1,scol(tline-1,tcol)-1);
		   if sl<> bufman[tdBL]^.buffer[(tline-1) mod BL] then sl:=sl+chr(13)+chr(10);
		   end
		else
		   begin
		   sl:='';
		   sl:=chr(13)+chr(10);
		   end;
x:=length(bufman[tdBL]^.buffer[(tline-1) mod BL])-scol(tline-1,tcol);
sr:=copy(bufman[tdBL]^.buffer[(tline-1) mod BL],scol(tline-1,tcol),x+1);	bufman[tdBL]^.buffer[(tline-1) mod BL]:=sl;
	if maxline+1>((last^.no+1)*BL)
		then
			appendbuf;
	for i:=maxline downto tline do
		begin
		bufman[(i+1) div BL]^.buffer[(i+1) mod BL]:=bufman[i div BL]^.buffer[i mod BL];
		end;
		maxline:=maxline+1;
        	bufman[tdBL]^.buffer[tmBL]:=sr;
		end;
	if topx=1 then
	begin
	col:=1;
{
	clrline(line-1);

	writebuf(1,line-1,nocol,line-1);
}
	if line>noline then
		begin
		movedown;
		line:=noline;
		end;
{
	gotoxy(col+sc,line+startline);
	insline;
	gotoxy(col+sc,line+startline);
	writebuf(1,line,nocol,line);
}
	if not block then
		writebuf(1,1,nocol,noline);
	end
	else
		begin
		topx:=1;
		col:=1;
	if not block then
		writebuf(1,1,nocol,noline);
		end;
gotoxy(col+sc,line+startline);
end
	else
		begin
		col:=1;
		movedown;
		end;
end;

PROCEDURE acceptchar(letter:char;block:boolean);
begin

len:=length(bufman[tdBL]^.buffer[tmBL]);
if scol(tline,tcol)>len-2 then
	begin
		for i:=1 to col-edcol(tline,len-2) do
insert(' ',bufman[tdBL]^.buffer[tmBL],len-1);
	end;
if (mode='O') then  if bufman[tdBL]^.buffer[tmBL,scol(tline,tcol)]<>chr(9) then
	delete(bufman[tdBL]^.buffer[tmBL],scol(tline,tcol),1);

insert(letter,bufman[tdBL]^.buffer[tmBL],scol(tline,tcol));
{*********}

if bufman[tdBL]^.buffer[tmBL,scol(tline,tcol)]=chr(9) then
	begin
		col:=col+tabsize;
		if col>nocol then
			begin
			topx:=topx+col-nocol;
			col:=nocol;
			if not block then
				writebuf(1,1,nocol,noline);
			end
		     else
		if not block then
		     begin
		     clrline(line);
		     writebuf(1,line,nocol,line);
		     end;
	end
	else
	begin
	col:=col+1;
if col>nocol then
		begin
		topx:=topx+1;
		col:=nocol;
		if not block then
			writebuf(1,1,nocol,noline);
		end
		else
		if not block then
			begin
			clrline(line);
			writebuf(1,line,nocol,line);
			end;

	end;
gotoxy(col+sc,line+startline);
end;

PROCEDURE backspace;
begin
if col>1 then
	 col:=col-1
	else
		begin
		line:=line-1;
		col:=edcol(tline,length(bufman[tdBL]^.buffer[tmBL]));
		end;
delchar;
gotoxy(col+sc,line+startline);
end;

PROCEDURE pageup;
begin
topy:=topy-noline;
if topy<0 then topy:=0;
writebuf(1,1,nocol,noline);
end;


PROCEDURE pagedown;
begin
topy:=topy+noline;
if tline>maxline then
		begin
		topy:=maxline;
		line:=1;
		end;
writebuf(1,1,nocol,noline);
end;


PROCEDURE setcursor;
begin
gotoxy(1,25);
write('Cursor : Full block, Half block, Invisible or Normal  ?  (F/H/I/N)  ');
resp:=upcase(readkey);
if resp in  ['F','H','I','N'] then setc(resp);
deline(25);
end;

PROCEDURE findpattern;
var ts:string;
	c:char;
begin
gotoxy(1,25);
windows(wmsg,cls);

write('Find  :  <',finds,'>  ');
readln(ts);
if length(ts)<>0 then finds:=ts;
i:=topy+line;
repeat
x:=pos(finds,bufman[i div BL]^.buffer[i mod BL]);
i:=i+1;
until (x<>0) or (i>maxline);
i:=i-1;
if x=0 then
	begin
	windows(wmsg,cls);
	write('"',finds,'" -Search string not found.');
	window(1,1,80,25);
	end
else
begin
col:=edcol(i,x);
line:=i-topy+1;
if (i>topy+noline-1) then
	begin
	topy:=i-noline div 2;
	line:=noline div 2+1;
	writebuf(1,1,nocol,noline);
	end;
window(1,1,80,25);
deline(25);
end;
end;

PROCEDURE replace;
label 100,200;
var
	ts,ops:string;
	c:char;
	i,cnt,tx,ty:integer;
begin
ops:='';
resp:=' ';
windows(wmsg,cls);
write('Find    :  <',finds,'>  ');
readln(ts);
if length(ts)<>0 then finds:=ts;
write('Replace :  <',reps,'>  ');
readln(ts);
if length(ts)<>0 then reps:=ts;
write('Option  :  <',ops,'>  ');
readln(ts);
if length(ts)<>0 then ops:=ts;
upstring(ops);
window(1,1,80,25);
cnt:=0;
100:
i:=topy+line-1;
repeat
if i<maxline then i:=i+1;
x:=pos(finds,bufman[i div BL]^.buffer[i mod BL]);
until (x<>0) or (i=maxline);
if x=0 then
	begin
	windows(wmsg,cls);
	if ops='A' then
			write('"',finds,'" -Search string not found.')
		else
			write(cnt:4,' string(s) replaced.');
	window(1,1,80,25);
	if keypressed then goto 200;
	end;
col:=edcol(i,x);
line:=i-topy+1;
if (i>topy+noline-1) then
	begin
	topy:=i-noline div 2;
	line:=noline div 2+1;
	end;
writebuf(1,1,nocol,noline);
if ops='S' then
	begin
	tx:=wherex;
	ty:=wherey;
	windows(wmsg,cls);
	write('Replace ? (Y/N)  ');
	window(1,1,80,25);
	setc('F');
	gotoxy(tx,ty);
	resp:=readkey;
	resp:=upcase(resp);
	setc('N');
	if resp=ESC then goto 200;
	end;
if (ops='A')  or (resp='Y') then
begin
delete(bufman[i div BL]^.buffer[i mod BL],x,length(finds));
insert(reps,bufman[i div BL]^.buffer[i mod BL],x);
writebuf(1,1,nocol,noline);
end;
cnt:=cnt+1;
if (ops='A') or (ops='S') then goto 100;
200:
window(1,1,80,25);
deline(25);
end;

{U+}
PROCEDURE keystat;
var
	x,i,p,spos:integer;
	stat:string[10];
begin
if keyed(1)
	then
		begin
		mode:='I';
		stat:='Insert   ';
		end
	else
		begin
		mode:='O';
		stat:='Overwrite';
		end;
for p:=1 to 9 do
		move(stat[p],mem[Vseg:(32+p)*2],1);

(*
for i:= 2 to 8 do
	begin
		x:=(i-1)*6+32;
		spos:=25;
	if keyed(i) then
		BEGIN
		case i of
		       {1:  stat:='Insert   ';}
			2:  stat:=' CAPS ';
			3:  stat:=' NUM  ';
			4:  stat:='SCROLL';
			5:  stat:='  Alt ';
			6:  stat:=' Ctl  ';
			7:  stat:='Shift ';    {Left}
			8:  stat:='shift ';    {Right}
		   end;
		for p:=1 to 6 do
			move(stat[p],mem[Vseg:(spos-1)*160+(x+p-2)*2],1);
	   end
	   else
		move(spaceline,mem[Vseg:(spos-1)*160+(x-1)*2],12);
	end;
*)
end;

PROCEDURE ctlhome;
begin
topx:=1;
col:=1;
if tline>noline then
begin
line:=1;
topy:=0;
writebuf(1,1,nocol,noline);
end
else
	begin
	line:=1;
	gotoxy(col,line);
	end;
end;
PROCEDURE ctlend;
begin
topx:=1;
col:=1;
if tline<maxline-noline then
begin
line:=noline div 2;
topy:=maxline-line-1;
writebuf(1,1,nocol,noline);
end
else
	begin
	line:=maxline-topy+1;
	gotoxy(col,line);
	end;
end;

PROCEDURE savefile;
begin
windows(wmsg,cls);
msg(' Saving editor file... ');
window(1,1,80,25);
rewrite(ed);
for i:=0 to maxline-1 do
	write(ed,bufman[i div BL]^.buffer[i mod BL]);
close(ed);
end;

procedure clrwind(w1,w2,w3,w4:integer);
begin
window(w1,w2,w3,w4);
clrscr;
window(1,1,80,25);
end;

PROCEDURE loadfile;
label 100;
begin
lastno:=fileno;
aborted:=FALSE;
windows(wmsg,cls);
s:=paramstr(1);
if paramstr(1)='' then
	begin
	write(' Edit file name ?  ');
	readln(s);
	end;
if (fileno<>0) and (length(s)=0) then
begin
clrwind(pfdat[fileno,1],pfdat[fileno,2],pfdat[fileno,3],pfdat[fileno,4]);
goto 100;
end;

upstring(s);
i:=0;
repeat
	i:=i+1;
until (i=5) or (s=filename[i]);
if (i<5)  then
begin
fileno:=i       { this means file exists }
end
	  else
		begin
		if not exist(s) then
			begin
			assign(ed,s);
			rewrite(ed);
			close(ed);
			end;
		fileno:=fileno+1;
		if fileno>4 then
			begin
			writeln('FILE FULL');
			exit;
			end;
		filename[fileno]:=s;
		readfile(fileno);
		if aborted then
			if lastno<>0 then fileno:=lastno;
	end;
100:
w1:=filedat[fileno,1];
w2:=filedat[fileno,2];
w3:=filedat[fileno,3];
w4:=filedat[fileno,4];
box(w1,w2,w3,w4,single,0);
for k:=0 to 4000 do
	if odd(k) then scrbuf[k]:=chr(norm)
	else scrbuf[k]:=' ';
move(mem[Vseg:0160],scrbuf,4000-160);
takefile(fileno);
writebuf(1,1,nocol,noline);
end;

PROCEDURE windsize;
var
	c:char;
	wall,mover:char;
	x,i:integer;
	screen:image;
begin
clrscr;
put(screen);
window(1,1,80,25);
setc('I');
if fileno<>0 then
	begin
	w1:=filedat[fileno,1];
	w2:=filedat[fileno,2];
	w3:=filedat[fileno,3];
	w4:=filedat[fileno,4];
	for i:=1 to 8 do pfdat[fileno,i]:=filedat[fileno,i];
	end;
box(w1,w2,w3,w4,single,0);
i:=0;
for k:=0 to 3999 do
	if odd(k) then scrbuf[k]:=#7
		else scrbuf[k]:=#32;
move(mem[Vseg:0160],scrbuf,4000-160);
mem[Vseg:(w1-1)*2+(w2+w4-2) div 2*160]:=ord(^]);
mem[Vseg:(w3-1)*2+(w2+w4-2) div 2*160]:=ord(^]);
mem[Vseg:((w1+w3-2) div 2)*2+(w2-1)*160]:=ord(^R);
mem[Vseg:((w1+w3-2) div 2)*2+(w4-1)*160]:=ord(^R);

repeat
c:=readkey;
if c=#0
   then
	begin
	c:=readkey;
	mover:=c;
	end
   else
	begin
	c:=upcase(c);
	wall:=c;
	mover:=#0;
	end;

if (wall in  ['T','B','L','R']) then
begin
case mover of
	up :
		if (wall='T') or (wall='B') then
		begin
		get(screen);
		if wall='T' then if w2>2 then w2:=w2-1;
		if wall='B' then if w4-1>w2 then w4:=w4-1;
		box(w1,w2,w3,w4,single,0);
		if wall='T'
			then
				mem[Vseg:((w1+w3-2) div 2)*2+(w2-1)*160]:=ord(^X)
			else
				mem[Vseg:((w1+w3-2) div 2)*2+(w4-1)*160]:=ord(^X);
		end;
	down :
		if (wall='T') or (wall='B') then
		begin
		get(screen);
		if wall='T' then if w2+1<w4 then w2:=w2+1;
		if wall='B' then if w4<25 then w4:=w4+1;
		box(w1,w2,w3,w4,single,0);
		if wall='T'
			then
				mem[Vseg:((w1+w3-2) div 2)*2+(w2-1)*160]:=ord(^Y)
			else
				mem[Vseg:((w1+w3-2) div 2)*2+(w4-1)*160]:=ord(^Y);
		end;
	left :  if (wall='R') or (wall='L') then
		 begin
		get(screen);
		if wall='L' then if w1>1 then w1:=w1-1;
		if wall='R' then if w3-1>w1 then w3:=w3-1;
		box(w1,w2,w3,w4,single,0);
		if wall='L'
			then
				mem[Vseg:(w1-1)*2+(w2+w4-2) div 2*160]:=ord(^[)
			else
				mem[Vseg:(w3-1)*2+(w2+w4-2) div 2*160]:=ord(^[);
		end;
	right :
		if (wall='R') or (wall='L') then
		begin
		get(screen);
		if wall='L' then if w1+1<w3 then w1:=w1+1;
		if wall='R' then if w3<80 then w3:=w3+1;
		box(w1,w2,w3,w4,single,0);
		if wall='L'
			then
				mem[Vseg:(w1-1)*2+(w2+w4-2) div 2*160]:=ord(^Z)
			else
				mem[Vseg:(w3-1)*2+(w2+w4-2) div 2*160]:=ord(^Z);
		end;
	#0  :
		begin
		get(screen);
		box(w1,w2,w3,w4,single,0);
		if wall='T' then
			mem[Vseg:((w1+w3-2) div 2)*2+(w2-1)*160]:=ord(^R);
		if wall='B' then
			mem[Vseg:((w1+w3-2) div 2)*2+(w4-1)*160]:=ord(^R);
		if wall='L' then
			mem[Vseg:(w1-1)*2+(w2+w4-2) div 2*160]:=ord(^]);
		if wall='R' then
			mem[Vseg:(w3-1)*2+(w2+w4-2) div 2*160]:=ord(^]);
		end;
     	end;
{
if w1>w3 then
	begin
	x:=w1;
	w1:=w3;
	w3:=x;
	end;
if w2>w4 then
	begin
	x:=w2;
	w2:=w4;
	w4:=x;
	end;
}
end;
until c=ESC;
setc('N');

if fileno=0 then i:=1 else i:=fileno;
filedat[i,1]:=w1;
filedat[i,2]:=w2;
filedat[i,3]:=w3;
filedat[i,4]:=w4;
box(w1,w2,w3,w4,single,0);
loadfile;
end;

{
procedure writehead(ron:boolean);
var tx:integer;
begin
if ron=FALSE then
	begin
	video(reversed);
	case wherex of
		1:		write('  ',head[1],' ');
		11:		write('  ',head[2],' ');
		21:		write('  ',head[3],'  ');
		31:		write('  ',head[4],' ');
		end;

	video(low);
	tx:=wherex;
				gotoxy(3,1);
				write('P');
				gotoxy(13,1);
				write('A');
				gotoxy(23,1);
				write('D');
				gotoxy(33,1);
				write('O');
	gotoxy(tx,1);
	end
	else
	begin
video(low);
case wherex of
1:
		begin
		gotoxy(wherex+1,wherey);
		write('Û',head[1],'Û');
		end;

11:
		begin
                gotoxy(wherex+1,wherey);
		write('Û',head[2],'Û');
		end;

21:
		begin
                gotoxy(wherex+1,wherey);
		write('Û',head[3],'Û');
                gotoxy(wherex+1,wherey);
		end;

31:
		begin
		gotoxy(wherex+1,wherey);
		write('Û',head[4],'Û');
		end;

end;
end;
end;
}

PROCEDURE startblock;
begin
bco[1]:=tline;
bco[2]:=tcol;
if (bco[3]>0) or (bco[4]>0) then
	writebuf(1,1,nocol,noline);
end;

PROCEDURE endblock;
begin
bco[3]:=tline;
bco[4]:=tcol;
writebuf(1,1,nocol,noline);
end;

PROCEDURE copyblock;
var
	c:char;
	bline,bcol,sbsline,sbscol,totline:integer;
begin
totline:=bco[3]-bco[1];
bline:=bco[1];
bcol:=bco[2];
sbsline:=bco[1];
sbscol:=bco[2];
bco[1]:=tline;
bco[2]:=tcol;
repeat
c:=bufman[bline div BL]^.buffer[bline mod BL][scol(bline,bcol)];
if c=#13
		then
			begin
				enterline(TRUE);
				bline:=bline+1;
				if sbsline>=bco[1] then
				{# effect of col should be included }
						begin
						bline:=bline+1;
						bco[3]:=bco[3]+1;
						end;
				bcol:=1;
			end
		else
			begin
				acceptchar(c,TRUE);
				if c=#9 then
						bcol:=bcol+tabsize
					else
						bcol:=bcol+1;
			end;
if bcol>160 then exit;
until (bline>bco[3]) or ((bline=bco[3]) and (bcol=bco[4]));
bco[3]:=bco[1]+totline;
if bco[1]=bco[3] then
		bco[4]:=bco[2]+abs(bco[4]-sbscol);
writebuf(1,1,nocol,noline);
end;

PROCEDURE delblock(dbco:a4i);
var
	c:char;
	cnt:integer;
	bline,bcol:integer;
begin
cnt:=0;
bline:=dbco[1];
bcol:=dbco[2];
line:=bline-topy+1;
col:=bcol-topx+1;
repeat
c:=bufman[bline div BL]^.buffer[bline mod BL][scol(bline,bcol)];
case c of
	#13:
		begin
			bline:=bline+1;
			bcol:=1;
		end;
	#9:	bcol:=bcol+tabsize
	else
		bcol:=bcol+1;
	end;
if dbco[2]>160 then exit;     { # remove }
inc(cnt);
until (bline>dbco[3]) or ((bline=dbco[3]) and (bcol=dbco[4]));
repeat
	delchar;
	dec(cnt);
until cnt=0;
fillchar(bco,sizeof(bco),0);
writebuf(1,1,nocol,noline);
end;

procedure moveblock;
var
	sbco,tbco:a4i;
begin
for i:=1 to 4 do sbco[i]:=bco[i];
copyblock;
for i:=1 to 4 do tbco[i]:=bco[i];
delblock(sbco);
for i:=1 to 4 do bco[i]:=tbco[i];
end;


procedure hideblock;
begin
hide:=TRUE;
writebuf(1,1,nocol,noline);
end;

procedure blockcoms;
var c:char;
begin
repeat
c:=readkey;
if ord(c)=0 then c:=readkey;
until ord(c)<>0;
case upcase(c) of
	'B' : startblock;
	'K' : endblock;
	'C' : copyblock;
	'H' : hideblock;
	'V' : moveblock;
	'Y' : delblock(bco);
	end;
end;
			    { MAIN EDITOR PROGRAM }
procedure editf;
label 100,200;
var
	screen:image;
begin
window(1,1,80,25);
fillchar(bco,sizeof(bco),0);
rev:=FALSE;
clrscr;
setc('N');
{
hpix(1,1,80,o[1]);
box(1,2,80,24,single,0);
}
for fileno:=1 to 4 do
		begin
		filename[fileno]:='';
		filedat[fileno,1]:=w1;
		filedat[fileno,2]:=w2;
		filedat[fileno,3]:=w3;
		filedat[fileno,4]:=w4;
		filedat[fileno,5]:=1;
		filedat[fileno,6]:=0;
		filedat[fileno,7]:=1;
		filedat[fileno,8]:=1;
		end;
fileno:=0;
	startline:=w2;
	noline:=w4-w2-1;
	startcol:=w1+1;
	nocol:=w3-w1-1;
video(low);
for k:=0 to 159 do
	begin
	if odd(k) then
	spaceline[k]:=chr(norm)
		  else
	spaceline[k]:=' ';
	end;
box(w1,w2-1,w3,w4-1,single,0);
put(screen1);
nomem:=(w3-w1-1)*2;
sc:=startcol-1;
sl:=startline-1;
for k:=0 to 3999 do
	if odd(k) then scrbuf[k]:=chr(norm)
	else scrbuf[k]:=' ';
move(mem[Vseg:0160],scrbuf,4000-160);
move(scrbuf,mem[Vseg:0160],4000-160);
line:=1;
col:=1;
topx:=1;
topy:=0;
loadfile;
200:
gotoxy(2,1);
{video(reversed);}
write(' Line        Col                       ');
write('                                       ');
{video(low);    }
clrbuf;
writebuf(1,1,nocol,noline);
repeat
{video(reversed);}
gotoxy(8,1);  write('    ');
gotoxy(19,1); write('    ');
gotoxy(8,1);  write(tline+1);
gotoxy(19,1); write(tcol);
{video(low);}
keystat;
gotoxy(col+sc,line+startline);
pcheck:=false;
repeat
if not pcheck then keystat
	else
	begin
	letter:=readkey;
	end;
	pcheck:=keypressed;
until pcheck;
letter:=readkey;
gotoxy(col+sc,line+startline);
{
gettime(hour,min,sec,sec100);
}
if letter=#0 then
	begin
	keystat;
	letter:=readkey;
	case letter of
	right : moveright;
	left  : moveleft;
	up    : moveup;
	down  : movedown;
	pgup   : pageup;
	pgdn   : pagedown;
{F1}	#59   : windsize;
{F2}    #60   : savefile;
{F3}	#61   : loadfile;
	'S'   : delchar;
	'G'   : gohome;
	'O'   : goend;
	end
	end
	else
	case letter of
		ENTER : enterline(FALSE);
		#8  : backspace;
		ESC: exit;
		^C : setcursor;
		^F : findpattern;
		^B : ctlhome;
		^E : ctlend;
		^R : replace;
		^K : blockcoms;
{		^L : menusystem;}
		else
			if fileno<>0 then acceptchar(letter,FALSE);
end;
{
gettime(xhour,xmin,xsec,xsec100);
gotoxy(1,25);
t:=(xhour*3600+xmin*60+xsec+xsec100/100-(hour*3600+min*60+sec+sec100/100));
write(t:5:2,' sec');
}
until false;  {ord(letter)=esc; }
100:
end;

begin
w4:=21;
if (paramstr(5)<>'') then
begin
val(paramstr(3),w1,err);
val(paramstr(3),w2,err);
val(paramstr(4),w3,err);
val(paramstr(5),w4,err);
end;
editf;
end.
