unit game;

interface

uses graph,crt,pcx,dos;

type buf=array[1..25,1..25] of byte;
     pbuf=^buf;
     topscore = record
                 name:string[10];
                 time:word;
                 moves:word;
                 end;
     toparr=array[1..5] of topscore;
     index = record
           name:string[20];
           size:longint;
           posit:longint;
           top86:toparr;
           top43:toparr;
           end;


const   nplaces=32;
        xl=18;
        yl=18;
        cursc=50;

var  drv,drvm,work:integer;
     ppos:integer;
     ch:char;
     f:file;
     arrowu:pbuf;
     arrowd:pbuf;
     arrowr:pbuf;
     arrowl:pbuf;
     diff:byte;
     a,stepx,stepy,sx,sy:integer;
     places:array[1..nplaces,1..3] of integer;
     puz:array[1..6,1..8] of integer;
     h1,m1,s1,s11:word;
     timepass,t1,t2:longint;
     mnv1,mnv2:string;
     moves:longint;
     ind:integer;
     textdir:byte;
     msgc:integer;


function is_end:boolean;
procedure chose;
procedure mix;
procedure init;
procedure upScroll(x,y,l:integer);
procedure downScroll(x,y,l:integer);
procedure leftScroll(x,y:integer);
procedure rightScroll(x,y:integer);
procedure title;
procedure hiscore;

implementation


procedure fadeaway(speed:byte);

var reg:registers;
    i,j:integer;
    orig_pal:paltype;

begin
orig_pal:=palette256;
for i:=1 to 256 do
    for j:=1 to 3 do
        begin
             palette256[i,j]:=palette256[i,j] div 4;
        end;
for i:=1 to 64 div speed do
    begin
    for j:=1 to 256 do
        begin
             if palette256[j,1]>speed-1 then begin
                                       dec(palette256[j,1],speed);
                                       {setrgbpalette(j-1,palette256[j,1],palette256[j,2],palette256[j,3]);}
                                       end;
             if palette256[j,2]>speed-1 then begin
                                       dec(palette256[j,2],speed);
                                       {setrgbpalette(j-1,palette256[j,1],palette256[j,2],palette256[j,3]);}
                                       end;
             if palette256[j,3]>speed-1 then begin
                                       dec(palette256[j,3],speed);
                                       {setrgbpalette(j-1,palette256[j,1],palette256[j,2],palette256[j,3]);}
                                       end;

        end;
    Reg.ah := $10;
    Reg.al := $12;
    Reg.bx := 0;
    Reg.cx := 256;
    Reg.dx := ofs (Palette256);
    Reg.es := seg (Palette256);
    intr ($10, Reg);
    delay(90);
    end;
palette256:=orig_pal;
end;

procedure hiscore;

const nplace:array[1..5] of string[3]=('1st','2nd','3rd','4th','5th');

var findex:file of index;
    image:index;
    mnv1,mnv2:string;
    i,j,nr:integer;
    top:toparr;

begin

fadeaway(3);
cleardevice;
setrgbpalette(black,0,0,0);
setrgbpalette(cursc,63,63,63);
assign(findex,'index.spr');reset(findex);
seek(findex,ind-1);
read(findex,image);
case diff of
1:top:=image.top86;
2:top:=image.top43;
end;
for i:=1 to 5 do
    if top[i].time>timepass then begin
                                       for j:=5 downto i+1 do
                                       top[j]:=top[j-1];
                                       top[i].time:=timepass;
                                       top[i].moves:=moves;
                                       settextstyle(0,0,0);
                                       setfillstyle(1,black);
                                       setcolor(cursc);
                                       outtextxy(getmaxx div 2-textwidth('M')*8,100,'ENTER YOUR NAME :');
                                       nr:=0;
                                       top[i].name:='';
                                       repeat
                                       if keypressed then begin
                                                          ch:=readkey;
                                                          if (ch=#8) and (nr>0) then
                                                          begin
                                                          delete(top[i].name,nr,1);
                                                          setfillstyle(1,black);
                                                          bar(getmaxx div 2-textwidth('M')*5,110+textheight('M'),
                                                          getmaxx div 2+textwidth('M')*5,130+2*textheight('M'));
                                                          setcolor(cursc);
                                                          outtextxy(getmaxx div 2-textwidth('M')*5,
                                                                   110+textheight('M'),top[i].name);
                                                          dec(nr);
                                                          end;
                                                          if (' '<=ch) and (ch<'z') then
                                                          if nr<10 then
                                                          begin
                                                          setfillstyle(1,black);
                                                          bar(getmaxx div 2-textwidth('M')*5,110+textheight('M'),
                                                          getmaxx div 2+textwidth('M')*5,130+2*textheight('M'));
                                                          setcolor(cursc);
                                                          top[i].name:=top[i].name+ch;
                                                          outtextxy(getmaxx div 2-textwidth('M')*5,
                                                                   110+textheight('M'),top[i].name);
                                                          inc(nr);
                                                          end;{if nr}
                                                          end{if key}
                                                     else ch:=#0;
                                       until ch=#13;
                                       for i:=63 downto 0 do setrgbpalette(cursc,i,i,i);
                                       cleardevice;
                                       {fadeaway(4);
                                       cleardevice;}
                                       seek(findex,filepos(findex)-1);
                                       case diff of
                                       1:image.top86:=top;
                                       2:image.top43:=top;
                                       end;
                                       write(findex,image);
                                       break;
                                       end;
close(findex);
posit:=image.posit;
size:=image.size;
readpcx('images.spr');
settextstyle(0,0,0);
setcolor(cursc);
outtextxy(getmaxx div 2-textwidth('M')*(length(image.name) div 2),0,image.name);
case diff of
1:outtextxy(getmaxx div 2-textwidth('M')*13,textheight('M'),'TOP SCORERS ( 4X3 TABLE )');
2:outtextxy(getmaxx div 2-textwidth('M')*13,textheight('M'),'TOP SCORERS ( 8X6 TABLE )');
end;
for i:=1 to 5 do
    with image do
         begin
         if top[i].time div 60<10 then begin
                                         str(top[i].time div 60,mnv1);
                                         mnv1:='0'+mnv1;
                                         end      {minute}
                                    else str(top[i].time div 60,mnv1);
         if top[i].time mod 60<10 then begin
                                         str(top[i].time mod 60,mnv2);
                                         mnv2:='0'+mnv2;
                                         end      {secunde}
                                    else str(top[i].time mod 60,mnv2);

         mnv1:=mnv1+':'+mnv2+' (';
         str(top[i].moves,mnv2);
         mnv1:=mnv1+mnv2+' moves)';
         mnv1:=nplace[i]+' '+top[i].name+' '+mnv1;
         outtextxy(getmaxx div 2-textwidth('M')*(length(mnv1) div 2),(i+2)*(textheight('M')+10),mnv1);
         end;

repeat until readkey=#13;

end;

procedure init;
var i,j:integer;
begin
assign(f,'images.spr');
new(arrowu);new(arrowd);new(arrowl);new(arrowr);
reset(f,1);blockread(f,arrowr^,512);
blockread(f,arrowl^,512);
blockread(f,arrowd^,512);
blockread(f,arrowu^,512);
close(f);
ppos:=26;
timepass:=0;t1:=0;t2:=0;moves:=0;
case diff of
2 : begin
    stepx:=(xmax-xmin+1) div 8;stepy:=(ymax-ymin+1) div 6;
    sx:=8;sy:=6;
    for i:=1 to 8 do
        begin
        places[i,1]:=xdep+(i-1)*((xmax-xmin+1) div 8);
        places[i,2]:=0;
        places[i,3]:=1;
        putimage(places[i,1],places[i,2],arrowu^,normalput);
        end;
    for i:=1 to 6 do
        begin
        places[i+8,2]:=ydep+(i-1)*((ymax-ymin+1) div 6);
        places[i+8,1]:=320-xl-5;
        places[i+8,3]:=2;
        putimage(places[i+8,1],places[i+8,2],arrowr^,normalput);
        end;
    for i:=1 to 8 do
        begin
        places[23-i,1]:=xdep+(i-1)*((xmax-xmin+1) div 8);
        places[23-i,2]:=200-yl;
        places[23-i,3]:=3;
        putimage(places[23-i,1],places[23-i,2],arrowd^,normalput);
        end;
    for i:=1 to 6 do
        begin
        places[29-i,2]:=ydep+(i-1)*((ymax-ymin+1) div 6);
        places[29-i,1]:=5;
        places[29-i,3]:=4;
        putimage(places[29-i,1],places[29-i,2],arrowl^,normalput);
        end;
   a:=28;for i:=1 to 6 do for j:=1 to 8 do puz[i,j]:=(i-1)*8+j;
   end;
1: begin
    stepx:=(xmax-xmin+1) div 4;stepy:=(ymax-ymin+1) div 3;
    sx:=4;sy:=3;
    for i:=1 to 4 do
        begin
        places[i,1]:=xdep+(i-1)*((xmax-xmin+1) div 4);
        places[i,2]:=0;
        places[i,3]:=1;
        putimage(places[i,1],places[i,2],arrowu^,normalput);
        end;
    for i:=1 to 3 do
        begin
        places[i+4,2]:=ydep+(i-1)*((ymax-ymin+1) div 3);
        places[i+4,1]:=320-xl-5;
        places[i+4,3]:=2;
        putimage(places[i+4,1],places[i+4,2],arrowr^,normalput);
        end;
    for i:=1 to 4 do
        begin
        places[12-i,1]:=xdep+(i-1)*((xmax-xmin+1) div 4);
        places[12-i,2]:=200-yl;
        places[12-i,3]:=3;
        putimage(places[12-i,1],places[12-i,2],arrowd^,normalput);
        end;
    for i:=1 to 3 do
        begin
        places[15-i,2]:=ydep+(i-1)*((ymax-ymin+1) div 3);
        places[15-i,1]:=5;
        places[15-i,3]:=4;
        putimage(places[15-i,1],places[15-i,2],arrowl^,normalput);
        end;
   a:=14;for i:=1 to 3 do for j:=1 to 4 do puz[i,j]:=(i-1)*4+j;
   end;

end;


end;

procedure moveo(var sursa, dest; count:word);
begin
asm
mov dx,ds;
lds si,sursa;
les di,dest;
mov cx,count;
shr cx,1;
cld;
rep movsw;
jnc @sfarsit;
movsb;
@sfarsit:mov ds,dx;
end;
end;

procedure moved(var sursa, dest; count:word);
begin
asm
mov dx,ds;
lds si,sursa;
les di,dest;
mov cx,count;
shr cx,1;
std;
rep movsw;
jnc @sfarsit;
movsb;
@sfarsit:mov ds,dx;
end;
end;


procedure upScroll(x,y,l:integer);
var line:array[1..100] of byte;
    i:integer;
    scr:array[0..199,0..319] of byte absolute $a000:0;

begin
moveo(scr[y,x],line,l);
for i:=y to ymax+y-1 do moveo(scr[i+1,x],scr[i,x],l);
moveo(line,scr[y+ymax,x],l);
end;

procedure downScroll(x,y,l:integer);
var line:array[1..100] of byte;
    i:integer;
    scr:array[0..199,0..319] of byte absolute $a000:0;
begin
moveo(scr[y,x],line,l);
for i:=y downto ydep do moveo(scr[i-1,x],scr[i,x],l);
moveo(line,scr[y-ymax,x],l);
end;

procedure leftScroll(x,y:integer);
var line:array[1..100] of byte;
    i:integer;
    scr:array[0..199,0..319] of byte absolute $a000:0;
begin
for i:=y to y+stepy-1 do
    begin
    line[i-y+1]:=scr[i,x];
    moveo(scr[i,x+1],scr[i,x],xmax-1);
    scr[i,x+xmax-1]:=line[i-y+1];
    end;
end;

procedure rightScroll(x,y:integer);
var line:array[1..100] of byte;
    i:integer;
    scr:array[0..199,0..319] of byte absolute $a000:0;
begin
for i:=y to y+stepy-1 do
    begin
    line[i-y+1]:=scr[i,x-1];
    moved(scr[i,x-3],scr[i,x-2],xmax);
    scr[i,x-xmax]:=line[i-y+1];
    end;
end;

procedure appear;
begin
{asm
Reg.ah := $10;
Reg.al := $12;
Reg.bx := 0;
Reg.cx := 255;
Reg.dx := ofs (Palette256);
Reg.es := seg (Palette256);
intr ($10, Reg);
end;}
end;



procedure mix;

var i,j,rnd:integer;

begin

randomize;{do you want the same mix all the time !?}
for j:=1 to 25 do
    begin
         rnd:=random(a-1)+1;
         case places[rnd,3] of
         1:begin
                for i:=1 to stepy do upscroll(places[rnd,1],ydep,stepx);
                work:=puz[1,rnd];
                for i:=1 to sy-1 do puz[i,rnd]:=puz[i+1,rnd];
                puz[sy,rnd]:=work;
           end;
         3:begin
                for i:=1 to stepy do downscroll(places[rnd,1],ydep+ymax,stepx);
                work:=puz[sy,2*sx+sy+1-rnd];
                for i:=sy downto 2 do puz[i,2*sx+sy+1-rnd]:=puz[i-1,2*sx+sy+1-rnd];
                puz[1,2*sx+sy+1-rnd]:=work;
           end;
         2:begin
                for i:=1 to stepx do rightscroll(xdep+xmax,places[rnd,2]);
                work:=puz[rnd-sx,sx];
                for i:=sx downto 2 do puz[rnd-sx,i]:=puz[rnd-sx,i-1];
                puz[rnd-sx,1]:=work;

                {work:=puz[rnd-sx,1];
                for i:=1 to sx-1 do puz[rnd-sx,i]:=puz[rnd-sx,i+1];
                puz[rnd-sx,sx]:=work;}
           end;
         4:begin
                for i:=1 to stepx do leftscroll(xdep,places[rnd,2]);
                work:=puz[2*(sx+sy)+1-rnd,1];
                for i:=1 to sx-1 do puz[2*(sx+sy)+1-rnd,i]:=puz[2*(sx+sy)+1-rnd,i+1];
                puz[2*(sx+sy)+1-rnd,sx]:=work;

                {work:=puz[2*(sx+sy)+1-rnd,sx];
                for i:=sx downto 2 do puz[2*(sx+sy)+1-rnd,i]:=puz[2*(sx+sy)+1-rnd,i-1];
                puz[2*(sx+sy)+1-rnd,1]:=work;}
           end;

         end;{end case : mixing!}
    end;{for j:randomize for!}
end;{end mix proc}

function is_end:boolean;
var i,j : integer;
begin
is_end:=false;
for i:=1 to sy do for j:=1 to sx do if puz[i,j]<>(i-1)*sx+j then exit;
is_end:=true;
end;


procedure title;
var  wos:array[1..140,1..170] of byte;
     reg:registers;
     i,j:integer;
begin
assign(f,'images.spr');
reset(f,1);
seek(f,2048+32);{search for W.O.S. title}
blockread(f,palette256,768);
Reg.ah := $10;
Reg.al := $12;
Reg.bx := 0;
Reg.cx := 255;
Reg.dx := ofs (Palette256);
Reg.es := seg (Palette256);
intr ($10, Reg);
blockread(f,wos,23800);
for i:=1 to 140 do moveo(wos[i,1],scr[i+20,(getmaxx div 2)-85],170);
repeat until readkey=#13;
end;

procedure movew(var sursa,dest;count:word);
begin
asm
mov dx,ds;
lds si,sursa;
les di,dest;
mov cx,count;
mov bx,0;
@again:
mov al,ds:[si+bx];
cmp al,0;
je @pas;
mov es:[di+bx],al;
@pas:inc bx;
loop @again;
mov ds,dx;
end;
end;

procedure usefont1(x,y:integer;s:string);
{autodesk mixare de palete : se salveaza paleta pt erde.gif;
se incarca font18.gif;se incarca paleta salvata ;se salveaza
imaginea font18}
const letters:string='ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!''+()- .,/;:';
type spr=array[0..1000] of byte;
var i,j,k:integer;
    f:file;
    xm,ym:word;
    letter:spr;
begin
assign(f,'font.spr');
reset(f,525);
xm:=15;ym:=35;
if textdir=1 then x:=x-xm*(length(s) div 2);
for i:=1 to length(s) do
    begin
         for k:=1 to length(letters) do
         if s[i]=letters[k] then
         begin
         seek(f,k-1);
         blockread(f,letter,1);
         for j:=1 to ym do movew(letter[(j-1)*xm],scr[y+j,x+(i-1)*xm],xm);
         break;
         end;
         {putimage(x+(i-1)*16,y,letter^,0);}
    end;
close(f);
end;

procedure chose;

const dx=120;
      dy=40;
      msgm=48;
      msg:array[1..msgm] of string=('Level is setted to 4X3 grid','Level is setted to 8X6 grid',
      'Are you leaving already ?!','Is DOS so attractive ?','Welcome to Mondo-Puzzle !',
      'Use up/down arrow to move cursor','Spc or Enter to select','T to choose dificulty level',
      'Esc to quit this great game.','While you''re playing ','use left/right arrows to move',
      'the target and Enter/Spc','to drag picture.','Or you''ll use the mouse ','and left button mouse.',
      'Mouse should not work ','if you have a SVGA monitor ','and a mouse driver like GMOUSE.COM,',
      'I mean you won''t be able to move','the target more than half of screen',
      'That''s Wings Of Sorrow''s new creation','W.O.S. is Phane','I made this zoft in 6 days',
      'Between 20.04.1995 and 4.05.1995','I hope you''ll enjoy this game','although it doesn''t have',
      'background music but if...','(there are some ifs),my friends','will bring me the MOD file format',
      ' the next version will have ','some great music and also','another puzzle game,more complicated',
      'and also the computer will solve ','the puzzle.',
      'If you want to work with me','or you have any suggestion ','please send mail to 1900 Timisoara','Camin 7C',
      'for W.O.S. and I''ll be grateful ','all my life long.','Send my digital greetings to','First,to my parents',
      'as they helped my to buy the computer','then to all my friends','from all the corners of the universe',
      'If you still watch this screen','I BEG YOU TO START THE GAME','else I will start it !');

var  image:index;
     findex:file of index;
     imglist:array[1..100] of string;
     mind:integer;
     gnd:pbuf;
     {msgc:word;}
     time,timei:longint;
     hi,mi,si,s1i:word;

label is_chose;

begin

fadeaway(3);
cleardevice;
posit:=2048+13106;
size:=35788;
readpcx('images.spr');
textdir:=1;
usefont1(getmaxx div 2,0,'MONDO+PUZZLE');
assign(findex,'index.spr');reset(findex);
ind:=1;
setcolor(215);settextstyle(0,0,0);

repeat
read(findex,image);
outtextxy(dx+10,dy+ind*textheight('>'),image.name);
inc(ind);
until eof(findex);

mind:=ind-1;
ind:=1;
diff:=1;
msgc:=5;
new(gnd);
getimage(dx,ind*textheight('>')+dy,dx+textwidth('>'),(ind+1)*textheight('>')+dy,gnd^);
outtextxy(dx,ind*textheight('>')+dy,'>');
timei:=0;


repeat
if keypressed then ch:=readkey
              else ch:=#0;

case upcase(ch) of
#80 : begin
      putimage(dx,ind*textheight('>')+dy,gnd^,normalput);
      inc(ind);
      if ind>mind then ind:=1;
      getimage(dx,ind*textheight('>')+dy,dx+textwidth('>'),(ind+1)*textheight('>')+dy,gnd^);
      setcolor(215);
      outtextxy(dx,dy+ind*textheight('>'),'>');
      end;
#72 : begin
      putimage(dx,ind*textheight('>')+dy,gnd^,normalput);
      dec(ind);
      if ind<1 then ind:=mind;
      getimage(dx,ind*textheight('>')+dy,dx+textwidth('>'),(ind+1)*textheight('>')+dy,gnd^);
      setcolor(215);
      outtextxy(dx,dy+ind*textheight('>'),'>');
      end;
#32,#13 : begin
      fadeaway(3);
      cleardevice;
      seek(findex,ind-1);
      read(findex,image);
      posit:=image.posit;
      size:=image.size;
      readpcx('images.spr');
      close(findex);
      dispose(gnd);
      goto is_chose;
      end;
#27 : begin
      msgc:=random(2)+3;
      setfillstyle(1,black);
      bar(0,180,319,199);
      outtextxy(160-(textwidth('M') div 2)*length(msg[msgc]),194-textheight('g'),msg[msgc]);
      fadeaway(1);
      cleardevice;
      closegraph;
      clrscr;
      writeln('Thanx for playing MONDO-PUZZLE');
      write('Until we meet again...');
      halt;
      end;
'T' : begin
      inc(diff);
      if diff>2 then diff:=1;
      setfillstyle(1,black);
      bar(0,180,319,199);
      setcolor(215);
      case diff of
      1:outtextxy(160-(textwidth('M') div 2)*length(msg[diff]),194-textheight('g'),msg[diff]);
      2:outtextxy(160-(textwidth('M') div 2)*length(msg[diff]),194-textheight('g'),msg[diff]);
      end;
      end;
end;{case}
gettime(hi,mi,si,s1i);
time:=hi*3600+mi*60+si;
if time-timei>6 then begin
                    setfillstyle(1,black);
                    bar(0,180,319,199);
                    inc(msgc);
                    if msgc>msgm then msgc:=5;{do a topscore reading}
                    outtextxy(160-(textwidth('M') div 2)*length(msg[msgc]),194-textheight('g'),msg[msgc]);
                    timei:=time;
                    end;
until (ch=#32) or (ch=#13);

is_chose:end;
end.