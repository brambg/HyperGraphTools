#=
test_cyk:
- Julia version:
- Author: bramb
- Date: 2019-02-15
=#

function rhs_matches_terminal(rhs,terminal)
    size(rhs) == 1 && rhs[1] == terminal
end

function rule_index(rules,terminal)
    index = []
    for (i,rule) in enumerate(rules)
        if rhs_matches_terminal(rule[2])
            push!(index,i)
        end
    end
end

function validate(tokens, grammar)
    # grammar rules need to be in chomsky normal form:
    # https://en.wikipedia.org/wiki/Chomsky_normal_form

    # let the input be a string I consisting of n characters: a1 ... an.
    n = size(tokens)

    # let the grammar contain r nonterminal symbols R1 ... Rr, with start symbol R1.
    r = size(grammar)

    # let P[n,n,r] be an array of booleans. Initialize all elements of P to false.
    p = Array{Bool,3}[]
    p = [ false for x in 1:n, y in 1:n, z in 1:r ]

    # for each s = 1 to n
    for s in 1:n
    #   for each unit production Rv → as
        for v in rule_index(grammar,tokens[s])
    #     set P[1,s,v] = true
            p[1,s,v] = true
         end
    end

    # for each l = 2 to n -- Length of span
    for l in 2:n
    #   for each s = 1 to n-l+1 -- Start of span
        for s in 1:n-1+l
    #     for each p = 1 to l-1 -- Partition of span
            for p in 1:l-1
    #       for each production Ra  → Rb Rc
    #         if P[p,s,b] and P[l-p,s+p,c] then set P[l,s,a] = true
            end
        end
    end
    # if P[n,1,1] is true then
    #   I is member of language
    # else
    #   I is not member of language
    return p[n,1,1]
end