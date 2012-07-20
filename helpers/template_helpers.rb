module TemplateHelpers
  include Rack::Utils
  alias_method :h, :escape
end
