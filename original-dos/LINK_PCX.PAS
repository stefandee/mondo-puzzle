program link;
{used to link .pcx files to a global file to run with puzzle}
{link only 241 X 162 files}
type    topscore = record
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

var work:index;
    imgs,imgd:file;
    fi:file of index;
    lst:text;
    namefis:string;
    i:integer;
    zone:array[1..60000] of byte;
begin
assign(fi,'index.spr');rewrite(fi);
assign(imgd,'images.spr');rewrite(imgd,1);
assign(lst,'list.txt');reset(lst);
assign(imgs,'targets.spr');
reset(imgs,1);
blockread(imgs,zone,filesize(imgs));
blockwrite(imgd,zone,filesize(imgs));
close(imgs);
{se pune la inceput toata grafica
pe care prog o foloseste:sagetile,
sigla,palete de culoare}
assign(imgs,'c_wings0.pcx');
reset(imgs,1);
blockread(imgs,zone,filesize(imgs));
blockwrite(imgd,zone,filesize(imgs));
close(imgs);
assign(imgs,'c_erde.pcx');
reset(imgs,1);
blockread(imgs,zone,filesize(imgs));
blockwrite(imgd,zone,filesize(imgs));
close(imgs);

repeat
readln(lst,namefis);
assign(imgs,namefis);
reset(imgs,1);
write('fisier : ',namefis,' ');readln(work.name);
work.size:=filesize(imgs);
work.posit:=filepos(imgd);
for i:=1 to 5 do with work.top86[i] do
                      begin
                      name:='phane';
                      time:=60*59+59;
                      moves:=60;
                      end;
for i:=1 to 5 do with work.top43[i] do
                      begin
                      name:='phane';
                      time:=60*9+59;
                      moves:=10;
                      end;

write(fi,work);
blockread(imgs,zone,filesize(imgs));
blockwrite(imgd,zone,filesize(imgs));
close(imgs);
until eof(lst);
close(imgd);
close(lst);

end.


