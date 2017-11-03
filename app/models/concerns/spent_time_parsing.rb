module SpentTimeParsing
  extend ActiveSupport::Concern

  MAX_SPENT_TIME = 300000000000
  HOUR = 'h|(hours?)'.freeze
  MINUTE = 'm|(min(utes?)?)'.freeze
  SPENT_TIME_REGEXP = "(\\d+)(#{HOUR}|#{MINUTE})\\s?".freeze

  included do
    validate :spent_time_max
  end

  def spent_time_view
    SpentTimeParsing.spent_time_view(spent_time)
  end

  def self.spent_time_view(time)
    format('%0.2dh %0.2dm', time.to_i / 3600, time.min)
  end

  def spent_time=(value)
    value.instance_of?(String) ? super(retrieve_time_from_string(value)) : super(value)
  end

  private

  def spent_time_max
     if (spent_time.to_i > MAX_SPENT_TIME)
        errors.add(:spent_time, I18n.t('can_not_be_long'))
    end
  end

  def retrieve_time_from_string(string)
    time = Time.at(0)
    string.scan(/#{SPENT_TIME_REGEXP}/i).each do |element|
      if element[1] =~ /#{HOUR}/i
        time += element[0].to_i.hours
      elsif element[1] =~ /#{MINUTE}/i
        time += element[0].to_i.minutes
      end
    end
    time.to_datetime
  end
end
