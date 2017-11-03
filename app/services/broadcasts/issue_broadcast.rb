class IssueBroadcast
  COUNTER_UPDATER = {
    create: {
      all_issues:      ->(_issue) { 1 },
      open_issues:     ->(issue) { issue.closed? ? 0 : 1 },
      closed_issues:   ->(issue) { issue.closed? ? 1 : 0 },
      assigned_issues: ->(issue) { issue.assigner_id ? { now: issue.assigner_id } : 0 },
      reported_issues: ->(issue) { issue.reporter_id ? { now: issue.reporter_id } : 0 },
      non_assigned:    ->(issue) { issue.assigner_id.nil? ? 1 : 0 }
    },
    update: {
      open_issues:     lambda do |issue|
        if issue.status_id_changed? && issue.closed?
          -1
        elsif issue.status_id_changed? && issue.was_closed?
          1
        else
          0
        end
      end,
      closed_issues:   lambda do |issue|
        if issue.status_id_changed? && issue.closed?
          1
        elsif issue.status_id_changed? && issue.was_closed?
          -1
        else
          0
        end
      end,
      assigned_issues: lambda do |issue|
        issue.assigner_id_changed? ? { now: issue.assigner_id, was: issue.assigner_id_was } : 0
      end,
      non_assigned:    lambda do |issue|
        if issue.assigner_id_changed? && issue.assigner_id_was.nil?
          -1
        elsif issue.assigner_id_changed? && issue.assigner_id.nil?
          1
        else
          0
        end
      end
    },
    delete: {
      all_issues:      ->(_issue) { -1 },
      open_issues:     ->(issue) { issue.closed? ? 0 : -1 },
      closed_issues:   ->(issue) { issue.closed? ? -1 : 0 },
      assigned_issues: ->(issue) { issue.assigner_id ? { was: issue.assigner_id } : 0 },
      reported_issues: ->(issue) { issue.reporter_id ? { was: issue.reporter_id } : 0 },
      non_assigned:    ->(issue) { issue.assigner_id.nil? ? -1 : 0 }
    }
  }.freeze

  def initialize(issue)
    @issue = issue
  end

  def create
    ActionCable.server.broadcast(
      "issues_#{@issue.project_id}",
      action: :create,
      params: {
        status_id: @issue.status_id,
        html:      render_issue
      },
      counters: counters(:create)
    )
  end

  def update
    ActionCable.server.broadcast(
      "issues_#{@issue.project_id}",
      action: :update,
      params: {
        id:        @issue.id,
        status_id: @issue.status_id,
        html:      render_issue
      },
      counters: counters(:update)
    )
  end

  def delete
    ActionCable.server.broadcast(
      "issues_#{@issue.project_id}",
      action: :delete,
      params: {
        id: @issue.id
      },
      counters: counters(:delete)
    )
  end

  private

  def counters(action)
    COUNTER_UPDATER[action].each_with_object({}) do |(key, value), hash|
      hash[key] = value.call(@issue)
    end
  end

  def render_issue
    ApplicationController.render(
      partial: 'issues/issue',
      locals: {
        issue: @issue
      }
    )
  end
end
