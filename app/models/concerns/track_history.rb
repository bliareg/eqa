module TrackHistory
  attr_writer :updater_id

  def self.included(base)
    base.before_save :add_comment_history
  end

  private

  def add_comment_history
    if new_record?
      case self
      when Issue
        comments.build(
          body: 'Issue was created', is_history: true, crash_id: crash_id, user_id: reporter_id
        )
        if test_case_id
          test_case.comments.create(
            body: 'Test case based issue', is_history: true, user_id: reporter_id
          )
        end
      else
        comments.build(
          body: 'Test Case was created', is_history: true, user_id: created_by
        )
      end
    else
      comments.create(
        body: update_track,
        is_history: true,
        user_id: @updater_id || current_user_id
      )
    end
  end

  def update_track
    update_history = ''
    old_values_hash.each do |attr_name, old_value|
      if attr_name == 'module_id'
        update_history << "Test case was moved {old_val{#{old_value}}old_val}"\
                          "{new_val{#{test_module.title}}new_val}\n"
      else
        update_history << '{attr_name{' + attr_name.sub('_id', '').capitalize + '}attr_name}' \
                          "{old_val{#{old_value}}old_val}" \
                          "{new_val{#{send(attr_name.sub('_id', ''))}}new_val}\n"
      end
    end
    update_history
  end
end
