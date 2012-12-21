module TemplateHelpers
  include Rack::Utils
  alias_method :h, :escape

  def pagination(num_pages, page)
    return if not num_pages or num_pages < 0

    width = 10
    from = [1, page - (width >> 1)].max
    to   = [from + width - 1, num_pages].min

    while (to - from + 1) < width && (to < num_pages || from > 1)
      to   += 1 if to   < num_pages
      from -= 1 if from > 1
    end

    erb :pagination, :locals => {:from => from, :to => to, :page => page, :num_pages => num_pages}

  end
end