(* a very simple basic interpreter
* (c)2017 by ir. Marc Dendooven *)
program edBas;
uses sysutils;

const lastLine = 9999; 

var line: string;
    lp: integer; // pointer in 'line'
    prog: array[1..lastLine] of string;
    lc: integer; // line counter in 'prog'
    terminated: boolean = false;
    
    function number: integer;
    begin
	number := 0;    
	while (line[lp]) in ['0'..'9'] do begin number := number*10+ord(line[lp])-ord('0'); inc(lp) end;
    end;
    
    procedure addLine;
    begin
	lc := 0;
	prog[number] := trim(rightStr(line,length(line)-lp+1))
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
		while lc <= lastLine do
		begin
			if prog[lc] <> '' then begin line := prog[lc]; execLine end;
			inc(lc)
		end
	end;
    
    begin

	if      leftStr(line,5) = 'PRINT' then writeln(rightStr(line, length(line)-5))
	else if leftstr(line,3) = 'REM' then // do nothing
	else if leftStr(line,3) = 'RUN' then run
	else if leftstr(line,4) = 'LIST' then list
	else if leftstr(line,3) = 'NEW' then for lc := 1 to lastLine do prog[lc]:=''
	else if leftstr(line,3) = 'END' then lc := lastLine
	else if leftstr(line,4) = 'EXIT' then begin writeln('bye'); terminated := true; end
	else begin write('SYNTAX ERROR'); if lc > 0 then write(' in line ', lc); writeln; lc := lastLine end 
    end;

    procedure evaluate;
    begin
	line := upCase(trim(line)); lp := 1;
	if line = '' then exit;
	if line[lp] in ['0'..'9'] then addLine else execLine
    end;

begin
    writeln('+-----------------------------------------+');
    writeln('| edBas  V0.0 DEV                         |');
    writeln('| (c)2017 by ir. Marc Dendooven           |');
    writeln('| This is a very simple BASIC interpreter |');
    writeln('| edBas is still under construction       |');
    writeln('| implemented are PRINT(partial), REM,    |');
    writeln('| RUN,LIST,NEW,END and EXIT               |');   
    writeln('+-----------------------------------------+');
    writeln;
    repeat // Read Evaluate Loop
	write('>'); readln(line);
	evaluate
    until terminated 
end. 
