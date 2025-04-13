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
             '9×9', '13×13', 'torus', 'rengo', 'fantom', 'hex go'],
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
      days_expanded = days.map { |day| hours_expand(day) }
      days_expanded.each do |hr|
        hr.each do |key, value|
          hours[key.to_sym] ||= []
          hours[key.to_sym] << value
        end
      end
      hours
    end

    # Vertical merging: merge same events in the same column
    def add_rowspan(basic_table)
      columns = basic_table.transpose

      merged_columns = columns.map.with_index do |col, offset|
        # Build a new column array by grouping adjacent cells with the same event
        new_col = Array.new(col.size)
        i = 0
        while i < col.size
          cell = col[i]
          rowspan = col.drop(i).take_while { |c| c[:event] == cell[:event] }.size
          new_col[i] = cell.merge(rowspan: rowspan, colspan: 1, offset: offset)
          i += rowspan
        end
        new_col
      end
      # Transpose back to rows and remove nil cells per row
      merged_columns.transpose.map { |row| row.compact }
    end

    # Horizontal merging: only merge cells if they are immediately adjacent
    def add_colspan(row)
      merged = []
      current_cell = nil
      row.each do |cell|
        if current_cell.nil?
          current_cell = cell
        else
          # Only merge if the cell is immediately adjacent (i.e. its original offset equals
          # the current cell's offset plus its colspan), and if event and rowspan match.
          if cell[:event] == current_cell[:event] &&
             cell[:rowspan] == current_cell[:rowspan] &&
             (current_cell[:offset] + current_cell[:colspan] == cell[:offset])
            current_cell = current_cell.merge(colspan: current_cell[:colspan] + cell[:colspan])
          else
            merged << current_cell
            current_cell = cell
          end
        end
      end
      merged << current_cell if current_cell
      merged
    end

    # Find category for event, processed sequentially, first match
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

      days = days_split.map { |day_description| parse_day(day_description) }
      by_hours = flip_hours(days.map { |h| h[:hours] })

      basic_table = by_hours.values.map { |hour| hour.map { |event| { event: event } } }
      rowspanned = add_rowspan(basic_table)
      colspanned = rowspanned.map { |row| add_colspan(row) }

      # Prepend each row with an hour label cell.
      with_hours = []
      @@hrs.each_with_index do |hr, index|
        with_hours << colspanned[index].unshift({ event: hr, colspan: 1, rowspan: 1, offset: 0 })
      end

      hours = with_hours.map { |row| row.map { |cell| preprocess_cell(cell) } }

      template = File.read('_plugins/cal_template.html.erb')
      ERB.new(template).result(binding)
    end

    def generate(site)
      files = ["cal-1", "cal-2"]
      files.each do |fid|
        content = File.read("calendar/#{fid}.md")
        File.write("_includes/#{fid}.html", make_table(content))
      end
    end
  end
end
