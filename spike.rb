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
        # le um verso de acordes e o transforma em uma hash com as posicoes dos acordes
        chords_lines = []
        chords.lines.each_with_index do |line|
            chords_txt = line.split(/(\s)/).delete_if{|token| token.empty?}
            chord_pos = {}
            chords_txt.each_with_index do |chord, i|
                chord_pos[i] = chord unless chord == "\s"
            end
            chords_lines << chord_pos
        end
        p chords_lines

        # muda a tonalidade de todos os acordes
        chords_lines.map! do |line|
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

            # insere linha alterada no verso
            tuned_line.to_h
        end
    end
end

lyrics = "Wise men say, only fools rush in
But I can't help falling in love with you"
chords = "C    Em  Am        F     C    G
    F G     Am   F          C    G    C"

lyrics << "\n" unless lyrics[lyrics.size - 1] == "\n"
chords << "\n" unless chords[chords.size - 1] == "\n"

p Song.change_tone(chords, 2)