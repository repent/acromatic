class DefinitionsController < ApplicationController
  before_action :set_definition, only: [:show, :edit, :update, :destroy, :sentence_case, 
    :titlecase]
  before_action :authenticate_user!

  # GET /definitions
  # GET /definitions.json
  def index
    @definitions = Definition.all
  end

  # GET /definitions/1
  # GET /definitions/1.json
  def show
  end

  # GET /definitions/new
  def new
    set_dictionary
    @definition = Definition.new
  end

  # GET /definitions/1/edit
  def edit
  end

  # GET /definitions/1/sentence_case
  def sentence_case
    @definition.sentence_case!
    redirect_to @definition.dictionary || @definition
  end

  # GET/definitions/1/title_case
  def titlecase
    @definition.titlecase!
    redirect_to @definition.dictionary || @definition
  end

  # POST /definitions
  # POST /definitions.json
  def create
    @definition = Definition.new(definition_params)

    respond_to do |format|
      if @definition.save
        format.html { redirect_to @definition.dictionary, notice: 'Definition was successfully created.' }
        format.json { render :show, status: :created, location: @definition }
      else
        format.html { render :new }
        format.json { render json: @definition.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /definitions/1
  # PATCH/PUT /definitions/1.json
  def update
    respond_to do |format|
      if @definition.update(definition_params)
        format.html { redirect_to @definition.dictionary || @definition, notice: 'Definition was successfully updated.' }
        format.json { render :show, status: :ok, location: @definition }
      else
        format.html { render :edit }
        format.json { render json: @definition.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /definitions/1
  # DELETE /definitions/1.json
  def destroy
    dictionary = @definition.dictionary
    @definition.destroy
    respond_to do |format|
      format.html { redirect_to dictionary_url(dictionary.id), notice: 'Definition was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_definition
      @definition = Definition.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def definition_params
      params.require(:definition).permit(:dictionary_id, :initialism, :meaning)
    end

    def set_dictionary
      @dictionary = Dictionary.find(params[:dictionary_id])
    end
end
