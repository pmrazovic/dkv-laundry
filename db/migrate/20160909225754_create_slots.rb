class CreateSlots < ActiveRecord::Migration
  def change
    create_table :slots do |t|
    	t.integer  :user_id
    	t.integer  :room_number
    	t.datetime :start
    	t.datetime :finish
      t.timestamps null: false
    end
  end
end
