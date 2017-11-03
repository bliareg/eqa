module Importable
  def load_csv(file, separator)
    return [false, 'Please select a valid CSV file.'] if file.blank? || file.size.zero?
    [get_csv_headers(file.path, separator), csv_model_fields]
  end

  def parse_csv(file_path, mappings, project_id, separator)
    parse_objects = []
    CSV.foreach(file_path, headers: :first_row, col_sep: separator) do |row|
      parse_objects << create_csv(mappings, row, project_id)
    end
    parse_objects
  end

  def get_csv_headers(file_path, separator, encoding = Encoding::UTF_8)
    CSV.foreach(file_path, headers: :first_row, col_sep: separator, encoding: encoding)
       .first.to_hash.map do |field_name, example|
      ["#{field_name} (e.g.: #{example})", field_name]
    end
  rescue EncodingError, ArgumentError
    get_csv_headers(file_path, separator, Encoding::UTF_16) if encoding != Encoding::UTF_16
  end

  def csv_model_fields
    columns = defined?(self::ATTRS) ? column_names + self::ATTRS : column_names
    (columns - self::EXCLUDED_CSV_ATTRIBUTES).collect do |field|
      [field.to_s.gsub(/_|(id)/, ' ').strip.capitalize, field.to_s]
    end
  end

  def prepare_mappings(mappings, row)
    mappings.each_with_object({}) do |(model_field, csv_fields), hash|
      next if csv_fields.empty?
      hash[model_field] = if csv_fields.size > 1
                            csv_fields.map { |field| row.field(field) }.join("\n")
                          else
                            row.field(csv_fields.first)
                          end
    end
  end

  def find_user_by_full_name(user_name)
    return nil if user_name.blank?
    first_name, last_name = user_name.downcase.split(/\s|\./)
    User.where('lower(first_name) = ?
                AND lower(last_name) = ?
                OR lower(email) = ?', first_name, last_name, user_name).first.try(:id)
  end
end
