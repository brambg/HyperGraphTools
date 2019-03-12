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

function Base.length(production::Production)
    return length(production.terms)
end

function Base.getindex(production::Production, i::Int64)
    return production.terms[i]
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

abstract type AState end

mutable struct Column
    index::Int64
    token::String
    states::Array{AState}
    _unique::Set{AState}

    Column(index::Int64, token::String) = new(index,token,[],Set())
end

function Base.iterate(column::Column)
    return iterate(column.states)
end

function Base.iterate(column::Column, i::Int64)
    return iterate(column.states,i)
end

function Base.push!(column::Column, state::AState)
    if !(state in column._unique)
        push!(column._unique,state)
        state.end_column = column
        push!(column.states, state)
        return true
    else
        return false
    end
end

mutable struct State <: AState
    name::String
    production::Production
    dot_index::Int64
    start_column::Column
    end_column::Column

    State(name::String, production::Production, dot_index::Int64, start_column::Column) =
      new(name,production,dot_index,start_column)
end


function iscompleted(state::State)
    return state.dot_index > length(state.production)
end

function next_term(state::State)
    return (iscompleted(state)) ? nothing : state.production[state.dot_index]
end

# mutable struct Node
#     value
#     children
# end

GAMMA_RULE = "GAMMA"
function earley_parse(tokens, grammar)
    table = [Column(i,token) for (i,token) in enumerate(tokens)]
#     @show(table)
    start_rule = grammar.rules_index["S"]
#     @show(start_rule)
    push!(table[1],State(GAMMA_RULE, Production([start_rule]), 1, table[1]))
#     @show(table)

    for (i, col) in enumerate(table)
#         @show(i,col)
        for state in col.states
#             @show(state)
            if iscompleted(state)
                println("state $state is completed!")
                complete(col,state)
            else
                term = next_term(state)
                @show(term)
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
        if state.name == GAMMA_RULE && iscompleted(state)
            return st
        else
            throw("parsing failed")
        end
    end
end

function predict(col::Column, rule::Rule)
    for prod in rule.productions
        push!(col, State(rule.name, prod, 1, col))
    end
end

function scan(column::Column, state::State, token::String)
    if (token != column.token)
        return nothing
    end
    push!(column, State(state.name, state.production, state.dot_index + 1, state.start_column))
end

function complete(column::Column, state::State)
    if !iscompleted(state)
        return nothing
    end
    for st in state.start_column
        term = next_term(st)
        if !isa(term,Rule)
            continue
        end
        if (term.name == state.name)
            push!(column, State(st.name, st.production, st.dot_index + 1, st.start_column))
        end
    end
end

# http://matt.might.net/articles/parsing-with-derivatives/
end