# spike para um ideado sistema de busca

require "i18n"
I18n.available_locales = [:en]

text = "A reunião está em curso"
p text
p I18n.transliterate(text)