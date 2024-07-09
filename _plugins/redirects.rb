module Jekyll
  class RedirectGenerator < Generator
    def generate(site)
      redirects = site.config['redirects'] || {}

      redirects.each do |source, target|
        site.pages << RedirectPage.new(site, site.source, source, target)
      end
    end
  end

  class RedirectPage < Page
    def initialize(site, base, source, target)
      @site = site
      @base = base
      @dir = ''
      @name = "#{source.gsub('/', '')}.html"

      self.process(@name)

      self.read_yaml(File.join(base, '_layouts'), 'redirect.html')
      self.data['redirect_to'] = target
    end
  end
end
