class ReviewsController < ApplicationController
  def index
    @reviews = Review.all
  end
  
  def show
    @review = Review.find(params[:id])
  end
  
  def new
    @review = Review.new
  end
  
  def create
    @review = Review.new(
      restaurant: params[:review][:restaurant],
      body: params[:review][:body])
    @review.save
    
    redirect_to review_path(@review)
  end
end
