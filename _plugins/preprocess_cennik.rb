module Jekyll
  module Converters
    class PreprocessCennik < Markdown
      priority :high

      def convert(content)
        if content.include?('## Cennik')
          super(sum_prices(content))
        else
          super(content)
        end
      end

      def sum_prices(content)
        content.gsub(/\{\s*(\d+)\s*\+\s*(\d+)\s*\}/) do |match|
          ($1.to_i + $2.to_i).to_s
        end
      end
    end
  end
end
