program sprite_view;
uses graph,crt;
type spr=array[1..50,1..50] of byte;
     buf=^spr;
var i,drv,drvm:integer;
    f:file;
    l1:buf;
begin
drv:=installuserdriver('svga256',nil);
drvm:=0;
initgraph(drv,drvm,'c:\bin\tp7\bgi');
assign(f,'font18.spr');
reset(f,1);
new(l1);
for i:=1 to 2 do
begin
blockread(f,l1^,640);
putimage(20*i,0,l1^,normalput);
end;

repeat until readkey=#13;
end.

