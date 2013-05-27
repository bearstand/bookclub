class CategoriesController < ApplicationController
  def index
    @categories = Category.all

    respond_to do |format|
      format.html
      format.xml  { render :xml => @categories }
    end
  end
end
