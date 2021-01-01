# spike para um ideado sistema de busca

require "i18n"
I18n.available_locales = [:en]

text = "A reunião está em curso"
p text
p I18n.transliterate(text)

hash = {"title"=>"teste", "author"=>"teste", "category"=>"teste", "number"=>"0"}
param = hash.delete("category")
p hash
p param

nilthing = nil
p nilthing
p nilthing.to_i

token = "     A#m   ddr           "
p token.gsub!(/\s/,'')
p atoms = token.split(/([ABCDEFG][#b]*)/).delete_if{|token| token.empty?}
p token[token.size-1]
p atoms.last

hash = {"title"=>"teste", "author"=>"teste", "category"=>"teste", "number"=>"0"}
mandatory = {"author"=>nil}
p hash.merge(mandatory)

# adicionar favoritos de usuarios (version_id)