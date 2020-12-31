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

# adicionar favoritos de usuarios (version_id)