#=
test_earley:
- Julia version: 1.1.0
- Author: bramb
- Date: 2019-03-08
=#
using Test
using HyperGraphTools.Earley

@testset "Earley 1" begin
    g = Grammar()

    N = Rule("N", [Production("time"), Production("flight"), Production("banana"), Production("flies"), Production("boy"), Production("telescope")])
    D = Rule("D", [Production("the"), Production("a"), Production("an")])
    V = Rule("V", [Production("book"), Production("eat"), Production("sleep"), Production("saw")])
    P = Rule("P", [Production("with"), Production("in"), Production("on"), Production("at"), Production("through")])

    PP = Rule("PP")
    NP = Rule("NP", [Production([D, N]), Production("john"), Production("houston")])
    push!(NP,Production([NP, PP]))
    push!(PP,Production([P, NP]))

    VP = Rule("VP", Production([V, NP]))
    push!(VP,Production([VP, PP]))
    S = Rule("S", [Production([NP, VP]), Production([VP])])
#     @show(S)

    push!(g,S)
    push!(g,N)
    push!(g,D)
    push!(g,V)
    push!(g,P)
    push!(g,PP)
    push!(g,NP)
    push!(g,VP)
#     @show(g)

    grammar_string = str(g)
    expected = """
    S -> NP VP | VP
    PP -> P NP
    NP -> D N | "john" | "houston" | NP PP
    P -> "with" | "in" | "on" | "at" | "through"
    N -> "time" | "flight" | "banana" | "flies" | "boy" | "telescope"
    V -> "book" | "eat" | "sleep" | "saw"
    VP -> V NP | VP PP
    D -> "the" | "a" | "an"
    """

    @test grammar_string == expected
    println(grammar_string)

    tokens = ["book", "the", "flight", "through", "houston"]
    state = earley_parse(tokens,g)
    println(str(state))

    tokens = ["john", "saw", "the", "boy", "with", "the", "telescope"]
    state = earley_parse(tokens,g)
    println(str(state))
end

@testset "Earley 2" begin
    g = Grammar()

    SYM = Rule("SYM", Production("a"))
    OP = Rule("OP", Production("+"))
    EXPR = Rule("EXPR", Production([SYM]))
    push!(EXPR,Production([EXPR, OP, EXPR]))
    S = Rule("S", [Production([EXPR])])

    push!(g,S)
    push!(g,SYM)
    push!(g,OP)
    push!(g,EXPR)

    grammar_string = str(g)
    expected = """
    EXPR -> SYM | EXPR OP EXPR
    S -> EXPR
    SYM -> "a"
    OP -> "+"
    """

    @test grammar_string == expected
    println(grammar_string)

    tokens = ["a", "+", "a", "+", "a", "+", "a"]
    state = earley_parse(tokens,g)
    println(str(state))
end