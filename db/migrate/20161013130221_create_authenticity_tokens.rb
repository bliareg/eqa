class CreateAuthenticityTokens < ActiveRecord::Migration[5.0]
  def change
    create_table :authenticity_tokens do |t|
      t.string :token
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
