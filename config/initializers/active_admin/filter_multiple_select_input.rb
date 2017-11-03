module ActiveAdmin
  module Inputs
    class MultipleSelectInput < Formtastic::Inputs::SelectInput
      include ActiveAdmin::Inputs::Filters::Base

      def input_name
        "#{super}_in"
      end

      def extra_input_html_options
        {
          class: 'chosen',
          multiple: true
        }
      end
    end
  end
end
