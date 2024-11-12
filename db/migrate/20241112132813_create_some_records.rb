class CreateSomeRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :some_records do |t|
      t.text :capabilities

      t.timestamps
    end
  end
end
