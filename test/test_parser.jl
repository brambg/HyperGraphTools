#=
test_parser:
- Julia version: 1.1.0
- Author: bramb
- Date: 2019-02-13
=#
using Test

@testset "parser" begin
    using HyperGraphTools.Parser
    using HyperGraphTools.SimpleTAGMLTokenizer

    r = my_parse()
    @test r == "Hello World"

    function has_no_errors(x)
        isempty(filter(x -> x.type == SimpleTAGMLTokenizer.ERROR, x))
    end

    function validate(tokens,grammar)
        earley = Earley(grammar)
        validate(earley,tokens)
    end

    # use case 1: 2 layers, full overlap
    tagml1 = "[root>[tag|a>[other|b>one two three<other]<tag]<root]"
    grammar1 = """
    S -> ROOT
    ROOT -> [root> TAG <root]
    TAG -> [tag|a> OTHER <tag]
    OTHER -> [other|b> TEXT <other]
    TEXT -> "one two three"
    """
    chomsky_grammar1 = """
    S -> ROOT
    ROOT -> ROOT_START TAG_ROOT_END
    TAG_ROOT_END -> TAG ROOT_END
    ROOT_START -> [root>
    ROOT_END -> <root]
    TAG -> [tag|a> OTHER <tag]
    OTHER -> [other|b> TEXT <other]
    TEXT -> "one two three"
    """
    t1 = tokenize(tagml1)
    @test has_no_errors(t1)
    grammar = Dict([
      ("S", ["ROOT"]),
      ("ROOT", ["[root>", "TAG", "<root]"]),
      ("TAG", ["[tag|a>", "OTHER", "<tag]"]),
      ("OTHER", ["[other|b>", "TEXT", "<other]"]),
      ("TEXT", ["one two three"])
    ])
    @test validate(t1,grammar)

    # use case 2: 2 layers, partial overlap
    tagml2 = "[root>[tag|a>one [other|b>two<tag] three<other]<root]"
    grammar2 = """
    S -> ROOT
    ROOT -> [root> ROOTBODY <root]
    ROOTBODY -> OPENTAG ROOTBODY | CLOSETAG ROOTBODY | TEXT ROOTBODY | ε
    OPENTAG -> [tag|a> | [other|b>
    CLOSETAG -> <tag] | <other]
    TEXT -> "one " | "two" | " three"
    """
    t2 = tokenize(tagml2)
    @test has_no_errors(t2)


    # use case 3: 2 layers, no overlap
    tagml3 = "[root>[tag|a>one<tag] two [other|b>three<other]<root]"
    grammar3 = """
    S -> ROOT
    ROOT -> [root> ROOTBODY <root]
    ROOTBODY -> (OPENTAG | CLOSETAG | TEXT)+
    OPENTAG -> [tag|a> | [other|b>
    CLOSETAG -> <tag] | <other]
    TEXT -> "one" | " two " | "three"
    """
    t3 = tokenize(tagml3)
    @test has_no_errors(t3)

    # use case 4: 2 layers, shared tags
    tagml4a = "[root|+a,+b>[tag|a,b>[other|a,b>one two three<other]<tag]<root]"
    tagml4b = "[root|+a,+b>[tag|a,b>[other|a,b>[w|a>one<w] [b|b>two<b] three<other]<tag]<root]"
    t4a = tokenize(tagml4a)
    t4b = tokenize(tagml4b)
    @test has_no_errors(t4a)
    @test has_no_errors(t4b)

end

