program link_mouse_sprite;
var fs,fd:file;
    zone:array[1..66] of byte;
begin
assign(fs,'hand.ms');
reset(fs,1);
blockread(fs,zone,66);
close(fs);
assign(fd,'images.spr');
reset(fd,1);
seek(fd,filesize(fd)+1);
blockwrite(fd,zone,66);
close(fd);
end.

