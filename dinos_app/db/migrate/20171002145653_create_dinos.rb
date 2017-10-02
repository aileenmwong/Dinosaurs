class CreateDinos < ActiveRecord::Migration[5.1]
  def change
    create_table :dinos do |t|
      t.string :name
      t.string :color
      t.string :breed

      t.timestamps
    end
  end
end
