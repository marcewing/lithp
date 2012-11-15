(* funcs1.pas for Lithp 3.0a2 *)
(* (c) 1989 Marc Ewing        *)
(* functions A through K      *)

unit funcsak;

interface
uses listaux;

function do_eval(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_dynamic(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_function_list(AItem: ItemPointer;
                          var VariableTable: VariableTableType): ItemPointer;
function do_exit(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_error(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_continue(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;
function do_evalstack(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;
function do_flushmem(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;
function do_debug_level(AItem: ItemPointer;
                        var VariableTable: VariableTableType): ItemPointer;
function do_gc(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;
function do_if(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;
function do_adjoin(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_eof(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_close(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_intersection(AItem: ItemPointer;
                         var VariableTable: VariableTableType): ItemPointer;
function do_distinctp(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;
function do_int_char(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;
function do_char_int(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;
function do_boundp(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_butlast(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_break(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_copy(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_cos(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_arctan(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_abs(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_exp(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_floatp(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_integerp(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;
function do_evenp(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_floor(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_ceiling(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_denominator(AItem: ItemPointer;
                        var VariableTable: VariableTableType): ItemPointer;
function do_gcd(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_defun(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_get(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_getf(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_consp(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_defmacro(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;
function do_and(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_concat_symbol(AItem: ItemPointer;
                          var VariableTable: VariableTableType): ItemPointer;
function do_concat(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_funcall(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_copy_list(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;
function do_go(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;
function do_case(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_delete(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_assoc(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_apply(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_do(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;

implementation
uses evaluate,lithpaux,evalfuns,listio;

function do_eval(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* eval *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_eval:=errorloop('NO ARGUMENT TO EVAL',Nil,AItem,VariableTable);
        exit
      end;
    do_eval:=eval(eval(BItem^.Car,VariableTable),VariableTable);
  end; (* eval *)

function do_dynamic(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  begin
    GScope:=Dynamic;
    do_dynamic:=truesymbol;
  end;

function do_function_list(AItem: ItemPointer;
                          var VariableTable: VariableTableType): ItemPointer;

  begin (* function-list *)
    do_function_list:=dofunctionlist(FunctionStack);
  end; (* function-list *)

function do_exit(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  begin (* exit *)
    if AItem^.Cdr=Nil then
      do_exit:=Nil
    else
      do_exit:=eval(AItem^.Cdr^.Car,VariableTable);
    GExit:=True;
  end; (* exit *)

function do_error(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  begin (* error *)
    if GDebugLevel<1 then
      writeln('*** NOT IN DEBUG LOOP')
    else
      displayerrormessage(GErrorStack^.S,GErrorStack^.Item1,
                          GErrorStack^.Item2);
    do_error:=Nil;
  end; (* error *)

function do_continue(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;

  begin (* continue *)
    if GDebugLevel<1 then
      begin
        writeln('*** NOT IN DEBUG LOOP');
        do_continue:=Nil
      end
    else
      begin
        write('*** CONTINUE TO EVALUATE: ');
        writeitem(GErrorStack^.Item2,output);
        writeln;
        do_continue:=eval(GErrorStack^.Item2,VariableTable);
        GExit:=True
      end;
  end; (* continue *)

function do_evalstack(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;
    x: integer;
    TempEvalStack: EvalStackType;

  begin (* evalstack *)
    BItem:=AItem^.Cdr;
    TempEvalStack:=GEvalStack^.Next;
    if TempEvalStack=Nil then
      writeln('*** EVAL STACK IS EMPTY')
    else
      begin
        x:=TempEvalStack^.Level;
        if BItem<>Nil then
          begin
            temp1:=eval(BItem^.Car,VariableTable);
            if isint(temp1) then
              x:=temp1^.theInteger
          end;
        while (TempEvalStack<>Nil) and (x>0) do
          begin
            write('LEVEL ',TempEvalStack^.Level:2,': ');
            writeitem(TempEvalStack^.Item,output);
            writeln;
            dec(x);
            TempEvalStack:=TempEvalStack^.Next
          end
      end;
    do_evalstack:=Nil;
  end; (* evalstack *)

function do_flushmem(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;

  begin (* flushmem *)
    flushmem;     (* GTop gets set to True in flush code *)
    GProgGo:=False;
    GProgReturn:=False;
    writeln('*** HEAP FLUSHED');
    do_flushmem:=Nil;
  end; (* flushmem *)

function do_debug_level(AItem: ItemPointer;
                        var VariableTable: VariableTableType): ItemPointer;

  var
    temp1: ItemPointer;

  begin (* debug-level *)
    newitem(temp1);
    temp1^.ItemType:=IntegerI;
    temp1^.theInteger:=GDebugLevel;
    do_debug_level:=temp1;
  end; (* debug-level *)

function do_gc(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;
    x: integer;

  begin (* gc *)
    BItem:=AItem^.Cdr;
    temp1:=Nil;
    if BItem<>Nil then
      temp1:=eval(BItem^.Car,VariableTable);
    if (GDebugLevel>0) and (BItem=Nil) then
      begin
        writeln('*** IN DEBUG: TEMPORARY VARIABLES COULD BE LOST');
        writeln('*** TO FORCE GC USE: (GC <NON-NIL VALUE>)');
        do_gc:=Nil;
        exit
      end;
    if (not notornull(temp1)) or (GDebugLevel<1) then
      begin
        x:=gc(VariableTable);
        writeln(x,' cons cells were recovered.')
      end;
    do_gc:=Nil;
  end; (* gc *)

function do_if(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* if *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) or (BItem^.Cdr^.Cdr=Nil) then
      begin
        do_if:=errorloop('TOO FEW ARGS TO IF:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not(notornull(temp1)) then
      do_if:=eval(BItem^.Cdr^.Car,VariableTable)
    else
      do_if:=eval(BItem^.Cdr^.Cdr^.Car,VariableTable);
  end; (* if *)

function do_adjoin(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* adjoin *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_adjoin:=errorloop('TOO FEW ARGS TO ADJOIN:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_adjoin:=errorloop('BAD ARG TO ADJOIN:',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp3:=member(temp1,temp2,False);
    if temp3=Nil then
      begin
        newitem(temp3);
        temp3^.ItemType:=ConsI;
        temp3^.Car:=temp1;
        temp3^.Cdr:=temp2;
        do_adjoin:=temp3
      end
    else
      do_adjoin:=temp2;
  end; (* adjoin *)

function do_eof(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* eof *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) then
      begin
        do_eof:=errorloop('TOO FEW ARGS TO EOF:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if temp1^.itemtype<>FileI then
      begin
        do_eof:=errorloop('BAD ARG TO EOF:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    if GFileTable[temp1^.theFile].thefile=Nil then
      begin
        do_eof:=errorloop('FILE NOT OPEN:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    if eof(GFileTable[temp1^.theFile].thefile^) then
      do_eof:=truesymbol
    else
      do_eof:=Nil;
  end; (* eof *)

function do_close(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* close! *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) then
      begin
        do_close:=errorloop('TOO FEW ARGS TO CLOSE:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if temp1^.itemtype<>FileI then
      begin
        do_close:=errorloop('BAD ARG TO CLOSE:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    if GFileTable[temp1^.theFile].thefile=Nil then
      begin
        do_close:=errorloop('FILE NOT OPEN:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    {$I-}
    close(GFileTable[temp1^.theFile].thefile^);
    {$I+}
    if ioresult<>0 then
      begin
        do_close:=errorloop('UNABLE TO CLOSE FILE:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    GFileTable[temp1^.theFile].thefile:=Nil;
    GFileTable[temp1^.theFile].fn:='CLOSED';
    GFileTable[temp1^.theFile].status:=closed;
    do_close:=temp1;
  end; (* close *)

function do_intersection(AItem: ItemPointer;
                         var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* intersection *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_intersection:=errorloop('TOO FEW ARGS TO INTERSECTION:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_intersection:=errorloop('BAD ARG TO INTERSECTION:',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    if not(islist(temp1)) then
      begin
        do_intersection:=errorloop('BAD ARG TO INTERSECTION:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_intersection:=intersection(temp1,temp2,True);
  end; (* intersection *)

function do_distinctp(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* distinctp *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_distinctp:=errorloop('TOO FEW ARGS TO DISTINCTP:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_distinctp:=errorloop('BAD ARG TO DISTINCTP:',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    if not(islist(temp1)) then
      begin
        do_distinctp:=errorloop('BAD ARG TO DISTINCTP:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp3:=Nil;
    if subset(temp1,temp2,True) then
      temp3:=truesymbol;
    do_distinctp:=temp3;
  end; (* distinctp *)

function do_int_char(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* int-char *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_int_char:=errorloop('NO ARG TO INT-CHAR:',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not(isint(temp1)) then
      begin
        do_int_char:=errorloop('BAD ARG TO INT-CHAR:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp2);
    temp2^.ItemType:=StringI;
    temp2^.theString:=chr(temp1^.theInteger);
    do_int_char:=temp2;
  end; (* int-char *)

function do_char_int(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* char-int *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_char_int:=errorloop('NO ARG TO CHAR-INT:',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if (temp1=Nil) or (temp1^.ItemType<>StringI) then
      begin
        do_char_int:=errorloop('BAD ARG TO CHAR-INT:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp2);
    temp2^.ItemType:=IntegerI;
    temp2^.theInteger:=ord(temp1^.theString[1]);
    do_char_int:=temp2;
  end; (* char-int *)

function do_boundp(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;
    stemp: VariablePointer;

  begin (* boundp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_boundp:=errorloop('NO ARG TO BOUNDP:',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not issymbol(temp1) then
      begin
        do_boundp:=errorloop('BAD ARG TO BOUNDP:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    stemp:=isdefinedsymbol(temp1^.Symbol,VariableTable);
    if stemp<>Nil then
      do_boundp:=truesymbol
    else
      do_boundp:=Nil;
  end; (* boundp *)

function do_butlast(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* butlast *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_butlast:=errorloop('NO ARG TO BUTLAST:',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not(islist(temp1)) then
      begin
        do_butlast:=errorloop('BAD ARG TO BUTLAST:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp2:=copyitem(temp1);
    if (temp2=Nil) or (temp2^.Cdr=Nil) then
      do_butlast:=Nil
    else
      begin
        temp1:=temp2;
        while temp1^.Cdr^.Cdr<>Nil do
          temp1:=temp1^.Cdr;
        temp1^.Cdr:=Nil;
        do_butlast:=temp2
      end;
  end; (* butlast *)

function do_break(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* break *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) or (BItem^.Cdr^.Cdr=Nil) then
      begin
        do_break:=errorloop('TOO FEW ARGS TO BREAK:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    temp3:=eval(BItem^.Cdr^.Cdr^.Car,VariableTable);
    if (temp1=Nil) or (temp1^.ItemType<>StringI) then
      begin
        do_break:=errorloop('BAD ARG TO BREAK:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_break:=errorloop(temp1^.theString,temp2,temp3,VariableTable);
  end; (* break *)

function do_copy(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3,temp4: ItemPointer;

  begin (* copy *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) or (BItem^.Cdr^.Cdr=Nil) then
      begin
        do_copy:=errorloop('TOO FEW ARGS TO BREAK:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    temp3:=eval(BItem^.Cdr^.Cdr^.Car,VariableTable);
    if (temp1=Nil) or (temp1^.ItemType<>StringI) then
      begin
        do_copy:=errorloop('BAD ARG TO BREAK:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    if not isint(temp2) then
      begin
        do_copy:=errorloop('BAD ARG TO BREAK:',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    if not isint(temp3) then
      begin
        do_copy:=errorloop('BAD ARG TO BREAK:',BItem^.Cdr^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp4);
    temp4^.ItemType:=StringI;
    temp4^.theString:=copy(temp1^.theString,
                           getint(temp2),getint(temp3));
    do_copy:=temp4;
  end; (* copy *)

function do_cos(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp2: ItemPointer;

  begin (* cos *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_cos:=errorloop('NO ARG TO COS',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isnumber(temp2)) then
      begin
        do_cos:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_cos:=cosine(temp2);
  end; (* cos *)

function do_arctan(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp2: ItemPointer;

  begin (* arctan *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_arctan:=errorloop('NO ARG TO ARCTAN',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isnumber(temp2)) then
      begin
        do_arctan:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_arctan:=arctn(temp2);
  end; (* arctan *)

function do_abs(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp2: ItemPointer;

  begin (* abs *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_abs:=errorloop('NO ARG TO ABS',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isnumber(temp2)) then
      begin
        do_abs:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_abs:=absol(temp2);
  end; (* abs *)

function do_exp(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp2: ItemPointer;

  begin (* exp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_exp:=errorloop('NO ARG TO EXP',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isnumber(temp2)) then
      begin
        do_exp:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_exp:=expon(temp2);
  end; (* exp *)

function do_floatp(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* floatp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_floatp:=errorloop('NO ARG TO FLOATP',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    temp1:=nil;
    if isfloat(temp2) then
      temp1:=truesymbol;
    do_floatp:=temp1;
  end; (* floatp *)

function do_integerp(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* integerp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_integerp:=errorloop('NO ARG TO INTEGERP',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    temp1:=nil;
    if isint(temp2) then
      temp1:=truesymbol;
    do_integerp:=temp1;
  end; (* integerp *)

function do_evenp(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* evenp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_evenp:=errorloop('NO ARG TO EVENP',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isint(temp2)) then
      begin
        do_evenp:=errorloop('ARG NOT AN INTEGER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1:=Nil;
    if evenp(temp2) then
      temp1:=truesymbol;
    do_evenp:=temp1;
  end; (* evenp *)

function do_floor(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* floor *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_floor:=errorloop('NO ARG TO FLOOR',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isnumber(temp2)) then
      begin
        do_floor:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1:=trnc(temp2);
    if minusp(temp1) then
      temp1^.theInteger:=temp1^.theInteger-1;
    do_floor:=temp1;
  end; (* floor *)

function do_ceiling(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* ceiling *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_ceiling:=errorloop('NO ARG TO CEILING',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isnumber(temp2)) then
      begin
        do_ceiling:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1:=trnc(temp2);
    if plusp(temp1) then
      temp1^.theInteger:=temp1^.theInteger+1;
    do_ceiling:=temp1;
  end; (* ceiling *)

function do_denominator(AItem: ItemPointer;
                        var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* denominator *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_denominator:=errorloop('NO ARG TO DENOMINATOR',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isratio(temp2)) then
      begin
        do_denominator:=errorloop('ARG MUST BE A RATIO',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    reduce(temp2^.Ratio);
    newitem(temp1);
    temp1^.ItemType:=IntegerI;
    temp1^.theInteger:=temp2^.Ratio.den;
    do_denominator:=temp1;
  end; (* denominator *)

function do_gcd(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* gcd *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_gcd:=errorloop('TOO FEW ARGS TO EVENP',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not(isint(temp1)) then
      begin
        do_gcd:=errorloop('ARG NOT AN INTEGER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(isint(temp1)) then
      begin
        do_gcd:=errorloop('ARG NOT AN INTEGER',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp3);
    temp3^.ItemType:=IntegerI;
    temp3^.theInteger:=gcd(temp1^.theInteger,temp2^.theInteger);
    do_gcd:=temp3;
  end; (* gcd *)

function do_defun(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* defun *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) or (BItem^.Cdr^.Cdr=Nil) then
      begin
        do_defun:=errorloop('TOO FEW ARGS TO DEFUN',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=BItem^.Car;
    if not(isvsymbol(temp1)) then
      begin
        do_defun:=errorloop('NOT A VALID SYMBOL',temp1,
                         AItem,VariableTable);
        exit
      end;
    do_defun:=defun(AItem,FunctionStack,VariableTable);
  end; (* defun *)

function do_get(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;
    stemp: VariablePointer;

  begin (* get *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_get:=errorloop('TOO FEW ARGS TO GET',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not(isvsymbol(temp1)) then
      begin
        do_get:=errorloop('NOT A VALID SYMBOL',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    stemp:=isdefinedsymbol(temp1^.Symbol,VariableTable);
    if stemp=Nil then
      begin
        do_get:=errorloop('UNBOUND SYMBOL',temp1,
                         AItem,VariableTable);
        exit
      end
    else
      begin
        temp2:=eval(BItem^.Cdr^.Car,VariableTable);
        if not(issymbol(temp2)) then
          begin
            do_get:=errorloop('PROPERTY MUST BE A SYMBOL',BItem^.Cdr^.Car,
                             AItem,VariableTable);
            exit
          end;
        temp2:=propmember(stemp^.PropList,temp2^.Symbol);
        if temp2=Nil then
          do_get:=Nil
        else
          do_get:=temp2^.Cdr^.Car
      end;
  end; (* get *)

function do_getf(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* getf *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_getf:=errorloop('TOO FEW ARGS TO GETF',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(issymbol(temp2)) then
      begin
        do_getf:=errorloop('PROPERTY MUST BE A SYMBOL',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not(islist(temp1)) then
      begin
        do_getf:=errorloop('NOT A VALID PROPERTY LIST',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1:=propmember(temp1,temp2^.Symbol);
    if temp1=Nil then
      do_getf:=Nil
    else
      do_getf:=temp1^.Cdr^.Car;
  end; (* getf *)

function do_consp(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* consp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_consp:=errorloop('NO ARG TO CONSP',Nil,
                         AItem,VariableTable);
        exit
      end;
    Temp1:=eval(BItem^.Car,VariableTable);
    if (not(notornull(AItem))) and (AItem^.ItemType=ConsI) then
      do_consp:=truesymbol
    else
      do_consp:=Nil;
  end; (* consp *)

function do_defmacro(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* defmacro *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) or (BItem^.Cdr^.Cdr=Nil) then
      begin
        do_defmacro:=errorloop('TOO FEW ARGS TO DEFMACRO',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=BItem^.Car;
    if not(isvsymbol(temp1)) then
      begin
        do_defmacro:=errorloop('NOT A VALID SYMBOL',temp1,
                         AItem,VariableTable);
        exit
      end;
    do_defmacro:=defun(AItem,MacroStack,VariableTable);
  end; (* defmacro *)

function do_and(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* and *)
    BItem:=AItem^.Cdr;
    temp1:=truesymbol;
    while (not(notornull(temp1))) and (BItem<>Nil) do
      begin
        temp1:=eval(BItem^.Car,VariableTable);
        BItem:=BItem^.Cdr
      end;
    do_and:=temp1;
  end; (* and *)

function do_concat_symbol(AItem: ItemPointer;
                          var VariableTable: VariableTableType): ItemPointer;

  label
    EndFunc;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* concat-symbol *) (* concats symbols *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_concat_symbol:=errorloop('NO ARGS TO CONCAT-SYMBOL',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=truesymbol;
    temp1^.Symbol:='';
    while BItem<>Nil do
      begin
        temp2:=eval(BItem^.Car,VariableTable);
        if not(issymbol(temp2)) then
          begin
            do_concat_symbol:=errorloop('ARG NOT A SYMBOL',BItem^.Car,
                             AItem,VariableTable);
            goto EndFunc
          end;
        temp1^.Symbol:=temp1^.Symbol+temp2^.Symbol;
        BItem:=BItem^.Cdr
      end;
    do_concat_symbol:=temp1;
    EndFunc:
  end; (* concat-symbol *)

function do_concat(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  label
    EndFunc;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* concat *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_concat:=errorloop('NO ARGS TO CONCAT',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=truesymbol;
    temp1^.ItemType:=StringI;
    temp1^.theString:='';
    while BItem<>Nil do
      begin
        temp2:=eval(BItem^.Car,VariableTable);
        if not((temp2<>Nil) and (temp2^.ItemType=StringI)) then
          begin
            do_concat:=errorloop('ARG NOT A STRING',BItem^.Car,
                             AItem,VariableTable);
            goto EndFunc
          end;
        temp1^.theString:=concat(temp1^.theString,temp2^.theString);
        BItem:=BItem^.Cdr
      end;
    do_concat:=temp1;
    EndFunc:
  end; (* concat *)

function do_funcall(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* funcall *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_funcall:=errorloop('NO ARGS TO FUNCALL',Nil,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp1);
    temp1^.ItemType:=ConsI;
    temp1^.Car:=eval(BItem^.Car,VariableTable);
    temp1^.Cdr:=copyitem(BItem^.Cdr);
    do_funcall:=eval(temp1,VariableTable);
  end; (* funcall *)

function do_copy_list(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* copy-list *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_copy_list:=errorloop('NO ARG TO COPY-LIST',Nil,
                         AItem,VariableTable);
        exit
      end;
    do_copy_list:=copyitem(eval(BItem^.Car,VariableTable));
  end; (* copy-list *)

function do_go(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* go *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_go:=errorloop('NO ARG TO GO',Nil,
                         AItem,VariableTable);
        exit
      end;
    if not issymbol(BItem^.Car) then
      begin
        do_go:=errorloop('ARG NOT A SYMBOL',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_go:=BItem^.Car;
    GProgGo:=True;
  end; (* go *)

function do_case(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  label
    EndFunc;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;
    found: boolean;

  begin (* case *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_case:=errorloop('TOO FEW ARGS TO CASE',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    BItem:=BItem^.Cdr;
    found:=False;
    while (BItem<>Nil) and not(found) do
      begin
        temp2:=BItem^.Car;
        if isatom(temp2) then
          begin
            do_case:=errorloop('BAD FORM TO CASE',temp2,
                             AItem,VariableTable);
            goto EndFunc
          end;
        temp3:=temp2^.Car;
        if isatom(temp3) then
          if (issymbol(temp3) and (temp3^.Symbol='OTHERWISE')) then
            begin
              found:=True;
              temp2:=temp2^.Cdr;
              while temp2<>Nil do
                begin
                  temp3:=eval(temp2^.Car,VariableTable);
                  temp2:=temp2^.Cdr
                end
            end
          else
            begin
              do_case:=errorloop('BAD FORM KEYLIST',temp3,
                               AItem,VariableTable);
              goto EndFunc
            end;
        if not(notornull(member(temp1,temp3,False))) then
          begin
            found:=True;
            temp2:=temp2^.Cdr;
            while temp2<>Nil do
              begin
                temp3:=eval(temp2^.Car,VariableTable);
                temp2:=temp2^.Cdr
              end
          end;
        BItem:=BItem^.Cdr
      end;
    if not(found) then
      do_case:=Nil
    else
      do_case:=temp3;
    EndFunc:
  end; (* case *)

function do_delete(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* delete *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_delete:=errorloop('TOO FEW ARGS TO DELETE',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_delete:=errorloop('ARG NOT A LIST',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_delete:=delete(temp1,temp2);
  end; (* delete *)

function do_assoc(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;
    found: boolean;

  begin (* assoc *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_assoc:=errorloop('TOO FEW ARGS TO ASSOC',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_assoc:=errorloop('BAD ASSOC LIST',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    found:=False;
    while (temp2<>Nil) and not(found) do
      begin
        if not isatom(temp2^.Car) then
          found:=eql(temp1,temp2^.Car^.Car);
        if not found then
          temp2:=temp2^.Cdr;
      end;
    if not found then
      do_assoc:=Nil
    else
      do_assoc:=temp2^.Car;
  end; (* assoc *)

function do_apply(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* apply *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_apply:=errorloop('NO ARG TO APPLY',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=Nil;
    if BItem^.Cdr<>Nil then
      begin
        temp2:=eval(BItem^.Cdr^.Car,VariableTable);
        if not(islist(temp2)) then
          begin
            do_apply:=errorloop('BAD ARGUMENT LIST',BItem^.Cdr^.Car,
                             AItem,VariableTable);
            exit
          end
      end;
    temp3:=apply(temp1,temp2);
    do_apply:=eval(temp3,VariableTable);
  end; (* apply *)

function do_do(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* do *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_do:=errorloop('NO ARG TO DO',Nil,
                         AItem,VariableTable);
        exit
      end;
    if not islist(BItem^.Car) then
      begin
        do_do:=errorloop('BAD VARIABLE LIST TO DO',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    if BItem^.Cdr=Nil then
      begin
        do_do:=Nil;
        exit
      end;
    do_do:=dodo(AItem,VariableTable);
  end; (* do *)

end. (* unit funcsak *)
