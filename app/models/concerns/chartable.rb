module Chartable
  def line_chart(attr)
    LineChart.new(self, attr).chart
  end

  class LineChart
    attr_reader :chart

    def initialize(chartable_class, attr)
      @date_range = attr[:day_ago].days.ago.to_date..Date.today
      @chartable_class = chartable_class
      @attr = attr
      retrieve_chart!
    end

    private

    def retrieve_chart!
      @chart = { items: retrieve_result_hash.map { |key, val| [key.text, val] },
                 labels: @date_range.map { |date| date.strftime('%d/%m') } }
    end

    def retrieve_result_hash
      objects_per_date = retrieve_objects_per_date
      result_hash = retrieve_template

      @date_range.each_with_index do |date, i|
        grouped_objects = (objects_per_date[date] || []).group_by(&@attr[:field])
        result_hash.merge!(grouped_objects) { |_key, old_val, new_val| old_val << new_val.size }
        result_hash.each { |key, val| result_hash[key] << 0 if val.size < i + 1 }
      end
      result_hash
    end

    def retrieve_objects_per_date
      @attr[:parent].public_send(@chartable_class.name.underscore.pluralize)
                    .where(created_at: @date_range.first..@date_range.last.next)
                    .group_by { |obj| obj.created_at.to_date }
    end

    def retrieve_template
      @chartable_class.public_send(@attr[:field]).values
                      .each_with_object({}) { |key, hash| hash[key] = [] }
    end
  end
end
