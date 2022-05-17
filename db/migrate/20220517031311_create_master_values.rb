class CreateMasterValues < ActiveRecord::Migration[5.2]
  def change
    create_table :master_values do |t|
      t.string :name

      t.timestamps
    end
  end
end
