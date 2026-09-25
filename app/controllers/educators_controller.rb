# DReSA-specific controller for the AI educator tiles page.
class EducatorsController < ApplicationController
  before_action :set_educator, only: [:show, :edit, :update, :destroy]

  def index
    @educators = Educator.order(:created_at)
  end

  def show
  end

  def new
    authorize Educator
    @educator = Educator.new
  end

  def edit
    authorize @educator
  end

  def create
    authorize Educator
    @educator = Educator.new(educator_params)
    @educator.user = current_user
    if @educator.save
      redirect_to educators_path, notice: 'Educator was successfully registered.'
    else
      render :new
    end
  end

  def update
    authorize @educator
    if @educator.update(educator_params)
      redirect_to educators_path, notice: 'Educator was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    authorize @educator
    @educator.destroy
    redirect_to educators_path, notice: 'Educator was removed.'
  end

  private

  def set_educator
    @educator = Educator.friendly.find(params[:id])
  end

  def educator_params
    params.require(:educator).permit(:title, :url, :description, :image, :image_url, :category)
  end
end
