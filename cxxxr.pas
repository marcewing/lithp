                if length(func) in [4..6] then
                  begin  (* CxxxxR *)
                    x:=length(func);
                    if (func[1]='C') and (func[x]='R') then
                      begin
                        x:=x-1;
                        found:=True;
                        temp1:=truesymbol;
                        temp1^.Symbol:='';
                        while (x>1) and found do
                          if func[x] in ['A','D'] then
                            begin
                              temp1^.Symbol:=temp1^.Symbol+func[x];
                              x:=x-1
                            end
                          else
                            found:=False;
                        if found then
                          begin
                            temp2:=eval(AItem^.Cdr^.Car,VariableTable);
                            for x:=1 to length(temp1^.Symbol) do
                              if temp1^.Symbol[x]='A' then
                                temp2:=temp2^.Car
                              else
                                temp2:=temp2^.Cdr;
                            eval:=temp2;
                            goto GEndFunc
                          end
                      end
                  end;  (* CxxxxR *)

