class UnspacesValidator < ActiveModel::EachValidator
  def validate_each(record, attr_name, value)
    return if value.nil? || !(value =~ /\A\s+\z/)
    record.errors.add(attr_name, :zip_code, options.merge(value: value))
  end
end
  # This allows us to assign the validator in the model
module ActiveModel::Validations::HelperMethods
  def validates_unspaces(*attr_names)
    validates_with UnspacesValidator, _merge_attributes(attr_names)
  end
end
