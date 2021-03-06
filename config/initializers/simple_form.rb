ActionView::Helpers::FormBuilder.class_eval do
    def submit_with_override(field, options = {})
      data_disable_with = { }
      options[:data] = data_disable_with.merge(options[:data] || {})
      submit_without_override(field, options)
    end
    alias_method_chain :submit, :override
  end