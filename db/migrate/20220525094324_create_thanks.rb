class CreateThanks < ActiveRecord::Migration[5.2]
  def change
    create_table :thanks do |t|
      t.string :user_id
      t.integer :count
      t.timestamps
    end
  end
end
