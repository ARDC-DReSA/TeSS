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
    if ardc_heading_allowed? && @educator.save
      # DRESA-96: a tile from someone who is not a curator or admin goes live at once,
      # and the site contact is emailed so a curator can check it (and hide it if needed).
      EducatorMailer.new_tile(@educator).deliver_later unless Educator.ardc_heading_user?(current_user)
      redirect_to educators_path, notice: 'Educator was successfully registered.'
    else
      render :new
    end
  end

  def update
    authorize @educator
    @educator.assign_attributes(educator_params)
    if ardc_heading_allowed? && @educator.save
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

  # DRESA-96: only curators and admins may move a tile into an ARDC heading
  # (Dataspaces, FAIR). The drop-down already hides them; this also stops a
  # hand-made request. A tile already under an ARDC heading keeps it when edited.
  def ardc_heading_allowed?
    return true unless Educator::ARDC_HEADINGS.include?(@educator.category)
    return true if Educator.ardc_heading_user?(current_user)
    return true if @educator.persisted? && !@educator.category_changed?
    @educator.errors.add(:category, 'is kept for ARDC tiles; please choose another heading')
    false
  end

  def set_educator
    @educator = Educator.friendly.find(params[:id])
  end

  def educator_params
    params.require(:educator).permit(:title, :url, :description, :image, :image_url, :category,
                                     :content_provider_id, :licence, :status,
                                     keywords: [], target_audience: [])
  end
end
