(* evaluate.pas for Lithp 3.0a2 *)
(* (c) 1989 Marc Ewing      *)

unit evaluate;

interface
uses listaux;

var
  GProgGo,GProgReturn: Boolean;

function eval(AItem: ItemPointer;
              var VariableTable: VariableTableType): ItemPointer;

implementation
uses evalfuns,lithpaux,funcs0,funcsak,funcslp,funcsqz,listio;

function eval(AItem: ItemPointer;
              var VariableTable: VariableTableType): ItemPointer;

  label
    GEndFunc,GNoFunc,EndEval,
    AFuncs,BFuncs,CFuncs,DFuncs,EFuncs,FFuncs,GFuncs,HFuncs,IFuncs,
    JFuncs,KFuncs,LFuncs,MFuncs,NFuncs,OFuncs,PFuncs,QFuncs,RFuncs,
    SFuncs,TFuncs,UFuncs,VFuncs,WFuncs,XFuncs,YFuncs,ZFuncs;

  var
    BItem,temp4,temp3,temp1,temp2: ItemPointer;
    func: string[16];
    stemp: VariablePointer;
    ftemp: FunctionStackType;
    TempEvalStack: EvalStackType;
    found: boolean;

  begin (* eval *)
    if GTop then
      begin
        eval:=Nil;
        goto EndEval
      end;
    if Sptr<1300 then
      begin (* not enough stack space *)
        writeln;
        writeln('*** YOU GREEDY BASTARD!  YOU TRASHED THE STACK!');
        writeln('*** LAST ATTEMPTED EXPRESSION (NOT COMPLETED):');
        write('*** ');
        writeitem(AItem,output);
        writeln;
        writeln('*** BACK TO TOP LEVEL');
        eval:=Nil;
        GTop:=True;
        goto EndEval
      end;
    if memavail<1000 then
      begin (* not enough heap space *)
        writeln;
        writeln('*** NOT ENOUGH HEAP SPACE TO FINISH THE OPERATION');
        writeln('*** LAST ATTEMPTED EXPRESSION (NOT COMPLETED):');
        write('*** ');
        writeitem(AItem,output);
        writeln;
        writeln('*** BACK TO TOP LEVEL');
        eval:=Nil;
        GTop:=True;
        goto EndEval
      end;
    new(TempEvalStack);
    TempEvalStack^.Next:=GEvalStack;
    TempEvalStack^.Item:=AItem;
    if GEvalStack=Nil then
      TempEvalStack^.Level:=1
    else
      TempEvalStack^.Level:=GEvalStack^.Level+1;
    GEvalStack:=TempEvalStack;
    if isatom(AItem) then
      if notornull(AItem) then
        eval:=Nil
      else
        if (issymbol(AItem)) and (AItem^.Symbol='T') then
          eval:=truesymbol
        else
          if isnumber(AItem) then
            if isratio(AItem) then
              begin
                temp1:=copyitem(AItem);
                reduce(temp1^.Ratio);
                eval:=temp1
              end
            else
              eval:=copyitem(AItem)
          else
            if (AItem^.ItemType=StringI) or
               (AItem^.ItemType=FileI) then
              eval:=copyitem(AItem)
            else
              begin
                stemp:=isdefinedsymbol(AItem^.Symbol,VariableTable);
                if stemp<>Nil then
                  eval:=stemp^.Item
                else
                  eval:=errorloop('SYMBOL HAS NO VALUE:',
                                  AItem,AItem,VariableTable)
              end
    else
      begin
        if AItem^.Car^.ItemType=ConsI then
          if (AItem^.Car^.Car^.ItemType=SymbolI) and
             (AItem^.Car^.Car^.Symbol='LAMBDA') then
            begin
              temp1:=AItem^.Car^.Cdr;
              if (temp1=Nil) or (not islist(temp1)) then
                begin
                  temp1:=errorloop('BAD PARAMETER LIST',temp1,
                                   AItem,VariableTable);
                  goto GEndFunc
                end;
              while temp1<>Nil do
                if not isvsymbol(temp1^.Car) then
                  begin
                    temp1:=errorloop('BAD PARAMETER LIST',temp1,
                                     AItem,VariableTable);
                    goto GEndFunc
                  end
                else
                  temp1:=temp1^.Cdr;
              eval:=dolambda(AItem,VariableTable,True)
            end
          else
            eval:=errorloop('NOT A FUNCTION CLOSURE:',
                            AItem^.Car,AItem,VariableTable)
        else
          begin
            func:=AItem^.Car^.Symbol;
            ftemp:=isdefinedfunction(func,MacroStack);
            if ftemp<>Nil then
              found:=False (* do not evaluate actual parameters *)
            else
              begin
                ftemp:=isdefinedfunction(func,FunctionStack);
                if ftemp<>Nil then
                  found:=True (* evaluate actual parameters *)
              end;
            if ftemp<>Nil then
              begin
                temp1:=copyitem(AItem);
                temp1^.Car:=ftemp^.LambdaList;
                temp2:=dolambda(temp1,VariableTable,found);
                if found then
                  eval:=temp2
                else
                  eval:=eval(temp2,VariableTable) (* eval again, if macro *)
              end
            else
              begin (* system defined functions *)
                BItem:=AItem^.Cdr;

                case func[1] of
                  'A': goto AFuncs;
                  'B': goto BFuncs;
                  'C': goto CFuncs;
                  'D': goto DFuncs;
                  'E': goto EFuncs;
                  'F': goto FFuncs;
                  'G': goto GFuncs;
                  'H': goto HFuncs;
                  'I': goto IFuncs;
                  'J': goto JFuncs;
                  'K': goto KFuncs;
                  'L': goto LFuncs;
                  'M': goto MFuncs;
                  'N': goto NFuncs;
                  'O': goto OFuncs;
                  'P': goto PFuncs;
                  'Q': goto QFuncs;
                  'R': goto RFuncs;
                  'S': goto SFuncs;
                  'T': goto TFuncs;
                  'U': goto UFuncs;
                  'V': goto VFuncs;
                  'W': goto WFuncs;
                  'X': goto XFuncs;
                  'Y': goto YFuncs;
                  'Z': goto ZFuncs;
                end; (* case *)

                (* non-alphabetic functions first *)

                  if func='=' then
                    begin
                      eval:=do_equ(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if (func='<>') or (func='/=') or (func='=/') then
                    begin
                      eval:=do_not_equal(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='+' then
                    begin
                      eval:=do_plus(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='-' then
                    begin
                      eval:=do_sub(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='/'then
                    begin
                      eval:=do_divide(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='>' then
                    begin
                      eval:=do_greater(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if (func='>=') or (func='=>') then
                    begin
                      eval:=do_greater_equal(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='<' then
                    begin
                      eval:=do_less(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if (func='<=') or (func='=<') then
                    begin
                      eval:=do_less_equal(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='*' then
                    begin
                      eval:=do_mult(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                AFuncs:

                  if func='ABS' then
                    begin
                      eval:=do_abs(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='ADJOIN' then
                    begin
                      eval:=do_adjoin(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='AND' then
                    begin
                      eval:=do_and(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='APPEND' then
                    begin
                      eval:=do_append(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='APPLY' then
                    begin
                      eval:=do_apply(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='ARCTAN' then
                    begin
                      eval:=do_arctan(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='ASSOC' then
                    begin
                      eval:=do_assoc(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='ATOM' then
                    begin
                      eval:=do_atom(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                BFuncs:

                  if func='BACKQUOTE' then
                    begin
                      eval:=do_backquote(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='BOUNDP' then
                    begin
                      eval:=do_boundp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='BREAK' then
                    begin
                      eval:=do_break(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='BUTLAST' then
                    begin
                      eval:=do_butlast(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                CFuncs:

                  if func='CAR' then
                    begin
                      eval:=do_car(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='CASE' then
                    begin
                      eval:=do_case(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='CDR' then
                    begin
                      eval:=do_cdr(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='CEILING' then
                    begin
                      eval:=do_ceiling(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='CHAR-INT' then
                    begin
                      eval:=do_char_int(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='CLOSE' then
                    begin
                      eval:=do_close(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='CONCAT' then
                    begin
                      eval:=do_concat(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='CONCAT-SYMBOL' then
                    begin
                      eval:=do_concat_symbol(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='COND' then
                    begin
                      eval:=do_cond(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='CONS' then
                    begin
                      eval:=do_cons(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='CONSP' then
                    begin
                      eval:=do_consp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='CONTINUE' then
                    begin
                      eval:=do_continue(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='COPY' then
                    begin
                      eval:=do_copy(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='COPY-LIST' then
                    begin
                      eval:=do_copy_list(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='COS' then
                    begin
                      eval:=do_cos(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                DFuncs:

                  if func='DEBUG-LEVEL' then
                    begin
                      eval:=do_debug_level(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='DEFMACRO' then
                    begin
                      eval:=do_defmacro(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='DEFUN' then
                    begin
                      eval:=do_defun(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='DELETE' then
                    begin
                      eval:=do_delete(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='DENOMINATOR' then
                    begin
                      eval:=do_denominator(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='DISTINCTP' then
                    begin
                      eval:=do_distinctp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='DIV' then
                    begin
                      eval:=do_div(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='DIVIDE' then
                    begin
                      eval:=do_divide(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='DO' then
                    begin
                      eval:=do_do(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='DYNAMIC' then
                    begin
                      eval:=do_dynamic(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                EFuncs:

                  if func='EOF' then
                    begin
                      eval:=do_eof(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='EQ' then
                    begin
                      eval:=do_eq(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='EQL' then
                    begin
                      eval:=do_eql(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='ERROR' then
                    begin
                      eval:=do_error(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='EVAL' then
                    begin
                      eval:=do_eval(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='EVALSTACK' then
                    begin
                      eval:=do_evalstack(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='EVENP' then
                    begin
                      eval:=do_evenp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='EXIT' then
                    begin
                      eval:=do_exit(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='EXP' then
                    begin
                      eval:=do_exp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                FFuncs:

                  if func='FLOATP' then
                    begin
                      eval:=do_floatp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='FLOOR' then
                    begin
                      eval:=do_floor(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='FLUSHMEM' then
                    begin
                      eval:=do_flushmem(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='FUNCALL' then
                    begin
                      eval:=do_funcall(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='FUNCTION-LIST' then
                    begin
                      eval:=do_function_list(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                GFuncs:

                  if func='GC' then
                    begin
                      eval:=do_gc(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='GCD' then
                    begin
                      eval:=do_gcd(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='GET' then
                    begin
                      eval:=do_get(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='GETF' then
                    begin
                      eval:=do_getf(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='GO' then
                    begin
                      eval:=do_go(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                HFuncs:

                goto GNoFunc; (* fell through *)

                IFuncs:

                  if func='IF' then
                    begin
                      eval:=do_if(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='INT-CHAR' then
                    begin
                      eval:=do_int_char(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='INTEGERP' then
                    begin
                      eval:=do_integerp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='INTERSECTION' then
                    begin
                      eval:=do_intersection(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                JFuncs:
                goto GNoFunc; (* fell through *)

                KFuncs:
                goto GNoFunc; (* fell through *)

                LFuncs:

                  if func='LAST' then
                    begin
                      eval:=do_last(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LENGTH' then
                    begin
                      eval:=do_length(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LET' then
                    begin
                      eval:=do_let(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LIST' then
                    begin
                      eval:=do_list(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LIST-LENGTH' then
                    begin
                      eval:=do_list_length(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LIST*' then
                    begin
                      eval:=do_list_star(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LISTP' then
                    begin
                      eval:=do_listp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LN' then
                    begin
                      eval:=do_ln(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LOAD' then
                    begin
                      eval:=do_load(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LOGAND' then
                    begin
                      eval:=do_logand(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LOGIOR' then
                    begin
                      eval:=do_logior(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LOGNOT' then
                    begin
                      eval:=do_lognot(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LOGSHL' then
                    begin
                      eval:=do_logshl(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LOGSHR' then
                    begin
                      eval:=do_logshr(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='LOGXOR' then
                    begin
                      eval:=do_logxor(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                MFuncs:

                  if func='MACRO-LIST' then
                    begin
                      eval:=do_macro_list(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='MACROEXPAND' then
                    begin
                      eval:=do_macroexpand(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='MAPC' then
                    begin
                      eval:=do_mapc(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='MAPCAR' then
                    begin
                      eval:=do_mapcar(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='MAPL' then
                    begin
                      eval:=do_mapl(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='MAPLIST' then
                    begin
                      eval:=do_maplist(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='MEMBER' then
                    begin
                      eval:=do_member(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if (func='-') or (func='MINUS') then
                    begin
                      eval:=do_sub(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='MINUSP' then
                    begin
                      eval:=do_minusp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='MOD' then
                    begin
                      eval:=do_mod(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='MULT' then
                    begin
                      eval:=do_mult(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                NFuncs:

                  if func='NCONC' then
                    begin
                      eval:=do_nconc(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='NTH' then
                    begin
                      eval:=do_nth(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='NTHCDR' then
                    begin
                      eval:=do_nthcdr(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if (func='NULL') or (func='NOT') then
                    begin
                      eval:=do_null(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='NUMBERP' then
                    begin
                      eval:=do_numberp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='NUMERATOR' then
                    begin
                      eval:=do_numerator(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                OFuncs:

                  if func='ODDP' then
                    begin
                      eval:=do_oddp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='OPENI' then
                    begin
                      eval:=do_openi(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='OPENO' then
                    begin
                      eval:=do_openo(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='OR' then
                    begin
                      eval:=do_or(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                PFuncs:

                  if func='PAIRLIS' then
                    begin
                      eval:=do_pairlis(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='PLUS' then
                    begin
                      eval:=do_plus(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='PLUSP' then
                    begin
                      eval:=do_plusp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='PRIN1' then
                    begin
                      eval:=do_prin1(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='PRINT' then
                    begin
                      eval:=do_print(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='PROG1' then
                    begin
                      eval:=do_prog1(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='PROG2' then
                    begin
                      eval:=do_prog2(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='PROG' then
                    begin
                      eval:=do_prog(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='PROGN' then
                    begin
                      eval:=do_progn(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='PUTPROP' then
                    begin
                      eval:=do_putprop(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                QFuncs:

                  if func='QUOTE' then
                    begin
                      eval:=do_quote(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                RFuncs:

                  if func='RANDOM' then
                    begin
                      eval:=do_random(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='RATIONAL' then
                    begin
                      eval:=do_rational(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='RATIOP' then
                    begin
                      eval:=do_ratiop(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='READ' then
                    begin
                      eval:=do_read(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='REMOVE' then
                    begin
                      eval:=do_remove(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='REMPROP' then
                    begin
                      eval:=do_remprop(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='RETURN' then
                    begin
                      eval:=do_return(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='REVERSE' then
                    begin
                      eval:=do_reverse(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='ROOM' then
                    begin
                      eval:=do_room(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='ROUND' then
                    begin
                      eval:=do_round(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='RPLACA' then
                    begin
                      eval:=do_rplaca(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='RPLACD' then
                    begin
                      eval:=do_rplacd(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                SFuncs:

                  if func='SCOPE' then
                    begin
                      eval:=do_scope(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SET' then
                    begin
                      eval:=do_set(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SET-DIFFERENCE' then
                    begin
                      eval:=do_set_difference(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SET-EQUAL' then
                    begin
                      eval:=do_set_equal(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SET-XOR' then
                    begin
                      eval:=do_set_exclusive_or(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SETF' then
                    begin
                      eval:=do_setf(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SETQ' then
                    begin
                      eval:=do_setq(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SIN' then
                    begin
                      eval:=do_sin(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SQR' then
                    begin
                      eval:=do_sqr(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SQRT' then
                    begin
                      eval:=do_sqrt(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='STATIC' then
                    begin
                      eval:=do_static(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='STRING' then
                    begin
                      eval:=do_string(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='STRINGP' then
                    begin
                      eval:=do_stringp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SUBSETP' then
                    begin
                      eval:=do_subsetp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SYMBOL-FUNCTION' then
                    begin
                      eval:=do_symbol_function(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SYMBOL-MACRO' then
                    begin
                      eval:=do_symbol_macro(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SYMBOL-PLIST' then
                    begin
                      eval:=do_symbol_plist(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SYMBOL-VALUE' then
                    begin
                      eval:=do_symbol_value(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='SYMBOLP' then
                    begin
                      eval:=do_symbolp(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                TFuncs:

                  if func='TERPRI' then
                    begin
                      eval:=do_terpri(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='TOP' then
                    begin
                      eval:=do_top(AItem,VariableTable);
                      goto GEndFunc
                    end;

                  if func='TRUNCATE' then
                    begin
                      eval:=do_truncate(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                UFuncs:

                  if func='UNION' then
                    begin
                      eval:=do_union(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                VFuncs:

                  if func='VARIABLE-LIST' then
                    begin
                      eval:=do_variable_list(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)

                WFuncs:
                goto GNoFunc; (* fell through *)

                XFuncs:
                goto GNoFunc; (* fell through *)

                YFuncs:
                goto GNoFunc; (* fell through *)

                ZFuncs:

                  if func='ZEROP' then
                    begin
                      eval:=do_zerop(AItem,VariableTable);
                      goto GEndFunc
                    end;

                goto GNoFunc; (* fell through *)


                GNoFunc:

                eval:=errorloop('SYMBOL HAS NO FUNCTION DEFINITION:',
                                AItem^.Car,AItem,VariableTable);
                GEndFunc:
              end (* system defined functions *)
          end
      end;
    if GTop then (* GTop could be set during FLUSHMEM *)
      goto EndEval;
    TempEvalSTack:=GEvalStack;
    GEvalStack:=GEvalStack^.Next;
    dispose(TempEvalStack);
    EndEval:
  end; (* eval *)

begin
  GProgGo:=False;
  GProgReturn:=False
end. (* unit evaluate *)