unit funcs0;

interface
uses listaux;

function do_car(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_cdr(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_atom(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_listp(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_null(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_quote(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;
function do_backquote(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;
function do_eql(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_eq(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;
function do_plus(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_mult(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_sub(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_divide(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;
function do_div(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_mod(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_equ(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function do_greater(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;
function do_less(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_less_equal(AItem: ItemPointer;
                       var VariableTable: VariableTableType): ItemPointer;
function do_greater_equal(AItem: ItemPointer;
                          var VariableTable: VariableTableType): ItemPointer;
function do_not_equal(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;
function do_setq(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_cons(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_list(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_cond(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;
function do_append(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

implementation
uses evaluate,lithpaux,evalfuns;

function do_car(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* car *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_car:=errorloop('NO ARGUMENT TO CAR',
                        Nil,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if (temp1=Nil) or (temp1^.ItemType<>ConsI) then
      do_car:=errorloop('BAD ARGUMENT TO CAR:',
                      BItem^.Car,AItem,VariableTable)
    else
      do_car:=temp1^.Car;
  end; (* car *)

function do_cdr(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1: ItemPointer;

  begin (* cdr *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_cdr:=errorloop('NO ARGUMENT TO CDR',
                        Nil,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    if (temp1=Nil) or (temp1^.ItemType<>ConsI) then
      do_cdr:=errorloop('BAD ARGUMENT TO CDR:',
                      BItem^.Car,AItem,VariableTable)
    else
      do_cdr:=temp1^.Cdr;
  end; (* cdr *)

function do_atom(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* atom *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_atom:=errorloop('NO ARGUMENT TO ATOM',
                        Nil,AItem,VariableTable);
        exit
      end;
    if isatom(eval(BItem^.Car,VariableTable)) then
      do_atom:=truesymbol
    else
      do_atom:=Nil;
  end; (* atom *)

function do_listp(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* listp *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_listp:=errorloop('NO ARGUMENT TO LISTP',
                        Nil,AItem,VariableTable);
        exit
      end;
    if islist(eval(BItem^.Car,VariableTable)) then
      do_listp:=truesymbol
    else
      do_listp:=Nil;
  end; (* listp *)

function do_null(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* null *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_null:=errorloop('NO ARGUMENT TO NOT/NULL',
                        Nil,AItem,VariableTable);
        exit
      end;
    if notornull(eval(BItem^.Car,VariableTable)) then
      do_null:=truesymbol
    else
      do_null:=Nil;
  end; (* null *)

function do_quote(AItem: ItemPointer;
                  var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* quote *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_quote:=errorloop('NO ARGUMENT TO QUOTE',
                        Nil,AItem,VariableTable);
        exit
      end;
    do_quote:=copyitem(BItem^.Car);
  end; (* quote *)

function do_backquote(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem: ItemPointer;

  begin (* backquote *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_backquote:=errorloop('NO ARGUMENT TO BACKQUOTE',
                        Nil,AItem,VariableTable);
        exit
      end;
    do_backquote:=dobackquote(BItem^.Car,VariableTable);
  end; (* backquote *)

function do_eql(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* eql *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_eql:=errorloop('TOO FEW ARGUMENTS TO EQL',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if (temp1=temp2) or (eql(temp1,temp2)) then
      do_eql:=truesymbol
    else
      do_eql:=Nil;
  end; (* eql *)

function do_eq(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* eq *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_eq:=errorloop('TOO FEW ARGUMENTS TO EQ',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if temp1=temp2 then
      do_eq:=truesymbol
    else
      do_eq:=Nil;
  end; (* eq *)

function do_plus(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  label
    EndFunc;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* plus *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_plus:=errorloop('NO ARGUMENTS TO +',
                        Nil,AItem,VariableTable);
        exit
      end;
    temp1:=BItem;
    newitem(temp2);
    temp2^.ItemType:=IntegerI;
    temp2^.theInteger:=0;
    repeat
      temp3:=eval(temp1^.Car,VariableTable);
      if not isnumber(temp3) then
        begin
          do_plus:=errorloop('BAD ARG TO + :',
                          temp1^.Car,AItem,VariableTable);
          goto EndFunc
        end;
      temp2:=plus(temp2,temp3);
      temp1:=temp1^.Cdr
    until temp1=Nil;
    do_plus:=temp2;
    EndFunc:
  end; (* plus *)

function do_mult(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  label
    EndFunc;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* mult *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_mult:=errorloop('NO ARGUMENTS TO *',
                        Nil,AItem,VariableTable);
        exit
      end;
    temp1:=AItem^.Cdr;
    newitem(temp2);
    temp2^.ItemType:=IntegerI;
    temp2^.theInteger:=1;
    repeat
      temp3:=eval(temp1^.Car,VariableTable);
      if not isnumber(temp3) then
        begin
          do_mult:=errorloop('BAD ARG TO * :',
                          temp1^.Car,AItem,VariableTable);
          goto EndFunc
        end;
      temp2:=mult(temp2,temp3);
      temp1:=temp1^.Cdr
    until temp1=Nil;
    do_mult:=temp2;
    EndFunc:
  end; (* mult *)

function do_sub(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3,temp4: ItemPointer;

  begin (* sub *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_sub:=errorloop('NO ARGUMENTS TO -',
                        Nil,AItem,VariableTable);
        exit
      end;
    temp3:=BItem^.Car;
    temp2:=BItem^.Cdr;
    temp1:=eval(temp3,VariableTable);
    if not isnumber(temp1) then
      begin
        do_sub:=errorloop('BAD ARG TO - :',
                        temp3,AItem,VariableTable);
        exit
      end;
    if temp2=Nil then
      begin
        newitem(temp4);
        temp4^.ItemType:=IntegerI;
        temp4^.theInteger:=0
      end
    else
      begin
        temp4:=eval(temp2^.Car,VariableTable);
        if not isnumber(temp4) then
          begin
            do_sub:=errorloop('BAD ARG TO - :',
                            temp2^.Car,AItem,VariableTable);
            exit
          end
      end;
    do_sub:=sub(temp4,temp1);
  end; (* sub *)

function do_divide(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3,temp4: ItemPointer;

  begin (* realdiv *)
    BItem:=AItem^.Cdr;
    if BItem=Nil then
      begin
        do_divide:=errorloop('NO ARGUMENTS TO /',
                        Nil,AItem,VariableTable);
        exit
      end;
    temp3:=BItem^.Car;
    temp2:=BItem^.Cdr;
    temp1:=eval(temp3,VariableTable);
    if not isnumber(temp1) then
      begin
        do_divide:=errorloop('BAD ARG TO / :',
                        temp3,AItem,VariableTable);
        exit
      end;
    if temp2=Nil then
      begin
        temp4:=temp1;
        newitem(temp1);
        temp1^.ItemType:=IntegerI;
        temp1^.theInteger:=1
      end
    else
      begin
        temp4:=eval(temp2^.Car,VariableTable);
        if not isnumber(temp4) then
          begin
            do_divide:=errorloop('BAD ARG TO - :',
                            temp2^.Car,AItem,VariableTable);
            exit
          end
      end;
    do_divide:=realdiv(temp1,temp4);
  end; (* realdiv *)

function do_div(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* div *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_div:=errorloop('TOO FEW ARGUMENTS TO DIV',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not isrational(temp1) then
      begin
        do_div:=errorloop('BAD ARG TO DIV:',
                        BItem^.Car,AItem,VariableTable);
        exit
      end;
    if not isrational(temp2) then
      begin
        do_div:=errorloop('BAD ARG TO DIV:',
                        BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    do_div:=intdiv(temp1,temp2);
  end; (* div *)

function do_mod(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* mod *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_mod:=errorloop('TOO FEW ARGUMENTS TO MOD',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not isint(temp1) then
      begin
        do_mod:=errorloop('BAD ARG TO MOD:',
                        BItem^.Car,AItem,VariableTable);
        exit
      end;
    if not isint(temp2) then
      begin
        do_mod:=errorloop('BAD ARG TO MOD:',
                        BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    do_mod:=intmod(temp1,temp2);
  end; (* mod *)

function do_equ(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* = *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_equ:=errorloop('TOO FEW ARGUMENTS TO =',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if islist(temp1) then
      begin
        do_equ:=errorloop('BAD ARG TO = :',
                        BItem^.Car,AItem,VariableTable);
        exit
      end;
    if islist(temp2) then
      begin
        do_equ:=errorloop('BAD ARG TO = :',
                        BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    temp3:=Nil;
    if isequal(temp1,temp2) then
      temp3:=truesymbol;
    do_equ:=temp3;
  end; (* = *)

function do_greater(AItem: ItemPointer;
                    var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* > *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_greater:=errorloop('TOO FEW ARGUMENTS TO >',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if islist(temp1) then
      begin
        do_greater:=errorloop('BAD ARG TO > :',
                        BItem^.Car,AItem,VariableTable);
        exit
      end;
    if islist(temp2) then
      begin
        do_greater:=errorloop('BAD ARG TO > :',
                        BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    temp3:=Nil;
    if isgreater(temp1,temp2) then
      temp3:=truesymbol;
    do_greater:=temp3;
  end; (* > *)

function do_less(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* < *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_less:=errorloop('TOO FEW ARGUMENTS TO <',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if islist(temp1) then
      begin
        do_less:=errorloop('BAD ARG TO < :',
                        BItem^.Car,AItem,VariableTable);
        exit
      end;
    if islist(temp2) then
      begin
        do_less:=errorloop('BAD ARG TO < :',
                        BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    temp3:=Nil;
    if isless(temp1,temp2) then
      temp3:=truesymbol;
    do_less:=temp3;
  end; (* < *)

function do_less_equal(AItem: ItemPointer;
                       var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* <= *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_less_equal:=errorloop('TOO FEW ARGUMENTS TO <=',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if islist(temp1) then
      begin
        do_less_equal:=errorloop('BAD ARG TO <= :',
                        BItem^.Car,AItem,VariableTable);
        exit
      end;
    if islist(temp2) then
      begin
        do_less_equal:=errorloop('BAD ARG TO <= :',
                        BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    temp3:=Nil;
    if islessequal(temp1,temp2) then
      temp3:=truesymbol;
    do_less_equal:=temp3;
  end; (* <= *)

function do_greater_equal(AItem: ItemPointer;
                          var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* >= *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_greater_equal:=errorloop('TOO FEW ARGUMENTS TO >=',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if islist(temp1) then
      begin
        do_greater_equal:=errorloop('BAD ARG TO >= :',
                        BItem^.Car,AItem,VariableTable);
        exit
      end;
    if islist(temp2) then
      begin
        do_greater_equal:=errorloop('BAD ARG TO >= :',
                        BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    temp3:=Nil;
    if isgreaterequal(temp1,temp2) then
      temp3:=truesymbol;
    do_greater_equal:=temp3;
  end; (* >= *)

function do_not_equal(AItem: ItemPointer;
                      var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* <> *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_not_equal:=errorloop('TOO FEW ARGUMENTS TO <>',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if islist(temp1) then
      begin
        do_not_equal:=errorloop('BAD ARG TO <> :',
                        BItem^.Car,AItem,VariableTable);
        exit
      end;
    if islist(temp2) then
      begin
        do_not_equal:=errorloop('BAD ARG TO <> :',
                        BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    temp3:=Nil;
    if isnotequal(temp1,temp2) then
      temp3:=truesymbol;
    do_not_equal:=temp3;
  end; (* <> *)

function do_setq(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  label
    EndFunc;

  Var
    BItem,temp1,temp2: ItemPointer;

  begin (* setq *)
    BItem:=AItem^.Cdr;
    temp2:=BItem;
    temp1:=Nil;
    repeat
      if temp2^.Cdr=Nil then
        begin
          do_setq:=temp1;
          writeln('*** SETQ: Odd args - last discarded');
          goto EndFunc
        end;
      temp1:=eval(temp2^.Cdr^.Car,VariableTable);
      if not isvsymbol(temp2^.Car) then
        begin
          do_setq:=errorloop('ARGUMENT TO SETQ NOT A VALID SYMBOL:',
                          temp2^.Car,AItem,VariableTable);
          goto EndFunc
        end;
      setq(temp2^.Car^.Symbol,temp1,VariableTable);
      temp2:=temp2^.Cdr^.Cdr
    until temp2=Nil;
    do_setq:=temp1;
    EndFunc:
  end; (* setq *)

function do_cons(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* cons *)
    BItem:=AItem^.Cdr;
    if (BItem=Nil) or (BItem^.Cdr=Nil) then
      begin
        do_cons:=errorloop('TOO FEW ARGUMENTS TO CONS',
                        BItem,AItem,VariableTable);
        exit
      end;
    temp1:=eval(BItem^.Car,VariableTable);
    temp2:=eval(BItem^.Cdr^.Car,VariableTable);
    if not islist(temp2) then
      begin
        do_cons:=errorloop('BAD ARG TO CONS: ',
                        BItem^.Cdr^.Car,AItem,VariableTable);
        exit
      end;
    newitem(temp3);
    temp3^.ItemType:=ConsI;
    temp3^.Car:=temp1;
    temp3^.Cdr:=temp2;
    do_cons:=temp3;
  end; (* cons *)

function do_list(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* list *)
    BItem:=AItem^.Cdr;
    if Bitem=Nil then
      begin
        do_list:=Nil;
        exit
      end;
    Temp2:=BItem;
    newitem(Temp1);
    Temp3:=Temp1;
    Temp1^.ItemType:=ConsI;
    Temp1^.Car:=eval(Temp2^.Car,VariableTable);
    Temp2:=Temp2^.Cdr;
    Temp1^.Cdr:=Nil;
    While Temp2<>Nil do
      begin
        newitem(Temp1^.Cdr);
        Temp1^.Cdr^.ItemType:=ConsI;
        Temp1^.Cdr^.Car:=eval(Temp2^.Car,VariableTable);
        Temp2:=Temp2^.Cdr;
        Temp1:=Temp1^.Cdr;
        Temp1^.Cdr:=Nil
      end;
    do_list:=Temp3;
  end; (* list *)

function do_cond(AItem: ItemPointer;
                 var VariableTable: VariableTableType): ItemPointer;

  label
    EndFunc;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;
    found: Boolean;

  begin (* cond *)
    BItem:=AItem^.Cdr;
    temp3:=BItem;
    found:=False;
    temp2:=Nil;
    while (temp3<>Nil) and not(found) do
      begin
        temp1:=temp3^.Car;
        if isatom(temp1) then
          begin
            do_cond:=errorloop('BAD ARG TO COND',temp1,
                            AItem,VariableTable);
            goto EndFunc
          end;
        temp2:=eval(temp1^.Car,VariableTable);
        if not(notornull(temp2)) then
          begin
            found:=True;
            temp1:=temp1^.Cdr;
            while temp1<>Nil do
              begin
                temp2:=eval(temp1^.Car,VariableTable);
                temp1:=temp1^.Cdr
              end
          end;
        temp3:=temp3^.Cdr
      end;
    do_cond:=temp2;
    EndFunc:
  end; (* cond *)

function do_append(AItem: ItemPointer;
                   var VariableTable: VariableTableType): ItemPointer;

  label
    EndFunc;

  Var
    BItem,temp1,temp2,temp3: ItemPointer;

  begin (* append *)
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
        do_append:=errorloop('ARG MUST BE A LIST',temp3^.Car,
                         AItem,VariableTable);
        exit
      end;
    temp1:=copyitem(temp1);
    do_append:=temp1;
    temp3:=temp3^.Cdr;
    while temp3<>Nil do
      begin
        temp2:=eval(temp3^.Car,VariableTable);
        if not(islist(temp2)) then
          begin
            do_append:=errorloop('ARG MUST BE A LIST',temp3^.Car,
                             AItem,VariableTable);
            goto EndFunc
          end;
        if not(notornull(temp2)) then
          begin
            temp2:=copyitem(temp2);
            while temp1^.Cdr<>Nil do
              temp1:=temp1^.Cdr;
            temp1^.Cdr:=temp2;
            temp1:=temp2
          end;
        temp3:=temp3^.Cdr
      end;
    EndFunc:
  end; (* append *)

end. (* unit funcs0 *)
