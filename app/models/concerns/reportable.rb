module Reportable
  def reports(attr)
    charts = attr[:report_type] ? [report_chart(attr)] : report_charts(attr)
    {
      charts: charts,
      data:   report_data(attr)
    }
  end

  def report_charts(attr)
    self::REPORTS.except(:data).keys.map do |report_type|
      report_chart(attr.merge(report_type: report_type))
    end
  end

  def report_data(attr)
    # variable 'attr' use in data hash
    self::REPORTS[:data].except(:description, :users_row_name)
                        .each_with_object({}) do |data, hash|
      hash[data[0]] = instance_eval(data[1])
    end.merge(users_row_name: self::REPORTS[:data][:users_row_name])
  end

  def report_chart(attr)
    Report.new(self, attr).report
  end

  class Report
    attr_reader :report

    def initialize(reportable_class, attr)
      @reportable_class = reportable_class
      report_init!(attr[:report_type].to_sym)
      install_chart_data!(attr)
      install_description!(attr)
      install_table!(attr)
      @report.except!(:legends, :name, :legend_key, :relation, :count, :result)
    end

    private

    def report_init!(report_type)
      @report = @reportable_class::REPORTS[report_type].deep_dup.merge(
        labels: [], results: [], backgroundColors: [], borderColors: []
      )
    end

    def install_chart_data!(attr)
      chart_data = attr[:parent].instance_eval(relation(attr))
                                .group_by(&attr[:report_type].to_sym)
      legends(attr).each do |legend|
        legend_data = chart_data[legend_key(legend)]
        append_to_labels!(legend_data, legend)
        append_to_results!(legend_data)
        append_to_color!
      end
    end

    def install_description!(attr)
      # var 'attr' might be used in description expresion
      description = ''
      description_hash = @reportable_class::REPORTS[:data][:description] || \
                         @report[:description]
      description_hash.each do |key, value|
        description << I18n.t("reportable.#{key}") +
                        ": #{@reportable_class.instance_eval(value)}<br>"
      end
      @report[:description] = description.html_safe
    end

    def install_table!(attr)
      # var 'attr' might be used in description expresion
      return unless @report[:table]
      @report[:table][:item] = @reportable_class.instance_eval(@report[:table][:item])
    end

    def relation(attr)
      # var 'attr' might be used in description expresion
      @report[:relation] || @reportable_class.name.underscore.pluralize
    end

    def legends(attr)
      # variable 'attr' might be used in report legends expresion
      @reportable_class.instance_eval(@report[:legends])
    end

    def legend_key(legend)
      @report[:legend_key] ? legend.instance_eval(@report[:legend_key]) : legend
    end

    def append_to_labels!(legend_data, legend)
      @report[:labels] << "#{legend_name(legend)} (#{legend_count(legend_data)})"
    end

    def append_to_results!(legend_data)
      @report[:results] << legend_result(legend_data)
    end

    def append_to_color!
      @report.merge!(random_color) { |_key, oldval, newval| oldval << newval }
    end

    def legend_name(legend)
      @report[:name] ? legend.instance_eval(@report[:name]) : legend
    end

    def legend_count(legend_data)
      # variable 'legend_data' might be used in report count expresion
      @report[:count] ? @reportable_class.instance_eval(@report[:count]) : (legend_data.try(:size) || 0)
    end

    def legend_result(legend_data)
      # variable 'legend_data' might be used in report result expresion
      @report[:result] ? @reportable_class.instance_eval(@report[:result]) : (legend_data.try(:size) || 0)
    end

    def random_color
      r, g, b = rand(255), rand(255), rand(255)
      {
        backgroundColors: "rgba(#{r}, #{g}, #{b}, 0.4)",
        borderColors: "rgba(#{r}, #{g}, #{b}, 1)"
      }
    end
  end
end
