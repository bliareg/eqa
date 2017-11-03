module UrlHelpers
  def root_url
    url_hash = ActionMailer::Base.default_url_options
    "#{url_hash[:protocol] || 'http://'}#{url_hash[:host]}" +
      (url_hash[:port] ? ":#{url_hash[:port]}" : '')
  end
end
