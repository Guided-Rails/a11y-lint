require "rouge"
require "securerandom"

class Shared::CodeTabs < Bridgetown::Component
  TABS = [
    { key: :erb,   label: "ERB",   lexer: "erb" },
    { key: :slim,  label: "Slim",  lexer: "slim" },
    { key: :phlex, label: "Phlex", lexer: "ruby" }
  ].freeze

  attr_reader :id

  def initialize(erb:, slim: nil, phlex: nil)
    @samples = { erb: erb, slim: slim, phlex: phlex }
    @id = "code-tabs-#{SecureRandom.hex(4)}"
  end

  def tabs
    TABS.select { |tab| @samples[tab[:key]] }
  end

  def tab_id(key)
    "#{id}-tab-#{key}"
  end

  def panel_id(key)
    "#{id}-panel-#{key}"
  end

  def highlighted(key, lexer_name)
    formatter = Rouge::Formatters::HTML.new
    lexer = Rouge::Lexer.find(lexer_name) || Rouge::Lexers::PlainText.new
    inner = formatter.format(lexer.lex(@samples[key].to_s))
    %(<pre class="highlight"><code>#{inner}</code></pre>)
  end
end
