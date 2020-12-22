# require 'objspace'

# class Verse
#     @lines = []
# end

lyrics = "Wise men say, only fools rush in
But I can't help falling in love with you
"

chords = "C    Em  Am        F     C    G
    F G     Am   F          C    G    C
"

# p lyrics.lines.count

chords.lines.each_with_index do |line, i|
    print line
    print lyrics.lines[i]
end

# chords = [
#     {
#         0 => 'C',
#         5 => 'Em',
#         9 => 'Am',
#         19 => 'F',
#         25 => 'C',
#         30 => 'G'
#     },{
#         4 => 'F',
#         6 => 'G',
#         12 => 'Am',
#         17 => 'F',
#         28 => 'C',
#         33 => 'G',
#         38 => 'C'
#     }
# ]

# chords.map! do |line|

# end

# lyrics.lines.each do |line|
#     p line
# end

# coiso = []
# coiso.insert(21, 'ola')
# coiso.insert(5, 99)
# coisa = {}
# coisa[21] = 'ola'
# coisa[5] = 99
# p coiso
# p ObjectSpace.memsize_of(coiso)
# p coisa
# p ObjectSpace.memsize_of(coisa)
