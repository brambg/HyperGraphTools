#=
test_parser:
- Julia version: 1.1.0
- Author: bramb
- Date: 2019-02-13
=#
using Test

function has_no_errors(x)
    isempty(filter(x -> x.type == SimpleTAGMLTokenizer.ERROR, x))
end

@testset "use case 1: 2 layers, full overlap" begin
    using HyperGraphTools.SimpleTAGMLTokenizer
    using HyperGraphTools.CYK

    # use case 1: 2 layers, full overlap
    tagml1 = "[root>[tag|a>[other|b>one two three<other]<tag]<root]"
#     grammar1 = """
#     S -> ROOT
#     ROOT -> [root> TAG <root]
#     TAG -> [tag|a> OTHER <tag]
#     OTHER -> [other|b> TEXT <other]
#     TEXT -> "one two three"
#     """
#     chomsky_grammar1 = """
#     S -> ROOT
#     ROOT -> ROOT_START TAG_ROOT_END
#     TAG_ROOT_END -> TAG ROOT_END
#     ROOT_START -> [root>
#     ROOT_END -> <root]
#     TAG -> TAG_START OTHER_TAG_END
#     OTHER_TAG_END -> OTHER TAG_END
#     TAG_START -> [tag|a>
#     TAG_END -> <tag]
#     OTHER -> OTHER_START TEXT_OTHER_END
#     TEXT_OTHER_END -> TEXT OTHER_END
#     OTHER_START -> [other|b>
#     OTHER_END -> <other]
#     TEXT -> "one two three"
#     """
    tokens = tokenize(tagml1)
    @test has_no_errors(tokens)
    string_tokens = [t.content for t in tokens]
    println("string_tokens=$string_tokens")
    grammar = Grammar()
    add_rule!(grammar, Rule("S",("ROOT_START","TAG_ROOT_END")))
    add_rule!(grammar, Rule("TAG_ROOT_END",("TAG","ROOT_END")))
    add_rule!(grammar, Rule("TAG", ("TAG_START", "OTHER_TAG_END")))
    add_rule!(grammar, Rule("OTHER_TAG_END", ("OTHER", "TAG_END")))
    add_rule!(grammar, Rule("OTHER", ("OTHER_START", "TEXT_OTHER_END")))
    add_rule!(grammar, Rule("TEXT_OTHER_END", ("TEXT", "OTHER_END")))
    add_rule!(grammar, Rule("ROOT_START", "[root>"))
    add_rule!(grammar, Rule("TAG_START", "[tag|a>"))
    add_rule!(grammar, Rule("OTHER_START", "[other|b>"))
    add_rule!(grammar, Rule("TEXT", "one two three"))
    add_rule!(grammar, Rule("OTHER_END", "<other]"))
    add_rule!(grammar, Rule("TAG_END", "<tag]"))
    add_rule!(grammar, Rule("ROOT_END", "<root]"))
    println("grammar=$grammar")
    @test validate(string_tokens,grammar)
end

@testset "use case 2: 2 layers, partial overlap" begin
    using HyperGraphTools.SimpleTAGMLTokenizer
    using HyperGraphTools.CYK

    # use case 2: 2 layers, partial overlap
    tagml2 = "[root>[tag|a>one [other|b>two<tag] three<other]<root]"
#     grammar2 = """
#     S -> ROOT
#     ROOT -> [root> ROOTBODY <root]
#     ROOTBODY -> OPENTAG ROOTBODY | CLOSETAG ROOTBODY | TEXT ROOTBODY | ε
#     OPENTAG -> [tag|a> | [other|b>
#     CLOSETAG -> <tag] | <other]
#     TEXT -> "one " | "two" | " three"
#     """
    tokens = tokenize(tagml2)
    @test has_no_errors(tokens)

    string_tokens = [t.content for t in tokens]
    grammar = Grammar()
    add_rule!(grammar, Rule("S",("ROOTSTART","MIXED_ROOTEND")))
    add_rule!(grammar, Rule("MIXED_ROOTEND",("MIXED","ROOTEND")))
    add_rule!(grammar, Rule("MIXED", ("MIXED", "MIXED")))
    add_rule!(grammar, Rule("ROOTSTART", "[root>"))
    add_rule!(grammar, Rule("MIXED", "[tag|a>"))
    add_rule!(grammar, Rule("MIXED", "[other|b>"))
    add_rule!(grammar, Rule("MIXED", "one "))
    add_rule!(grammar, Rule("MIXED", "two"))
    add_rule!(grammar, Rule("MIXED", " three"))
    add_rule!(grammar, Rule("MIXED", "<other]"))
    add_rule!(grammar, Rule("MIXED", "<tag]"))
    add_rule!(grammar, Rule("ROOTEND", "<root]"))
    println("grammar=$grammar")
    @test validate(string_tokens,grammar)
end

@testset "use case 3: 2 layers, no overlap" begin
    using HyperGraphTools.SimpleTAGMLTokenizer
    using HyperGraphTools.CYK
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
    grammar_idlp3 = """
    S -> {ROOT}
    ROOT -> {ROOTOPEN,BODY,ROOTCLOSE}
    ROOTOPEN < {BODY,ROOTCLOSE}
    BODY < ROOTCLOSE
    BODY -> {OPENTAG,CLOSETAG,TEXT,BODY}
    OPENTAG -> {OPENTAG("tag"),OPENTAG("other")}
    CLOSETAG -> {CLOSETAG("tag"),CLOSETAG("other")}
    OPENTAG("tag") < CLOSETAG("tag")
    OPENTAG("other") < CLOSETAG("other")
    """
    t3 = tokenize(tagml3)
    @test has_no_errors(t3)
end

@testset "use case 4: 2 layers, shared tags (a)" begin
    using HyperGraphTools.SimpleTAGMLTokenizer
    using HyperGraphTools.CYK

    # use case 4: 2 layers, shared tags
    tagml4a = "[root|+a,+b>[tag|a,b>[other|a,b>one two three<other]<tag]<root]"
    t4a = tokenize(tagml4a)
    @test has_no_errors(t4a)
end

@testset "use case 4: 2 layers, shared tags (b)" begin
    using HyperGraphTools.SimpleTAGMLTokenizer
    using HyperGraphTools.CYK

    # use case 4: 2 layers, shared tags
    tagml4b = "[root|+a,+b>[tag|a,b>[other|a,b>[w|a>one<w] [b|b>two<b] three<other]<tag]<root]"
    t4b = tokenize(tagml4b)
    @test has_no_errors(t4b)
end
