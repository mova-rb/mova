require "bundler/setup"
require "benchmark/ips"
require "securerandom"

require "mova"
require "i18n"
require "r18n-core"

mova = Mova::Translator.new.tap do |t|
  def t.locales_to_try(locale)
    [locale, :ru, :en]
  end
end
mova.put(en: {hello: "Hello"}, uk: {hi: "Привіт"})

I18n.enforce_available_locales = true
I18n::Backend::Simple.include(I18n::Backend::Fallbacks)
I18n.fallbacks[:uk] = [:uk, :ru, :en]
I18n.backend.store_translations(:en, {hello: "Hello"})
I18n.backend.store_translations(:uk, {hi: "Привіт"})
I18n.locale = :uk

module R18nHashLoader
  def self.available; [R18n.locale("uk"), R18n.locale("ru"), R18n.locale("en")] end
  def self.load(locale)
    case locale.code
    when "en" then {"hello" => "Hello"}
    when "uk" then {"hi" => "Привіт"}
    when "ru" then {}
    end
  end
end
R18n.default_places = R18nHashLoader
R18n.set("uk")

Benchmark.ips do |x|
  x.report("mova") { mova.get(:hello, :uk) }
  x.report("i18n") { I18n.t(:hello) }
  x.report("r18n") { R18n.t.hello }

  x.compare!
end
