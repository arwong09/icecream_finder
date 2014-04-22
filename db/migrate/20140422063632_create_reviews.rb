class CreateReviews < ActiveRecord::Migration
  def change
    create_table :reviews do |t|
      t.string :restaurant
      t.text :review
      
      t.timestamps
    end
  end
end
