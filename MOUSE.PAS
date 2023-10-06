unit mouse;

INTERFACE

uses dos;
type	Graph_Shape_Array = array[0..31] of integer;
var Regs:registers;
var Button,X,Y:integer;

procedure Show_M;
procedure Hide_M;
procedure Graph_M_Shape(X_Hot_Pixel, Y_Hot_Pixel:integer;
			var cursor: Graph_Shape_Array);
procedure Reset_M(var M_status,Nu_of_Buttons:integer);
procedure Graph_M_pos(var Button,X,Y:integer);
procedure Text_M_Pos(var Button, X,Y:integer);
procedure Set_V_Limit(Minimum,Maximum:integer);
procedure Set_H_Limit(Minimum,Maximum:integer);
procedure Text_M_Shape(Soft_Hard,Scan_Line1,Scan_Line2:integer);
procedure Locate_M(x,y:integer);

IMPLEMENTATION

procedure Show_M;
begin
Regs.ax:=1;
intr($33,Regs);
end;

procedure Graph_M_Shape(X_Hot_Pixel, Y_Hot_Pixel:integer;
			var cursor: Graph_Shape_Array);
begin
with Regs do
begin
ax:=9;
bx:=X_Hot_Pixel;
cx:=Y_Hot_Pixel;
dx:=ofs(cursor[0]);
es:=seg(cursor[0]);
end;
intr($33,Regs);
end;

procedure Reset_M(var M_status,Nu_of_Buttons:integer);
begin
Regs.ax:=0;
intr($33,Regs);
with Regs do
begin
if ax>maxint then M_Status:=-1 else M_status:=ax;
Nu_of_Buttons:=bx;
end;
end;

procedure Text_M_Pos(var Button, X,Y:integer);
begin
Regs.ax:=3;
intr($33,Regs);
with Regs do
begin
Button:=bx;
x:=cx;
y:=dx;
end;
x:=x div 8 +1;
y:=y div 8 +1;
end;


procedure Hide_M;
begin
Regs.ax:=2;
intr($33,Regs);
end;

procedure Graph_M_pos(var Button,X,Y:integer);
begin
Regs.ax:=3;
intr($33,Regs);
with Regs do
begin
Button:=bx;
x:=cx;
y:=dx;
end;
end;

procedure Locate_M(x,y:integer);
begin
Regs.ax:=4;
Regs.cx:=x;
Regs.dx:=y;
intr($33,Regs);
end;


procedure Set_V_Limit(Minimum,Maximum:integer);
begin
Regs.ax:=8;
Regs.cx:=Minimum;
Regs.dx:=Maximum;
intr($33,regs);
end;

procedure Set_H_Limit(Minimum,Maximum:integer);
begin
Regs.ax:=7;
Regs.cx:=Minimum;
Regs.dx:=Maximum;
intr($33,regs);
end;

procedure Text_M_Shape(Soft_Hard,Scan_Line1,Scan_Line2:integer);
begin
Regs.ax:=10;
Regs.cx:=Scan_Line1;
Regs.dx:=Scan_Line2;
intr($33,regs);
end;
end.


