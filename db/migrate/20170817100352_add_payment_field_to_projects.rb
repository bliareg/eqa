class AddPaymentFieldToProjects < ActiveRecord::Migration[5.0]
  def change
    add_column :projects, :is_payment_expired, :boolean, default: false
  end
end
