namespace :db_maintenance do
  desc 'Create missing attachments after e7c0899ee755dcaf0ae949623ac8357c2870cc09'
  task :create_missing_attachments => :environment do

    User.all.each do |user|
      p ' '.rjust(4) + "create attachment for user: #{user.id} #{user.name}"

      user.avatar = Attachment.new(file_file_name: user.avatar_file_name,
                                   file_content_type: user.avatar_content_type)
    end

    Project.all.each do |proj|
      p ' '.rjust(4) + "create attachment for project: #{proj.id} #{proj.title}"

      proj.logo = Attachment.new(file_file_name: proj.logo_file_name,
                                 file_content_type: proj.logo_content_type)
    end

    Organization.all.each do |org|
      p ' '.rjust(4) + "create attachment for organization: #{org.id} #{org.title}"

      org.logo = Attachment.new(file_file_name: org.logo_file_name,
                                file_content_type: org.logo_content_type)
    end

  end
end
