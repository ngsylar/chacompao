class Version < ApplicationRecord
    validates :title, presence: true
    belongs_to :song
    belongs_to :user

    before_create :default_behavior
    before_update :default_behavior

    # retorna os dados de forma apresentavel ao usuario
    def transcribe
        reverse_engineering

        @transcribed_text = ""
        @song_structure.each do |verse|
            types = @partitions_structure[verse].map{|type| type}
            unless /^Verse/ === verse
                @transcribed_text << "#{verse}:\n"
            end
            @song_partitions[verse].each do |line|
                @transcribed_text << "#{types.shift}#{line}\n"
            end
            @transcribed_text << "\n"
        end

        @transcribed_text
    end

    # retorna a cifra como um texto editavel
    def handwrite
        reverse_engineering

        @handwritten_text = ""
        unwritten_verse = @song_structure.uniq
        @song_structure.each do |verse|
            if unwritten_verse.include?(verse)
                @handwritten_text << "#{verse}:\n" unless /^Verse/ === verse
                @song_partitions[verse].each do |line|
                    @handwritten_text << "#{line}\n"
                end
                unwritten_verse.shift
            else
                @handwritten_text << "#{verse}\n\n" unless /^Verse/ === verse
            end
        end

        @handwritten_text
    end

    private
        # define os acordes conhecidos
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

        # transforma o texto inserido em dados estruturados que serao convertidos em strings de registro
        def default_behavior
            song_parser(self.songparts)

            self.songstruct = @song_structure.to_s
            self.songparts = @song_partitions.to_s.gsub("\\r", "").gsub("\\n", "\n")
            self.partsstructs = @partitions_structure.to_s
        end

        # transforma as strings de registro em dados estruturados
        def reverse_engineering
            @song_structure = self.songstruct.gsub(/[\[\]\"]/, "").split(", ")
            @partitions_structure = self.partsstructs.gsub(/[{}\"]/, "").split("], ").map{
                |h| h1,h2 = h.split("=>[");
                {h1 => h2.gsub("]", "").split(", ")}
            }.reduce(:merge)
            @song_partitions = self.songparts.gsub(/[{}\"]/, "").split("], ").map{
                |h| h1,h2 = h.split("=>[");
                {h1 => h2.gsub("]", "").split("\n, ")}
            }.reduce(:merge)
        end

        # le um verso de acordes e o transforma em uma hash com as posicoes dos acordes
        def create_lines_from (chords)
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
        def create_text_from (tuned_chords)
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
        def change_chords (chords, key_change)
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

        # verifica se o token nao eh um acorde
        def not_chord (token)
            bib_token = [] << token[0]
            /^[[:lower:]]/ === token || !bib.include?(bib_token)
        end

        # separa letra de acordes em um verso da musica
        def verse_parser (verse)
            @verse_structure = []
            @temp_lyrics = ""
            @temp_chords = ""

            # para cada linha do verso
            @song_partitions[verse].each do |line|
                splitted_line = line.split(/\s+/).delete_if{|token| token.empty?}
                splitted_line.each_with_index do |token, token_i|
                    # se linha contem nao acorde, salva linha na variavel de letras
                    if not_chord(token)
                        @verse_structure << "L"
                        @temp_lyrics << line
                        break
                    # se linha contem apenas acordes, salva linha na variavel de acordes
                    elsif token_i == (splitted_line.size - 1)
                        @verse_structure << "C"
                        @temp_chords << line
                    end
                end
            end

            # salva a estrutura do verso
            @partitions_structure[verse] = @verse_structure
        end

        # une letra e acordes em um verso da musica
        def join_verse_lines (verse_name)
            verse = []
            splitted_lyrics = @temp_lyrics.split(/\n/)
            splitted_chords = @temp_chords.split(/\n/)
            
            # analisa a estrutura do verso para unir as linhas na ordem correta
            @verse_structure.each do |type|
                case type
                when "L"
                    verse << splitted_lyrics.shift
                    verse.last << "\n" unless verse.last[verse.last.size - 1] == "\n"
                when "C"
                    verse << splitted_chords.shift
                    verse.last << "\n" unless verse.last[verse.last.size - 1] == "\n"
                end
            end

            # salva o verso com acordes alterados
            @song_partitions[verse_name] = verse

            # limpa variaveis temporarias da musica
            @verse_structure = []
            @temp_lyrics = ""
            @temp_chords = ""
        end

        # muda a tonalidade de um verso
        def change_verse_tone (verse_name, key_change)
            # cria variavel com os acordes original
            verse_parser(verse_name)
            chords_lines = create_lines_from(@temp_chords)

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

            # salva os acordes alterados
            @temp_chords = create_text_from(chords_lines)
            join_verse_lines(verse_name)
        end

        # muda a tonalidade da musica
        def change_tone (key_change=0)
            @song_structure.uniq.each do |verse_name|
                change_verse_tone(verse_name, key_change)
            end
        end

        # cria uma estrutura de dados para a musica
        def song_parser (song_text)
            # faz correcao de final de musica
            text_end = song_text[(song_text.size - 2), 2]
            song_text << "\n\n" unless text_end == "\n\n"

            # variaveis principais da musica
            @song_structure = []
            @song_partitions = {}
            @partitions_structure = {}

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
                        while @song_structure.include?(verse_name)
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
                        if @song_structure.include?(stripped_line) && verse_name.empty?
                            @song_structure << stripped_line
                        # se nao, guarda linha em uma variavel temporaria
                        else
                            verse << line
                        end
                    end
                
                # se linha for quebra de linha e verso anterior nao esta vazio
                elsif !verse.empty?
                    # salvar verso com identificacao generica na estrutura e nas particoes
                    if verse_name.empty?
                        @song_structure << "Verse #{verse_i}" 
                        @song_partitions["Verse #{verse_i}"] = verse
                        verse_i += 1
                    # salvar verso com identificador na estrutura e nas particoes
                    else
                        @song_structure << verse_name 
                        @song_partitions[verse_name] = verse
                        verse_name = ""
                    end
                    # limpa variavel temporaria
                    verse = []
                end
            end

            # cria a estrutura dos versos
            change_tone
        end
end
