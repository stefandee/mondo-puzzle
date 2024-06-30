program get_font;

uses graph,crt,pcxr;
const xl=16;
      yl=36;
type buf=array[1..xl,1..yl] of byte;
     pbuf=^buf;
var  drv,drvm,x,y,size,i,j:integer;
     ch:char;
     f:file of byte;
     img:buf;
     b:byte;

Begin

drv:=installuserdriver('svga256',nil);
initgraph(drv,drvm,'c:\bin\tp7\bgi');
readpcx('font18p.pcx');
{new(p);}
x:=0;
y:=0;
assign(f,'font18.spr');
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
      {size:=imagesize(x+1,y+1,x+xl-1,y+yl-1);
      getimage(x+1,y+1,x+xl-1,y+yl-1,p^);}
      for j:=y+1 to y+yl-1 do
      for i:=x+1 to x+xl-1 do
           begin
              b:=getpixel(i,j);
              write(f,b);
           end;
      end;

end;
until ch=#27;
close(f);
end.





