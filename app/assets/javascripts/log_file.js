$(document).on('click', '.show_crash_issue', function() {
  issue_id = $(this).data('issue-id');
  open_issue(issue_id);
});