class DinosController < ApplicationController
  def index
    # you need to get all Dinos from the database
  end
  def show
    @dino = params[:id]
  end
end
