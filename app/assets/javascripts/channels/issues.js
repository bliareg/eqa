Issues = {
  cable: {
    init: function() {
      if (isSubscriptionAlreadyCreate('IssuesChannel')) {
        return false;
      }

      App.issues = App.cable.subscriptions.create(
        {
          channel: "IssuesChannel",
          project_id: $('.agile').data('project-id')
        },
        {
          connected: function() {
            // Called when the subscription is ready for use on the server
          },

          disconnected: function() {
            // Called when the subscription has been terminated by the server
          },

          received: function(data) {
            // Called when there's incoming data on the websocket for this channel
            Issues[data.action](data.params);
            Issues.updateCounters(data.counters);
          },

          create: function() {
            return this.perform('create');
          },

          update: function() {
            return this.perform('update');
          },

          delete: function() {
            return this.perform('delete');
          }
        }
      );
    }
  },
  create: function (params) {
    var status = $('#status-' + params.status_id);
    if (!status) return;

    status.prepend(params.html);
    var issues_count = $('#status-' + params.status_id).siblings('.agile_title').find('.count')
    issues_count.text(parseInt(issues_count.text()) + 1);
  },
  update: function (params) {
    var issue = $('.agile_card[data-issue-id=' + params.id + ']');
    if (issue.length == 0) return;

    if (issue.parent().attr('id') != 'status-' + params.status_id) {
      var issues_count = issue.parent().siblings('.agile_title').find('.count')
      issues_count.text(parseInt(issues_count.text()) - 1);
      $('#status-' + params.status_id).append(issue);
      issues_count = issue.parent().siblings('.agile_title').find('.count')
      issues_count.text(parseInt(issues_count.text()) + 1);
    }
    issue.replaceWith(params.html);
  },
  delete: function (params) {
    var issue = $('.agile_card[data-issue-id=' + params.id + ']');
    if (issue.length == 0) return;

    var issues_count = issue.parents('.agile_content').siblings('.agile_title').find('.count');
    issues_count.text(parseInt(issues_count.text()) - 1);
    issue.remove();
  },
  updateCounter: function(filter, value) {
    var filterCountElement = $('#filter-' + filter + '-count'),
        count = parseInt(filterCountElement.text()),
        increment;
    if (filter == 'assigned_issues' || filter == 'reported_issues') {
      current_user_id = $('.agile').data('user-id');
      if (value.was == current_user_id) {
        increment = -1;
      } else if (value.now == current_user_id) {
        increment = 1;
      } else {
        increment = 0;
      }
    } else {
      increment = value;
    }
    filterCountElement.text(count + increment);
  },
  updateCounters: function(counters) {
    for (var filter in counters){
      Issues.updateCounter(filter, counters[filter])
    }
  }
}
