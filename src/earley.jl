"""
# module Earley

- Julia version:
- Author: bramb
- Date: 2019-02-13

based on https://github.com/tomerfiliba/tau/blob/master/earley3.py

# Examples

```jldoctest
julia>using HyperGraphTools.Earley
```
"""
module Earley

DEBUG = false

import Base.push!, Base.isequal, Base.hash, Base.iterate, Base.length, Base.getindex

export earley_parse,
    str,
    Grammar,
    Rule,
    Production


mutable struct Production
    terms::Vector{}

    Production(term::String) = new([term])

    Production(terms::Vector{}) = new(terms)
end

length(production::Production) = length(production.terms)

getindex(production::Production, i::Int64) = production.terms[i]

isequal(p1::Production, p2::Production) = p1.terms == p2.terms

mutable struct Rule
    name::String
    productions::Vector{Production}

    Rule(name::String) = new(name,[])

    Rule(name::String, production::Production) = new(name,[production])

    Rule(name::String, productions::Vector{Production}) = new(name,productions)
end

push!(rule::Rule, production::Production) = push!(rule.productions, production)

mutable struct Grammar
    rules_index::Dict{String,Rule}

    Grammar() = new(Dict{String,Rule}())
end

push!(grammar::Grammar, rule::Rule) = grammar.rules_index[rule.name] = rule

abstract type AState end

mutable struct Column
    index::Int64
    token::String
    states::Vector{AState}
    _unique::Set{AState}

    Column(index::Int64, token::String) = new(index,token,[],Set())
end

iterate(column::Column) = iterate(column.states)

iterate(column::Column, i::Int64) = iterate(column.states,i)

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
    end_column::Union{Column,Nothing}

    State(name::String, production::Production, dot_index::Int64, start_column::Column) =
      new(name,production,dot_index,start_column,nothing)
end

function Base.isequal(state1::State, state2::State)
    return (state1.name, state1.production, state1.dot_index, state1.start_column) == (state2.name, state2.production, state2.dot_index, state2.start_column)
end

hash(state::State) = hash(state.name) + hash(state.production) + hash(state.dot_index) + hash(state.start_column)

iscompleted(state::State) = state.dot_index - 1 >= length(state.production)

next_term(state::State) = (iscompleted(state)) ? nothing : state.production[state.dot_index]

GAMMA_RULE = "γ"
function earley_parse(tokens, grammar)
    table = [Column(i,token) for (i,token) in enumerate(vcat(["∅"],tokens))]
    start_rule = grammar.rules_index["S"]
    push!(table[1],State(GAMMA_RULE, Production([start_rule]), 1, table[1]))

    for (i, col) in enumerate(table)
        DEBUG && println("## $(i - 1) $(col.token)")
        for state in col.states
            DEBUG && println(str(state))
            if iscompleted(state)
                DEBUG && println("> state $(str(state)) is completed!")
                complete(col,state)
            else
                term = next_term(state)
                DEBUG && println("term = $(str(term))")
                if (isa(term,Rule))
                    predict(col,term)
                    DEBUG && println("after predict: col.states =\n\t", join([str(s) for s in col.states],"\n\t"))
                elseif (i < length(table))
                    scan(table[i + 1], state, term)
                    DEBUG && println("after scan: table[i + 1].states =\n\t", join([str(s) for s in table[i + 1].states],"\n\t"))
                end
            end
            DEBUG && println()
        end
    end
    # find gamma rule in last table column (otherwise fail)
#     gamma_states = filter(s->s.name == GAMMA_RULE, collect(table[end]))
    for state in table[end]
        DEBUG && println(str(state))
        if state.name == GAMMA_RULE && iscompleted(state)
            return state
        end
    end
#     !isempty(gamma_states) && iscompleted(gamma_states[1]) && return gammma_state[1]
    throw("parsing failed")
end

predict(col::Column, rule::Rule) = map(prod -> push!(col, State(rule.name, prod, 1, col)), rule.productions)

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

function str(grammar::Grammar)
    buf = IOBuffer()
    for r in values(grammar.rules_index)
        write(buf,str(r) * "\n")
    end
    return String(take!(buf))
end

function str(rule::Rule)
    lhs = rule.name
    rhs = join(map(str, rule.productions), " | ")
    return "$lhs -> $rhs"
end

function str(production::Production)
    parts = [isa(t,Rule) ? t.name : "\"$t\"" for t in production.terms ]
    return join(parts," ")
end

function str(state::State)
    terms = [isa(t,Rule) ? t.name : "\"$t\"" for t in state.production.terms]
    insert!(terms, state.dot_index, "•")
    _end = state.end_column == nothing ? -1 : state.end_column.index - 1
    return "$(state.name)\t->\t$(join(terms," "))\t\t[$(state.start_column.index - 1)-$(_end)]"
end

str(s::String) = "\"$s\""

# http://matt.might.net/articles/parsing-with-derivatives/
end