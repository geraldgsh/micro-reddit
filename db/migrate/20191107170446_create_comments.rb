class CreateComments < ActiveRecord::Migration[6.0]
  def change
    create_table :comments do |t|
      t.text :body
      t.references :user, index: true
      t.references :post, index: true

      t.timestamps
    end
  end
end
