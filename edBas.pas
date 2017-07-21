(* a very simple basic interpreter
* (c)2017 by ir. Marc Dendooven *)
program edBas;
uses sysutils, strutils;

const lastLine = 9999;
      maxStack = 20;

var line: string;
    lp: integer; // pointer in 'line'
    
    prog: array[1..lastLine] of string;
    lc: integer; // line counter in 'prog'
    
    vars: array[1..26] of integer;
    
    stack: array[1..maxStack] of integer;
    sp: integer = 1; //stackpointer
    
    terminated: boolean = false;
    running: boolean = false;
    ch: char;
 
    procedure fatal(e:string);
    begin
	write(e); 
	if running then write(' in line ', lc); writeln; 
	running := false
    end;
 
    procedure push(l: integer);
    begin
	if SP <= maxStack then begin stack[SP] := l; inc(SP) end
			 else fatal('STACK OVERFLOW')
    end;
    
    function pop: integer;
    begin
	if SP > 1 then begin dec(SP); pop := stack[SP] end
		  else fatal('RETURN WITHOUT GOSUB')
    end;

    procedure getCh;
    begin
	inc(lp);
	if lp <= length(line) then ch := line[lp] else ch := #0;
    end;
		
    procedure setCh(pos: integer);
    begin
	lp:= pos-1;
	getCh;
    end;
 
    function number: integer;
    begin
	number := 0;    
	while ch in ['0'..'9'] do begin number := number*10+ord(ch)-ord('0'); getCh end;
    end;
    
    procedure addLine;
    begin
	prog[number] := trim(rightStr(line,length(line)-lp+1))
    end;
 
    procedure clear;
    var i: integer;
    begin
	for i := 1 to 26 do vars[i] := 0
    end;
    
    procedure new;
    begin
	for lc := 1 to lastLine do prog[lc]:=''
    end; 
    
    procedure execLine;

	procedure list;
	var i: integer;
	begin
	    for i := 1 to lastLine do if prog[i]<>'' then writeln(i,' ',prog[i])
	end;
	
	procedure run;
	begin
		lc := 1;
		SP := 1;
		clear;
		running := true;
		while running and(lc <= lastLine)  do
		begin
			if prog[lc] <> '' then begin line := prog[lc]; execLine end;
			inc(lc)
		end
	end;
	
	procedure skipWhite;
	begin
	    while ch in [#1..#32] do getCh
	end;
	
	function num_expression: integer;
	var minus: boolean;
	    val: integer;
	
	    function term: integer;
	    var division: boolean;
		val: integer;
	    
		function factor: integer;
		begin
		    case ch of
		    'A'..'Z': begin factor := vars[ord(ch)-ord('A')+1]; getCh end;
		    '0'..'9': factor := number;
		    '(': begin 
			    getCh; 
			    factor := num_expression(); 
			    if ch <> ')' then fatal('SYNTAX ERROR');
			    getCh
			 end
		    else fatal('SYNTAX ERROR')
		    end
		end;
	    
	    begin //term
		term := factor;
		while ch in ['*','/'] do
		    begin
			if ch = '/' then division := true else division := false;
			getCh;
			val := factor;
			if division then term := term div val
				    else term := term * val
		    end
	    end;
	
	begin //num_expression
	    skipWhite;
	    minus := false;
	    case ch of
	    '+': getch;
	    '-': begin getch; minus := true end
	    end;
	    num_expression := term;
	    if minus then num_expression := -num_expression;
	    skipWhite;
	    while ch in ['+','-'] do
		begin
		    if ch = '-' then minus := true else minus := false;
		    getch;
		    val := term;
		    if minus 	then num_expression := num_expression - val
				else num_expression := num_expression + val
		end
	end;
	
	procedure expr_list;
	var cr: boolean;
	
	    function expression: string;
	    begin
		expression := '';
		skipWhite;
		if ch = #0 then exit;
		if ch = '"' then begin 
				    getCh; 
				    while ch <> '"' do begin expression := expression+ch; getCh end;
				    getCh
				 end
			    else expression := intToStr(num_expression)
	    end;
	
	begin //expr_list
	    write(expression);
	    cr := true;
	    while ch in [',',';'] do begin
					if ch = ',' then write('      ');
					getCh; if ch = #0 then cr := false else write(expression); 
				     end;
	    if cr then writeln;
	end;
	
	procedure let;
	var v: integer;
	begin
	    skipWhite;
	    if ch in ['A'..'Z'] then v := ord(ch)-ord('A')+1 else fatal('SYNTAX ERROR');
	    getCh;
	    skipWhite;
	    if ch <> '=' then fatal('SYNTAX ERROR');
	    getCh;
	    vars[v]:=num_expression
	end;
	
	procedure varlist;
	
	    procedure rdVar;
	    begin
		skipWhite;
		if ch in ['A'..'Z'] then readLn(vars[ord(ch)-ord('A')+1]);
		getCh
	    end;
	
	begin
	    rdVar; while ch = ',' do begin getCh; rdVar end;
	end;
	
	procedure save;
	var i: integer;
	    f: text;
	begin
	    assign(f,'default.bas');
	    rewrite(f);
	    for i := 1 to lastLine do if prog[i]<>'' then writeln(f,i,' ',prog[i]);
	    close(f)
	end;
	
    	procedure load;
	var f: text;
	begin
	    new;
	    assign(f,'default.bas');
	    reset(f);
	    while not eof(f) do begin readln(f,line); setCh(1); addLine end;
	    close(f)
	end;
	
	procedure ifThen;
	var first: integer;
	    relop: boolean;
	begin
	    first := num_expression;
	    case ch of
		'<': begin
			getCh;
			if ch = '=' then begin getCh; if first <= num_expression then relop:=true else relop:=false end
			            else if first < num_expression then relop:=true else relop:=false 
		     end;
		'>': begin
			getCh;
			if ch = '=' then begin getCh; if first >= num_expression then relop:=true else relop:=false end
			            else if first > num_expression then relop:=true else relop:=false 
		     end;
		'=': begin getCh; if first = num_expression then relop:=true else relop:=false end
		else fatal('SYNTAX ERROR')
	    end;
	    if MidStr(line,lp,4) <> 'THEN' then fatal('SYNTAX ERROR');
	    setCh(lp+5);
	    if relop then begin line := trim(rightStr(line,length(line)-lp+1)) ;execLine end 
	end;
	
    begin
	if      leftStr(line,5) = 'PRINT' then begin setCh(6); expr_list end
	else if leftstr(line,4) = 'GOTO' then begin setCh(5); lc := num_expression-1 end	
	else if leftstr(line,3) = 'LET' then begin setCh(4); let; end
	else if leftstr(line,2) = 'IF' then begin setCh(3); ifThen; end	
	else if leftstr(line,5) = 'GOSUB' then begin setCh(6); push(lc); lc := num_expression-1 end
	else if leftstr(line,6) = 'RETURN' then lc := pop		
	else if leftstr(line,5) = 'INPUT' then begin setCh(6);varList end	
	else if leftstr(line,3) = 'REM' then // do nothing
	else if leftStr(line,3) = 'RUN' then run
	else if leftstr(line,5) = 'CLEAR' then clear	
	else if leftstr(line,4) = 'LIST' then list
	else if leftstr(line,3) = 'NEW' then new
	else if leftstr(line,3) = 'END' then lc := lastLine
	else if leftstr(line,4) = 'LOAD' then load
	else if leftstr(line,4) = 'SAVE' then save
	else if leftstr(line,4) = 'EXIT' then begin writeln('bye'); terminated := true; end
	else fatal('SYNTAX ERROR') 
    end;

    procedure evaluate;
    begin
	line := upCase(trim(line)); setCh(1);
	if line = '' then exit;
	if line[lp] in ['0'..'9'] then addLine else execLine
    end;

begin // main
    writeln('+-----------------------------------------+');
    writeln('| Welcome to edBas  V0.1 DEV              |');
    writeln('| (c)2017 by ir. Marc Dendooven           |');
    writeln('| This is a very simple BASIC interpreter |');
    writeln('| edBas is still under construction       |');
    writeln('+-----------------------------------------+');
    writeln;
    new; 
    clear;
    repeat // Read Evaluate Loop
	write('>'); readln(line);
	evaluate
    until terminated 
end. 
