module Jekyll
  class MakeCal < Generator
    # Perhaps consider sleeping 22-7 ?
    @@hrs = [
      "08", "09", "10", "11", "12", "13", "14",
      "15", "16", "17", "18", "19", "20", "21",
    ]

    # How the source should mark nothing happening
    @@empty = "~"

    @@categories = {
      food: ['śniadanie', 'obiad', 'kolacja', 'ognisko'],
      play: ['poznawczy', 'memoriał', 'maraton', 'mpp', 'blitz',
             '9×9', '13×13', 'torus', 'rengo', 'fantom'],
      learn: ['zajęcia', 'tsumego', 'wykład', 'podział', 'relay'],
    }

    # Parse schedule for a single day
    def parse_day(day_description)
      day, hours = day_description.split(/\n/, 2)
      hour_list = hours.strip.split(/\n/).map do |hour|
        match = hour.strip.match(/(\d+) (.*)/)
        { match[1] => match[2] }
      end
      { day: day, hours: hour_list.reduce({}, :merge) }
    end

    # Make sure the missing hours are filled properly
    def hours_expand(hours)
      new = {}
      running_event = @@empty
      @@hrs.each do |hr|
        if hours.include?(hr)
          running_event = hours[hr]
        end
        new[hr] = running_event
      end
      new
    end

    # Flip from [{08: event, 09: another}, {08: event, 09: breakfast}]
    # to {8: [event, event], 9: [another, breakfast]}
    def flip_hours(days)
      hours = {}
      days_expanded = days.map do |day|
        hours_expand(day)
      end

      days_expanded.each do |hr|
        hr.each do |key, value|
          hours[key.to_sym] ||= []
          hours[key.to_sym] << value
        end
      end
      hours
    end

    # Process single row, merge cells with same event
    # using colspan, add offset for later perusal
    def add_colspan(row)
      colspan = []
      current_value = nil
      count = 0
      total = 0

      row.each do |cell|
        if cell != current_value
          colspan << {
            event: current_value,
            colspan: count,
            offset: total - count,
          } unless current_value.nil?
          count = 1
          current_value = cell
        else
          count += 1
        end
        total += 1
      end

      colspan << {
        event: current_value,
        colspan: count,
        offset: total - count,
      } unless current_value.nil?
      colspan
    end

    # Is a cell covered by any of the cells in the rows above?
    def is_covered(this, array_above)
      array_above.reverse.each_with_index do |row, row_distance|
        row.each do |cell|
          if cell[:event] == this[:event] &&
              cell[:offset] == this[:offset] &&
              cell[:colspan] == this[:colspan] &&
              cell[:rowspan] > row_distance
            return true
          end
        end
      end
      false
    end

    # Adds rowspan and 
    # Expects array to have colspan + offset defined
    def add_rowspan(array)
      new = []
      rows = array.length

      array.each_with_index do |row, row_index|
        new[row_index] = []
        row.each do |cell|
          # check all the rows above if this is covered by an above rowspan
          if is_covered(cell, new)
            next
          end

          # for this and the rows below, look how many contain the same cell
          rowspan = 0
          (row_index...rows).each do |tmp_row_index|
            if array[tmp_row_index].include?(cell)
              rowspan += 1
            else
              break
            end
          end

          new[row_index] << cell.merge(rowspan: rowspan)
        end
      end

      new
    end

    # Find category for event, processed sequentially, first match goes
    def find_category(event)
      @@categories.each do |category, keywords|
        keywords.each do |keyword|
          return category if event.downcase.include?(keyword)
        end
      end
      'other'
    end

    # Various single-cell enhancements, last thing we do
    def preprocess_cell(cell)
      if cell[:event] == @@empty
        cell[:event] = "" # nothing!
      elsif cell[:event] =~ /^\d\d$/
        cell[:event] = cell[:event] + ":00"
      else
        cell[:class] = find_category(cell[:event])
      end
      cell
    end

    def make_table(content)
      week, days_str = content.split(/\n/, 2)
      week = week.sub("# ", "")

      days_split = days_str.strip.split(/## /)
      days_split.shift # remove empty first item

      days = days_split.map do |day_description|
        parse_day(day_description)
      end

      by_hours = flip_hours(days.map { |hash| hash[:hours] })
      colspanned = by_hours.values.map do |hour|
        add_colspan(hour)
      end
      rowspanned = add_rowspan(colspanned)

      with_hours = []
      @@hrs.each_with_index do |hr, index|
        with_hours << rowspanned[index].unshift({event: hr, colspan: 1, rowspan: 1})
      end

      hours = with_hours.map do |row|
        row.map do |cell|
          preprocess_cell(cell)
        end
      end

      template = File.read('_plugins/cal_template.html.erb')
      ERB.new(template).result(binding)
    end

    def generate(site)
      files = [ "cal-1", "cal-2" ]
      files.each do |fid|
        content = File.read("calendar/#{fid}.md")
        File.write("_includes/#{fid}.html", make_table(content))
      end
    end
  end
end
