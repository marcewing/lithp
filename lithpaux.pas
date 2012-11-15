unit lithpaux;

interface
uses listaux;

type
  EvalStackType= ^EvalType;
  EvalType= record
              Next: EvalStackType;
              Item: ItemPointer;
              Level: integer
            end;

  ErrorStackType= ^ErrorType;
  ErrorType= record
               Next: ErrorStackType;
               S: string;
               Item1,Item2: ItemPointer
             end;

  filestatustype= (openi,openo,closed);
  FilePtr= ^text;
  FileTableType= array[0..47] of record
                                   thefile: FilePtr;
                                   status: filestatustype;
                                   fn: stringtype
                                 end;

var
  GFileTable: FileTableType;
  GEvalStack: EvalStackType;
  GErrorStack: ErrorStackType;
  GExit,GTop: boolean;
  GDebugLevel: integer;

procedure displayerrormessage(s: string;item1,item2: ItemPointer);
function errorloop(ErrorS: string; ErrorItem1,ErrorItem2: ItemPointer;
                   VarTab: VariableTableType): ItemPointer;
function readevalprint(VarTab: VariableTableType): ItemPointer;

implementation
uses evaluate,listio;

const
  CleanUpSize= 20000; (* between evals, if mem<CleanUpSize, gc *)

procedure initfiletable(var FT: FileTableType);

  var
    x: byte;

  begin (* initfiletable *)
    for x:=0 to 47 do
      GFileTable[x].thefile:=Nil
  end; (* initfiletable *)

{$F+}  (* force far call for procedure variable *)

procedure markstuff;

  var
    etemp: EvalStackType;
    errtemp: ErrorStackType;

  begin (* markstuff *)
    etemp:=GEvalStack;
    while etemp<>Nil do
      begin
        markcons(etemp^.Item);
        etemp:=etemp^.Next
      end;
    errtemp:=GErrorStack;
    while errtemp<>Nil do
      begin
        markcons(errtemp^.Item1);
        markcons(errtemp^.Item2);
        errtemp:=errtemp^.Next
      end
  end; (* markstuff *)

procedure initstuff;

  begin (* initstuff *)
    GEvalStack:=Nil;
    GErrorStack:=Nil;
    initfiletable(GFileTable)
  end; (* initstuff *)

procedure flushstuff;

  var
    x: integer;

  begin (* flushstuff *)
    GTop:=True;
    for x:=0 to 47 do
      if (GFileTable[x].thefile<>Nil) and
         (GFileTable[x].status<>closed) then
        close(GFileTable[x].thefile^)
  end; (* flushstuff *)

{$F-}  (* end force far call *)

function readevalprint(VarTab: VariableTableType): ItemPointer;

  var
    item1,item2: ItemPointer;
    x: integer;

  begin (* readevalprint *)
    repeat
      item1:=Nil;
      readitem(item1,false,input);
      item2:=eval(Item1,VarTab);
      if GTop or GExit then
        GTop:=False
      else
        begin
          writeitem(item2,output);
          writeln
        end;
      if memavail<CleanUpSize then
        begin
          x:=gc(VarTab);
          writeln(x:7,' cons cells were recovered')
        end
    until GExit=True;
    readevalprint:=item2
  end; (* readevalprint *)

procedure displayerrormessage(s: string; item1,item2: ItemPointer);

  begin (* displayerrormessage *)
    writeln('*** ERROR: ',s);
    write('*** ');
    writeitem(item1,output);
    writeln;
    writeln('*** CODE TO RE-EVALUATE:');
    write('*** ');
    writeitem(item2,output);
    writeln
  end; (* displayerrormessage *)

function errorloop(ErrorS: string; ErrorItem1,ErrorItem2: ItemPointer;
                   VarTab: VariableTableType): ItemPointer;

  var
    item3,item4: ItemPointer;
    x: integer;

  procedure pusherror(S: string; Item1,Item2: ItemPointer);

    var
      t: ErrorStackType;

    begin (* pusherror.errorloop *)
      new(t);
      t^.S:=S;
      t^.Item1:=Item1;
      t^.Item2:=Item2;
      t^.Next:=GErrorStack;
      GErrorStack:=t
    end; (* pusherror.errorloop *)

  procedure poperror(S: string; Item1,Item2: ItemPointer);

    var
      t: ErrorStackType;

    begin (* poperror.errorloop *)
      t:=GErrorStack;
      GErrorStack:=GErrorStack^.Next;
      dispose(t)
    end; (* poperror.errorloop *)

  begin (* errorloop *)
    if not GTop then
      begin
        displayerrormessage(ErrorS,ErrorItem1,ErrorItem2);
        pusherror(ErrorS,ErrorItem1,ErrorItem2);
        inc(GDebugLevel);
        repeat
          item3:=Nil;
          readitem(item3,false,input);
          item4:=eval(Item3,VarTab);
          if not(GExit or GTop) then
            begin
              writeitem(item4,output);
              writeln
            end
        until GExit or GTop;
        GExit:=False;
        dec(GDebugLevel);
        poperror(ErrorS,ErrorItem1,ErrorItem2);
        errorloop:=item4
      end
    else
      errorloop:=Nil
  end; (* errorloop *)

begin
  prog_mark:=markstuff;
  prog_init:=initstuff;
  prog_flush:=flushstuff;

  GDebugLevel:=0;
  GExit:=False;
  GTop:=False;

  initstuff
end. (* unit lithpaux *)