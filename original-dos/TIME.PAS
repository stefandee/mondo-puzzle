gettime(hi,mi,si,s1i);
timei:=hi*3600+mi*60+si;
repeat
if keypressed then begin
                   dels;
                   goto mnu;
                   end;
gettime(hi,mi,si,s1i);
time:=hi*3600+mi*60+si;
until time-timei>6;
