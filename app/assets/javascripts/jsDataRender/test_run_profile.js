JsDataRender.test_run_profile = {
  // Main function
  render_data: function(data) {
    this.private_stuff.render_table(data.table_data, data.labels)
    this.private_stuff.render_chart(data.gon_values, data.chart_labels)
    this.private_stuff.render_chart_info(data.chart_info)
    this.private_stuff.update_continue_link(data.first_untested_result_id)
    this.private_stuff.render_test_plans_progress(data.test_plans_progress)
  },

  private_stuff: {
    // Render functions
    render_chart: function(chart_data, chart_labels) {
      container = $('div.testRun-chart');
      container.find('iframe, canvas').remove();
      container.prepend('<canvas id="test_run_statuses_calculating_chart" width="700" height="350""></canvas>');
      BuildDiagram(chart_data, chart_labels);
    },
    render_table: function(table_data, labels) {
      t_rows = $('div.cases-test-content-item table tbody tr')
      if(table_data.untested != null) {
        untested = this.filter_rows(t_rows, table_data.untested)
        this.repaint_statuses(labels, "untested", untested)
      }
      if(table_data.pass != null) {
        passed = this.filter_rows(t_rows, table_data.pass)
        this.repaint_statuses(labels, "pass", $(passed))
      }
      if(table_data.fail != null) {
        failed = this.filter_rows(t_rows, table_data.fail)
        this.repaint_statuses(labels, "fail", $(failed))
      }
      if(table_data.na != null) {
        na = this.filter_rows(t_rows, table_data.na)
        this.repaint_statuses(labels, "na", $(na))
      }
      if(table_data.block != null) {
        blocked = this.filter_rows(t_rows, table_data.block)
        this.repaint_statuses(labels, "block", $(blocked))
      }
    },
    render_chart_info: function(info) {
      $('div.testRun-chart').find('#printImage').remove();
      container.append(info);
    },
    update_continue_link: function(first_untested_result_id) {
      continue_link = $('.testRun-test-header .continue-btn')
      if (first_untested_result_id) {
        continue_link.attr('href', continue_link.attr('href').replace(/[0-9]+/, first_untested_result_id));
      } else {
        continue_link.hide();
      }
    },
    render_test_plans_progress: function(test_plans_progress) {
      $.each(test_plans_progress, function(key, value) {
        progress_bar = $('#run-for-test-plan-' + key).find('.progress-bar');
        progress_bar.find('.progress .passed').css('width', value.pass);
        progress_bar.find('.progress .blocked').css('width', value.block);
        progress_bar.find('.progress .not-available').css('width', value.na);
        progress_bar.find('.progress .failed').css('width', value.fail);
        progress_bar.find('.progress .untested').css('width', value.untested);
        progress_bar.find('.passed-progress').text(value.pass);
      });
    },

    // Help functions
    filter_rows: function(all_rows, result_ids) {
      filtered = all_rows.filter(function() {
        this_element = $(this);
        this_id = this_element.data('test-result-id');

        if(this_id === undefined)
          this_id = 0

        for(i = 0; i < result_ids.length; i++) {
          if(this_id == result_ids[i]) {
            return this_element
          }
        }
      })
      return filtered;
    },
    repaint_statuses: function(labels, status, elements) {
      repaint = function(status_class, label) {
        for(i = 0; i < elements.length; i++) {
          element =  $(elements[i]).find('td.status div.status-block')
          element.removeClass('pass fail untested block not-available')
          element.addClass(status_class)
          element.text(label)
        }
      }
      switch(status) {
        case "pass":
          repaint("pass", labels.pass)
          break;
        case "block":
          repaint("block", labels.block)
          break;
        case "fail":
          repaint("fail", labels.fail)
          break;
        case "na":
          repaint("not-available", labels.na)
          break;
        case "untested":
          repaint("untested", labels.untested)
          break;
      }
    }

  }
}
