(* funcs3.pas for Lithp 3.0a2 *)
(* (c) 1989 Marc Ewing        *)
(* functions Q through Z      *)

unit funcsqz;

interface
uses listaux;

function do_top(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_set_difference(AItem: ItemPointer;
                           var VariableTable: VariableTableType): ItemPointer;
function do_set_equal(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;
function do_union(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_set_exclusive_or(AItem: ItemPointer;
                             var VariableTable: VariableTableType): ItemPointer;
function do_subsetp(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_set(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_room(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_terpri(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_read(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_static(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_scope(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_variable_list(AItem: ItemPointer;
                          var VariableTable: VariableTableType): ItemPointer;
function do_symbol_function(AItem: ItemPointer;
                            var VariableTable: VariableTableType): ItemPointer;
function do_symbol_macro(AItem: ItemPointer;
                         var VariableTable: VariableTableType): ItemPointer;
function do_symbol_value(AItem: ItemPointer;
                         var VariableTable: VariableTableType): ItemPointer;
function do_symbol_plist(AItem: ItemPointer;
                         var VariableTable: VariableTableType): ItemPointer;
function do_rplacd(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_rplaca(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_remove(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_reverse(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_return(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_random(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_stringp(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_ratiop(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_rational(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;
function do_symbolp(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_string(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_sin(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_sqrt(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_sqr(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_zerop(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_truncate(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;
function do_round(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_remprop(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_setf(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

implementation
uses evaluate,lithpaux,evalfuns,listio;

function do_top(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  begin (* top *)
    writeln('*** RETURN TO TOP LEVEL');
    do_top:=Nil;
    GTop:=True;
    GProgGo:=False;
    GProgReturn:=False
  end; (* top *)

function do_set_difference(AItem: ItemPointer;
                           var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* set-difference *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_set_difference:=errorloop('TOO FEW ARGS TO SET-DIFFERENCE',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_set_difference:=errorloop('BAD ARG TO SET-DIFFERENCE:',
                          BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    if not(islist(temp1)) then
      begin
        do_set_difference:=errorloop('BAD ARG TO SET-DIFFERENCE:',
                          BItem^.Car,AItem,VariableTable);
        exit
      end;
    do_set_difference:=intersection(temp1,temp2,False);
  end; (* set-difference *)

function do_set_equal(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3,temp4: ItemPointer;

  begin (* set-equal *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_set_equal:=errorloop('TOO FEW ARGS TO SET-EQUAL',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_set_equal:=errorloop('BAD ARG TO SET-EQUAL:',
                          BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    if not(islist(temp1)) then
      begin
        do_set_equal:=errorloop('BAD ARG TO SET-EQUAL:',
                          BItem^.Car,AItem,VariableTable);
        exit
      end;
    temp3:=intersection(temp1,temp2,False);
    temp4:=intersection(temp2,temp1,False);
    if (notornull(temp3) and notornull(temp4)) then
      do_set_equal:=truesymbol
    else
      do_set_equal:=Nil;
  end; (* set-equal *)

function do_union(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* union *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_union:=errorloop('TOO FEW ARGS TO UNION',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_union:=errorloop('BAD ARG TO UNION:',
                          BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    if not(islist(temp1)) then
      begin
        do_union:=errorloop('BAD ARG TO UNION:',
                          BItem^.Car,AItem,VariableTable);
        exit
      end;
    do_union:=union(temp1,temp2,True);
  end; (* union *)

function do_set_exclusive_or(AItem: ItemPointer;
                             var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* set-exclusive-or *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_set_exclusive_or:=errorloop('TOO FEW ARGS TO SET-EXCLUSIVE-OR',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_set_exclusive_or:=errorloop('BAD ARG TO SET-EXCLUSIVE-OR:',
                          BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    if not(islist(temp1)) then
      begin
        do_set_exclusive_or:=errorloop('BAD ARG TO SET-EXCLUSIVE-OR:',
                          BItem^.Car,AItem,VariableTable);
        exit
      end;
    do_set_exclusive_or:=union(temp1,temp2,False);
  end; (* set-exclusive-or *)

function do_subsetp(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* subsetp *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_subsetp:=errorloop('TOO FEW ARGS TO SUBSETP',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_subsetp:=errorloop('BAD ARG TO SUBSETP:',
                          BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    if not(islist(temp1)) then
      begin
        do_subsetp:=errorloop('BAD ARG TO SUBSETP:',
                          BItem^.Car,AItem,VariableTable);
        exit
      end;
    temp3:=Nil;
    if subset(temp1,temp2,False) then
      temp3:=truesymbol;
    do_subsetp:=temp3;
  end; (* subsetp *)

function do_set(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* set *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_set:=errorloop('TOO FEW ARGS TO SET',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not isvsymbol(temp1) then
      begin
        do_set:=errorloop('ARGUMENT MUST BE A SYMBOL:',
                         BItem^.Car,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    setq(temp1^.Symbol,temp2,VariableTable);
    do_set:=temp2;
  end; (* set *)

function do_room(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  var
    x: integer;

  begin (* room *)
    write('There are ');
    writeln(memavail:7,' bytes available');
    x:=numberconscells;
    writeln('There are ',x,' cons cells in use.');
    do_room:=Nil;
  end; (* room *)

function do_terpri(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* terpri *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) then
      begin
        writeln(output);
        do_terpri:=Nil;
        exit
      end;
    Temp1:=eval(BItem^.Car,VariableTable);
    if (temp1^.Itemtype=FileI) then
      if (GFileTable[temp1^.thefile].status=openo) then
        begin
          writeln(GFileTable[temp1^.thefile].thefile^);
          do_terpri:=Nil;
          exit
        end
      else
        begin
          (* file not open for writing *)
          do_terpri:=errorloop('FILE NOT OPEN FOR OUTPUT:',
                           temp1,AItem,VariableTable);
          exit
        end
    else
      begin
        do_terpri:=errorloop('BAD ARG TO TERPRI:',
                         temp1,AItem,VariableTable);
        exit
      end
  end; (* terpri *)

function do_read(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* read *)
    BItem:=AItem^.Cdr;
    if (BItem<>Nil) then
      begin
        temp1:=eval(Bitem^.car,VariableTable);
        if (temp1^.Itemtype=FileI) and
           (GFileTable[temp1^.thefile].status=openi) then
          readitem(temp2,true,GFileTable[temp1^.thefile].thefile^)
        else
          begin
            (* file not open for reading *)
            do_read:=errorloop('FILE NOT OPEN FOR READING:',
                             temp1,AItem,VariableTable);
            exit
          end
      end
    else
      readitem(Temp2,false,input);
    do_read:=Temp2;
  end; (* read *)

function do_static(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  begin
    GScope:=Static;
    do_static:=truesymbol;
  end;

function do_scope(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    temp1: ItemPointer;

  begin
    newitem(temp1);
    temp1^.ItemType:=SymbolI;
    if GScope=Static then
      temp1^.Symbol:='STATIC'
    else
      temp1^.Symbol:='DYNAMIC';
    do_scope:=temp1;
  end;

function do_variable_list(AItem: ItemPointer;
                          var VariableTable: VariableTableType): ItemPointer;

  begin (* variable-list *)
    do_variable_list:=dovariablelist(VariableTable,true,Nil);
  end; (* variable-list *)

function do_symbol_function(AItem: ItemPointer;
                            var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;
    ftemp: FunctionStackType;

  begin (* symbol-function *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_symbol_function:=errorloop('NO ARG TO SYMBOL-FUNCTION',
                         Nil,AItem,VariableTable);
        exit
      end;
    Temp1:=eval(BItem^.Car,VariableTable);
    if not(isvsymbol(temp1)) then
      begin
        do_symbol_function:=errorloop('ARG NOT A SYMBOL',
                         BItem^.Car,AItem,VariableTable);
        exit
      end;
    ftemp:=isdefinedfunction(Temp1^.Symbol,FunctionStack);
    if ftemp=Nil then
      do_symbol_function:=Nil
    else
      do_symbol_function:=ftemp^.LambdaList;
  end; (* symbol-function *)

function do_symbol_macro(AItem: ItemPointer;
                         var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;
    ftemp: FunctionStackType;

  begin (* symbol-macro *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_symbol_macro:=errorloop('NO ARG TO SYMBOL-MACRO',
                         Nil,AItem,VariableTable);
        exit
      end;
    Temp1:=eval(BItem^.Car,VariableTable);
    if not(isvsymbol(temp1)) then
      begin
        do_symbol_macro:=errorloop('ARG NOT A SYMBOL',
                         BItem^.Car,AItem,VariableTable);
        exit
      end;
    ftemp:=isdefinedfunction(Temp1^.Symbol,MacroStack);
    if ftemp=Nil then
      do_symbol_macro:=Nil
    else
      do_symbol_macro:=ftemp^.LambdaList;
  end; (* symbol-macro *)

function do_symbol_value(AItem: ItemPointer;
                         var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* symbol-value *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_symbol_value:=errorloop('NO ARG TO SYMBOL-VALUE',
                         Nil,AItem,VariableTable);
        exit
      end;
    Temp1:=eval(BItem^.Car,VariableTable);
    if not(isvsymbol(temp1)) then
      begin
        do_symbol_value:=errorloop('ARG NOT A SYMBOL',
                         BItem^.Car,AItem,VariableTable);
        exit
      end;
    do_symbol_value:=eval(temp1,VariableTable);
  end; (* symbol-value *)

function do_symbol_plist(AItem: ItemPointer;
                         var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;
    stemp: VariablePointer;

  begin (* symbol-plist *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_symbol_plist:=errorloop('NO ARG TO SYMBOL-PLIST',
                         Nil,AItem,VariableTable);
        exit
      end;
    Temp1:=eval(BItem^.Car,VariableTable);
    if not(isvsymbol(temp1)) then
      begin
        do_symbol_plist:=errorloop('ARG NOT A SYMBOL',
                         BItem^.Car,AItem,VariableTable);
        exit
      end;
    stemp:=isdefinedsymbol(temp1^.Symbol,VariableTable);
    if stemp<>Nil then
      do_symbol_plist:=stemp^.PropList
    else
      do_symbol_plist:=Nil;
  end; (* symbol-plist *)

function do_rplacd(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* rplacd *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_rplacd:=errorloop('TOO FEW ARGS TO RPLACD',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if isatom(temp1) then
      begin
        do_rplacd:=errorloop('ARG MUST BE A LIST',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_rplacd:=errorloop('ARG MUST BE A LIST',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1^.Cdr:=temp2;
    do_rplacd:=temp1;
  end; (* rplacd *)

function do_rplaca(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* rplaca *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_rplaca:=errorloop('TOO FEW ARGS TO RPLACA',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if isatom(temp1) then
      begin
        do_rplaca:=errorloop('ARG MUST BE A LIST',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    temp1^.Car:=temp2;
    do_rplaca:=temp1;
  end; (* rplaca *)

function do_remove(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* remove *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_remove:=errorloop('TOO FEW ARGS TO REMOVE',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_remove:=errorloop('ARG MUST BE A LIST:',
                         BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    temp3:=copyitem(temp2);
    do_remove:=delete(temp1,temp2);
  end; (* remove *)

function do_reverse(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* reverse *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_reverse:=errorloop('NO ARG TO REVERSE',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not(islist(temp1)) then
      begin
        do_reverse:=errorloop('ARG MUST BE A LIST:',
                         BItem^.Car,AItem,VariableTable);
        exit
      end;
    temp2:=copyitem(temp1);
    reverse(temp2);
    do_reverse:=temp2;
  end; (* reverse *)

function do_return(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* return *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_return:=errorloop('NO ARG TO RETURN',
                         Nil,AItem,VariableTable);
        exit
      end;
    GProgReturn:=True;
    do_return:=eval(BItem^.Car,VariableTable);
  end; (* return *)

function do_random(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    temp2: ItemPointer;

  begin (* random *)
    newitem(temp2);
    temp2^.ItemType:=FloatI;
    str(random,temp2^.Symbol);
    do_random:=temp2;
  end; (* random *)

function do_stringp(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* stringp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_stringp:=errorloop('NO ARG TO STRINGP',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    temp1:=nil;
    if (temp2<>Nil) and (temp2^.ItemType=StringI) then
      temp1:=truesymbol;
    do_stringp:=temp1;
  end; (* stringp *)

function do_ratiop(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* ratiop *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_ratiop:=errorloop('NO ARG TO RATIOP',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    temp1:=nil;
    if (temp2<>Nil) and (temp2^.ItemType=RatioI) then
      temp1:=truesymbol;
    do_ratiop:=temp1;
  end; (* ratiop *)

function do_rational(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* rational *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_rational:=errorloop('NO ARG TO RATIONAL',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    temp1:=nil;
    if (temp2<>Nil) and
       (temp2^.ItemType in [RatioI,IntegerI]) then
      temp1:=truesymbol;
    do_rational:=temp1;
  end; (* rational *)

function do_symbolp(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* symbolp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_symbolp:=errorloop('NO ARG TO SYMBOLP',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    temp1:=nil;
    if issymbol(temp2) then
      temp1:=truesymbol;
    do_symbolp:=temp1;
  end; (* symbolp *)

function do_string(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* string *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_string:=errorloop('NO ARG TO STRING',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    temp1:=truesymbol;
    temp1^.ItemType:=StringI;
    if notornull(temp2) then
      temp1^.TheString:='NIL'
    else
      if islist(temp2) then
        temp1^.TheString:=''
      else
        case temp2^.ItemType of
          StringI: temp1^.TheString:=temp2^.TheString;
          SymbolI: temp1^.TheString:=temp2^.symbol;
          IntegerI: str(temp2^.TheInteger,temp1^.TheString);
          FloatI: str(temp2^.Float,temp1^.TheString);
          RatioI: begin
                    str(temp2^.Ratio.Num,temp3^.TheString);
                    temp1^.TheString:=temp3^.TheString+'/';
                    str(temp2^.Ratio.Den,temp3^.TheString);
                    temp1^.TheString:=temp1^.TheString+
                                      temp3^.TheString
                  end
        end; (* case *)
    do_string:=temp1;
  end; (* string *)

function do_sin(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp2: ItemPointer;

  begin (* sin *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_sin:=errorloop('NO ARG TO SIN',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not isnumber(temp2) then
      begin
        do_sin:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_sin:=sine(temp2);
  end; (* sin *)

function do_sqrt(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp2: ItemPointer;

  begin (* sqrt *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_sqrt:=errorloop('NO ARG TO SQRT',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not isnumber(temp2) then
      begin
        do_sqrt:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_sqrt:=sqrrt(temp2);
  end; (* sqrt *)

function do_sqr(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp2: ItemPointer;

  begin (* sqr *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_sqr:=errorloop('NO ARG TO SQR',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not isnumber(temp2) then
      begin
        do_sqr:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_sqr:=mult(temp2,temp2);
  end; (* sqr *)

function do_zerop(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* zerop *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_zerop:=errorloop('NO ARG TO ZEROP',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not isnumber(temp2) then
      begin
        do_zerop:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1:=Nil;
    if iszero(temp2) then
      temp1:=truesymbol;
    do_zerop:=temp1;
  end; (* zerop *)

function do_truncate(AItem: ItemPointer;
                     var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp2: ItemPointer;

  begin (* truncate *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_truncate:=errorloop('NO ARG TO TRUNCATE',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not isnumber(temp2) then
      begin
        do_truncate:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_truncate:=trnc(temp2);
  end; (* truncate *)

function do_round(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp2: ItemPointer;

  begin (* round *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_round:=errorloop('NO ARG TO ROUND',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not isnumber(temp2) then
      begin
        do_round:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_round:=doround(temp2);
  end; (* round *)

function do_remprop(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;
    stemp: VariablePointer;

  begin (* remprop *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_remprop:=errorloop('TOO FEW ARGS TO REMPROP',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not isvsymbol(temp1) then
      begin
        do_remprop:=errorloop('ARG NOT A VALID SYMBOL',
                         BItem^.Car,AItem,VariableTable);
        exit
      end;
    stemp:=isdefinedsymbol(temp1^.Symbol,VariableTable);
    if stemp=Nil then
      do_remprop:=Nil
    else
      begin
        temp1:=stemp^.PropList;
        if temp1=Nil then
          do_remprop:=Nil
        else
          begin
            temp2:=eval(BItem^.Cdr^.Car,VariableTable);
            if not issymbol(temp2) then
              begin
                do_remprop:=errorloop('ARG NOT A SYMBOL',
                                 BItem^.Cdr^.Car,AItem,VariableTable);
                exit
              end;
            if temp1^.Car^.Symbol=temp2^.Symbol then
              begin
                stemp^.PropList:=temp1^.Cdr^.Cdr;
                do_remprop:=temp1^.Cdr^.Car
              end
            else
              begin
                while (temp1^.Cdr<>Nil) and (temp1^.Cdr^.Car^.Symbol<>temp2^.Symbol) do
                  temp1:=temp1^.Cdr;
                if temp1^.Cdr=Nil then
                  do_remprop:=Nil
                else
                  begin
                    do_remprop:=temp1^.Cdr^.Cdr^.Car;
                    temp1^.Cdr:=temp1^.Cdr^.Cdr^.Cdr
                  end
              end
          end
      end;
  end; (* remprop *)

function do_setf(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* setf *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_setf:=errorloop('TOO FEW ARGS TO SETF',
                         Nil,AItem,VariableTable);
        exit
      end;
    do_setf:=dosetf(AItem,VariableTable);
  end;

end. (* unit funcsqz *)
