class BarangaysController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_barangay, only: [:show, :edit, :update, :destroy]
  
  def index
    @barangays = Barangay.all
  end
  
  def show
    @reports = @barangay.reports.includes(:user, :category).order(created_at: :desc)
  end
  
  def new
    @barangay = Barangay.new
    authorize @barangay
  end
  
  def create
    @barangay = Barangay.new(barangay_params)
    authorize @barangay
    
    if @barangay.save
      redirect_to @barangay, notice: "Barangay was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end
  
  def edit
    authorize @barangay
  end
  
  def update
    authorize @barangay
    
    if @barangay.update(barangay_params)
      redirect_to @barangay, notice: "Barangay was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    authorize @barangay
    @barangay.destroy
    redirect_to barangays_path, notice: "Barangay was successfully deleted."
  end
  
  private
  
  def set_barangay
    @barangay = Barangay.find(params[:id])
  end
  
  def barangay_params
    params.require(:barangay).permit(:name, :description, :address, :contact_number, :contact_email)
  end
end

