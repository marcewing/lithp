program lithp(input,output);

(*      V 3.0a2     *)
(*    (c) 1989 by   *)
(*    Marc Ewing    *)

(*$M 65520,0,655360 *) (* max stack size - 65520 *)

uses lithpaux,listaux;  (* <-- Order IS IMPORTANT *)

var
  item1: ItemPointer;

begin
  writeln('Lithp V3.0a2  --  A Lisp interpreter with a speech impediment');
  writeln('(c) 1989 Marc Ewing');

  GExit:=False;
  GTop:=False;

  item1:=readevalprint(GVariableTable);
  writeln('-- Bye! --')
end.