class CreateAccounts < ActiveRecord::Migration[6.1]
  def change
    create_table :accounts do |t|
      t.text :blob

      t.timestamps
    end
  end
end
