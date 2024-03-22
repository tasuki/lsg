module Jekyll
  module Converters
    class PreprocessCennik < Markdown
      safe true
      priority :high

      def convert(content)
        if content.include?('## Cennik')
          super(sum_prices(content))
        else
          super(content)
        end
      end

      def sum_prices(content)
        pattern = /\{\s*(\d+)\s*\+\s*(\d+)\s*\}/

        content.gsub(pattern) do |match|
          num1 = $1.to_i
          num2 = $2.to_i

          (num1 + num2).to_s
        end
      end
    end
  end
end
