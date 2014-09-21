require "bundler/setup"
require "benchmark/ips"
require "securerandom"

require "mova"
require "i18n"
require "r18n-core"

KEYS = Array.new(1000).map { SecureRandom.hex(8) }
DATA = {
  "this" => {
    "is" => {
      "really" => {
        "deep" => {
          "nested" => {
            "key" => KEYS.each_with_object({}) { |key, memo| memo[key] = SecureRandom.hex(30) }
          }
        }
      }
    }
  }
}

def random_key
  KEYS.sample
end

mova = Mova::Translator.new
mova.put(en: DATA)

I18n.enforce_available_locales = true
I18n.backend.store_translations(:en, DATA)
I18n.locale = :en

module R18nHashLoader
  def self.available; [R18n.locale("en")] end
  def self.load(locale); DATA end
end
R18n.default_places = R18nHashLoader
R18n.set("en")

Benchmark.ips do |x|
  x.report("mova") { mova.get("this.is.really.deep.nested.key.#{random_key}", :en) }
  x.report("i18n") { I18n.t("this.is.really.deep.nested.key.#{random_key}") }
  x.report("r18n") { R18n.t.this.is.really.deep.nested.key.send(random_key) }

  x.compare!
end
