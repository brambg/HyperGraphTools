#=
test_cyk:
- Julia version:
- Author: bramb
- Date: 2019-02-15
=#

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
  rule_index::Dict{Int,Array{Int,1}}
end
# struct Grammar{X}
#   nonTerminals::Array{X,1}
#   rules::Array{Rule{X},1}
#   rule_index::Dict{Int,Array{Int,1}}
#
# #   function Grammar()
# #       new{X}([],[],Dict{Int,Array{Int}})
# #   end
# end

_is_nonterminal(s::String) = all(c->isuppercase(c), s)

function non_terminals(r::Rule)
    ntSet = Set()
    push!(ntSet,r.lhs) # by definition, the lhs is a nonterminal

    potential_nonterminals = []
    if (typeof(r.rhs) == String)
        push!(potential_nonterminals,r.rhs)
    end
    for e in r.rhs
        if _is_nonterminal(e)
            push!(ntSet,e)
        end
    end
    return collect(ntSet)
end

function add_rule!(g::Grammar, r::Rule)
    for nt in non_terminals(r)
        if !nt in g.nonTerminals
            push!(g.nonTerminals,nt)
        end
    end

    push!(g.rules,r)

    lhs_index = indexin(r.lhs,g.nonTerminals)
    push!(g.rule_index[lhs_index],size(g.rules))
end

function rhs_matches_terminal(rhs, terminal)
    size(rhs) == 1 && rhs[1] == terminal
end

function rule_index(rules, terminal)
    index = []
    for (i,rule) in enumerate(rules)
        if rhs_matches_terminal(rule[2])
            push!(index,i)
        end
    end
end

function index_triples(rules)
    triples = []
    push!(triples,(1,2,3))
end

function validate(tokens, grammar)
    # grammar rules need to be in chomsky normal form:
    # https://en.wikipedia.org/wiki/Chomsky_normal_form

    # let the input be a string I consisting of n characters: a1 ... an.
    n = size(tokens)

    # let the grammar contain r nonterminal symbols R1 ... Rr, with start symbol R1.
    r = size(grammar)

    # let P[n,n,r] be an array of booleans. Initialize all elements of P to false.
    P = Array{Bool,3}[]
    P = [false for x in 1:n, y in 1:n, z in 1:r]

    # for each s = 1 to n
    for s in 1:n
    #   for each unit production Rv → as
        for v in rule_index(grammar,tokens[s])
    #     set P[1,s,v] = true
            P[1,s,v] = true
         end
    end

    # for each l = 2 to n -- Length of span
    for l in 2:n
    #   for each s = 1 to n-l+1 -- Start of span
        for s in 1:n-1+l
    #     for each p = 1 to l-1 -- Partition of span
            for p in 1:l-1
    #       for each production Ra  → Rb Rc
                for (a,b,c) in index_triples(grammar)
    #         if P[p,s,b] and P[l-p,s+p,c] then set P[l,s,a] = true
                    if (P[p,s,b] && P[l-p,s+p,c])
                        P[l,s,a] = true
                    end
                end
            end
        end
    end
    # if P[n,1,1] is true then
    #   I is member of language
    # else
    #   I is not member of language
    return P[n,1,1]
end

function main()
    r1 = Rule("S", ("A","B")) # S -> AB
    show(non_terminals(r1))
    r2 = Rule("A", "a") # A -> a
    show(non_terminals(r2))
    r3 = Rule("B", "b") # B -> b
    show(non_terminals(r3))
    g = Grammar([],[],Dict{Int64,Array{Int64,1}}())
    println(g)
    add_rule!(g,r1)
    add_rule!(g,r2)
    add_rule!(g,r3)
    println(g)
end

main()