Unit Mhandler;

interface
{$F+}

uses dos;

const COM1INTR = $0C;
      COM1PORT = $3F8;

var bytenum : word;
    combytes : array[0..2] of byte;
    xm, ym : longint;
    button1, button2 : boolean;
    MouseHandler : procedure;

procedure MyMouseHandler; Interrupt;
procedure InitMyDriver;
procedure CleanUpMyDriver;

implementation
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

The bytenum variable is used to keep track of which byte is expected next
(ie 0, 1 or 2). The combytes variable is simply an array to keep track of
bytes received so far. The mouse position will be stored in the x and y
varaibles (note that this example will not perfrom any range checking).
Button1 and button2 will be used to store the states of each of the buttons.
MouseHandler will be used to store the normal mouse driver event handler.
We'll need it to reset everything once we are finished.

Here's the actual handler:

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
}
procedure MyMouseHandler;
var dx, dy : integer;
var inbyte : byte;
begin

  { Get the port byte }
  inbyte := Port[COM1PORT];

  { Make sure we are properly "synched" }
  if (inbyte and 64) = 64 then bytenum := 0;

  { Store the byte and adjust bytenum }
  combytes[bytenum] := inbyte;
  inc(bytenum);

  { Have we received all 3 bytes? }
  if bytenum = 3 then
    begin
      { Yes, so process them }
      dx := (combytes[0] and 3) shl 6 + combytes[1];
      dy := (combytes[0] and 12) shl 4 + combytes[2];
      if dx >= 128 then dx := dx - 256;
      if dy >= 128 then dy := dy - 256;
      xm := xm + dx;
      if xm>319 then xm:=319;
      if xm<0 then xm:=0;
      ym := ym + dy;
      if ym>199 then ym:=199;
      if ym<0 then ym:=0;

      button1 := (combytes[0] And 32) <> 0;
      button2 := (combytes[0] And 16) <> 0;

      { And start on first byte again }
      bytenum := 0;
    end;

  { Acknowledge the interrupt }
  Port[$20] := $20;
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸

Once again pretty simple stuff. We just read the byte from the com1 port and
figure out if it's time to do anything yet. If bit 6 is set to 1 then we
know that it's meant to be the first byte of the 3, so we reset our
bytenum variable to zero (in a perfect world bytes would always come in 3's
and we would never need to check, but it never hurts to be careful).

When 3 bytes have been received we simple decode them according to the
diagram above and update the appropriate variables accordingly.

The 'Port[$20] := $20;' command just lets the interrupt controller know we
have processed the interrupt so it can send us the next one when it wants to.

Note that the above "handler" does nothing more than keep track of the
current mouse position and button states. If we were writing a proper mouse
driver for an SVGA game we would also have to write custom cursor routines.
I'll leave that bit to you!

To actually install our mouse driver we'll have to set up all the variables,
save the address of the current mouse handler and install our own. We'll
also need call the existing mouse driver to set up the COM1 port to make
sure it sends us the mouse bytes as it receives them. We could do this
ourselves, but why make life harder than it already is?

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
}
procedure InitMyDriver;
begin

  { Initialize the normal mouse handler }
  asm
    mov ax, 0
    int $33
  end;

  { Initialize some of the variables we'll be using }
  bytenum := 0;
  xm := 0;
  ym := 0;
  button1 := false;
  button2 := false;

  { Save the current mouse handler and set up our own }
  GetIntVec(COM1INTR, @MouseHandler);
  SetIntVec(COM1INTR, Addr(MyMouseHandler));
end;
{컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴켸


And finally when our program is finished it'll need to clean up after
itself and return control back to the normal mouse driver:

컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴컴커
}
procedure CleanUpMyDriver;
begin
  SetIntVec(COM1INTR, @MouseHandler);
end;

begin
end.