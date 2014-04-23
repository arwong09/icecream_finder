class AddImageColumn < ActiveRecord::Migration
  def change
    add_column :reviews, :img, :text
  end
end
