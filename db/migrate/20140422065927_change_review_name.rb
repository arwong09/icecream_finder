class ChangeReviewName < ActiveRecord::Migration
  def change
    rename_column :reviews, :review, :body
  end
end
