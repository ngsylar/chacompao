class Song
    # define os acordes conhecidos
    def self.bib
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

    # le um verso de acordes e o transforma em uma hash com as posicoes dos acordes
    def self.create_lines_from (chords)
        chords_lines = []
        chords.lines.each_with_index do |line|
            chords_txt = line.split(/(\s)/).delete_if{|token| token.empty?}
            chord_pos = {}
            pred_chord_size = 0
            chords_txt.each_with_index do |chord, i|
                unless chord == " "
                    pos = i + pred_chord_size
                    chord_pos[pos] = chord
                    pred_chord_size += chord.size - 1
                end
            end
            chords_lines << chord_pos
        end
        chords_lines
    end

    # transforma uma hash de acordes em uma string
    def self.create_text_from (tuned_chords)
        tuned_chords.map! do |line|
            line_txt = ""
            line.each do |key, value|
                while line_txt.size < key
                    line_txt << " "
                end
                line_txt << value
            end
            line_txt
        end

        chords = ""
        tuned_chords.each do |line|
            chords << line
        end
        chords
    end

    # muda a tonalidade de um arranjo de acordes
    def self.change_chords (chords, key_change)
        chords.map! do |chord|
            # divide o acorde em partes menores
            tokens = chord.split(/([\/ABCDEFG][#b]*)/).delete_if{|token| token.empty?}
            tokens.map! do |token|
                # procura parte do acorde em bib
                bib_id = bib.index{|key| key.include?(token)}
                
                # se parte do acorde nao esta definida em bib, insere parte
                if bib_id == nil
                    token

                # se parte do acorde esta definida em bib, insere parte alterada
                else
                    # faz correcao de tonalidade
                    key = bib_id + key_change
                    key -= 12 if key > 11
                    key += 12 if key < 0

                    bib[key][0]
                end
            end

            # insere acorde no arranjo
            tokens.join
        end
    end

    # muda a tonalidade de um verso
    def self.change_tone (chords, key_change=0)
        chords_lines = create_lines_from(chords)

        # muda a tonalidade de todos os acordes
        chords_lines.map! do |line|
            # muda a tonalidade de uma linha
            tuned_chords = change_chords(line.values, key_change)
            tuned_line = line.keys.zip(tuned_chords)
        
            # faz correcao de espacamento
            pred_chord_limit = -1
            tuned_line.map! do |chord|
                if chord.first <= pred_chord_limit
                    pred_chord_limit += 1
                    [pred_chord_limit, chord.last]
                else
                    pred_chord_limit = chord.first + chord.last.size
                    chord
                end
            end

            # insere linha transposta no verso
            tuned_line.to_h
        end

        create_text_from(chords_lines)
    end

    # cria uma estrutura de dados para a musica
    def song_parser (song_text)
        # faz correcao de final de musica
        text_end = song_text[(song_text.size - 2), 2]
        song_text << "\n\n" unless text_end == "\n\n"

        # variaveis principais da musica
        @song_estructure = []
        @song_partitions = {}

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
                    while @song_estructure.include?(verse_name)
                        verse_name.gsub!(/\s*\d+$/, "") if /\s*\d+$/ === verse_name
                        verse_name = "#{verse_name} #{verse_j}"
                        verse_j += 1
                    end
                    # guarda o resto da linha em uma variavel temporaria
                    line = splitted_line.first
                    verse << line unless line == nil

                # se nao
                when /^\s*(.)+\s*\n+$/
                    # se linha eh identificador existente na estrutura, reinserir identificador na estrutura
                    stripped_line = line.strip
                    if @song_estructure.include?(stripped_line) && verse_name.empty?
                        @song_estructure << stripped_line
                    # se nao, guarda linha em uma variavel temporaria
                    else
                        verse << line
                    end
                end
            
            # se linha for quebra de linha e verso anterior nao esta vazio
            elsif !verse.empty?
                # salvar verso com identificacao generica na estrutura e nas particoes
                if verse_name.empty?
                    @song_estructure << "Verse #{verse_i}" 
                    @song_partitions["Verse #{verse_i}"] = verse
                    verse_i += 1
                # salvar verso com identificador na estrutura e nas particoes
                else
                    @song_estructure << verse_name 
                    @song_partitions[verse_name] = verse
                    verse_name = ""
                end
                # limpa variavel temporaria
                verse = []
            end
        end
    end

    # verifica se o token nao eh um acorde
    def not_chord (token)
        bib_token = [] << token[0]
        /^[[:lower:]]/ === token || !Song.bib.include?(bib_token)
    end

    # separa letra de acordes em um verso da musica
    def verse_parser (verse)
        verse_estructure = []

        lyrics = ""
        chords = ""
        @song_partitions[verse].each do |line|
            splitted_line = line.split(/\s+/).delete_if{|token| token.empty?}
            splitted_line.each_with_index do |token, token_i|
                if not_chord(token)
                    verse_estructure << "L"
                    lyrics << line
                    break
                elsif token_i == (splitted_line.size - 1)
                    verse_estructure << "C"
                    chords << line
                end
            end
        end

        p lyrics
        p chords
        p verse_estructure
    end

    # getters
    def estructure
        @song_estructure
    end
    def partitions
        @song_partitions
    end
end

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
                          
Instrumentos: C G Am C G

C    Em Am            F     C    G
Take my hand, take my whole life too
    F G     Am   F          C    G    C
For I can't help falling in love with you
    F G     Am   F          C    G    C
For I can't help falling in love with you

Instrumentos: C G

Final: C G Am C G

Instrumentos: Am C

Final: G"

song_inst = Song.new
song_inst.song_parser(song_text)
p song_inst.estructure
print "\n"

song_inst.verse_parser(song_inst.estructure[1])