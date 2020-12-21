song = "Intro: C G Am C G
 
C    Em  Am        F     C    G
Wise men say, only fools rush in
    F G     Am   F          C    G    C
But I can't help falling in love with you
 
 
 
C     Em Am             F  C G
Shall I  stay, would it be a sin?
   F G     Am   F          C    G    C
If I can't help falling in love with you

Coro:             
Em           B7    Em            B7
Like a river flows surely to the sea
Em            B7
Darling so it goes
Em          A7             Dm  G
Some things   are meant to be
 
C    Em Am            F     C    G
Take my hand, take my whole life too
    F G     Am   F          C    G    C
For I can't help falling in love with you
 
Coro
                          
Instrumentos: C G Am C G

C    Em Am            F     C    G
Take my hand, take my whole life too
    F G     Am   F          C    G    C
For I can't help falling in love with you
    F G     Am   F          C    G    C
For I can't help falling in love with you

Instrumentos: C G

Final: C G Am C G"

song_end = song[(song.size - 2), 2]
song << "\n\n" unless song_end == "\n\n"

song_estructure = []
lyrics = {}

verse_name = ""
verse_i = 1
verse_j = 2
verse = []
song.lines.each do |line|
    verse_break = line.scan(/^[\s]*\n$/)
    if verse_break.empty?
        case line
        when /^\s*(.)+:\s*/
            splitted_line = line.split(/:\s*/)
            verse_name = splitted_line.shift
            if song_estructure.include?(verse_name)
                verse_name = "#{verse_name} #{verse_j}"
                verse_j += 1
            end
            line = splitted_line.first
            verse << line unless line == nil
        when /^\s*(.)+\s*$/
            line.strip!
            if song_estructure.include?(line) && verse_name.empty?
                song_estructure << line
            else
                verse << line
            end
        end
    elsif !verse.empty?
        if verse_name.empty?
            song_estructure << "Verse #{verse_i}" 
            lyrics["Verse #{verse_i}"] = verse
            verse_i += 1
        else
            song_estructure << verse_name 
            lyrics[verse_name] = verse
            verse_name = ""
        end
        verse = []
    end
end
lyrics.each do |key, verse|
    puts "#{key}: #{verse}"
end
p song_estructure