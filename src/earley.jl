"""
# module Earley

- Julia version: 
- Author: bramb
- Date: 2019-02-13

# Examples

```jldoctest
julia>using HyperGraphTools.Earley
```
"""
module Earley

import Base.push!

export earley_parse,
    Grammar,
    Rule,
    Production


mutable struct Production
    terms::Array{}

    Production(term::String) = new([term])

    Production(terms::Array{}) = new(terms)
end

mutable struct Rule
    name::String
    productions::Array{Production,1}

    Rule(name::String) = new(name,[])

    Rule(name::String, production::Production) = new(name,[production])

    Rule(name::String, productions::Array{Production,1}) = new(name,productions)
end

function Base.push!(rule::Rule, production::Production)
    push!(rule.productions, production)
end

mutable struct Grammar
    rules_index::Dict{String,Rule}

    Grammar() = new(Dict{String,Rule}())
end

function Base.push!(grammar::Grammar, rule::Rule)
    grammar.rules_index[rule.name] = rule
end

mutable struct Column
    index::Int64
    token::String
    states::Array{}

    Column(index::Int64, token::String) = new(index,token,[])
end

mutable struct State
    name::String
    production::Production
    dot_index::Int64
    start_column::Column
    end_column::Column
    complete::Bool
    next_term

    State(name::String,production::Production,dot_index::Int64,start_column::Column) =
      new(name,production,dot_index,start_column)
end

function Base.push!(column::Column, state::State)
    push!(column.states, state)
end


mutable struct Node
    value
    children
end

GAMMA_RULE = "GAMMA"
function earley_parse(tokens, grammar)
    table = [Column(i,token) for (i,token) in enumerate(vcat([""], tokens))]
    @show(table)
    start_rule = grammar.rules_index["S"]
    @show(start_rule)
    push!(table[1],State(GAMMA_RULE, Production("S"), 0, table[1]))

    for (i, col) in enumerate(table)
        for state in col.states
            if state.complete
                complete(col,state)
            else
                term = state.next_term
                if (isa(term,Rule))
                    predict(col,term)
                elseif (i + 1 < length(table))
                    scan(table[i + 1],state,term)
                end
            end
        end
    end
    # find gamma rule in last table column (otherwise fail)
    for state in table[end]
        if state.name == GAMMA_RULE && state.completed
            return st
        else
            throw("parsing failed")
        end
    end
end

# procedure PREDICTOR((A → α•Bβ, j), k, grammar)
#     for each (B → γ) in GRAMMAR-RULES-FOR(B, grammar) do
#         ADD-TO-SET((B → •γ, k), S[k])
#     end

# procedure SCANNER((A → α•aβ, j), k, words)
#     if a ⊂ PARTS-OF-SPEECH(words[k]) then
#         ADD-TO-SET((A → αa•β, j), S[k+1])
#     end

# procedure COMPLETER((B → γ•, x), k)
#     for each (A → α•Bβ, j) in S[x] do
#         ADD-TO-SET((A → αB•β, j), S[k])
#     end

# http://matt.might.net/articles/parsing-with-derivatives/
end