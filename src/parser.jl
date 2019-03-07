"""
# module Parser

- Julia version: 
- Author: bramb
- Date: 2019-02-13

# Examples

```jldoctest
julia>using HyperGraphTools.Parser
```
"""
module Parser

export Earley

struct Earley
end


# DECLARE ARRAY S;
s = []

# function INIT(words)
#     S ← CREATE-ARRAY(LENGTH(words) + 1)
#     for k ← from 0 to LENGTH(words) do
#         S[k] ← EMPTY-ORDERED-SET
function init(tokens)
    s = [Set() for i in 1:(length(tokens))]
end

# function EARLEY-PARSE(words, grammar)
#     INIT(words)
#     ADD-TO-SET((γ → •S, 0), S[0])
#     for k ← from 0 to LENGTH(words) do
#         for each state in S[k] do  // S[k] can expand during this loop
#             if not FINISHED(state) then
#                 if NEXT-ELEMENT-OF(state) is a nonterminal then
#                     PREDICTOR(state, k, grammar)         // non-terminal
#                 else do
#                     SCANNER(state, k, words)             // terminal
#             else do
#                 COMPLETER(state, k)
#         end
#     end
#     return chart
function early_parse(tokens,grammar)
    init(tokens)

end

# procedure PREDICTOR((A → α•Bβ, j), k, grammar)
#     for each (B → γ) in GRAMMAR-RULES-FOR(B, grammar) do
#         ADD-TO-SET((B → •γ, k), S[k])
#     end

# procedure SCANNER((A → α•aβ, j), k, words)
#     if a ⊂ PARTS-OF-SPEECH(words[k]) then
#         ADD-TO-SET((A → αa•β, j), S[k+1])
#     end

# procedure COMPLETER((B → γ•, x), k)
#     for each (A → α•Bβ, j) in S[x] do
#         ADD-TO-SET((A → αB•β, j), S[k])
#     end

# http://matt.might.net/articles/parsing-with-derivatives/
end