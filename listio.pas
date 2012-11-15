(* listio.pas for Lithp 3.0a2 *)
(* (c) 1989 Marc Ewing      *)

unit listio;

interface
uses listaux;

procedure readitem(var AItem: ItemPointer; auxfile: boolean; var infile: text);
procedure writeitem(AItem: ItemPointer; var outfile: text);

implementation
uses lithpaux,crt;

const
  TabLength= 10;

procedure readitem(var AItem: ItemPointer; auxfile: boolean; var infile: text);

  label
    skip;

  type
    StringPointer= ^StringNode;
    StringNode= record
                  Ch: char;
                  Next,Last: StringPointer
                end;

  var
    a,c: StringPointer;
    ch: char;
    Parens,i: integer;
    Done,quotes: boolean;

  function makeitem(var a: StringPointer): ItemPointer;

    var
      temp2: ItemPointer;

    function makeatom(var a: StringPointer): ItemPointer;

      var
        temp: ItemPointer;
        astring,bstring: string[32];
        rat: boolean;
        x: integer;

      begin (* makeatom.makeitem.readitem *)
        temp:=truesymbol;
        x:=0;
        if (a<>Nil) and (a^.Ch='"') then
          begin (* get a string *)
            temp^.ItemType:=StringI;
            temp^.theString:='';
            a:=a^.next;
            dispose(a^.Last);
            a^.Last:=Nil;
            while (a<>Nil) and (a^.Ch<>'"') do
              begin
                temp^.theString:=temp^.theString+a^.Ch;
                a:=a^.Next;
                dispose(a^.Last);
                a^.Last:=Nil
              end;
            if a<>Nil then
              if a^.Next<>Nil then
                begin
                  a:=a^.Next;
                  dispose(a^.Last);
                  a^.Last:=Nil
                end
              else
                begin
                  dispose(a);
                  a:=Nil
                end
          end
        else
          if ((a<>Nil) and (a^.Ch in ['+','-']) and
             (a^.next<>Nil) and (ord(a^.next^.Ch)<=ord('9'))
             and (ord(a^.next^.Ch)>=ord('0'))) or
             ((ord(a^.Ch)<=ord('9')) and (ord(a^.Ch)>=ord('0'))) then
            begin (* get a number *)
              rat:=false;
              astring:='';
              bstring:='';
              while (a<>Nil) and
                    not(a^.Ch in ['(',' ',')','''',',','`','"']) do
                begin
                  if a^.Ch='/' then
                    rat:=true
                  else
                    if not rat then
                      astring:=astring+a^.Ch
                    else
                      bstring:=bstring+a^.Ch;
                  if a^.Next<>Nil then
                    begin
                      a:=a^.Next;
                      dispose(a^.Last);
                      a^.Last:=Nil
                    end
                  else
                    begin
                      dispose(a);
                      a:=Nil
                    end
                end;
              if rat then
                begin
                  temp^.ItemType:=RatioI;
                  val(astring,temp^.Ratio.num,x);
                  val(bstring,temp^.Ratio.den,x)
                end
              else
                begin
                  val(astring,temp^.theInteger,x);
                  if x=0 then
                    temp^.ItemType:=IntegerI
                  else
                    begin
                      temp^.ItemType:=FloatI;
                      val(astring,Temp^.Float,x)
                    end
                end
            end
          else
            begin (* get a symbol *)
              x:=0;
              temp^.Symbol:='';
              while (x<SymbolLength) and (a<>Nil)
                    and not(a^.Ch in ['(',' ',')','''',',','`','"']) do
                begin
                  x:=x+1;
                  temp^.Symbol:=temp^.Symbol+a^.Ch;
                  if a^.Next<>Nil then
                    begin
                      a:=a^.Next;
                      dispose(a^.Last);
                      a^.Last:=Nil
                    end
                  else
                    begin
                      dispose(a);
                      a:=Nil
                    end
                end;
              while (a<>Nil) and not(a^.Ch in ['(',' ',')','''',',','`','"']) do
                if a^.Next<>Nil then
                  begin
                    a:=a^.Next;
                    dispose(a^.Last);
                    a^.Last:=Nil
                  end
                else
                  begin
                    dispose(a);
                    a:=Nil
                  end
            end;
        if (temp^.ItemType=SymbolI) and (temp^.Symbol='NIL') then
          makeatom:=Nil
        else
          makeatom:=temp
      end; (* makeatom.makeitem.readitem *)

    function makelist(var a: StringPointer): ItemPointer;

      var
        temp1,temp2: ItemPointer;

      begin (* makelist.makeitem.readitem *)
        newitem(temp1);
        temp1^.ItemType:=ConsI;
        a:=a^.Next;
        dispose(a^.Last);
        a^.Last:=Nil;
        while a^.Ch=' ' do
          begin
            a:=a^.Next;
            dispose(a^.Last);
            a^.Last:=Nil
          end;
        if a^.Ch=')' then
          begin
            if a^.Next<>Nil then
              begin
                a:=a^.Next;
                dispose(a^.Last);
                a^.Last:=Nil
              end
            else
              begin
                dispose(a);
                a:=Nil
              end;
            makelist:=Nil
          end
        else
          begin
            temp2:=makeitem(a);
            temp1^.Car:=temp2;
            new(a^.Last);
            a^.Last^.Ch:='(';
            a^.Last^.Next:=a;
            a:=a^.Last;
            temp1^.Cdr:=makelist(a);
            makelist:=temp1
          end
      end; (* makelist.makeitem.readitem *)

    begin (* makeitem.readitem *)
      while (a<>Nil) and (a^.Ch=' ') do
        if a^.Next<>Nil then
          begin
            a:=a^.Next;
            dispose(a^.Last);
            a^.Last:=Nil
          end
        else
          begin
            dispose(a);
            a:=Nil
          end;
      if a<>Nil then
        case a^.Ch of
          '(': makeitem:=makelist(a);
          '''','`',',':
                begin
                  if (a^.Ch=',') and (a^.Next<>Nil) and (a^.Next^.Ch='@') then
                    begin
                      a:=a^.Next;
                      if (a<>Nil) and (a^.Last<>Nil) then
                        begin
                          dispose(a^.Last);
                          a^.Last:=Nil
                        end
                     end;
                  newitem(temp2);
                  temp2^.ItemType:=ConsI;
                  temp2^.Car:=trueSymbol;
                  case a^.Ch of
                    '''': temp2^.Car^.Symbol:='QUOTE';
                    '`': temp2^.Car^.Symbol:='BACKQUOTE';
                    ',': temp2^.Car^.Symbol:='COMMA';
                    '@': temp2^.Car^.Symbol:='COMMA-AT'
                  end;
                  if a^.Next<>Nil then
                    begin
                      a:=a^.Next;
                      dispose(a^.Last);
                      a^.Last:=Nil
                    end
                  else
                    begin
                      dispose(a);
                      a:=Nil
                    end;
                  newitem(temp2^.Cdr);
                  temp2^.Cdr^.ItemType:=ConsI;
                  temp2^.Cdr^.Car:=makeitem(a);
                  temp2^.Cdr^.Cdr:=Nil;
                  makeitem:=temp2
                end;
          else (* case *)
            makeitem:=makeatom(a)
        end (* case *)
      else
        makeitem:=Nil
    end; (* makeitem.readitem *)

  begin (* readitem *)
    Done:=False;
    quotes:=False;
    Parens:=0;
    new(a);
    a^.Ch:=' ';
    c:=a;
    a^.Last:=Nil;
    write(GDebugLevel,':',Parens,':>');
    repeat
      if auxfile then
        if eof(infile) then
          ch:=#27
        else
          read(infile,ch)
      else
        ch:=readkey;
      case ord(ch) of
        13: begin (* return *)
              write(ch);
              write(chr(10));
              if (a=c) or quotes then
                write(GDebugLevel,':',Parens,':>')
              else
                if Parens=0 then
                  Done:=true
                else
                  write(GDebugLevel,':',Parens,':>')
            end; (* return *)
        40: begin (* ( *)
              if not quotes then
                Parens:=Parens+1;
              write(ch);
              a^.Ch:=ch;
              new(a^.Next);
              a^.Next^.Last:=a;
              a:=a^.Next
            end; (* ( *)
        41: begin (* ) *)
              if not quotes then
                Parens:=Parens-1;
              write(ch);
              a^.Ch:=ch;
              new(a^.Next);
              a^.Next^.Last:=a;
              a:=a^.Next
            end; (* ) *)
        27: begin (* escape *)
              writeln('-TERMINATED-');
              Parens:=0;
              quotes:=False;
              while a^.Last<>Nil do
                begin
                  a:=a^.Last;
                  dispose(a^.Next);
                  a^.Next:=Nil
                end;
              a^.Ch:=' ';
              dispose(a);
              AItem:=Nil;
              goto skip
            end;
        8: (* backspace *)
           if a^.Last<>Nil then
             begin
               a:=a^.Last;
               dispose(a^.Next);
               a^.Next:=Nil;
               if a^.Ch='"' then
                 quotes:=not quotes;
               if (a^.Ch=')') and (not quotes) then
                 Parens:=Parens+1;
               if (a^.Ch='(') and (not quotes) then
                 Parens:=Parens-1;
               a^.Ch:=' ';
               write(chr(8));
               write(' ');
               write(chr(8))
             end;
        9: (* tab *)
           for i:=1 to TabLength do
             begin
               a^.Ch:=' ';
               write(' ');
               new(a^.Next);
               a^.Next^.Last:=a;
               a:=a^.Next
             end;
        10: (* line feed *)
            begin
            end
        else (* case *)
          begin
            write(ch);
            if ch='"' then
              quotes:=not quotes;
            if quotes then
              a^.Ch:=ch
            else
              a^.Ch:=upcase(ch);
            new(a^.Next);
            a^.Next^.Last:=a;
            a:=a^.Next
          end
      end (* case *)
    until Done;
    a:=a^.Last;
    dispose(a^.Next);
    a^.Next:=Nil;
    AItem:=makeitem(c);
    while (c<>Nil) do
      if c^.Next<>Nil then
        begin
          c:=c^.Next;
          dispose(c^.Last);
          c^.Last:=Nil
        end
      else
        begin
          dispose(c);
          c:=Nil
        end;
    skip:
  end; (* readitem *)

procedure writeitem(AItem: ItemPointer; var outfile: text);

  procedure dowrite(AItem: ItemPointer; Parens: boolean);

    begin (* dowrite.writeitem *)
      if notornull(AItem) then
        write('NIL')
      else
        case AItem^.ItemType of
          SymbolI:  write(outfile,AItem^.Symbol);
          IntegerI: write(outfile,AItem^.theInteger);
          FloatI: write(outfile,AItem^.Float);
          RatioI: write(outfile,AItem^.Ratio.Num,'/',AItem^.Ratio.Den);
          StringI: write(outfile,'"',AItem^.theString,'"');
          FileI: write(outfile,'File:',GFileTable[aitem^.thefile].fn);
          ConsI: begin
                   if Parens then
                     write(outfile,'(');
                   dowrite(AItem^.Car,True);
                   if AItem^.Cdr<>Nil then
                     begin
                       write(outfile,' ');
                       dowrite(AItem^.Cdr,False)
                     end;
                   if Parens then
                     write(outfile,')')
                 end
        end
    end; (* dowrite.writeitem *)

  begin (* writeitem *)
    dowrite(AItem,True)
  end; (* writeitem *)

end. (* unit listio *)