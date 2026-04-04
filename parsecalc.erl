-module(parsecalc).
-export([calculate/1]).

calculate(CalcExpr) ->
	reduce(parse_tokens(CalcExpr)).

reduce([{expression,A}, {chartok,"+"}, {expression,B} | Rest]) ->
	reduce([{expression,A+B}|Rest]);
reduce([{expression,A}, {chartok,"-"}, {expression,B} | Rest]) ->
	reduce([{expression,A-B}|Rest]);
reduce([{expression,A}, {chartok,"*"}, {expression,B} | Rest]) ->
	reduce([{expression,A*B}|Rest]);
reduce([{expression,A}, {chartok,"/"}, {expression,B} | Rest]) ->
	reduce([{expression,A/B}|Rest]);
reduce([{chartok,"("},{expression,A},{chartok,")"} | Rest]) ->
	reduce([{expression,A}|Rest]);
reduce([{expression,A}, {chartok,B}, {chartok,"("} | Rest]) ->
	reduce([{expression,A}, {chartok,B}, {expression,reduce(Rest)}]);
reduce([{expression,A},{chartok,")"} | Rest]) ->
	reduce([{expression,A} | Rest]);
reduce([{expression,A}]) -> A.

parse_tokens(CalcExpr) ->
	parse_tokens(CalcExpr,[]).
parse_tokens([],TokenList) -> TokenList;
parse_tokens(CalcExpr,TokenList) -> parse_whitespace(CalcExpr,TokenList).

parse_whitespace(CalcExpr,TokenList) ->
	case re:run(CalcExpr,"^(\\s+)(.*)$",[{capture,all,list}]) of
		{match,[_,_,Rest]} -> parse_tokens(Rest, TokenList);
		nomatch -> parse_float(CalcExpr,TokenList) end.
		
parse_float(CalcExpr,TokenList) ->
	case re:run(CalcExpr,"^(\\d+\\.\\d+)(.*)$",[{capture,all,list}]) of
		{match,[_,FloatString,Rest]} -> 
			{FloatToken,[]} = string:to_float(FloatString),
			parse_tokens(Rest, lists:append(TokenList,{expression,FloatToken}));
		nomatch -> parse_int(CalcExpr,TokenList) end.
	
parse_int(CalcExpr,TokenList) ->
	case re:run(CalcExpr,"^(\\d+)(.*)$",[{capture,all,list}]) of
		{match,[_,IntString,Rest]} ->
			{IntToken,_} = string:to_integer(IntString),
			parse_tokens(Rest, lists:append(TokenList,[{expression,IntToken}]));
		nomatch -> parse_chartok(CalcExpr,TokenList) end.
		
parse_chartok(CalcExpr,TokenList) ->
	case re:run(CalcExpr,"^([\\n+\\-*/()])(.*)$",[{capture,all,list}]) of
		{match,[_,CharTok,Rest]} -> parse_tokens(Rest, lists:append(TokenList,[{chartok,CharTok}]));
		nomatch -> parse_quit(CalcExpr,TokenList) end.
		
parse_quit(CalcExpr,TokenList) ->
	case re:run(CalcExpr,"^(quit|exit)(.*)$",[{caputre,all,list}]) of
		{match,[_,_,Rest]} -> parse_tokens(Rest, lists:append(TokenList,quit));
		nomatch -> [] end.
		

		

