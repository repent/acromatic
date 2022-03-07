class DocumentsController < ApplicationController
  before_action :set_document, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, only: [:index]
  before_action :check_expiry, only: [:show, :edit, :update]

  # GET /documents
  # GET /documents.json
  def index
    @documents = Document.all
  end

  # GET /documents/1
  # GET /documents/1.json
  def show
  end

  # GET /documents/new
  def new
    @document = Document.new
    # Set defaults
    @document.allow_mixedcase = true
    @document.allow_plurals = true
    @document.allow_hyphens = true
    @document.allow_numbers = true
    @document.allow_short = true
    @document.exclude_roman = true
    @document.guess_meanings = true
  end

  # GET /documents/1/edit
  def edit
  end

  # POST /documents
  # POST /documents.json
  def create
    begin
      @document = Document.new(document_params)

      respond_to do |format|
        if @document.save
          format.html do
            @document.trawl
            redirect_to @document, notice: 'Document was successfully created.'
          end
          format.json { render :show, status: :created, location: @document }
        else
          format.html { render :new }
          format.json { render json: @document.errors, status: :unprocessable_entity }
        end
      end

    rescue RuntimeError => e # RuntimeError: unknown file type (xxx)
      @document = Document.new
      @document.errors.add(:file, e.message)
      render :new, notice: "Upload failed, unsupported file type"
    end
  end

  # PATCH/PUT /documents/1
  # PATCH/PUT /documents/1.json
  def update # Re-render when options have been changed
    respond_to do |format|
      if @document.update(document_params)
        format.html { redirect_to @document, notice: 'Document was successfully updated.' }
        format.json { render :show, status: :ok, location: @document }
      else
        format.html { render :edit }
        format.json { render json: @document.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /documents/1
  # DELETE /documents/1.json
  def destroy
    @document.destroy
    respond_to do |format|
      format.html { redirect_to documents_url, notice: 'Document was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_document
      @document = Document.find(params[:id])
    end

    # Check that the document has been created in the last... day?
    # This is the only form of privacy protection as there is no user privacy
    # Session privacy would be better
    def check_expiry
      expiry_time = Time.now - 1.day
      redirect_to new_document_url if @document.updated_at < expiry_time
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def document_params
      params.fetch(:document, {}).permit(:file, :allow_mixedcase, :allow_plurals, :allow_hyphens,
        :allow_numbers, :allow_short, :exclude_roman, :dictionary_id, :guess_meanings)
    end
end
