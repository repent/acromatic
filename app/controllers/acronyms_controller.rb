class AcronymsController < ApplicationController
  before_action :set_acronym, only: [:show, :edit, :update, :destroy]

  # GET /acronyms
  # GET /acronyms.json
  def index
    @acronyms = Acronym.all
  end

  # GET /acronyms/1
  # GET /acronyms/1.json
  def show
  end

  # GET /acronyms/new
  def new
    @acronym = Acronym.new
  end

  # GET /acronyms/1/edit
  def edit
  end

  # POST /acronyms
  # POST /acronyms.json
  def create
    @acronym = Acronym.new(acronym_params)

    respond_to do |format|
      if @acronym.save
        format.html { redirect_to @acronym, notice: 'Acronym was successfully created.' }
        format.json { render :show, status: :created, location: @acronym }
      else
        format.html { render :new }
        format.json { render json: @acronym.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /acronyms/1
  # PATCH/PUT /acronyms/1.json
  def update
    respond_to do |format|
      if @acronym.update(acronym_params)
        format.html { redirect_to @acronym, notice: 'Acronym was successfully updated.' }
        format.json { render :show, status: :ok, location: @acronym }
      else
        format.html { render :edit }
        format.json { render json: @acronym.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /acronyms/1
  # DELETE /acronyms/1.json
  def destroy
    @acronym.destroy
    respond_to do |format|
      format.html { redirect_to acronyms_url, notice: 'Acronym was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_acronym
      @acronym = Acronym.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def acronym_params
      params.require(:acronym).permit(:acronym, :context, :bracketed, :bracketed_on_first_use,
        :meaning)
    end
end
