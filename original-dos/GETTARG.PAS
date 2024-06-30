program get_target;

uses graph,crt,pcxr;
const xl=20;
      yl=20;
type buf=array[1..xl,1..yl] of byte;
     pbuf=^buf;
var  drv,drvm,x,y,size:integer;
     ch:char;
     f:file;
     p:pbuf;

Begin

drv:=installuserdriver('svga256',nil);
initgraph(drv,drvm,'c:\bin\tp7\bgi');
readpcx('targets.pcx');
new(p);
x:= 100;
y:=100;
assign(f,'targets.spr');
rewrite(f);
setwritemode(xorput);
rectangle(x,y,x+xl,y+yl);
repeat
if keypressed then ch:=readkey
              else ch:=#0;

case ch of
#75 : begin
      rectangle(x,y,x+xl,y+yl);
      dec(x);
      rectangle(x,y,x+xl,y+yl);
      end;
#77 : begin
      rectangle(x,y,x+xl,y+yl);
      inc(x);
      rectangle(x,y,x+xl,y+yl);
      end;
#72 : begin
      rectangle(x,y,x+xl,y+yl);
      dec(y);
      rectangle(x,y,x+xl,y+yl);
      end;
#80 : begin
      rectangle(x,y,x+xl,y+yl);
      inc(y);
      rectangle(x,y,x+xl,y+yl);
      end;
#32 : begin
      size:=imagesize(x+2,y+2,x+xl-2,y+yl-2);
      getimage(x+2,y+2,x+xl-2,y+yl-2,p^);
      blockwrite(f,p^,(size div 128)+1);
      end;
end;
until ch=#27;
close(f);
end.



 

