class CreateVins < ActiveRecord::Migration[5.2]
  def change
    create_table :vins do |t|
      t.string :model
      t.string :brand
      t.timestamps
    end
  end
end
