class ISO3166::Data
  private

  class << self
    def load_cache
      @@cache ||= Marshal.load(File.binread(datafile_path %w(countries cache countries)))
      fixes = YAML.load_file Rails.root.join('app', 'services', 'countries_i18n_fix', 'fix_countries.yml')
      @@cache.deep_merge!(fixes)
    end
  end
end
