class AddServiceMailchimpIdToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :mailchimp_service_id, :string
  end
end
