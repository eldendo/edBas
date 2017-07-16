(* a very simple basic interpreter
* (c)2017 by ir. Marc Dendooven *)
program edBas;
uses sysutils;

const lastLine = 9999; 

var line: string;
    lp: integer; // pointer in 'line'
    prog: array[1..lastLine] of string;
    quit: boolean = true;
    
    function number: integer;
    begin
	number := 0;    
	while (line[lp]) in ['0'..'9'] do begin number := number*10+ord(line[lp])-ord('0'); inc(lp) end;
    end;
    
    procedure addLine;
    begin
	prog[number] := trim(rightStr(line,length(line)-lp))
    end;
    
    procedure execLine;
    
	procedure list;
	var i: integer;
	begin
		for i := 1 to lastLine do if prog[i]<>'' then writeln(i,' ',prog[i])
	end;
    
    begin
	if      leftstr(line,4) = 'LIST' then list
	else if leftstr(line,4) = 'EXIT' then begin writeln('bye'); quit := true; end
	else if leftstr(line,3) = 'REM' then // do nothing
	else writeln('SYNTAX ERROR') 
    end;

    procedure evaluate;
    begin
	line := upCase(trim(line)); lp := 1;
	if line[lp] in ['0'..'9'] then addLine else execLine
    end;

begin
    writeln('+-----------------------------------------+');
    writeln('| edBas  V0.0 DEV                         |');
    writeln('| (c)2017 by ir. Marc Dendooven           |');
    writeln('| This is a very simple BASIC interpreter |');
    writeln('+-----------------------------------------+');
    writeln;
    
    repeat // Read Evaluate Loop
	write('>');
	readln(line);
	evaluate
    until quit 
end. 
