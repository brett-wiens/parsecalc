-module(parsecalc).
-export([calculate/1,reduce/1,reduce/2,parse/1,parse/2]).

calculate(CalcExpr) ->
	reduce(parse(CalcExpr)).

reduce(TokenList) -> reduce([],TokenList).
reduce([{e,A}, {c,B} | Rest], [{e,C}]) -> reduce(Rest, [{e,A}, {c,B}, {e,C}]);
reduce([{e,A}, {c,B} | LRest], [{e,C}, {c,")"} | RRest]) -> reduce(LRest,[{e,A},{c,B},{e,C}|RRest]);
reduce(L,[{e,A},{c,")"} | Rest]) -> reduce(L,[{e,A} | Rest]);
reduce(L,[{e,A}, {c,"*"}, {e,B} | Rest]) -> reduce(L,[{e,A*B}|Rest]);
reduce(L,[{e,A}, {c,"/"}, {e,B} | Rest]) -> reduce(L,[{e,A/B}|Rest]);
reduce(L,[{e,A}, {c,"+"}, {e,B} | Rest]) -> reduce(L,[{e,A+B}|Rest]);
reduce(L,[{e,A}, {c,"-"}, {e,B} | Rest]) -> reduce(L,[{e,A-B}|Rest]);
reduce(L,[{c,"("},{e,A},{c,")"} | Rest]) -> reduce(L,[{e,A}|Rest]);
reduce(L,[{e,A}, {c,B}, {c,"("} | Rest]) -> reduce([{e,A}, {c,B} | L],Rest);
reduce(L,[{c,"("} | Rest]) -> reduce([{e,0},{c,"+"}|L],Rest);
reduce([],[{e,A}]) -> A.

parse(CalcExpr) -> parse(CalcExpr,[]).
parse([],TokenList) -> TokenList;
parse({w,CalcExpr},TokenList) ->
	case re:run(CalcExpr,"^(\\s+)(.*)$",[{capture,all,list}]) of
		{match,[_,_,Rest]} -> parse(Rest, TokenList);
		nomatch -> parse({f,CalcExpr},TokenList) end;
parse({f,CalcExpr},TokenList) ->
	case re:run(CalcExpr,"^(\\d+\\.\\d+)(.*)$",[{capture,all,list}]) of
		{match,[_,FloatString,Rest]} -> 
			{FloatToken,[]} = string:to_float(FloatString),
			parse(Rest, TokenList++[{e,FloatToken}]);
		nomatch -> parse({i,CalcExpr},TokenList) end;
parse({i,CalcExpr},TokenList) ->
	case re:run(CalcExpr,"^(\\d+)(.*)$",[{capture,all,list}]) of
		{match,[_,IntString,Rest]} ->
			{IntToken,_} = string:to_integer(IntString),
			parse(Rest, TokenList++[{e,IntToken}]);
		nomatch -> parse({c,CalcExpr},TokenList) end;
parse({c,CalcExpr},TokenList) ->
	case re:run(CalcExpr,"^([\\n+\\-*/()])(.*)$",[{capture,all,list}]) of
		{match,[_,CharTok,Rest]} -> parse(Rest, TokenList++[{c,CharTok}]);
		nomatch -> parse({q,CalcExpr},TokenList) end;
parse({q,CalcExpr},TokenList) ->
	case re:run(CalcExpr,"^(quit|exit)(.*)$",[{caputre,all,list}]) of
		{match,[_,_,Rest]} -> parse(Rest, TokenList++[quit]);
		nomatch -> [] end;
parse(CalcExpr,TokenList) -> parse({w,CalcExpr},TokenList).
		
