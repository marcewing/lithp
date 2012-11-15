(* evalfuns.pas for Lithp 3.0a2 *)
(* (c) 1989 Marc Ewing          *)

(* note on scoping:                                         *)
(* during a setq, if the symbol is not defined anywhere,    *)
(* (either lexically or dynamically) it is defined globally *)

unit evalfuns;

interface
uses listaux;

type
  ScopeType= (Dynamic,Static);

var
  GScope: ScopeType;

function dobackquote(AItem: ItemPointer; var VariableTable: VariableTableType): ItemPointer;
function isdefinedsymbol(AAtom: SymbolType; VariableTable: VariableTableType): VariablePointer;
function isdefinedfunction(AAtom: SymbolType; Stack: FunctionStackType): FunctionStackType;
function defun(AItem: ItemPointer; var Stack: FunctionStackType;
               var VariableTable: VariableTableType): ItemPointer;
function dofunctionlist(Stack: FunctionStackType): ItemPointer;
function dovariablelist(VarTab: VariableTableType; first: boolean;
                        thelist: ItemPointer): ItemPointer;
function propmember(AItem: ItemPointer; AAtom: SymbolType): ItemPointer;
function eql(AItem,BItem: ItemPointer): boolean;
function member(AItem,BItem: ItemPointer; eqf: boolean): ItemPointer;
function intersection(AItem,BItem: ItemPointer; yes: Boolean): ItemPointer;
function union(AItem,BItem: ItemPointer; Unn: boolean): ItemPointer;
function subset(AItem,BItem: ItemPointer; Ss: boolean): boolean;
function delete(AItem,BItem: ItemPointer): ItemPointer;
function apply(AItem,BItem: ItemPointer): ItemPointer;
function pairlisaux(var AItem,BItem: ItemPointer): ItemPointer;
function dolet(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;
function dodo(AItem: ItemPointer;
              var VariableTable: VariableTableType): ItemPointer;
function doprog(AItem: ItemPointer;
                var VariableTable: VariableTableType): ItemPointer;
function dosetf(AItem: ItemPointer; var VariableTable: VariableTableType): ItemPointer;
function dolambda(AItem: ItemPointer;
                  var VariableTable: VariableTableType;
                  ReEval: Boolean): ItemPointer;
function domap(Item,AItem,BItem: ItemPointer; l,r: boolean;
               VariableTable: VariableTableType): ItemPointer;

procedure errorhandler(id: SymbolType; Item: ItemPointer);
procedure setq(id: SymbolType; AItem: ItemPointer;
               var VariableTable: VariableTableType);
procedure reverse(var AItem: ItemPointer);

implementation
uses evaluate,lithpaux,listio;

procedure errorhandler(id: SymbolType; Item: ItemPointer);

  begin (* errorhandler *)
    write('*** Bad Arg to ',id,': ');
    writeitem(Item,output);
    writeln
  end; (* errorhandler *)

function dobackquote(AItem: ItemPointer; var VariableTable: VariableTableType): ItemPointer;

  var
    temp1,temp2,temp3: ItemPointer;

  begin  (* dobackquote.eval *)
    if isatom(AItem) then
      dobackquote:=copyitem(AItem)
    else
      if (AItem^.Car^.ItemType=SymbolI) and
         ((AItem^.Car^.Symbol='COMMA') or (AItem^.Car^.Symbol='COMMA-AT')) then
        dobackquote:=eval(AItem^.Cdr^.Car,VariableTable)
      else
        begin
          newitem(temp2);
          temp2^.Car:=Nil;
          temp2^.Cdr:=Nil;
          temp2^.ItemType:=ConsI;
          dobackquote:=temp2;
          repeat
            temp1:=AItem^.Car;
            if temp1^.ItemType<>ConsI then
              temp2^.Car:=copyitem(temp1)
            else
              begin
                temp3:=dobackquote(temp1,VariableTable);
                if (temp1^.Car<>Nil) and (temp1^.Car^.ItemType=SymbolI) and
                   (temp1^.Car^.Symbol='COMMA-AT') then
                  begin
                    temp3:=copyitem(temp3);
                    temp2^.Car:=temp3^.Car;
                    temp2^.Cdr:=temp3^.Cdr;
                    while temp2^.Cdr<>Nil do
                      temp2:=temp2^.Cdr
                  end
                else
                  temp2^.Car:=temp3
              end;
            AItem:=AItem^.Cdr;
            if AItem<>Nil then
              begin
                newitem(temp2^.Cdr);
                temp2:=temp2^.Cdr;
                temp2^.ItemType:=ConsI;
                temp2^.Car:=Nil;
                temp2^.Cdr:=Nil
              end
          until AItem=Nil
        end
  end; (* dobackquote.eval *)

function isdefinedsymbol(AAtom: SymbolType; VariableTable: VariableTableType): VariablePointer;

  (* note use of lexical (static) OR dynamic scoping *)

  var
    done,found: boolean;
    temp: VariablePointer;

  begin (* isdefinedsymbol.eval *)
    found:=False;
    temp:=Nil;
    done:=False;
    while (VariableTable<>Nil) and not(found or done) do
      begin
        temp:=VariableTable^.Variables;
        while (temp<>Nil) and not(found) do
          if temp^.Symbol=AAtom then
            found:=True
          else
            temp:=temp^.Next;
        if VariableTable^.Next=Nil then
          done:=True
        else
          if GScope=Static then
            while VariableTable^.Next<>Nil do
              VariableTable:=VariableTable^.Next
          else
            VariableTable:=VariableTable^.Next
      end;
    isdefinedsymbol:=temp
  end; (* isdefinedsymbol.eval *)

procedure setq(id: SymbolType; AItem: ItemPointer;
               var VariableTable: VariableTableType);

  (* note on scoping:                                         *)
  (* during a setq, if the symbol is not defined anywhere,    *)
  (* (either lexically OR dynamically) it is defined globally *)

  var
    temp1: VariableTableType;
    temp: VariablePointer;
    found: boolean;

  begin (* setq.eval *)
    temp:=isdefinedsymbol(id,VariableTable);
    if temp=Nil then
      begin
        temp1:=VariableTable;
        while temp1^.Next<>Nil do
          temp1:=temp1^.Next;
        new(temp);
        temp^.Next:=temp1^.Variables;
        temp1^.Variables:=temp;
        temp^.Symbol:=id;
        temp^.PropList:=Nil
      end;
    temp^.Item:=AItem
  end; (* setq.eval *)

function isdefinedfunction(AAtom: SymbolType; Stack: FunctionStackType): FunctionStackType;

  begin (* isdefinedfunction.eval *)
    while (Stack<>Nil) and (Stack^.Name<>AAtom) do
      Stack:=Stack^.Next;
    isdefinedfunction:=Stack
  end; (* isdefinedfunction.eval *)

function defun(AItem: ItemPointer; var Stack: FunctionStackType;
               var VariableTable: VariableTableType): ItemPointer;

  label
    EndDefun;

  var
    temp: FunctionStackType;
    LambdaList,temp1: ItemPointer;
    id: symboltype;

  begin (* defun.eval *)
    id:=AItem^.Cdr^.Car^.Symbol;
    newitem(LambdaList);
    LambdaList^.ItemType:=ConsI;
    LambdaList^.Cdr:=AItem^.Cdr^.Cdr;
    newitem(LambdaList^.Car);
    LambdaList^.Car^.ItemType:=SymbolI;
    LambdaList^.Car^.Symbol:='LAMBDA';
    temp1:=LambdaList^.Cdr^.Car;
    if not islist(temp1) then
      begin
        temp1:=errorloop('BAD PARAMETER LIST',LambdaList^.Cdr^.Car,
                         AItem,VariableTable);
        goto EndDefun
      end;
    while temp1<>Nil do
      if not isvsymbol(temp1^.Car) then
        begin
          temp1:=errorloop('BAD PARAMETER LIST',LambdaList^.Cdr^.Car,
                           AItem,VariableTable);
          goto EndDefun
        end
      else
        temp1:=temp1^.Cdr;
    temp:=isdefinedfunction(id,Stack);
    if temp=Nil then
      begin
        new(temp);
        temp^.Next:=Stack;
        temp^.Name:=id;
        Stack:=temp
      end;
    temp^.LambdaList:=copyitem(LambdaList);
    temp1:=AItem^.Cdr^.Car;
    EndDefun:
    defun:=temp1
  end; (* defun.eval *)

function dofunctionlist(Stack: FunctionStackType): ItemPointer;

  var
    res,temp,temp1: ItemPointer;

  begin (* dofunctionlist.eval *)
    res:=Nil;
    while Stack<>Nil do
      begin
        newitem(temp);
        temp^.ItemType:=SymbolI;
        temp^.Symbol:=Stack^.Name;
        newitem(temp1);
        temp1^.ItemType:=ConsI;
        temp1^.Car:=temp;
        temp1^.Cdr:=res;
        res:=temp1;
        Stack:=Stack^.Next
      end;
    dofunctionlist:=res
  end; (* dofunctionlist.eval *)

function dovariablelist(VarTab: VariableTableType; first: boolean;
                        thelist: ItemPointer): ItemPointer;

  var
    res,temp1,temp2,temp3,temp4: ItemPointer;
    tempvar: VariablePointer;

  begin (* dovariablelist.eval *)
    if VarTab=Nil then
      dovariablelist:=thelist
    else
      begin
        if first then
          res:=Nil
        else
          begin
            newitem(res);
            res^.ItemType:=ConsI;
            res^.Car:=thelist;
            res^.Cdr:=Nil
          end;
        tempvar:=VarTab^.Variables;
        while tempvar<>Nil do
          begin
            newitem(temp1);
            temp1^.ItemType:=SymbolI;
            temp1^.Symbol:=tempvar^.Symbol;
            newitem(temp2);
            temp2^.ItemType:=ConsI;
            temp2^.Car:=temp1;
            temp2^.Cdr:=res;
            res:=temp2;
            tempvar:=tempvar^.Next
          end;
        dovariablelist:=dovariablelist(VarTab^.Next,false,res)
      end
  end; (* dovariablelist.eval *)

function propmember(AItem: ItemPointer; AAtom: SymbolType): ItemPointer;

  begin (* propmember.eval *)
    while (AItem<>Nil) and (AItem^.Car^.Symbol<>AAtom) do
      AItem:=AItem^.Cdr;
    propmember:=AItem
  end; (* propmember.eval *)

function eql(AItem,BItem: ItemPointer): boolean;

  var
    equal: boolean;

  begin (* eql.eval *)
    equal:=False;
    if (AItem=BItem) then
      equal:=True
    else
      if (AItem<>Nil) and (BItem<>Nil) and (AItem^.ItemType=BItem^.ItemType) then
        case AItem^.ItemType of
          SymbolI: equal:=AItem^.Symbol=BItem^.Symbol;
          IntegerI: equal:=AItem^.theInteger=BItem^.theInteger;
          FloatI: equal:=AItem^.Float=BItem^.Float;
          StringI: equal:=AItem^.theString=BItem^.theString;
          RatioI: equal:=(AItem^.Ratio.num*BItem^.Ratio.den) =
                         (AItem^.Ratio.den*BItem^.Ratio.num);
          ConsI: begin
                   equal:=eql(AItem^.Car,BItem^.Car);
                   if equal then
                     equal:=eql(AItem^.Cdr,BItem^.Cdr)
                 end
        end; (* case *)
    eql:=equal
  end; (* eql.eval *)

function member(AItem,BItem: ItemPointer; eqf: boolean): ItemPointer;

  begin (* member.eval *)
    if eqf then
      while (BItem<>Nil) and not(AItem=BItem^.Car) do
        BItem:=BItem^.Cdr
    else
      while (BItem<>Nil) and not(eql(AItem,BItem^.Car)) do
        BItem:=BItem^.Cdr;
    member:=BItem
  end; (* member.eval *)

function intersection(AItem,BItem: ItemPointer; yes: Boolean): ItemPointer;

  (* also does set-difference when yes=False *)

  var
    res,temp1: ItemPointer;

  begin (* intersection.eval *)
    res:=Nil;
    while AItem<>Nil do
      if notornull(member(AItem^.Car,BItem,False))<>yes then
        begin
          newitem(temp1);
          temp1^.ItemType:=ConsI;
          temp1^.Cdr:=res;
          temp1^.Car:=AItem^.Car;
          res:=temp1;
          AItem:=AItem^.Cdr
        end
      else
        AItem:=AItem^.Cdr;
    intersection:=res
  end; (* intersection.eval *)

function union(AItem,BItem: ItemPointer; Unn: boolean): ItemPointer;

  (* when Unn=False performs xor *)

  var
    res,temp1,temp2,temp3: ItemPointer;

  begin (* union.eval *)
    if Unn then
      res:=intersection(AItem,BItem,True)
    else
      res:=Nil;
    temp1:=intersection(AItem,BItem,False);
    temp2:=intersection(BItem,AItem,False);
    if res=nil then
      res:=temp1
    else
      if temp1<>Nil then
        begin
          temp3:=res;
          while temp3^.Cdr<>Nil do
            temp3:=temp3^.Cdr;
          temp3^.Cdr:=temp1
        end;
    if res=Nil then
      res:=temp2
    else
      if temp2<>Nil then
        begin
          temp3:=res;
          while temp3^.Cdr<>Nil do
            temp3:=temp3^.Cdr;
          temp3^.Cdr:=temp2
        end;
    union:=res
  end; (* union.eval *)

function subset(AItem,BItem: ItemPointer; Ss: boolean): boolean;

  (* does subset when Ss=False *)
  (* does distinct when Ss=True *)

  var
    OK: boolean;

  begin (* subset.eval *)
    OK:=True;
    while OK and (AItem<>Nil) do
      begin
        OK:=Ss=notornull(member(AItem^.Car,BItem,False));
        AItem:=AItem^.Cdr
      end;
    subset:=OK
  end; (* subset.eval *)

function delete(AItem,BItem: ItemPointer): ItemPointer;

  var
    first,temp1: ItemPointer;

  begin (* delete.eval *)
    first:=Nil;
    if not(eql(BItem^.Car,AItem)) then
      first:=BItem;
    while BItem^.Cdr<>Nil do
      begin
        temp1:=BItem^.Cdr^.Car;
        if eql(temp1,AItem) then
          BItem^.Cdr:=BItem^.Cdr^.Cdr
        else
          begin
            if first=Nil then
              first:=BItem^.Cdr;
            BItem:=BItem^.Cdr
          end
      end;
    delete:=first
  end; (* delete.eval *)

procedure reverse(var AItem: ItemPointer);

  var
    temp,temp2: ItemPointer;

  begin (* reverse.eval *)
    if (not(notornull(AItem))) and islist(AItem) and (AItem^.Cdr<>Nil) then
      begin
        temp2:=Nil;
        while AItem<>Nil do
          begin
            newitem(temp);
            temp^.ItemType:=ConsI;
            temp^.Cdr:=temp2;
            temp^.Car:=AItem^.Car;
            temp2:=temp;
            AItem:=AItem^.Cdr
          end;
        AItem:=temp2
      end
  end; (* reverse.eval *)

function apply(AItem,BItem: ItemPointer): ItemPointer;

  var
    temp1,temp2: ItemPointer;

  function applyarg(AItem: ItemPointer): ItemPointer;

    var
      temp1: ItemPointer;

    begin (* applyarg.apply.eval *)
      newitem(temp1);
      temp1^.ItemType:=ConsI;
      temp1^.Car:=truesymbol;
      temp1^.Car^.Symbol:='QUOTE';
      newitem(temp1^.Cdr);
      temp1^.Cdr^.ItemType:=ConsI;
      temp1^.Cdr^.Car:=AItem;
      temp1^.Cdr^.Cdr:=Nil;
      applyarg:=temp1
    end; (* applyarg.apply.eval *)

  begin (* apply.eval *)
    temp2:=Nil;
    if notornull(BItem) then
      begin
        newitem(temp1);
        temp2:=temp1;
        temp1^.ItemType:=ConsI;
        temp1^.Car:=applyarg(BItem^.Car);
        BItem:=BItem^.Cdr;
        while BItem<>Nil do
          begin
            newitem(temp1^.Cdr);
            temp1^.Cdr^.ItemType:=ConsI;
            temp1^.Cdr^.Car:=applyarg(BItem^.Car);
            temp1^.Cdr^.Cdr:=Nil;
            BItem:=BItem^.Cdr;
            temp1:=temp1^.Cdr
          end
      end;
    newitem(temp1);
    temp1^.ItemType:=ConsI;
    temp1^.Car:=AItem;
    temp1^.Cdr:=temp2;
    apply:=temp1
  end; (* apply.eval *)

function pairlisaux(var AItem,BItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* pairlisaux.eval *)
    newitem(temp);
    temp^.ItemType:=ConsI;
    temp^.Car:=AItem^.Car;
    AItem:=AItem^.Cdr;
    newitem(temp^.Cdr);
    temp^.Cdr^.ItemType:=ConsI;
    temp^.Cdr^.Cdr:=Nil;
    temp^.Cdr^.Car:=BItem^.Car;
    BItem:=BItem^.Cdr;
    pairlisaux:=temp
  end; (* pairlisaux.eval *)

function dolet(AItem: ItemPointer;
               var VariableTable: VariableTableType): ItemPointer;

  label
    EndLet;

  var
    temp: VariableTableType;
    temp1,temp2,temp3: ItemPointer;

  begin  (* dolet.eval *)
    new(temp);
    temp^.Next:=VariableTable;
    temp^.Variables:=Nil;
    temp1:=AItem^.Cdr^.Car;
    GWholeVariableTable:=temp;
    while temp1<>Nil do
      begin
        temp3:=temp1^.Car;
        if not (islist(temp3) and isvsymbol(temp3^.Car) and
                (temp3^.Cdr<>Nil)) then
          begin
            GWholeVariableTable:=VariableTable;
            dolet:=errorloop('BAD VARIABLE LIST TO LET',temp3,
                             AItem,VariableTable);
            goto EndLet
          end;
        temp2:=eval(temp3^.Cdr^.Car,VariableTable);
        temp^.Next:=Nil;
        setq(temp3^.Car^.Symbol,temp2,temp);
        temp^.Next:=VariableTable;
        temp1:=temp1^.Cdr
      end;
    temp1:=AItem^.Cdr^.Cdr;
    temp2:=Nil;
    while temp1<>Nil do
      begin
        temp2:=eval(temp1^.Car,temp);
        temp1:=temp1^.Cdr
      end;
    dolet:=temp2;
    EndLet:
    temp^.Next:=Nil;
    GWholeVariableTable:=VariableTable;
    flushvartable(temp)
  end; (* dolet.eval *)

function dodo(AItem: ItemPointer;
              var VariableTable: VariableTableType): ItemPointer;

  label
    EndDo;

  var
    temp2,ExitClause,Parms,Body,temp3: ItemPointer;
    ptemp,temp: VariableTableType;
    stemp: VariablePointer;

  begin (* dodo.eval *)
    ExitClause:=AItem^.Cdr^.Cdr^.Car;
    Parms:=AItem^.Cdr^.Car;
    new(temp);
    temp^.Next:=VariableTable;
    temp^.Variables:=Nil;
    GWholeVariableTable:=temp;
    while Parms<>Nil do
      begin
        temp3:=Parms^.Car;
        if not (islist(temp3) and isvsymbol(temp3^.Car) and
                (temp3^.Cdr<>Nil)) then
          begin
            GWholeVariableTable:=VariableTable;
            dodo:=errorloop('BAD VARIABLE LIST TO DO',temp3,
                             AItem,VariableTable);
            goto EndDo
          end;
        temp2:=eval(temp3^.Cdr^.Car,VariableTable);
        temp^.Next:=Nil;
        setq(temp3^.Car^.Symbol,temp2,temp);
        temp^.Next:=VariableTable;
        Parms:=Parms^.Cdr
      end;
    ptemp:=Nil;
    if notornull(ExitClause) then
      dodo:=Nil
    else
      begin
        new(ptemp);
        ptemp^.Next:=temp;
        GWholeVariableTable:=ptemp;
        ptemp^.Variables:=Nil;
        temp3:=AItem^.Cdr^.Cdr^.Cdr;
        while notornull(eval(ExitClause^.Car,temp)) do
          begin
            Body:=temp3;
            while Body<>Nil do
              begin
                temp2:=eval(Body^.Car,temp);
                Body:=Body^.Cdr
              end;
            Parms:=AItem^.Cdr^.Car;
            while Parms<>Nil do
              begin
                temp2:=Parms^.Car^.Cdr^.Cdr;
                if temp2<>Nil then
                  begin
                    temp2:=eval(temp2^.Car,temp);
                    ptemp^.Next:=Nil;
                    setq(Parms^.Car^.Car^.Symbol,temp2,ptemp);
                    ptemp^.Next:=temp
                  end;
                Parms:=Parms^.Cdr
              end;
            Parms:=AItem^.Cdr^.Car;
            ptemp^.Next:=Nil;
            while Parms<>Nil do
              begin
                stemp:=isdefinedsymbol(Parms^.Car^.Car^.Symbol,ptemp);
                if stemp<>Nil then
                  setq(stemp^.Symbol,stemp^.Item,temp);
                Parms:=Parms^.Cdr
              end;
            ptemp^.Next:=temp
          end;
        GWholeVariableTable:=temp;
        ptemp^.Next:=Nil;
        flushvartable(ptemp);
        while ExitClause<>Nil do
          begin
            temp2:=eval(ExitClause^.Car,temp);
            ExitClause:=ExitClause^.Cdr
          end;
        dodo:=temp2
      end;
    EndDo:
    temp^.Next:=Nil;
    GWholeVariableTable:=VariableTable;
    flushvartable(temp)
  end; (* dodo.eval *)

function doprog(AItem: ItemPointer;
                Var VariableTable: VariableTableType): ItemPointer;

  label
    EndProg;

  var
    temp: VariableTableType;
    temp1,temp2,temp3: ItemPointer;

  begin (* doprog.eval *)
    new(temp);
    temp^.Next:=VariableTable;
    GWholeVariableTable:=temp;
    temp^.Variables:=Nil;
    temp1:=AItem^.Cdr^.Car;
    while temp1<>Nil do
      begin
        temp3:=temp1^.Car;
        if not (islist(temp3) and isvsymbol(temp3^.Car) and
                (temp3^.Cdr<>Nil)) then
          begin
            GWholeVariableTable:=VariableTable;
            doprog:=errorloop('BAD VARIABLE LIST TO PROG',temp3,
                             AItem,VariableTable);
            goto EndProg
          end;
        temp2:=eval(temp3^.Cdr^.Car,VariableTable);
        temp^.Next:=Nil;
        setq(temp3^.Car^.Symbol,temp2,temp);
        temp^.Next:=VariableTable;
        temp1:=temp1^.Cdr
      end;
    temp1:=AItem^.Cdr^.Cdr;
    while (temp1<>Nil) and not(GProgReturn) do
      begin
        temp2:=temp1^.Car;
        if temp2^.ItemType<>ConsI then
          temp1:=temp1^.Cdr
        else
          begin
            temp3:=eval(temp2,temp);
            if GProgGo then
              begin
                GProgGo:=False;
                if not issymbol(temp3) then
                  begin
                    doprog:=errorloop('ILLEGAL USE OF GO',temp2,
                                      AItem,temp);
                    goto EndProg
                  end;
                temp1:=propmember(AItem^.Cdr^.Cdr,temp3^.Symbol)
              end
            else
              temp1:=temp1^.Cdr
          end
      end;
    doprog:=temp3;
    GProgReturn:=False;
    EndProg:
    temp^.Next:=Nil;
    GWholeVariableTable:=VariableTable;
    flushvartable(temp)
  end; (* doprog.eval *)

function dosetf(AItem: ItemPointer; var VariableTable: VariableTableType): ItemPointer;

  label
    EndDoSetf;

  var
    temp1,temp2,temp3: ItemPointer;
    ftemp: FunctionStackType;
    stemp: VariablePointer;
    id: SymbolType;

  begin (* dosetf.eval *)
    temp1:=AItem^.Cdr^.Car;
    temp2:=eval(AItem^.Cdr^.Cdr^.Car,VariableTable);
    if issymbol(temp1) then
      if not isvsymbol(temp1) then
        temp2:=errorloop('NOT A VALID SYMBOL',temp1,AItem,
                         VariableTable)
      else
        setq(temp1^.Symbol,temp2,VariableTable)
    else
      begin
        if (not issymbol(temp1^.Car)) or notornull(temp1^.Cdr) then
          begin
            temp2:=errorloop('BAD ARG TO SETF',temp1,AItem,VariableTable);
            goto EndDoSetf
          end;
        id:=temp1^.Car^.Symbol;
        temp3:=eval(temp1^.Cdr^.Car,VariableTable);
        if id='CAR' then
          if isatom(temp3) then
            begin
              temp2:=errorloop('RESULT NOT A VALID LIST',
                               temp1^.Cdr^.Car,AItem,VariableTable);
              goto EndDoSetf
            end
          else
            begin
              temp3^.Car:=temp2;
              goto EndDoSetf
            end;
        if id='CDR' then
          if isatom(temp3) then
            begin
              temp2:=errorloop('RESULT NOT A VALID LIST',
                               temp1^.Cdr^.Car,AItem,VariableTable);
              goto EndDoSetf
            end
          else
            begin
              temp3^.Cdr:=temp2;
              goto EndDoSetf
            end;
        if id='LAST' then
          if isatom(temp3) then
            begin
              temp2:=errorloop('RESULT NOT A VALID LIST',
                               temp1^.Cdr^.Car,AItem,VariableTable);
              goto EndDoSetf
            end
          else
            begin
              while temp3^.Cdr<>Nil do
                temp3:=temp3^.Cdr;
              temp3^.Car:=temp2;
              goto EndDoSetf
            end;

        if not isvsymbol(temp3) then
          begin
            temp2:=errorloop('RESULT NOT A VALID SYMBOL',
                             temp1^.Cdr^.Car,AItem,VariableTable);
            goto EndDoSetf
          end;
        if id='SYMBOL-VALUE' then
          setq(temp3^.Symbol,temp2,VariableTable);
        if id='SYMBOL-PLIST' then
          begin
            stemp:=isdefinedsymbol(temp3^.Symbol,VariableTable);
            if stemp=Nil then
              begin
                setq(temp3^.Symbol,Nil,VariableTable);
                stemp:=isdefinedsymbol(temp3^.Symbol,VariableTable)
              end;
            stemp^.PropList:=temp2
          end;
        if id='SYMBOL-FUNCTION' then
          begin
            newitem(temp1);
            temp1^.ItemType:=ConsI;
            temp1^.Car:=truesymbol;
            temp1^.Car^.Symbol:='DEFUN';
            temp1^.Cdr:=copyitem(temp2);
            temp1^.Cdr^.Car:=temp3;
            temp3:=defun(temp1,FunctionStack,VariableTable)
          end;
        if id='SYMBOL-MACRO' then
          begin
            newitem(temp1);
            temp1^.ItemType:=ConsI;
            temp1^.Car:=truesymbol;
            temp1^.Car^.Symbol:='DEMACRO';
            temp1^.Cdr:=copyitem(temp2);
            temp1^.Cdr^.Car:=temp3;
            temp3:=defun(temp1,MacroStack,VariableTable)
          end;
      end;
    EndDoSetf:
    dosetf:=temp2
  end; (* dosetf.eval *)

function dolambda(AItem: ItemPointer;
                  var VariableTable: VariableTableType;
                  ReEval: Boolean): ItemPointer;

  var
    temp: VariableTableType;
    temp1,temp2,temp3: ItemPointer;

  begin (* dolambda.eval *)
    new(temp);
    temp^.Next:=VariableTable;
    temp^.Variables:=Nil;
    GWholeVariableTable:=temp;
    if not(notornull(AItem^.Car^.Cdr^.Car)) then
      begin
        temp1:=AItem^.Car^.Cdr^.Car;
        temp2:=AItem^.Cdr;
        while (temp1<>Nil) and (temp2<>Nil) do
          begin
            if ReEval then
              temp3:=eval(temp2^.Car,VariableTable)
            else
              temp3:=temp2^.Car;
            temp^.Next:=Nil;
            setq(temp1^.Car^.Symbol,temp3,temp);
            temp^.Next:=VariableTable;
            temp1:=temp1^.Cdr;
            temp2:=temp2^.Cdr
          end;
        if temp1<>Nil then
          begin (* set extra args to Nil *)
            temp^.Next:=Nil;
            while temp1<>Nil do
              begin
                setq(temp1^.Car^.Symbol,Nil,temp);
                temp1:=temp1^.Cdr
              end;
            temp^.Next:=VariableTable
          end
      end;
    temp1:=AItem^.Car^.Cdr^.Cdr;
    temp2:=Nil;
    while temp1<>Nil do
      begin
        temp2:=eval(temp1^.Car,temp);
        temp1:=temp1^.Cdr
      end;
    dolambda:=temp2;
    temp^.Next:=Nil;
    GWholeVariableTable:=VariableTable;
    flushvartable(temp)
  end; (* dolambda.eval *)

function domap(Item,AItem,BItem: ItemPointer; l,r: boolean;
               VariableTable: VariableTableType): ItemPointer;

  var
    res,res1,temp1,temp2,temp3: ItemPointer;
    OK: boolean;

  function evallist(BItem: ItemPointer;
                    VariableTable: VariableTableType): ItemPointer;

    var
      res,temp1: ItemPointer;

    begin (* evallist.domap *)
      res:=Nil;
      BItem:=copyitem(BItem);
      if BItem<>Nil then
        begin
          newitem(res);
          res^.ItemType:=ConsI;
          res^.Car:=eval(BItem^.Car,VariableTable);
          res^.Cdr:=Nil;
          temp1:=res;
          BItem:=BItem^.Cdr
        end
      else
        res:=Nil;
      while BItem<>Nil do
        begin
          newitem(temp1^.Cdr);
          temp1:=temp1^.Cdr;
          temp1^.ItemType:=ConsI;
          temp1^.Car:=eval(BItem^.Car,VariableTable);
          temp1^.Cdr:=Nil;
          BItem:=BItem^.Cdr
        end;
      evallist:=res
    end; (* evallist.domap *)

  begin (* domap *)
    BItem:=evallist(BItem,VariableTable); (* makes a copy and evals each element *)
    if not r then
      res1:=copyitem(BItem^.Car)
    else
      res1:=nil;
    temp1:=BItem;
    OK:=True;
    while (temp1<>Nil) and OK do
      begin
        OK:=not issymbol(temp1^.Car);
        temp1:=temp1^.Cdr
      end;
    if not OK then
      res1:=errorloop('BAD ARG TO MAP',Item^.Cdr^.Cdr,
                      Item,VariableTable);
    while OK and not(notornull(BItem^.Car)) do
      begin
        if l then
          begin
            temp1:=apply(AItem,BItem);
            temp3:=eval(temp1,VariableTable)
          end
        else
          begin
            temp1:=Nil;
            temp2:=BItem;
            while temp2<>Nil do
              begin
                newitem(temp3);
                temp3^.ItemType:=ConsI;
                temp3^.Car:=temp2^.Car^.Car;
                temp3^.Cdr:=temp1;
                temp1:=temp3;
                temp2:=temp2^.Cdr
              end;
            temp2:=apply(AItem,temp1);
            temp3:=eval(temp2,VariableTable)
          end;
        if r then
          begin
            if res1=Nil then
              begin
                newitem(res);
                res1:=res
              end
            else
              begin
                newitem(res^.Cdr);
                res:=res^.Cdr
              end;
            res^.ItemType:=ConsI;
            res^.Car:=temp3;
            res^.Cdr:=Nil;
          end;
        temp1:=BItem;
        while temp1<>Nil do
          begin
            temp1^.Car:=temp1^.Car^.Cdr;
            OK:=OK and (not notornull(temp1^.Car));
            temp1:=temp1^.Cdr
          end
      end;
    domap:=res1
  end; (* domap *)

begin
  GScope:=Static
end. (* unit evalfuns *)
