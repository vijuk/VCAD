type corners=record
	cl,cr,lu,ll:byte;
	end;
var 	regs:registers;
	vseg:word;

procedure kswrite(x,y:byte;s:string);
Procedure ClearBuffer;
Function PrinterReady:boolean;
procedure NextKeys(var b1,b2:byte);
Function  FileExists(fn:string):boolean;
Procedure Full;
Procedure WindCo(var X:corners);
Procedure ksgoto(c,l:byte);
Procedure WhereC(var c,l:byte);
implementation
var
	monocard:boolean;
Procedure ClearBuffer;
var C:Char;
begin
while KeyPressed do C:=ReadKey;
end;

Function PrinterReady;
Var Ch:Char; WarningDisplayed:Boolean;
Begin
WarningDisplayed:=False;
Repeat
Regs.ah:=2; Regs.dx:=0;
Intr($17,Regs); { OBTAIN PRINTER STATUS, 144 INDICATES PRINTER READY }
If Regs.ah<>144 Then Begin
   If Not(WarningDisplayed) Then Begin  { WARNING IF NOT ALREADY DISPLAYED }
          Write('Printer Not Ready. Retry/Abort ? ');
          WarningDisplayed:=True;
                                 End;
   repeat until upcase(readkey) in ['R','A'];
   If Ch='A' Then Begin  { ABORT }
                  PrinterReady:=False;
                  Exit;
                  End;
                      End; { IF REGS.AH <> 144 }
Until Regs.ah=144; { EITHER ABORT MIDWAY, OR REPEAT TILL REGS.AH=44 }
PrinterReady:=True;
End;

procedure NextKeys;
begin
repeat until keypressed;
B1:=mem[$0040:lo(mem[$0040:$001A])];
B2:=mem[$0040:lo(mem[$0040:$001A])+1];
end;

Function FileExists;
Var Sr:SearchRec;
Begin
Findfirst(Fn,Archive,Sr); { LOOK FOR NORMAL AND R/O FILES }
FileExists:=DosError=0;
End;

Procedure Full;
Begin
Window(1,1,80,25);
End;

Procedure WindCo;
Begin
X.CL:=Lo(Windmin)+1; X.LU:=Hi(Windmin)+1; { WINDMIN & WINDMAX ARE TURBO }
X.CR:=Lo(Windmax)+1; X.LL:=Hi(Windmax)+1; { PASCAL SUPPLIED FUNCTIONS }
End;

Procedure KSgoto; { goto absolute _ location }
Begin
Regs.bh:=0;
Regs.ah:=2; Regs.bh:=0; Regs.dh:=L-1; Regs.dl:=C-1; Intr($10,Regs);
End;

Procedure WhereC;
Begin
Regs.bh:=0;
Regs.ah:=3; Intr($10,Regs); { Find Cursor Location And Mode. }
C:=Regs.dl+1; L:=Regs.dh+1;
End;

procedure kswrite(x,y:byte;s:string);
begin
ksgoto(x,y);
write(s);
end;


Begin  { Initialisation }
Intr($11,Regs); { Equipment Determination. Bytes 4 & 5 Indicate Video Card }
MonoCard:= (Regs.al And $30)=$30;
If MonoCard Then VSeg:=$b000 Else VSeg:=$b800;
end.
