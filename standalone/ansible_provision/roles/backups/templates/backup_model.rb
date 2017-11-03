# encoding: utf-8

##
# Backup Generated: my_backup
# Once configured, you can run the backup with the following command:
#
# $ backup perform -t my_backup [-c <path_to_configuration_file>]
#
# For more information about Backup's components, see the documentation at:
# http://backup.github.io/backup
#

Model.new(:{{ app_name }}, 'Description for {{ app_name }} backup') do
  database PostgreSQL do |db|
    db.name               = "{{ app_name }}_production"
    db.username           = "{{ app_name }}"
    db.password           = "{{ user_password_plain }}"
    db.host               = "localhost"
    db.port               = 5432
    # db.socket             = "/tmp/pg.sock"
  end

  compress_with Gzip

  store_with Local do |local|
    local.path = '{{ deploy_folder }}{{ app_name }}/backups/'
    # Use a number or a Time object to specify how many backups to keep.
    # local.keep = 31
  end

end
