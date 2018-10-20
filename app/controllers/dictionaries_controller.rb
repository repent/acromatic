class DictionariesController < ApplicationController
  before_action :set_dictionary, only: [:show, :edit, :update, :destroy, :merge_duplicates]
  before_action :authenticate_user!, except: [:show]

  # GET /dictionaries
  # GET /dictionaries.json
  def index
    @dictionaries = Dictionary.all
  end

  # GET /dictionaries/1
  # GET /dictionaries/1.json
  def show
  end

  # GET /dictionaries/new
  def new
    @dictionary = Dictionary.new
    #add_definitions(dictionary_params)
  end

  # GET /dictionaries/1/edit
  def edit
    #add_definitions(dictionary_params)
  end

  # POST /dictionaries
  # POST /dictionaries.json
  def create
    @dictionary = Dictionary.new(dictionary_real_params)
    @dictionary.save # we're in trouble if this blows up -- currently no validation
                     # of the name so it is less bad than the previous.
    @dictionary.update(dictionary_params)

    respond_to do |format|
      if @dictionary.save
        format.html { redirect_to @dictionary, notice: 'Dictionary was successfully created.' }
        format.json { render :show, status: :created, location: @dictionary }
      else
        format.html { render :new }
        format.json { render json: @dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /dictionaries/1
  # PATCH/PUT /dictionaries/1.json
  def update
    respond_to do |format|
      if @dictionary.update(dictionary_params)
        format.html { redirect_to @dictionary, notice: 'Dictionary was successfully updated.' }
        format.json { render :show, status: :ok, location: @dictionary }
      else
        format.html { render :edit }
        format.json { render json: @dictionary.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /dictionaries/1
  # DELETE /dictionaries/1.json
  def destroy
    @dictionary.destroy
    respond_to do |format|
      format.html { redirect_to dictionaries_url, notice: 'Dictionary was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def merge_duplicates
    logger.info "Merging duplicates in #{@dictionary.name}..."
    #binding.pry
    respond_to do |format|
      if count = @dictionary.merge_duplicates
        format.html { redirect_to @dictionary, notice: "#{count} duplicates were successfully merged." }
        #format.json { render :show, status: :ok, location: @dictionary }
      else
        format.html { redirect_to @dictionary, alert: 'Failed!' }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_dictionary
      @dictionary = Dictionary.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def dictionary_params
      params.require(:dictionary).permit(:name, :quick_add)
    end
    def dictionary_real_params
      params.require(:dictionary).permit(:name)
    end
end
