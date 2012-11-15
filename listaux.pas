(* listaux.pas for lithp 3.0a2 *)
(* (c) 1989 Marc Ewing         *)

unit listaux;

interface

(* can remove islist checks on isequal...isnotequal *)

const
  SymbolLength= 16;
  MaxStringLength= 16;

type
  SymbolType= string[SymbolLength];
  StringType= string[MaxStringLength];
  RatioType= record
               Num,Den: integer
             end;

  (* The ItemRec is the basic data element. *)
  (* All data is some type of an ItemRec.   *)

  ItemTypeType= (SymbolI,ConsI,IntegerI,FloatI,RatioI,StringI,FileI);
  ItemPointer= ^ItemRec;
  ItemRec= record
             Used: boolean;
             case ItemType: ItemTypeType of
               IntegerI: (theInteger: integer);
               FileI: (theFile: byte);
               FloatI: (Float: real);
               RatioI: (Ratio: RatioType);
               StringI: (TheString: StringType);
               SymbolI: (Symbol: SymbolType);
               ConsI: (Car,Cdr: ItemPointer)
           end;

  (* The variable table is used to keep track of symbols' *)
  (* values and proplists.  The table set-up is used to   *)
  (* create a lexically or dynamically scoped programming *)
  (* environment as preferred by the programmer.  As a    *)
  (* default, Lithp is lexically (staticly) scoped.       *)

  VariablePointer= ^VariableType;
  VariableType= record
                  Next: VariablePointer;
                  Symbol: SymbolType;
                  Item: ItemPointer;
                  PropList: ItemPointer
                end;
  VariableTableType= ^TableType;
  TableType= record
               Next: VariableTableType;
               Variables: VariablePointer
             end;

  (* The FunctionStack (and MacroStack) keep track of *)
  (* lambda bindings of symbols (or macro bindings).  *)
  (* All functions are global to the system.          *)

  FunctionStackType= ^FunctionType;
  FunctionType= record
                  Next: FunctionStackType;
                  Name: SymbolType;
                  LambdaList: ItemPointer
                end;

var

  GVariableTable: VariableTableType;

  (* GWholeVariableTable is a global vaiable that mirrors        *)
  (* GVariableTable so gc always knows the current VariableTable *)

  (* During some evaluations it is necessary to create an       *)
  (* additional variabletable yet not let the rest of Lithp     *)
  (* know about it.  But gc must always know all the cons cells *)
  (* that are in use so it won't trash them.                    *)

  GWholeVariableTable: VariableTableType;

  FunctionStack,MacroStack: FunctionStackType;

  prog_mark: procedure;
  prog_init: procedure;
  prog_flush: procedure;

procedure initvartable(var VT: VariableTableType);

procedure markcons(AItem: ItemPointer);
function gc(VariableTable: VariableTableType): integer;
procedure newitem(var AItem: ItemPointer);
function notornull(AItem: ItemPointer): boolean;
function isatom(AItem: ItemPointer): boolean;
function issymbol(AItem: ItemPointer): boolean;
function isvsymbol(AItem: ItemPointer): boolean;
function islist(AItem: ItemPointer): boolean;
function isnumber(AItem: ItemPointer): boolean;
function isint(AItem: ItemPointer): boolean;
function isfloat(AItem: ItemPointer): boolean;
function isratio(AItem: ItemPointer): boolean;
function getint(AItem: ItemPointer): integer;
function isrational(AItem: ItemPointer): boolean;
function getreal(AItem: ItemPointer): real;
function oddp(AItem: ItemPointer): boolean;
function evenp(AItem: ItemPointer): boolean;
function plusp(AItem: ItemPointer): boolean;
function minusp(AItem: ItemPointer): boolean;
function iszero(AItem: ItemPointer): boolean;
function isequal(AItem,BItem: ItemPointer): boolean;
function islessequal(AItem,BItem: ItemPointer): boolean;
function isgreaterequal(AItem,BItem: ItemPointer): boolean;
function isless(AItem,BItem: ItemPointer): boolean;
function isgreater(AItem,BItem: ItemPointer): boolean;
function isnotequal(AItem,BItem: ItemPointer): boolean;
function truesymbol: ItemPointer;
function getnumerator(AItem: ItemPointer): integer;
function getdenomenator(AItem: ItemPointer): integer;
function gcd(q,r: integer): integer;
procedure reduce(var R: RatioType);
function plus(AItem,BItem: ItemPointer): ItemPointer;
function sub(AItem,BItem: ItemPointer): ItemPointer;
function mult(AItem,BItem: ItemPointer): ItemPointer;
function realdiv(AItem,BItem: ItemPointer): ItemPointer;
function intmod(AItem,BItem: ItemPointer): ItemPointer;
function intdiv(AItem,BItem: ItemPointer): ItemPointer;
function sine(AItem: ItemPointer): ItemPointer;
function cosine(AItem: ItemPointer): ItemPointer;
function arctn(AItem: ItemPointer): ItemPointer;
function expon(AItem: ItemPointer): ItemPointer;
function nlog(AItem: ItemPointer): ItemPointer;
function absol(AItem: ItemPointer): ItemPointer;
function trnc(AItem: ItemPointer): ItemPointer;
function doround(AItem: ItemPointer): ItemPointer;
function sqrrt(AItem: ItemPointer): ItemPointer;
function copyitem(AItem: ItemPointer): ItemPointer;
procedure flushvartable(var a: VariableTableType);
procedure flushmem;
function numberconscells: integer;

implementation

type
  (* The ItemCellStack is used to keep track of all the  *)
  (* data in use by the programmer.  The 'Used' field in *)
  (* ItemRec is used with the ItemCellStack to perform   *)
  (* efficient garbage collection.                       *)

  ItemCellStackType= ^ItemCellType;
  ItemCellType= record
                  Next: ItemCellStackType;
                  ItemCell: ItemPointer
                end;

var
  ItemCellStack: ItemCellStackType;
  GStartMem: ^byte;

procedure initvartable(var VT: VariableTableType);

  begin (* initvartable *)
    new(VT);
    VT^.Next:=Nil;
    VT^.Variables:=Nil
  end; (* initvartable *)

procedure markcons(AItem: ItemPointer);

  begin (* markcons *)
    if AItem<>Nil then
      begin
        if AItem^.ItemType=ConsI then
          begin
            markcons(AItem^.Car);
            markcons(AItem^.Cdr)
          end;
        AItem^.Used:=True
      end
  end; (* markcons *)

function gc(VariableTable: VariableTableType): integer;

  const
    Dot= 50;  (* '.' interval during gc *)

  var
    temp,temp1: ItemCellStackType;
    ftemp: FunctionStackType;
    vtemp: VariableTableType;
    ptemp: VariablePointer;
    x: integer;

  begin (* gc *)
    write('Collecting Garbage...');
    temp:=ItemCellStack;
    while temp<>Nil do
      begin
        temp^.ItemCell^.Used:=False;
        temp:=temp^.Next
      end;
    ftemp:=FunctionStack;
    while ftemp<>Nil do
      begin
        markcons(ftemp^.LambdaList);
        ftemp:=ftemp^.Next
      end;
    ftemp:=MacroStack;
    while ftemp<>Nil do
      begin
        markcons(ftemp^.LambdaList);
        ftemp:=ftemp^.Next
      end;
    vtemp:=VariableTable;
    while vtemp<>Nil do
      begin
        ptemp:=vtemp^.Variables;
        while ptemp<>Nil do
          begin
            markcons(ptemp^.Item);
            markcons(ptemp^.PropList);
            ptemp:=ptemp^.Next
          end;
        vtemp:=vtemp^.Next
      end;

    prog_mark;  (* defined by program *)

    temp:=ItemCellStack;
    x:=0;
    while (temp<>Nil) and (temp^.ItemCell^.Used=False) do
      begin
        dispose(temp^.ItemCell);
        x:=x+1;
        temp1:=temp;
        temp:=temp^.Next;
        dispose(temp1)
      end;
    ItemCellStack:=temp;
    if temp<>Nil then
      while temp^.Next<>Nil do
        if temp^.Next^.ItemCell^.Used=True then
          temp:=temp^.Next
        else
          begin
            if (x div Dot)=(x/Dot) then
              write('.');
            temp1:=temp^.Next;
            temp^.Next:=temp1^.Next;
            dispose(temp1^.ItemCell);
            x:=x+1;
            dispose(temp1)
          end;
    gc:=x;
    writeln(' Done.')
  end; (* gc *)

procedure newitem(var AItem: ItemPointer);

  (* gc should be called with the global variable GWholeVariableTable *)
  (* to insure complete garbage collection during evals          *)

  var
    ctemp: ItemCellStackType;
    x: integer;

  begin (* newitem *)
    new(ctemp);
    new(ctemp^.ItemCell);
    AItem:=ctemp^.ItemCell;
    ctemp^.Next:=ItemCellStack;
    ItemCellStack:=ctemp
  end; (* newitem *)


function notornull(AItem: ItemPointer): boolean;

  begin (* notornull *)
    notornull:=(AItem=Nil) or (AItem^.Symbol='NIL')
  end; (* notornull *)

function isatom(AItem: ItemPointer): boolean;

  begin (* isatom *)
    isatom:=(notornull(AItem)) or (AItem^.ItemType<>ConsI)
  end; (* isatom *)

function issymbol(AItem: ItemPointer): boolean;

  begin (* issymbol *)
    issymbol:=notornull(AItem) or (AItem^.ItemType=SymbolI)
  end; (* issymbol *)

function isvsymbol(AItem: ItemPointer): boolean;

  begin (* isvsymbol *)
    isvsymbol:=(not(notornull(AItem))) and (AItem^.ItemType=SymbolI) and
               (AItem^.Symbol<>'T')
  end; (* isvsymbol *)

function islist(AItem: ItemPointer): boolean;

  begin (* islist *)
    islist:=(notornull(AItem)) or (AItem^.ItemType=ConsI)
  end; (* islist *)

function isnumber(AItem: ItemPointer): boolean;

  begin (* isnumber *)
    isnumber:=(AItem<>Nil) and
              ((AItem^.Itemtype=IntegerI) or
              (AItem^.ItemType=FloatI) or
              (AItem^.ItemType=RatioI))
  end; (* isnumber *)

function isint(AItem: ItemPointer): boolean;

  var
    x,y: integer;

  begin (* isint *)
    isint:=(AItem<>Nil) and (AItem^.ItemType=IntegerI)
  end; (* isint *)

function isfloat(AItem: ItemPointer): boolean;

  var
    x,y: integer;

  begin (* isfloat *)
    isfloat:=(AItem<>Nil) and (AItem^.ItemType=FloatI)
  end; (* isfloat *)

function isratio(AItem: ItemPointer): boolean;

  var
    x,y: integer;

  begin (* isratio *)
    isratio:=(AItem<>Nil) and (AItem^.ItemType=RatioI)
  end; (* isratio *)

function getint(AItem: ItemPointer): integer;

  (* no error checking *)

  begin (* getint *)
    getint:=AItem^.theInteger
  end; (* getint *)

function isrational(AItem: ItemPointer): boolean;

  begin (* isrational *)
    isrational:=(AItem<>Nil) and (AItem^.ItemType in [RatioI,IntegerI])
  end; (* isrational *)

function getreal(AItem: ItemPointer): real;

  begin (* getreal *)
    case AItem^.ItemType of
      FloatI: getreal:=AItem^.float;
      IntegerI: getreal:=AItem^.theInteger*1.0;
      RatioI: getreal:=AItem^.ratio.num/AItem^.ratio.den
    end
  end; (* getreal *)

function oddp(AItem: ItemPointer): boolean;

  begin (* oddp *)
    if (notornull(AItem)) or (AItem^.ItemType<>IntegerI) then
      oddp:=false
    else
      oddp:=odd(AItem^.theInteger)
  end; (* oddp *)

function evenp(AItem: ItemPointer): boolean;

  begin (* evenp *)
    if (notornull(AItem)) or (AItem^.ItemType<>IntegerI) then
      evenp:=false
    else
      evenp:=(not(odd(AItem^.theInteger))) and (AItem^.theInteger<>0)
  end; (* evenp *)

function plusp(AItem: ItemPointer): boolean;

  begin (* plusp *)
    if (notornull(AItem)) or not(isnumber(AItem)) then
      plusp:=false
    else
      plusp:=getreal(AItem) > 0.0
  end; (* plusp *)

function minusp(AItem: ItemPointer): boolean;

  begin (* minusp *)
    if (notornull(AItem)) or not(isnumber(AItem)) then
      minusp:=false
    else
      minusp:=getreal(AItem) < 0.0
  end; (* minusp *)

function iszero(AItem: ItemPointer): boolean;

  begin (* iszero *)
    if (notornull(AItem)) or not(isnumber(AItem)) then
      iszero:=false
    else
      iszero:=getreal(AItem) = 0.0
  end; (* iszero *)

function isequal(AItem,BItem: ItemPointer): boolean;

  begin (* isequal *)
    if islist(AItem) or islist(BItem) or
       (AItem^.ItemType<>BItem^.ItemType) then
      isequal:=false
    else
      case AItem^.ItemType of
        IntegerI: isequal:=AItem^.theInteger=BItem^.theInteger;
        FloatI: isequal:=AItem^.float=BItem^.float;
        RatioI: isequal:=(AItem^.Ratio.num*BItem^.Ratio.den) =
                         (BItem^.Ratio.num*AItem^.Ratio.den);
        StringI: isequal:=AItem^.theString=BItem^.theString;
        SymbolI: isequal:=AItem^.Symbol=BItem^.Symbol
      end (* case *)
  end; (* isequal *)

function islessequal(AItem,BItem: ItemPointer): boolean;

  begin (* islessequal *)
    if islist(AItem) or islist(BItem) or
       (AItem^.ItemType<>BItem^.ItemType) then
      islessequal:=false
    else
      case AItem^.ItemType of
        IntegerI: islessequal:=AItem^.theInteger<=BItem^.theInteger;
        FloatI: islessequal:=AItem^.float<=BItem^.float;
        RatioI: islessequal:=(AItem^.Ratio.num*BItem^.Ratio.den) <=
                         (BItem^.Ratio.num*AItem^.Ratio.den);
        StringI: islessequal:=AItem^.theString<=BItem^.theString;
        SymbolI: islessequal:=AItem^.Symbol<=BItem^.Symbol
      end (* case *)
  end; (* islessequal *)

function isgreaterequal(AItem,BItem: ItemPointer): boolean;

  begin (* isgreaterequal *)
    if islist(AItem) or islist(BItem) or
       (AItem^.ItemType<>BItem^.ItemType) then
      isgreaterequal:=false
    else
      case AItem^.ItemType of
        IntegerI: isgreaterequal:=AItem^.theInteger>=BItem^.theInteger;
        FloatI: isgreaterequal:=AItem^.float>=BItem^.float;
        RatioI: isgreaterequal:=(AItem^.Ratio.num*BItem^.Ratio.den) >=
                         (BItem^.Ratio.num*AItem^.Ratio.den);
        StringI: isgreaterequal:=AItem^.theString>=BItem^.theString;
        SymbolI: isgreaterequal:=AItem^.Symbol>=BItem^.Symbol
      end (* case *)
  end; (* isgreaterequal *)

function isless(AItem,BItem: ItemPointer): boolean;

  begin (* isless *)
    if islist(AItem) or islist(BItem) or
       (AItem^.ItemType<>BItem^.ItemType) then
      isless:=false
    else
      case AItem^.ItemType of
        IntegerI: isless:=AItem^.theInteger<BItem^.theInteger;
        FloatI: isless:=AItem^.float<BItem^.float;
        RatioI: isless:=(AItem^.Ratio.num*BItem^.Ratio.den) <
                         (BItem^.Ratio.num*AItem^.Ratio.den);
        StringI: isless:=AItem^.theString<BItem^.theString;
        SymbolI: isless:=AItem^.Symbol<BItem^.Symbol
      end (* case *)
  end; (* isless *)

function isgreater(AItem,BItem: ItemPointer): boolean;

  begin (* isgreater *)
    if islist(AItem) or islist(BItem) or
       (AItem^.ItemType<>BItem^.ItemType) then
      isgreater:=false
    else
      case AItem^.ItemType of
        IntegerI: isgreater:=AItem^.theInteger>BItem^.theInteger;
        FloatI: isgreater:=AItem^.float>BItem^.float;
        RatioI: isgreater:=(AItem^.Ratio.num*BItem^.Ratio.den) >
                         (BItem^.Ratio.num*AItem^.Ratio.den);
        StringI: isgreater:=AItem^.theString>BItem^.theString;
        SymbolI: isgreater:=AItem^.Symbol>BItem^.Symbol
      end (* case *)
  end; (* isless *)

function isnotequal(AItem,BItem: ItemPointer): boolean;

  begin (* isnotequal *)
    if islist(AItem) or islist(BItem) or
       (AItem^.ItemType<>BItem^.ItemType) then
      isnotequal:=false
    else
      case AItem^.ItemType of
        IntegerI: isnotequal:=AItem^.theInteger<>BItem^.theInteger;
        FloatI: isnotequal:=AItem^.float<>BItem^.float;
        RatioI: isnotequal:=(AItem^.Ratio.num*BItem^.Ratio.den) <>
                         (BItem^.Ratio.num*AItem^.Ratio.den);
        StringI: isnotequal:=AItem^.theString<>BItem^.theString;
        SymbolI: isnotequal:=AItem^.Symbol<>BItem^.Symbol
      end (* case *)
  end; (* isequal *)

function truesymbol: ItemPointer;

  var
    temp: ItemPointer;

  begin (* truesymbol *)
    newitem(temp);
    temp^.ItemType:=SymbolI;
    temp^.Symbol:='T';
    truesymbol:=temp
  end; (* truesymbol *)

function getnumerator(AItem: ItemPointer): integer;

  begin (* getnumerator *)
    if AItem^.ItemType=IntegerI then
      getnumerator:=AItem^.theInteger
    else
      getnumerator:=AItem^.ratio.num
  end; (* getnumerator *)

function getdenomenator(AItem: ItemPointer): integer;

  begin (* getdenomenator *)
    if AItem^.ItemType=IntegerI then
      getdenomenator:=1
    else
      getdenomenator:=AItem^.ratio.den
  end; (* getdenomenator *)

function gcd(q,r: integer): integer;

  begin (* gcd *)
    q:=abs(q);
    r:=abs(r);
    while (q>1) and (r>1) do
      if q>r then
        q:=q-r
      else
        r:=r-q;
    if r=0 then
      gcd:=q
    else
      if q=0 then
        gcd:=r
      else
        gcd:=1
  end; (* gcd *)

procedure reduce(var R: RatioType);

  var
    x: integer;

  begin (* reduce *)
    if ((r.num<0) and (r.den>0)) or
       ((r.den<0) and (r.num>0)) then
      begin
        r.num:=-abs(r.num);
        r.den:=abs(r.den)
      end;
    if (r.num<0) and (r.den<0) then
      begin
        r.num:=abs(r.num);
        r.den:=abs(r.den)
      end;
    if r.num=0 then
      r.den:=1;
    x:=gcd(r.num,r.den);
    r.num:=r.num div x;
    r.den:=r.den div x
  end; (* reduce *)

function plus(AItem,BItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* plus *)
    newitem(temp);
    if isfloat(AItem) or isfloat(BItem) then
      begin
        temp^.ItemType:=FloatI;
        temp^.Float:=getreal(AItem)+getreal(BItem)
      end
    else
      if isratio(AItem) or isratio(BItem) then
        begin
          temp^.ItemType:=RatioI;
          temp^.Ratio.den:=getdenomenator(AItem)*
                           getdenomenator(BItem);
          temp^.Ratio.num:=getnumerator(AItem)*getdenomenator(BItem)+
                           getnumerator(BItem)*getdenomenator(AItem);
          reduce(temp^.Ratio)
        end
      else
        begin
          temp^.ItemType:=IntegerI;
          temp^.theInteger:=AItem^.theinteger+BItem^.theInteger
        end;
    plus:=temp
  end; (* plus *)

function sub(AItem,BItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* sub *)
    newitem(temp);
    if isfloat(AItem) or isfloat(BItem) then
      begin
        temp^.ItemType:=FloatI;
        temp^.Float:=getreal(AItem)-getreal(BItem)
      end
    else
      if isratio(AItem) or isratio(BItem) then
        begin
          temp^.ItemType:=RatioI;
          temp^.Ratio.den:=getdenomenator(AItem)*
                           getdenomenator(BItem);
          temp^.Ratio.num:=getnumerator(AItem)*getdenomenator(BItem)-
                           getnumerator(BItem)*getdenomenator(AItem);
          reduce(temp^.Ratio)
        end
      else
        begin
          temp^.ItemType:=IntegerI;
          temp^.theInteger:=AItem^.theinteger-BItem^.theInteger
        end;
    sub:=temp
  end; (* sub *)

function mult(AItem,BItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* mult *)
    newitem(temp);
    if isfloat(AItem) or isfloat(BItem) then
      begin
        temp^.ItemType:=FloatI;
        temp^.Float:=getreal(AItem)*getreal(BItem)
      end
    else
      if isratio(AItem) or isratio(BItem) then
        begin
          temp^.ItemType:=RatioI;
          temp^.Ratio.den:=getdenomenator(AItem)*
                           getdenomenator(BItem);
          temp^.Ratio.num:=getnumerator(AItem)*getnumerator(BItem);
          reduce(temp^.Ratio)
        end
      else
        begin
          temp^.ItemType:=IntegerI;
          temp^.theInteger:=AItem^.theinteger*BItem^.theInteger
        end;
    mult:=temp
  end; (* mult *)

function realdiv(AItem,BItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* realdiv *)
    newitem(temp);
    temp^.ItemType:=FloatI;
    temp^.float:=getreal(AItem)/getreal(BItem);
    realdiv:=temp
  end; (* realdiv *)

function intmod(AItem,BItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* intmod *)
    newitem(temp);
    temp^.ItemType:=IntegerI;
    temp^.theInteger:=AItem^.theInteger mod BItem^.theInteger;
    intmod:=temp
  end; (* intmod *)

function intdiv(AItem,BItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* intdiv *)
    newitem(temp);
    if (AItem^.ItemType=RatioI) or (BItem^.ItemType=RatioI) then
      begin
        temp^.ItemType:=RatioI;
        temp^.Ratio.num:=getnumerator(AItem)*getdenomenator(BItem);
        temp^.Ratio.den:=getnumerator(BItem)*getdenomenator(AItem);
        reduce(temp^.Ratio)
      end
    else
      begin
        temp^.ItemType:=IntegerI;
        temp^.theInteger:=AItem^.theInteger div BItem^.theInteger
      end;
    intdiv:=temp
  end; (* intdiv *)

function sine(AItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* sine *)
    newitem(temp);
    temp^.ItemType:=FloatI;
    temp^.float:=sin(getreal(AItem));
    sine:=temp
  end; (* sine *)

function cosine(AItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* cosine *)
    newitem(temp);
    temp^.ItemType:=FloatI;
    temp^.float:=cos(getreal(AItem));
    cosine:=temp
  end; (* cosine *)

function arctn(AItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* arctn *)
    newitem(temp);
    temp^.ItemType:=FloatI;
    temp^.float:=arctan(getreal(AItem));
    arctn:=temp
  end; (* arctn *)

function expon(AItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* expon *)
    newitem(temp);
    temp^.ItemType:=FloatI;
    temp^.float:=exp(getreal(AItem));
    expon:=temp
  end; (* expon *)

function nlog(AItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* nlog *)
    newitem(temp);
    temp^.ItemType:=FloatI;
    temp^.float:=ln(getreal(AItem));
    nlog:=temp
  end; (* nlog *)

function absol(AItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* absol *)
    newitem(temp);
    if isint(AItem) then
      begin
        temp^.ItemType:=IntegerI;
        temp^.theInteger:=abs(AItem^.theInteger)
      end
    else
      if isfloat(AItem) then
        begin
          temp^.ItemType:=FloatI;
          temp^.Float:=abs(getreal(AItem))
        end
      else
        begin
          temp^.ItemType:=RatioI;
          temp^.Ratio.num:=abs(AItem^.Ratio.num);
          temp^.Ratio.den:=abs(AItem^.Ratio.den)
        end;
    absol:=temp
  end; (* absol *)

function trnc(AItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* trnc *)
    newitem(temp);
    temp^.ItemType:=IntegerI;
    temp^.theInteger:=trunc(getreal(AItem));
    trnc:=temp
  end; (* trnc *)

function doround(AItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* doround *)
    newitem(temp);
    temp^.ItemType:=IntegerI;
    temp^.theInteger:=round(getreal(AItem));
    doround:=temp
  end; (* round *)

function sqrrt(AItem: ItemPointer): ItemPointer;

  var
    temp: ItemPointer;

  begin (* sqrrt *)
    newitem(temp);
    temp^.ItemType:=FloatI;
    temp^.float:=sqrt(getreal(AItem));
    sqrrt:=temp
  end; (* sqrrt *)

function copyitem(AItem: ItemPointer): ItemPointer;

  var
    BItem: ItemPointer;

  begin (* copyitem *)
    BItem:=Nil;
    if AItem<> Nil then
      begin
        newitem(BItem);
        BItem^.ItemType:=AItem^.ItemType;
        if AItem^.ItemType=ConsI then
          begin
            BItem^.Car:=copyitem(AItem^.Car);
            BItem^.Cdr:=copyitem(AItem^.Cdr)
          end
        else
          case AItem^.ItemType of
            SymbolI: BItem^.symbol:=AItem^.symbol;
            FloatI: BItem^.float:=AItem^.float;
            FileI: BItem^.theFile:=AItem^.theFile;
            IntegerI: BItem^.theinteger:=AItem^.theinteger;
            StringI: BItem^.thestring:=AItem^.thestring;
            RatioI: BItem^.ratio:=AItem^.ratio
          end
      end;
    copyitem:=BItem
  end; (* copyitem *)

procedure flushvartable(var a: VariableTableType);

  var
    temp1: VariableTableType;
    temp: VariablePointer;

  begin (* flushvartable *)
    while a<>Nil do
      begin
        temp1:=a^.Next;
        while a^.Variables<>Nil do
          begin
            temp:=a^.Variables^.Next;
            dispose(a^.Variables);
            a^.Variables:=temp
          end;
        dispose(a);
        a:=temp1
      end
  end; (* flushvartable *)

procedure initstuff;

  begin (* initstuff *)
    initvartable(GVariableTable);
    GWholeVariableTable:=GVariableTable;
    FunctionStack:=Nil;
    MacroStack:=Nil;
    ItemCellStack:=Nil
  end; (* initstuff *)

procedure flushmem;

  begin (* flushmem *)
    prog_flush;

    release(GStartMem);
    new(GStartMem);

    initstuff;
    prog_init
  end; (* flushmem *)

function numberconscells: integer;

  var
    ctemp: ItemCellStackType;
    x: integer;

  begin (* numberconscells *)
    x:=0;
    ctemp:=ItemCellStack;
    while ctemp<>Nil do
      begin
        x:=x+1;
        ctemp:=ctemp^.Next
      end;
    numberconscells:=x
  end; (* numberconscells *)

begin
  new(GStartMem);
  initstuff
end. (* unit *)