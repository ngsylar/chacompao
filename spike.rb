# require 'objspace'

# def bib
#     {
#         1 => ['A'],
#         2 => ['A#', 'Bb'],
#         3 => ['B'],
#         4 => ['C'],
#         5 => ['C#', 'Db'],
#         6 => ['D'],
#         7 => ['D#', 'Eb'],
#         8 => ['E'],
#         9 => ['F'],
#         10 => ['F#', 'Gb'],
#         11 => ['G'],
#         12 => ['G#', 'Ab']
#     }
# end

def bib
    [
        ['A'],
        ['A#', 'Bb'],
        ['B'],
        ['C'],
        ['C#', 'Db'],
        ['D'],
        ['D#', 'Eb'],
        ['E'],
        ['F'],
        ['F#', 'Gb'],
        ['G'],
        ['G#', 'Ab']
    ]
end

# def rename_chord (tokens)
#     case tokens.size
#     when 1
#         note = "#{bib[tokens.first][0]}"
#     when 2
#         note = "#{bib[tokens.first][0]}/#{bib[tokens.last][0]}"
#     else
#         note = "error"
#     end
# end

chords = %w[Bb/D F/G Bb/D F/G Dm/Bb Dm/G F/C C D/C G/D A/G D/A]
# key_change = 1
p chords

# tokens = chords[0].split('/')
# tokens.map! do |token|
#     bib.select{|k,v| v.index(token)}.keys
# end
# tokens.flatten!.map! {|token| token + key_change}
# p rename_chord(tokens)

# chord = "D#dim/Bb7M"

# def change_tone (chord, key_change=0)
#     tokens = chord.split(/([\/ABCDEFG][#b]*)/).delete_if{|token| token.empty?}
#     tokens.map! do |token|
#         bib_id = bib.select{|k,v| v.index(token)}.keys
#         if bib_id.empty?
#             token
#         else
#             key = bib_id.first + key_change
#             "#{bib[key][0]}"
#         end
#     end
#     tokens.join
# end

def change_tone (chord, key_change=0)
    tokens = chord.split(/([\/ABCDEFG][#b]*)/).delete_if{|token| token.empty?}
    tokens.map! do |token|
        bib_id = bib.index{|key| key.include?(token)}
        
        if bib_id == nil
            token

        else
            key = bib_id + key_change
            key -= 12 if key > 11
            key += 12 if key < 0

            bib[key][0]
        end
    end
    tokens.join
end

# p change_tone(chord, 1)

chords.map! do |chord|
    change_tone(chord, 12)
end

p chords

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
