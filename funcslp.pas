(* funcs2.pas for Lithp 3.0a2 *)
(* (c) 1989 Marc Ewing        *)
(* functions L through P      *)

unit funcslp;

interface
uses listaux;

function do_load(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_member(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_length(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_list_length(AItem: ItemPointer;
                        var VariableTable: VariableTableType): ItemPointer;
function do_let(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_maplist(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_mapl(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_mapcar(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_mapc(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_macroexpand(AItem: ItemPointer;
                        var VariableTable: VariableTableType): ItemPointer;
function do_list_star(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;
function do_minusp(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_ln(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;
function do_logand(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_logior(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_lognot(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_logxor(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_logshl(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_logshr(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_last(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_macro_list(AItem: ItemPointer;
                       var VariableTable: VariableTableType): ItemPointer;
function do_print(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_prin1(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_prog1(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_prog2(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_progn(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_nconc(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_or(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;
function do_openi(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_openo(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_pairlis(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_numberp(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_nth(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_nthcdr(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_plusp(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_oddp(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_numerator(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;
function do_putprop(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_prog(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

implementation
uses evaluate,lithpaux,evalfuns,listio;

function do_load(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;
    afile: text;

  begin (* load *)
    BItem:=AItem^.Cdr;
    temp1:=eval(bitem^.car,variabletable);
    assign(afile,temp1^.theString);
    reset(afile);
    while not eof(afile) do
      begin
        readitem(temp1,true,afile);
        temp2:=eval(temp1,variabletable)
      end;
    close(afile);
    do_load:=truesymbol;
  end; (* load *)

function do_member(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;
    found: boolean;

  begin (* member *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_member:=errorloop('TOO FEW ARGS TO MEMBER',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp2)) then
      begin
        do_member:=errorloop('ARG NOT A LIST',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp3:=BItem^.Cdr^.Cdr;
    found:=False;
    if temp3<>Nil then
      begin
        temp3:=eval(temp3^.Car,VariableTable);
        found:=(temp3<>Nil) and (temp3^.Symbol='EQ')
      end;
    do_member:=member(temp1,temp2,found);
  end; (* member *)

function do_length(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;
    x: integer;

  begin (* length *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_length:=errorloop('NO ARG TO LENGTH',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    x:=0;
    if not(notornull(temp1)) then
      if temp1^.ItemType=ConsI then
        while temp1<>Nil do
          begin
            x:=x+1;
            temp1:=temp1^.Cdr
          end
      else
        if temp1^.ItemType in [SymbolI,StringI] then
          x:=length(temp1^.Symbol)
        else
          x:=1;
    newitem(temp1);
    temp1^.ItemType:=IntegerI;
    temp1^.theInteger:=x;
    do_length:=temp1;
  end; (* length *)

function do_list_length(AItem: ItemPointer;
                        var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;
    x: integer;

  begin (* list-length *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_list_length:=errorloop('NO ARG TO LIST-LENGTH',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not(islist(temp1)) then
      begin
        do_list_length:=errorloop('ARG NOT A LIST',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    x:=0;
    if not(notornull(temp1)) then
      while temp1<>Nil do
        begin
          x:=x+1;
          temp1:=temp1^.Cdr
        end;
    newitem(temp1);
    temp1^.ItemType:=IntegerI;
    temp1^.theInteger:=x;
    do_list_length:=temp1;
  end; (* list-length *)

function do_let(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* let *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_let:=errorloop('NO ARG TO LET',Nil,
                         AItem,VariableTable);
        exit
      end;
    if not islist(BItem^.Car) then
      begin
        do_let:=errorloop('BAD VARIABLE LIST TO LET',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_let:=dolet(AItem,VariableTable);
  end; (* let *)

function do_maplist(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* maplist *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_maplist:=errorloop('TOO FEW ARGS TO MAPLIST',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(AItem^.Cdr^.Car,VariableTable);
    temp2:=AItem^.Cdr^.Cdr;
    do_maplist:=domap(AItem,temp1,temp2,True,True,VariableTable);
  end; (* maplist *)

function do_mapl(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* mapl *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_mapl:=errorloop('TOO FEW ARGS TO MAPL',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(AItem^.Cdr^.Car,VariableTable);
    temp2:=AItem^.Cdr^.Cdr;
    do_mapl:=domap(AItem,temp1,temp2,True,False,VariableTable);
  end; (* mapl *)

function do_mapcar(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* mapcar *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_mapcar:=errorloop('TOO FEW ARGS TO MAPCAR',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(AItem^.Cdr^.Car,VariableTable);
    temp2:=AItem^.Cdr^.Cdr;
    do_mapcar:=domap(AItem,temp1,temp2,False,True,VariableTable);
  end; (* mapcar *)

function do_mapc(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* mapc *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_mapc:=errorloop('TOO FEW ARGS TO MAPC',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(AItem^.Cdr^.Car,VariableTable);
    temp2:=AItem^.Cdr^.Cdr;
    do_mapc:=domap(AItem,temp1,temp2,False,False,VariableTable);
  end; (* mapc *)

function do_macroexpand(AItem: ItemPointer;
                        var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;
    ftemp: FunctionStackType;

  begin (* macroexpand *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_macroexpand:=errorloop('NO ARG TO MACROEXPAND',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if (not(islist(temp2))) or (not(isvsymbol(temp2^.Car))) then
      begin
        do_macroexpand:=errorloop('NOT A VALID MACRO CALL',temp2,
                         AItem,VariableTable);
        exit
      end;
    ftemp:=isdefinedfunction(temp2^.Car^.Symbol,MacroStack);
    if ftemp=Nil then
      begin
        do_macroexpand:=errorloop('SYMBOL HAS NO MACRO DEFINITION',temp2^.Car,
                         AItem,VariableTable);
        exit
      end
    else
      begin
        temp1:=temp2^.Car;
        temp2^.Car:=ftemp^.LambdaList;
        do_macroexpand:=dolambda(temp2,VariableTable,False);
        temp2^.Car:=temp1
      end;
  end; (* macroexpand *)

function do_list_star(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3,temp4: ItemPointer;

  begin (* list* *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_list_star:=errorloop('NO ARG TO LIST*',Nil,
                         AItem,VariableTable);
        exit
      end;
    Temp2:=BItem;
    if temp2^.Cdr=Nil then
      begin
        temp1:=eval(temp2^.Car,VariableTable);
        if not(islist(temp1)) then
          begin
            do_list_star:=errorloop('LAST ARG TO LIST* NOT A LIST',temp2^.Car,
                             AItem,VariableTable);
            exit
          end
        else
          do_list_star:=temp1
      end
    else
      begin
        newitem(Temp1);
        Temp3:=Temp1;
        Temp1^.ItemType:=ConsI;
        Temp1^.Car:=eval(Temp2^.Car,VariableTable);
        Temp2:=Temp2^.Cdr;
        Temp1^.Cdr:=Nil;
        While Temp2^.Cdr<>Nil do
          begin
            newitem(Temp1^.Cdr);
            Temp1^.Cdr^.ItemType:=ConsI;
            Temp1^.Cdr^.Car:=eval(Temp2^.Car,VariableTable);
            Temp2:=Temp2^.Cdr;
            Temp1:=Temp1^.Cdr;
            Temp1^.Cdr:=Nil
          end;
        temp4:=eval(temp2^.Car,VariableTable);
        if not(islist(temp4)) then
          begin
            do_list_star:=errorloop('LAST ARG TO LIST* NOT A LIST',temp2^.Car,
                             AItem,VariableTable);
            exit
          end;
        temp1^.Cdr:=temp4;
        do_list_star:=Temp3
      end;
  end; (* list* *)

function do_minusp(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* minusp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_minusp:=errorloop('NO ARG TO MINUSP',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isnumber(temp2)) then
      begin
        do_minusp:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1:=Nil;
    if minusp(temp2) then
      temp1:=truesymbol;
    do_minusp:=temp1;
  end; (* minusp *)

function do_ln(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp2: ItemPointer;

  begin (* ln *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_ln:=errorloop('NO ARG TO LN',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isnumber(temp2)) then
      begin
        do_ln:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_ln:=nlog(temp2);
  end; (* ln *)

function do_logand(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* logand *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_logand:=errorloop('TOO FEW ARGS TO LOGAND:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(isint(temp1)) then
      begin
        do_logand:=errorloop('BAD ARG TO LOGAND',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    if not(isint(temp2)) then
      begin
        do_logand:=errorloop('BAD ARG TO LOGAND',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp3);
    temp3^.ItemType:=IntegerI;
    temp3^.theInteger:=(temp1^.theInteger) and
                       (temp2^.theInteger);
    do_logand:=temp3;
  end; (* logand *)

function do_logior(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* logior *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_logior:=errorloop('TOO FEW ARGS TO LOGIOR:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(isint(temp1)) then
      begin
        do_logior:=errorloop('BAD ARG TO LOGIOR',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    if not(isint(temp2)) then
      begin
        do_logior:=errorloop('BAD ARG TO LOGIOR',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp3);
    temp3^.ItemType:=IntegerI;
    temp3^.theInteger:=(temp1^.theInteger) or
                       (temp2^.theInteger);
    do_logior:=temp3;
  end; (* logior *)

function do_lognot(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp3: ItemPointer;

  begin (* lognot *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_lognot:=errorloop('NO ARG TO LOGNOT',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(AItem^.Cdr^.Car,VariableTable);
    if not(isint(temp1)) then
      begin
        do_lognot:=errorloop('BAD ARG TO LOGNOT',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp3);
    temp3^.ItemType:=IntegerI;
    temp3^.theInteger:=not (temp1^.theInteger);
    do_lognot:=temp3;
  end; (* lognot *)

function do_logxor(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* logxor *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_logxor:=errorloop('TOO FEW ARGS TO LOGXOR:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(isint(temp1)) then
      begin
        do_logxor:=errorloop('BAD ARG TO LOGXOR',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    if not(isint(temp2)) then
      begin
        do_logxor:=errorloop('BAD ARG TO LOGXOR',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp3);
    temp3^.ItemType:=IntegerI;
    temp3^.theInteger:=(temp1^.theInteger) xor
                       (temp2^.theInteger);
    do_logxor:=temp3;
  end; (* logxor *)

function do_logshl(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* logshl *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_logshl:=errorloop('TOO FEW ARGS TO LOGSHL:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(isint(temp1)) then
      begin
        do_logshl:=errorloop('BAD ARG TO LOGSHL',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    if not(isint(temp2)) then
      begin
        do_logshl:=errorloop('BAD ARG TO LOGSHL',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp3);
    temp3^.ItemType:=IntegerI;
    temp3^.theInteger:=(temp1^.theInteger) shl
                       (temp2^.theInteger);
    do_logshl:=temp3;
  end; (* logshl *)

function do_logshr(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* logshr *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_logshr:=errorloop('TOO FEW ARGS TO LOGSHR:',BItem,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(isint(temp1)) then
      begin
        do_logshr:=errorloop('BAD ARG TO LOGSHR',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    if not(isint(temp2)) then
      begin
        do_logshr:=errorloop('BAD ARG TO LOGSHR',BItem^.Cdr^.Car,
                         AItem,VariableTable);
        exit
      end;
    newitem(temp3);
    temp3^.ItemType:=IntegerI;
    temp3^.theInteger:=(temp1^.theInteger) shr
                       (temp2^.theInteger);
    do_logshr:=temp3;
  end; (* logshr *)

function do_last(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* last *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_last:=errorloop('NO ARG TO LAST:',Nil,
                         AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not(islist(temp1)) then
      begin
        do_last:=errorloop('BAD ARG TO LAST:',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    while (temp1<>Nil) and (temp1^.Cdr<>Nil) do
      temp1:=temp1^.Cdr;
    do_last:=temp1;
  end; (* last *)

function do_macro_list(AItem: ItemPointer;
                       var VariableTable: VariableTableType): ItemPointer;

  begin (* macro-list *)
    do_macro_list:=dofunctionlist(MacroStack);
  end; (* macro-list *)

function do_print(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* print *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) then
      begin
        do_print:=errorloop('TOO FEW ARGS TO PRINT',
                         BItem,AItem,VariableTable);
        exit
      end;
    Temp1:=eval(BItem^.Car,VariableTable);

    if (temp1^.Itemtype=FileI) then
      if (BItem^.cdr=Nil) then
        begin
          writeln(output);
          writeitem(temp1,output);
          write(output,' ')
        end
      else
        begin
          temp2:=eval(BItem^.cdr^.car,VariableTable);

          if (GFileTable[temp1^.thefile].status=openo) then
            begin
              writeln(GFileTable[temp1^.thefile].thefile^);
              writeitem(temp2,GFileTable[temp1^.thefile].thefile^);
              write(GFileTable[temp1^.thefile].thefile^,' ')
            end
          else
            begin
              (* file not open for writing *)
              do_print:=errorloop('FILE NOT OPEN FOR OUTPUT:',
                               temp1,AItem,VariableTable);
              exit
            end
        end
    else
      begin
        writeln(output);
        writeitem(temp1,output);
        write(output,' ')
      end;
    do_print:=Temp2;
  end; (* print *)

function do_prin1(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* prin1 *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) then
      begin
        do_prin1:=errorloop('TOO FEW ARGS TO PRIN1',
                         BItem,AItem,VariableTable);
        exit
      end;
    Temp1:=eval(BItem^.Car,VariableTable);
    if (temp1^.Itemtype=FileI) then
      if (BItem^.cdr=Nil) then
        writeitem(temp1,output)
      else
        begin
          temp2:=eval(BItem^.cdr^.car,VariableTable);
          if (GFileTable[temp1^.thefile].status=openo) then
            writeitem(temp2,GFileTable[temp1^.thefile].thefile^)
          else
            begin
              (* file not open for writing *)
              do_prin1:=errorloop('FILE NOT OPEN FOR OUTPUT:',
                               temp1,AItem,VariableTable);
              exit
            end
        end
    else
      writeitem(temp1,output);
    do_prin1:=Temp2;
  end; (* prin1 *)

function do_prog1(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* prog1 *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_prog1:=errorloop('NO ARG TO PROG1',
                         Nil,AItem,VariableTable);
        exit
      end;
    do_prog1:=eval(BItem^.Car,VariableTable);
    temp1:=BItem^.Cdr;
    while temp1<>Nil do
      begin
        temp2:=eval(temp1^.Car,VariableTable);
        temp1:=temp1^.Cdr
      end;
  end; (* prog1 *)

function do_prog2(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* prog2 *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_prog2:=errorloop('TOO FEW ARGs TO PROG2',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp1:=BItem^.Cdr;
    do_prog2:=eval(temp1^.Car,VariableTable);
    temp1:=temp1^.Cdr;
    while temp1<>Nil do
      begin
        temp2:=eval(temp1^.Car,VariableTable);
        temp1:=temp1^.Cdr
      end;
  end; (* prog2 *)

function do_progn(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* progn *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_progn:=errorloop('NO ARG TO PROGN',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp1:=BItem;
    while temp1<>Nil do
      begin
        temp2:=eval(temp1^.Car,VariableTable);
        temp1:=temp1^.Cdr
      end;
    do_progn:=temp2;
  end; (* progn *)

function do_nconc(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  label
    EndFunc;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* nconc *)
    BItem:=AItem^.Cdr;
    temp3:=AItem;
    temp1:=Nil;
    while (temp3<>Nil) and (notornull(temp1)) do
      begin
        temp3:=temp3^.Cdr;
        if temp3<>Nil then
          temp1:=eval(temp3^.Car,VariableTable);
      end;
    if not(islist(temp1)) then
      begin
        do_nconc:=errorloop('ARG MUST BE A LIST',temp3^.Car,
                         AItem,VariableTable);
        exit
      end;
    do_nconc:=temp1;
    temp3:=temp3^.Cdr;
    while temp3<>Nil do
      begin
        temp2:=eval(temp3^.Car,VariableTable);
        if not(islist(temp2)) then
          begin
            do_nconc:=errorloop('ARG MUST BE A LIST',temp3^.Car,
                             AItem,VariableTable);
            goto EndFunc
          end;
        if not(notornull(temp2)) then
          begin
            while temp1^.Cdr<>Nil do
              temp1:=temp1^.Cdr;
            temp1^.Cdr:=temp2;
            temp1:=temp2
          end;
        temp3:=temp3^.Cdr
      end;
    EndFunc:
  end; (* nconc *)

function do_or(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* or *)
    BItem:=AItem^.Cdr;
    temp1:=Nil;
    while (notornull(temp1)) and (BItem<>Nil) do
      begin
        temp1:=eval(BItem^.Car,VariableTable);
        BItem:=BItem^.Cdr
      end;
    do_or:=temp1;
  end; (* or *)

function do_openi(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;
    x: integer;

  begin (* openi *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) then
      begin
        do_openi:=errorloop('TOO FEW ARGS TO OPENI',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if temp1^.itemtype<>StringI then
      begin
        do_openi:=errorloop('ARG MUST BE A STRING:',
                         BItem^.Car,AItem,VariableTable);
        exit
      end;
    x:=0;
    while (GFileTable[x].thefile<>Nil) and (x<47) do
      inc(x);
    if GFileTable[x].thefile<>Nil then
      begin
        do_openi:=errorloop('TOO MANY FILES ALREADY OPEN:',
                         Nil,AItem,VariableTable);
        exit
      end;
    new(GFileTable[x].thefile);
    assign(GFileTable[x].thefile^,temp1^.theString);
    {$I-}
    reset(GFileTable[x].thefile^);
    {$I+}
    if IOResult<>0 then
      begin
        do_openi:=errorloop('UNABLE TO OPEN FILE:',
                         temp1,AItem,VariableTable);
        exit
      end;
    GFileTable[x].fn:=temp1^.theString;
    GFileTable[x].status:=openi;
    newitem(temp2);
    temp2^.ItemType:=FileI;
    temp2^.theFile:=x;
    do_openi:=temp2;
  end; (* openi *)

function do_openo(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;
    x: integer;

  begin (* openo *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) then
      begin
        do_openo:=errorloop('TOO FEW ARGS TO OPENO',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if temp1^.itemtype<>StringI then
      begin
        do_openo:=errorloop('ARG MUST BE A STRING:',
                         BItem^.Car,AItem,VariableTable);
        exit
      end;
    x:=0;
    while (GFileTable[x].thefile<>Nil) and (x<47) do
      inc(x);
    if GFileTable[x].thefile<>Nil then
      begin
        do_openo:=errorloop('TOO MANY FILES ALREADY OPEN:',
                         Nil,AItem,VariableTable);
        exit
      end;
    new(GFileTable[x].thefile);
    assign(GFileTable[x].thefile^,temp1^.theString);
    {$I-}
    rewrite(GFileTable[x].thefile^);
    {$I+}
    if IOResult<>0 then
      begin
        do_openo:=errorloop('UNABLE TO OPEN FILE:',
                         temp1,AItem,VariableTable);
        exit
      end;
    GFileTable[x].fn:=temp1^.thestring;
    GFileTable[x].status:=openo;
    newitem(temp2);
    temp2^.ItemType:=FileI;
    temp2^.theFile:=x;
    do_openo:=temp2;
  end; (* openo *)

function do_pairlis(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp3,temp4: ItemPointer;

  begin (* pairlis *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_pairlis:=errorloop('TOO FEW ARGS TO PAIRLIS',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp3:=eval(BItem^.Car,VariableTable);
    temp4:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp4)) then
      begin
        do_pairlis:=errorloop('BAD ARG TO PAIRLIS:',
                          BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    if not(islist(temp3)) then
      begin
        do_pairlis:=errorloop('BAD ARG TO PAIRLIS:',
                          BItem^.Car,AItem,VariableTable);
        exit
      end;
    if not(notornull(temp3)) then
      begin
        newitem(Temp1);
        AItem:=Temp1;
        Temp1^.ItemType:=ConsI;
        Temp1^.Car:=pairlisaux(temp3,temp4);
        Temp1^.Cdr:=Nil;
        While (Temp3<>Nil) and (temp4<>Nil) do
          begin
            newitem(Temp1^.Cdr);
            Temp1^.Cdr^.ItemType:=ConsI;
            Temp1^.Cdr^.Car:=pairlisaux(temp3,temp4);
            Temp1:=Temp1^.Cdr;
            Temp1^.Cdr:=Nil
          end;
        do_pairlis:=AItem
      end
    else
      do_pairlis:=Nil;
  end; (* pairlis *)

function do_numberp(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* numberp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_numberp:=errorloop('NO ARG TO NUMBERP',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    temp1:=Nil;
    if isatom(temp2) and not(notornull(temp2)) and
       isnumber(temp2) then
      temp1:=truesymbol;
    do_numberp:=temp1;
  end; (* numberp *)

function do_nth(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp3: ItemPointer;
    x: integer;

  begin (* nth *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_nth:=errorloop('TOO FEW ARGS TO NTH',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp3:=eval(BItem^.Car,VariableTable);
    temp1:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp1)) then
      begin
        do_nth:=errorloop('BAD ARG TO NTH:',
                          BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    if not(isint(temp3)) then
      begin
        do_nth:=errorloop('BAD ARG TO NTH:',
                          BItem^.Car,AItem,VariableTable);
        exit
      end;
    x:=getint(temp3);
    while (temp1<>Nil) and (x>0) do
      begin
        temp1:=temp1^.Cdr;
        x:=x-1
      end;
    if temp1=Nil then
      do_nth:=Nil
    else
      do_nth:=temp1^.Car;
  end; (* nth *)

function do_nthcdr(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp3: ItemPointer;
    x: integer;

  begin (* nthcdr *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_nthcdr:=errorloop('TOO FEW ARGS TO NTHCDR',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp3:=eval(BItem^.Car,VariableTable);
    temp1:=eval(BItem^.Cdr^.Car,VariableTable);
    if not(islist(temp1)) then
      begin
        do_nthcdr:=errorloop('BAD ARG TO NTHCDR:',
                          BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    if not(isint(temp3)) then
      begin
        do_nthcdr:=errorloop('BAD ARG TO NTHCDR:',
                          BItem^.Car,AItem,VariableTable);
        exit
      end;
    x:=getint(temp3);
    while (temp1<>Nil) and (x>0) do
      begin
        temp1:=temp1^.Cdr;
        x:=x-1
      end;
    do_nthcdr:=temp1;
  end; (* nthcdr *)

function do_plusp(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* plusp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_plusp:=errorloop('NO ARG TO PLUSP',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not isnumber(temp2) then
      begin
        do_plusp:=errorloop('ARG NOT A NUMBER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1:=Nil;
    if plusp(temp2) then
      temp1:=truesymbol;
    do_plusp:=temp1;
  end; (* plusp *)

function do_oddp(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* oddp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_oddp:=errorloop('NO ARG TO ODDP',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not isint(temp2) then
      begin
        do_oddp:=errorloop('ARG NOT AN INTEGER',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1:=Nil;
    if oddp(temp2) then
      temp1:=truesymbol;
    do_oddp:=temp1;
  end; (* oddp *)

function do_numerator(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* numerator *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_numerator:=errorloop('NO ARG TO NUMERATOR',
                         Nil,AItem,VariableTable);
        exit
      end;
    temp2:=eval(BItem^.Car,VariableTable);
    if not(isratio(temp2)) then
      begin
        do_numerator:=errorloop('ARG NOT A RATIO',BItem^.Car,
                         AItem,VariableTable);
        exit
      end;
    reduce(temp2^.Ratio);
    newitem(temp1);
    temp1^.ItemType:=IntegerI;
    temp1^.theInteger:=temp2^.Ratio.num;
    do_numerator:=temp1;
  end; (* numerator *)

function do_putprop(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;
    stemp: VariablePointer;

  begin (* putprop *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) or (BItem^.Cdr^.Cdr=Nil) then
      begin
        do_putprop:=errorloop('TOO FEW ARGS TO PUTPROP',
                         BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if not isvsymbol(temp1) then
      begin
        do_putprop:=errorloop('ARG NOT A VALID SYMBOL',
                         BItem^.Car,AItem,VariableTable);
        exit
      end;
    stemp:=isdefinedsymbol(temp1^.Symbol,VariableTable);
    if stemp=Nil then
      begin
        setq(temp1^.Symbol,Nil,VariableTable);
        stemp:=isdefinedsymbol(temp1^.Symbol,VariableTable)
      end;
    temp3:=eval(BItem^.Cdr^.Car,VariableTable);
    if not isvsymbol(temp3) then
      begin
        do_putprop:=errorloop('ARG NOT A SYMBOL',
                         BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    do_putprop:=temp3;
    temp2:=eval(BItem^.Cdr^.Cdr^.Car,VariableTable);
    temp1:=propmember(stemp^.PropList,Temp3^.Symbol);
    if temp1<>Nil then
      temp1^.Cdr^.Car:=copyitem(temp2)
    else
      begin
        newitem(temp1);
        temp1^.ItemType:=ConsI;
        temp1^.Cdr:=stemp^.PropList;
        temp1^.Car:=temp2;
        temp2:=temp1;
        newitem(temp1);
        temp1^.ItemType:=ConsI;
        temp1^.Cdr:=temp2;
        temp1^.Car:=temp3;
        stemp^.PropList:=temp1
      end;
  end; (* putprop *)

function do_prog(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* prog *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_prog:=errorloop('NO ARG TO PROG',
                         Nil,AItem,VariableTable);
        exit
      end;
    if not islist(BItem) then
      begin
        do_prog:=errorloop('BAD VARIABLE LIST TO PROG',
                         BItem,AItem,VariableTable);
        exit
      end;
    if BItem^.Cdr=Nil then
      begin
        do_prog:=Nil;
        exit
      end;
    do_prog:=doprog(AItem,VariableTable);
  end; (* prog *)

end. (* unit funcslp *)
