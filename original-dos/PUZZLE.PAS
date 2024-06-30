program puzzle;
{$M 65520,0,100000}
{using driver svga.bgi because both the targets and
targets.pcx must be used in the same graphic mode}
uses game,graph,crt,pcx,mouse,dos;
var i,j : integer;

label isend;

Begin

drv:=installuserdriver('svga256',nil);

drvm:=0;
initgraph(drv,drvm,'');
asm mov ax,$0013;
    int $10;
    end;
randomize;
posit:=2048;
size:=13106;
readpcx('images.spr');
checkbreak:=false;
repeat until readkey=#13;

repeat
chose;
init;
mix;
initmouse;

if mouse_exist then begin
                    loadshape('images.spr');
                    setshape;
                    {rect.a.x:=5;rect.a.y:=2;
                    rect.b.x:=319-5;rect.b.y:=199-5;
                    setrange(rect);
                    }
                    show;
                    end;

repeat
gettime(h1,m1,s1,s11);
t1:=3600*h1+m1*60+s1;
if (t2<>0) and (t1>t2) then begin
              timepass:=timepass+t1-t2;
              setfillstyle(1,black);
              bar(319-5*textwidth('A'),199-textheight('A'),320,200);
              if timepass div 60<10 then begin
                                         str(timepass div 60,mnv1);
                                         mnv1:='0'+mnv1;
                                         end      {minute}
                                    else str(timepass div 60,mnv1);
              if timepass mod 60<10 then begin
                                         str(timepass mod 60,mnv2);
                                         mnv2:='0'+mnv2;
                                         end      {secunde}
                                    else str(timepass mod 60,mnv2);
              settextstyle(0,0,0);
              outtextxy(319-5*textwidth('A'),199-textheight('A'),mnv1+':'+mnv2);
              {str(xm,mnv1);str(ym,mnv2);
              bar(0,0,50,10);
              outtextxy(0,0,mnv1+' '+mnv2);}
              end;

if keypressed
   then begin
         ch:=readkey;
         if ch='s'
            then
                  for i:=1 to sx do
                      for j:=1 to sy do
                          begin
                           str(puz[j,i],mnv1);
                           settextstyle(0,0,0);
                           setcolor(0);
                           outtextxy(i*10-10,j*10-10,mnv1);
                           setcolor(110);
                           outtextxy(i*10-10,j*10-10,mnv1);
                          end;
        end
   else ch:=#0;
if mouse_exist then
if leftbuttonpressed then begin
                          for j:=1 to a do
                          if (places[j,2]<y) and (places[j,2]+yl>y)
                             and (places[j,1]<x div 2) and (places[j,1]+xl>x div 2) then
                             begin
                             inc(moves);
                             case places[j,3] of
                             1 : begin
                                 hide;
                                 for i:=1 to stepy do upscroll(places[j,1],ydep,stepx);
                                 {mouse press liniile se vor misca in sus}
                                 work:=puz[1,j];
                                 for i:=1 to sy-1 do puz[i,j]:=puz[i+1,j];
                                 puz[sy,j]:=work;
                                 if is_end then begin
                                                hiscore;
                                                goto isend;
                                                end;
                                 show;
                                 break;
                                 end;{case}
                             3 : begin
                                 hide;
                                 for i:=1 to stepy do downscroll(places[j,1],ydep+ymax,stepx);
                                 work:=puz[sy,2*sx+sy+1-j];
                                 for i:=sy downto 2 do puz[i,2*sx+sy+1-j]:=puz[i-1,2*sx+sy+1-j];
                                 puz[1,2*sx+sy+1-j]:=work;
                                 if is_end then begin
                                                hiscore;
                                                goto isend;
                                                end;
                                 show;
                                 break;
                                 end;
                             2 : begin
                                 hide;
                                 for i:=1 to stepx do rightscroll(xdep+xmax,places[j,2]);
                                 work:=puz[j-sx,sx];
                                 for i:=sx downto 2 do puz[j-sx,i]:=puz[j-sx,i-1];
                                 puz[j-sx,1]:=work;
                                 if is_end then begin
                                                hiscore;
                                                goto isend;
                                                end;
                                 show;
                                 break
                                 end;
                             4 : begin
                                 hide;
                                 for i:=1 to stepx do leftscroll(xdep,places[j,2]);
                                 work:=puz[2*(sx+sy)+1-j,1];
                                 for i:=1 to sx-1 do puz[2*(sx+sy)+1-j,i]:=puz[2*(sx+sy)+1-j,i+1];
                                 puz[2*(sx+sy)+1-j,sx]:=work;
                                 if is_end then begin
                                                hiscore;
                                                goto isend;
                                                end;
                                 show;
                                 break;
                                 end;
                             end;{case}
                          end;{if 1}
                        end;

if not mouse_exist then
case ch of
#75 : begin
      setcolor(0);
      rectangle(places[ppos,1],places[ppos,2],places[ppos,1]+xl,places[ppos,2]+yl);
      dec(ppos);
      if ppos<1 then ppos:=a;
      setcolor(cursc);
      rectangle(places[ppos,1],places[ppos,2],places[ppos,1]+xl,places[ppos,2]+yl);
      end;
#77 : begin
      setcolor(0);
      rectangle(places[ppos,1],places[ppos,2],places[ppos,1]+xl,places[ppos,2]+yl);
      inc(ppos);
      if ppos>a then ppos:=1;
      setcolor(cursc);
      rectangle(places[ppos,1],places[ppos,2],places[ppos,1]+xl,places[ppos,2]+yl);
      end;
#32,#13 :
        begin
        inc(moves);
        case places[ppos,3] of
        1 : begin
        for i:=1 to stepy do upscroll(places[ppos,1],ydep,stepx);
        {liniile se vor misca in sus}
        work:=puz[1,ppos];
        for i:=1 to sy-1 do puz[i,ppos]:=puz[i+1,ppos];
        puz[sy,ppos]:=work;
        if is_end then begin
                       hiscore;
                       goto isend;
                       end;
        end;{case 1}
        3 : begin
            for i:=1 to stepy do downscroll(places[ppos,1],ydep+ymax,stepx);
            work:=puz[sy,2*sx+sy+1-ppos];
            for i:=sy downto 2 do puz[i,2*sx+sy+1-ppos]:=puz[i-1,2*sx+sy+1-ppos];
            puz[1,2*sx+sy+1-ppos]:=work;
            if is_end then begin
                           hiscore;
                           goto isend;
                           end;
            end;{case 3}
        2 : begin
            for i:=1 to stepx do rightscroll(xdep+xmax,places[ppos,2]);
            work:=puz[ppos-sx,1];
            for i:=1 to sx-1 do puz[ppos-sx,i]:=puz[ppos-sx,i+1];
            puz[ppos-sx,sx]:=work;
            if is_end then begin
                           hiscore;
                           goto isend;
                           end;
            end;{case 2}
        4 : begin
            for i:=1 to stepx do leftscroll(xdep,places[ppos,2]);
            work:=puz[2*(sx+sy)+1-ppos,sx];
            for i:=sx downto 2 do puz[2*(sx+sy)+1-ppos,i]:=puz[2*(sx+sy)+1-ppos,i-1];
            puz[2*(sx+sy)+1-ppos,1]:=work;
            if is_end then begin
                           hiscore;
                           goto isend;
                           end;
            end;{case 4}
        end;{case}
end;
end;

gettime(h1,m1,s1,s11);
t2:=3600*h1+m1*60+s1;
if t2>t1 then begin
              timepass:=timepass+t2-t1;
              setfillstyle(1,black);
              bar(319-5*textwidth('A'),199-textheight('A'),320,200);
              if timepass div 60<10 then begin
                                         str(timepass div 60,mnv1);
                                         mnv1:='0'+mnv1;
                                         end      {minute}
                                    else str(timepass div 60,mnv1);
              if timepass mod 60<10 then begin
                                         str(timepass mod 60,mnv2);
                                         mnv2:='0'+mnv2;
                                         end      {secunde}
                                    else str(timepass mod 60,mnv2);
              settextstyle(0,0,0);
              outtextxy(319-5*textwidth('A'),199-textheight('A'),mnv1+':'+mnv2);
              end;

until ch=#27;

isend:
dispose(arrowu);dispose(arrowd);dispose(arrowl);dispose(arrowr);
done;
until false

End.
