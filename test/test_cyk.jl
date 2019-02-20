#=
test_cyk:
- Julia version:
- Author: bramb
- Date: 2019-02-15
=#
using Test

@testset "CYK" begin
    using HyperGraphTools.CYK

    r1 = Rule("S", ("A","B")) # S -> A B
    @test CYK.non_terminals(r1) == ["S", "A", "B"]

    r2 = Rule("A", "a") # A -> a
    @test CYK.non_terminals(r2) == ["A"]

    r3 = Rule("B", "b") # B -> b
    @test CYK.non_terminals(r3) == ["B"]

    r4 = Rule("A", ("AA","C")) # A -> AA C
    @test CYK.non_terminals(r4) == ["A", "AA", "C"]

    r5 = Rule("C", "c") # C -> c
    @test CYK.non_terminals(r5) == ["C"]

    r6 = Rule("AA", "ä") # C -> c
    @test CYK.non_terminals(r6) == ["AA"]

    g = Grammar([],[],Dict{Int64,Array{Int64,1}}())
    add_rule!(g,r1)
    add_rule!(g,r2)
    add_rule!(g,r3)
    add_rule!(g,r4)
    add_rule!(g,r5)
    add_rule!(g,r6)

    it = CYK.index_triples(g)
    @test it == [(1, 2, 3), (2, 4, 5)] # (S->A B, A -> AA C)

    @test validate(["ä", "c", "b"],g)
    @test !validate(["x", "y", "z"],g)
    @test validate(["a", "b"],g)

    r1 = Rule("S",("NP","VP"))  # 1
    r2a = Rule("NP",("DET","N"))# 2
    r2b = Rule("NP","she")      # 3
    r3a = Rule("VP",("VP","PP"))# 4
    r3b = Rule("VP",("V","NP")) # 5
    r3c = Rule("VP","eats")     # 6
    r4 = Rule("DET","a")        # 7
    r5a = Rule("N","fish")      # 8
    r5b = Rule("N","fork")      # 9
    r6 = Rule("PP",("P","NP"))  # 10
    r7 = Rule("V","eats")       # 11
    r8 = Rule("P","with")       # 12
    g = Grammar([],[],Dict{Int64,Array{Int64,1}}())
    add_rule!(g,r1)
    add_rule!(g,r2a)
    add_rule!(g,r2b)
    add_rule!(g,r3a)
    add_rule!(g,r3b)
    add_rule!(g,r3c)
    add_rule!(g,r4)
    add_rule!(g,r5a)
    add_rule!(g,r5b)
    add_rule!(g,r6)
    add_rule!(g,r7)
    add_rule!(g,r8)
    @test g.nonTerminals == ["S", "NP", "VP", "DET", "N", "PP", "V", "P"]
    @test g.ruleIndex == Dict(
        1=>[1],
        2=>[2, 3],
        3=>[4, 5, 6],
        4=>[7],
        5=>[8, 9],
        6=>[10],
        7=>[11],
        8=>[12]
    )
    @test CYK.index_triples(g) == [(1, 2, 3), (2, 4, 5), (3, 3, 6), (3, 7, 2), (6, 8, 2)]
#     println(CYK.lhs_index(g,"she"))
#     println(CYK.lhs_index(g,"eats"))
#     println(CYK.lhs_index(g,"a"))
#     println(CYK.lhs_index(g,"fish"))
#     println(CYK.lhs_index(g,"with"))
#     println(CYK.lhs_index(g,"a"))
#     println(CYK.lhs_index(g,"fork"))
    @test validate(["she", "eats", "a", "fish", "with", "a", "fork"],g)
end
