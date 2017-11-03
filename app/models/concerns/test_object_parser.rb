module TestObjectParser
  ANDROID_PLATFORM = 'Android'.freeze
  IOS_PLATFORM = 'iOS'.freeze

  protected

  def set_build_params
    case File.extname(file_file_name)
    when TestObject::ANDROID_EXTNAME
      install_android_data
    when TestObject::IOS_EXTNAME
      install_ios_data
    else
      errors.add(:bad_extention, 'Your file name must have extention .apk or .ipa')
    end
  end

  private

  def install_android_data
    apk = Android::Apk.new(file.staged_path)
    manifest = Hash.from_xml(apk.manifest.to_xml)['manifest']
    assign_attributes(
      platform_version: "#{ANDROID_PLATFORM} #{manifest['platformBuildVersionName'].try { split('-')[0] }}",
      package:          manifest['package'],
      min_sdk_version:  "#{ANDROID_PLATFORM} #{manifest['uses_sdk']['android:minSdkVersion']}",
      sdk_version:      "#{ANDROID_PLATFORM} #{manifest['uses_sdk']['android:targetSdkVersion']}",
      identeficator:    "#{manifest['package']}:#{manifest['android:versionCode']}" \
                          ":#{manifest['android:versionName']}",
      file_file_name:   file_name_with_version(manifest['android:versionName'])
    )
  rescue Android::NotApkFileError
    errors.add(:not_apk_file, I18n.t('not_valid_apk_file_please_ensure_that_your_file_is_valid'))
  end

  def install_ios_data
    plist = CFPropertyList::List.new(data: ios_data)
    info_hash = CFPropertyList.native_types(plist.value)
    assign_attributes(
      platform_version: IOS_PLATFORM + info_hash['DTPlatformVersion'],
      min_sdk_version:  IOS_PLATFORM + info_hash['MinimumOSVersion'],
      package:          info_hash['CFBundleIdentifier'],
      identeficator:    info_hash['CFBundleIdentifier'] +
                        ':' + info_hash['CFBundleVersion'] +
                        ':' + info_hash['CFBundleShortVersionString'],
      file_file_name:   file_name_with_version(info_hash['CFBundleShortVersionString'])
    )
    build_ios_build_plist(info_hash: info_hash)
  end

  def ios_data
    regex = %r{^Payload\/.*\.app\/Info.plist$}
    zipfile = Zip::ZipFile.open(file.staged_path)
    path_file = zipfile.entries.select { |path| regex === path.to_s }
    zipfile.read(path_file.first.to_s)
  end

  def file_name_with_version(version)
    return file_file_name if version.nil?
    file_file_name.sub(/(\.\w+$)/, version[/[0-9.]+/] + '\1')
  end
end
