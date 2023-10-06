procedure startup;
begin
video(normal);
clrscr;
inpname  :='CON';
outname  :='CON';
insname  :='';
assign(out,outname);
assigncrt(out);
rewrite(out);
rev:=FALSE;
highletter:=TRUE;
end;