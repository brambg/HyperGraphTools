#=
test_earley:
- Julia version: 1.1.0
- Author: bramb
- Date: 2019-03-08
=#
using Test

@testset "Earley" begin
    using HyperGraphTools.Earley

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

    println(str(g))

    tokens = ["book", "the", "flight", "through", "houston"]
    state = earley_parse(tokens,g)
    println(str(state))

    tokens = ["john", "saw", "the", "boy", "with", "the", "telescope"]
    state = earley_parse(tokens,g)
    println(str(state))

end