class CreateEvents < ActiveRecord::Migration[7.0]
  def change
    create_table :events do |t|
      t.string :path, null: false
      t.string :method, null: false
      t.string :params
      t.references :visitor, null: false, foreign_key: {on_delete: :cascade}

      t.timestamps
    end
  end
end
