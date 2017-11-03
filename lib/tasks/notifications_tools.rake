namespace :notifications_tools do
  desc 'Checks notifications for every user'
  task :check_notifications => :environment do
    User.find_each do |user|
      set_up_vars(user)
      @roles.each do |role|
        if any_notification?(Notification::PROJECT, role.project_id)
          check_test_runs(project_id: role.project_id, info_only: true)
        else
          info = project_notification_fail_info(user, role.project_id)
          puts info[:info]
        end
      end
    end
    puts "\nDONE"
  end

  desc 'Add notification where it is missed'
  task :fix_notifications => :environment do

    test_run_process = proc do |project, test_run, info|
      notification = Notification.create(notificable: test_run,
                                         parent_notification: @user.notification(notificable: project),
                                         user: @user)
      print info
      if notification.valid?
        puts "SUCCESS for TestRun #{ test_run.id }, Notification: #{ notification.id } \n"
      else
        puts "FAILED for TestRun #{ test_run.id } \n"
      end
    end

    User.find_each do |user|
      set_up_vars(user)
      @roles.each do |role|
        if any_notification?(Notification::PROJECT, role.project_id)
          check_test_runs(project_id: role.project, &test_run_process)
        else
          info = project_notification_fail_info(user, role.project_id, true)
          print info[:info]
          project = info[:project]
          notification = Notification.create(notificable: project,
                                             user: user,
                                             turn_on: true);
          if notification.valid?
            puts "SUCCESS for Project: #{ project.id }, Notification: #{ notification.id } \n"
            check_test_runs(project: project, &test_run_process)
          else
            puts "FAIL for Project: #{ project.id } \n"
          end
        end
      end
    end
    puts "\nDONE"
  end

  @notifications
  @roles
  @user

  def set_up_vars(user)
    @roles = user.roles.where.not(project_id: nil)
    notifications = user.notifications
                        .where(notificable_type: [Notification::PROJECT, Notification::TEST_RUN])
    @notifications = notifications.to_a
    @user = user
  end

  def any_notification?(type, id)
    notification_filtered = @notifications.find { |notification| notification.notificable_id == id &&
                                                                 notification.notificable_type == type }
    !notification_filtered.nil?
  end

  def base_info(user_id, project_id, trying_to_fix, test_run_id = nil)
<<FAIL_INFO
\n=======FAIL=======\
#{ (test_run_id.nil? ? 'Project' : 'TestRun') }
Project: #{ project_id }, User: #{ user_id } #{ 'TestRun: ' + test_run_id.to_s  unless test_run_id.nil? } \
#{ "and posibly all test runs that belongs to this project." if !trying_to_fix && test_run_id.nil? }
FAIL_INFO
  end

  def project_notification_fail_info(user, project_id, trying_to_fix = false)
    info = base_info(user.id, project_id, trying_to_fix)
    project = Project.find(project_id)
    unless trying_to_fix
      info += project.inspect+"\n"
      info += user.inspect+"\n"
    end

    info += '=================='
    info += 'FIXING...' if trying_to_fix
    { project: project, info: info }
  end

  def test_run_notification_fail_info(user, project, test_run, trying_to_fix = false)
    info = base_info(user.id, project.id, trying_to_fix, test_run.id)
    unless trying_to_fix
      info += project.inspect+"\n"
      info += user.inspect+"\n"
      info += test_run.inspect+"\n"
    end
    info += '=================='
    info += 'FIXING...' if trying_to_fix
    info
  end

  def check_test_runs(options = { project: nil,
                                  project_id: nil,
                                  info_only: false }, &block)
    if options[:project]
      project = options[:project]
    else
      project = Project.find(options[:project_id])
    end
    info_only = options[:info_only]
    test_runs = project.test_runs.where(assigned_to: @user.id)
    test_runs.each do |test_run|
      any_notifications = any_notification?(TestRun.to_s, test_run.id)
      unless any_notifications
        info = test_run_notification_fail_info(@user,
                                               project,
                                               test_run, !info_only)
        if info_only
          puts info
        else
          yield(project, test_run, info) if block_given?
        end
      end
    end
  end
end
