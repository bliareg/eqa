# EXECUTE data_migrate:task['arg1'...] !!!!!."
# RUN THIS TASK BEFORE NOTIFICATIONS MIGRATIONS
namespace :data_migrate do
  desc "Saves into file: id, project_id from project_notifications. First arg - file path(absolute)"
  task :extract_data_from_project_notifications,[:file_path] => :environment do |t,args|
    file_path = (args['file_path'] ? args['file_path'] : "/tmp/project_ids_dump.csv")
    puts "Your data will be saved to: #{file_path}"
    print "Type new file path (optional):"
    new_file_path = STDIN.gets.chomp
    old_path = file_path
    file_path = (new_file_path.blank? ? old_path : new_file_path)
    f = nil
    #file creating
    unless File.exists? file_path
      puts "File does not exists, trying to create"
    else
      puts "Found file"
    end
    begin
      f = File.new file_path, "w"
    rescue
      puts "Error creating or opening file..."
    end
    # data extracting
    unless f.blank?
      data = ActiveRecord::Base.connection
        .execute('SELECT id, project_id '\
                 'FROM project_notifications')
      puts "Data uploading..."
      # file writing
      data.each do |e|
        f.puts("#{e['id']}, #{e['project_id']}")
        p "#{e}"
      end
      puts "\nDONE\n"
      f.close
    end
  end

# RUN THIS TASK AFTER NOTIFICATION MIGRATIONS ONLY ONES!!!
  desc "Fills data from csv file to notifications"
  task :fill_data_to_notifications,[:file_path] => :environment do |t,args|
    # get file path
    file_path = (args['file_path'] ? args['file_path'] : "/tmp/project_ids_dump.csv")
    puts "Dump file: #{file_path}"
    print "Type new file path (optional):"
    new_file_path = STDIN.gets.chomp
    old_path = file_path
    file_path = (new_file_path.blank? ? old_path : new_file_path)

    until File.exists? file_path
      puts "#{file_path} does not exists!!!"
      print "Type new file path:"
      file_path = STDIN.gets.chomp
    end
    # migrating project_notifications to notifications
    puts "\nStarted data migration"
    IO.foreach(file_path) do |line|
      notification = Notification.find_by(id: line
        .split(',')[0]
        .strip)
      if(notification.notificable_id == nil and
          notification.notificable_type == nil and
          notification.parent_notification_id == nil)
          notification.update(notificable_id: line.split(',')[1].strip,
                              notificable_type: "Project")
      end
    end
    # collect project ids
    project_ids = IO.read(file_path)
                    .split("\n")
      .collect {|e| e.split(',')[1].strip}
      .uniq

    p "project_ids #{project_ids}"
    # create notifications for test runs
    puts "Started creation notifications for test_runs"
    project_ids.each do |project_id|
      p "project_id #{project_id}"
      project = Project.find_by(id: project_id)
      next if project.nil?
      project.test_runs.each do |tr|
        p "project #{project.id} #{project.title}"
        notification_data = Notification.where(notificable: project,
                                               user_id: tr.assigned_to)
                                        .pluck(:id, :turn_on)
                                        .flatten
        Notification.create(turn_on: notification_data.last,
                            user_id: tr.assigned_to,
                            notificable: tr,
                            parent_notification_id: notification_data.first)
      end

    end
    print "\rDONE\n"
  end
end
