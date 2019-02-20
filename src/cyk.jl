"""
# module cyk

- Julia version: 
- Author: bramb
- Date: 2019-02-20

# Examples

```jldoctest
julia>using HyperGraphTools.CYK
julia>g = Grammar()
julia>add_rule!(g, Rule("S",("NP","VP"))) # S -> NP VP
julia>add_rule!(g, Rule("VP",("VP","PP")))
julia>add_rule!(g, Rule("VP",("V","NP")))
julia>add_rule!(g, Rule("VP","eats"))
julia>add_rule!(g, Rule("PP",("P","NP")))
julia>add_rule!(g, Rule("NP",("DET","N")))
julia>add_rule!(g, Rule("NP","she"))
julia>add_rule!(g, Rule("V","eats"))
julia>add_rule!(g, Rule("P","with"))
julia>add_rule!(g, Rule("N","fish"))
julia>add_rule!(g, Rule("N","fork"))
julia>add_rule!(g, Rule("DET","a"))

julia>validate(["she", "eats", "a", "fish", "with", "a", "fork"],g)
true

julia>validate(["with", "a", "fork", "eats", "she", "a", "fish"],g)
false
```
"""
module CYK

export
    Rule,
    Grammar,
    add_rule!,
    validate

struct Rule
    lhs::String
    rhs::Union{String,Tuple{String,String}}
end
# struct Rule{X}
#     lhs::X
#     rhs::Union{X,Tuple{X,X}}
# end

struct Grammar
  nonTerminals::Array{String,1}
  rules::Array{Rule,1}
  ruleIndex::Dict{Int,Array{Int,1}}

  function Grammar()
      new([],[],Dict{Int64,Array{Int64,1}}())
  end
end
# struct Grammar{X}
#   nonTerminals::Array{X,1}
#   rules::Array{Rule{X},1}
#   lhs_index::Dict{Int,Array{Int,1}}
#
# #   function Grammar()
# #       new{X}([],[],Dict{Int,Array{Int}})
# #   end
# end

_is_nonterminal(s::String) = all(c->isuppercase(c), s)

function non_terminals(r::Rule)
    ntSet = []
    push!(ntSet,r.lhs) # by definition, the lhs is a nonterminal

    potential_nonterminals = []
    if (typeof(r.rhs) == String)
        push!(potential_nonterminals,r.rhs)
    elseif (typeof(r.rhs) == Tuple{String,String})
        push!(potential_nonterminals, r.rhs[1])
        push!(potential_nonterminals, r.rhs[2])
    end
    for e in potential_nonterminals
        if _is_nonterminal(e)
            push!(ntSet,e)
        end
    end
    return collect(ntSet)
end

function add_rule!(g::Grammar, r::Rule)
    for nt in non_terminals(r)
        if !(nt in g.nonTerminals)
            push!(g.nonTerminals,nt)
        end
    end

    push!(g.rules,r)

    lhs_index = indexin([r.lhs],g.nonTerminals)[1]
    if (!haskey(g.ruleIndex,lhs_index))
        g.ruleIndex[lhs_index] = []
    end
    push!(g.ruleIndex[lhs_index],size(g.rules)[1]);
end

function rhs_matches_terminal(rhs, terminal)
    rhs == terminal
end

function lhs_index(grammar, terminal)
    index = []
    for rule in grammar.rules
        if rhs_matches_terminal(rule.rhs,terminal)
            push!(index,indexin([rule.lhs],grammar.nonTerminals)[1])
        end
    end
    return index
end

function index_triples(grammar)
    triples = []
    for a in keys(grammar.ruleIndex)
        for ri in grammar.ruleIndex[a]
            rhs = grammar.rules[ri].rhs
            if (typeof(rhs) == Tuple{String,String})
                b = indexin([rhs[1]],grammar.nonTerminals)[1]
                c = indexin([rhs[2]],grammar.nonTerminals)[1]
                push!(triples,(a,b,c))
            end
        end
    end
    return sort(triples)
end

function validate(tokens, grammar)
    # grammar rules need to be in chomsky normal form:
    # https://en.wikipedia.org/wiki/Chomsky_normal_form

    # let the input be a string I consisting of n characters: a1 ... an.
    n = size(tokens)[1]
#     println("n=$n")

    # let the grammar contain r nonterminal symbols R1 ... Rr, with start symbol R1.
    r = size(grammar.nonTerminals)[1]
#     println("r=$r")

    # let P[n,n,r] be an array of booleans. Initialize all elements of P to false.
    P = Array{Bool,3}[]
    P = [false for x in 1:n, y in 1:n, z in 1:r]
#     println(P)

    # for each s = 1 to n
    for s in 1:n
    #   for each unit production Rv → as
        for v in lhs_index(grammar,tokens[s])
    #     set P[1,s,v] = true
            P[1,s,v] = true
#             println("P[1,$s,$v] = true")
         end
    end
#     println(P)

    triples = index_triples(grammar)
#     exit()
    # for each l = 2 to n -- Length of span
    for length in 2:n
    #   for each s = 1 to n-l+1 -- Start of span
#         println("length=$length")
        for s in 1:(n-length+1)
#             println("  start=$s")
    #     for each p = 1 to l-1 -- Partition of span
            for p in 1:(length-1)
#             println("    partition=$p")
    #       for each production Ra  → Rb Rc
                for (a,b,c) in triples
    #         if P[p,s,b] and P[l-p,s+p,c] then set P[l,s,a] = true
#                     println("length=$length,start=$s,partition=$p, (a,b,c)=($a,$b,$c)")
#                     println("P[p,s,b]=$(P[p,s,b])")
#                     println("P[length-p,s+p,c]=$(P[length-p,s+p,c])")
#                     println("      (a,b,c)=($a,$b,$c)=$(grammar.nonTerminals[a])->$(grammar.nonTerminals[b]) $(grammar.nonTerminals[c]), P[p,s,b]=P[$p,$s($(tokens[s])),$b($(grammar.nonTerminals[b]))]=$(P[p,s,b]), P[length-p,s+p,c]=P[$(length-p),$(s+p)($(tokens[s+p])),$c($(grammar.nonTerminals[c]))]=$(P[length-p,s+p,c])")


                    if (P[p,s,b] && P[length-p,s+p,c])
                        P[length,s,a] = true
#                         println("        P[$length,$s($(tokens[s])),$a($(grammar.nonTerminals[a]))]=>true")
                    end
                end
            end
        end
    end
#     println(P)
    # if P[n,1,1] is true then
    #   I is member of language
    # else
    #   I is not member of language
    return P[n,1,1]
end

function show(r::Rule)
    println("$(r.lhs) -> $(r.rhs)")
end

end