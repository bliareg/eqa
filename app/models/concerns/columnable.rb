module Columnable
  extend ActiveSupport::Concern

  def self.included(base)
    base.after_create :generate_visibilities
  end

  def column_visibility(user)
    @cv ||= column_visibilities.find_by(user_id: user.id)
  end

  def column_set(user)
    # @column_set ||= column_visibility(user).column_set
    @column_set ||= JSON.parse(column_visibility(user).column_setting)
  end

  def generate_visibilities
    project.members.each do |user|
      cv = column_visibilities.new(user: user)
      cv.set_default_column_size
      cv.save
      # column_visibilities.create(user: user, column_set: default_column_set)
    end
  end

  def generate_visibility(user_id)
    cv = column_visibilities.new(user_id: user_id)
    cv.set_default_column_size
    cv.save
    # column_visibilities.create(
    #   user_id: user_id,
    #   column_set: default_column_set
    # )
  end

  def self.columnables_per(project)
    [project.test_runs, project.test_plans].flatten
  end

  module ClassMethods
    def default_columns
      ColumnVisibilitiesController::COLUMN_SOURCES[to_s].constantize.const_get('VISIBLE_COLUMNS')
    end

    def required_columns
      ColumnVisibilitiesController::COLUMN_SOURCES[to_s].constantize.const_get('REQUIRED_COLUMNS')
    end
  end

  private

  def default_column_set
    ColumnSet.default_for(self.class)
  end
end
