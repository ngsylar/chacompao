song_text = "Intro: C G Am C G
 
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

Coro

Coro
Coro

                          
Instrumentos: C G Am C G

C    Em Am            F     C    G
Take my hand, take my whole life too
    F G     Am   F          C    G    C
For I can't help falling in love with you
    F G     Am   F          C    G    C
For I can't help falling in love with you

Instrumentos: C G

Final: C G Am C G

Final: G"

# faz correcao de final de musica
text_end = song_text[(song_text.size - 2), 2]
song_text << "\n\n" unless text_end == "\n\n"

# variaveis principais da musica
song_estructure = []
song_partitions = {}

# variaveis temporarias para a estrutura da musica
verse_name = ""
verse_i = 1
verse = []

# transforma o texto da musica em uma estrutura particionada
# usa as variaveis temporarias para criar as variaveis principais
song_text.lines.each do |line|
    # define uma linha vazia para quebra de verso
    verse_break = line.scan(/^[\s]*\n$/)

    # se linha nao eh quebra de verso
    if verse_break.empty?
        case line

        # se linha comeca com declaracao de identificador
        when /^\s*(.)+:\s*/
            # guarda nome do identificador em uma variavel temporaria
            splitted_line = line.split(/:\s*/)
            verse_name = splitted_line.shift
            # se identificador ja esta na estrutura, renomeia identificador atual
            verse_j = 2
            while song_estructure.include?(verse_name)
                verse_name = "#{verse_name} #{verse_j}"
                verse_j += 1
            end
            # guarda o resto da linha em uma variavel temporaria
            line = splitted_line.first
            verse << line unless line == nil

        # se nao
        when /^\s*(.)+\s*\n*$/
            # se linha eh identificador existente na estrutura, reinserir identificador na estrutura
            line.strip!
            if song_estructure.include?(line) && verse_name.empty?
                song_estructure << line
            # se nao, guarda linha em uma variavel temporaria
            else
                verse << line
            end
        end
    
    # se linha for quebra de linha e verso anterior nao esta vazio
    elsif !verse.empty?
        # salvar verso com identificacao generica na estrutura e nas particoes
        if verse_name.empty?
            song_estructure << "Verse #{verse_i}" 
            song_partitions["Verse #{verse_i}"] = verse
            verse_i += 1
        # salvar verso com identificador na estrutura e nas particoes
        else
            song_estructure << verse_name 
            song_partitions[verse_name] = verse
            verse_name = ""
        end
        # limpa variavel temporaria
        verse = []
    end
end

# song_partitions.each do |key, verse|
#     puts "#{key}: #{verse}"
# end
p song_estructure