module MobileBuilder
  BUILD_APK_URI = URI('http://5.9.158.109:3000/builder/build_apk').freeze

  protected

  def mobile_build(build_repository_url)
    # http://username:token@project_url
    url = build_repository_url.split('//')
    upload_url = "#{url[0]}//#{username}:#{access_token}@#{url[1]}"

    response = send_http_post(BUILD_APK_URI, upload_url: upload_url,
                                             branch: branch)

    operation_status(response, retrieve_build(response))
  end

  private

  def send_http_post(uri, data)
    req = Net::HTTP::Post.new(uri)
    req.set_form_data(data)

    http = Net::HTTP.new(uri.hostname, uri.port)
    http.read_timeout = 500
    http.request(req)
  end

  def retrieve_build(response)
    {
      file: StringIO.open(response.body),
      file_file_name: retrieve_file_name(response),
      file_content_type: response.content_type
    }
  end

  def retrieve_file_name(response)
    raise I18n.t('connection_failed') unless response.code =~ /^2\d{2}$/
    file_name_regexp = /(?<=filename\=\")([\w,\-]*\.[\w,\-]*)/
    response.to_hash['content-disposition'][0][file_name_regexp]
  end
end
