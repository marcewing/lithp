program fix;

var
  s1: string;
  x: integer;

begin
  readln(s1);
  while not eof do
    if copy(s1,1,8)='function' then
      begin
        x:=10;
        while s1[x]<>':' do
          inc(x);
        write(copy(s1,1,x-1));
        writeln('(AItem: ItemPointer;');
        while x<>0 do
          begin
            write(' ');
            dec(x)
          end;
        writeln('var VariableTable: VariableTableType): ItemPointer;');
        readln(s1);
        if s1='' then
          begin
            writeln;
            writeln('  Var');
            writeln('    BItem,temp1,temp2,temp3,temp4: ItemPointer;');
            writeln;
            readln(s1);
            writeln(s1);
            writeln('    BItem:=AItem^.Cdr;');
            readln(s1)
          end
      end
    else
      begin
        writeln(s1);
        readln(s1)
      end;
  writeln(s1)
end.