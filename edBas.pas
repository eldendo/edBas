(* a very simple basic interpreter
* (c)2017 by ir. Marc Dendooven *)

program edBas;
uses sysutils;

var line: string;
    
    procedure addLine;
    begin
	writeln('add line: ',line)
    end;
    
    procedure execLine;
    begin
 	writeln('execute line: ',line)   
    end;

    procedure evaluate;
    begin
	line := trim(line);
	if line[1] in ['0'..'9'] then addLine else execLine
    end;

begin
    writeln('+-----------------------------------------+');
    writeln('| edBas  V0.0 DEV                         |');
    writeln('| (c)2017 by ir. Marc Dendooven           |');
    writeln('| This is a very simple BASIC interpreter |');
    writeln('+-----------------------------------------+');
    writeln;
    
    repeat // Read Evaluate Loop
	writeln('READY.'); write('>');
	readln(line);
	evaluate
    until false 
end. 
