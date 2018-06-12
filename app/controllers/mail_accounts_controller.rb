class MailAccountsController < ApplicationController
  before_action :set_mail_account, only: [:show, :edit, :update, :destroy, :pull_imap]
  before_action :authenticate_user!

  # GET /mail_accounts
  # GET /mail_accounts.json
  def index
    @mail_accounts = policy_scope(MailAccount)
  end

  # GET /mail_accounts/1
  # GET /mail_accounts/1.json
  def show
  end

  # GET /mail_accounts/new
  def new
    @mail_account = MailAccount.new
    authorize @mail_account
  end

  # GET /mail_accounts/1/edit
  def edit
  end

  # POST /mail_accounts
  # POST /mail_accounts.json
  def create
    @mail_account = MailAccount.new(mail_account_params)
    authorize(@mail_account)

    respond_to do |format|
      if @mail_account.save
        format.html { redirect_to @mail_account, notice: 'UserMail account was successfully created.' }
        format.json { render :show, status: :created, location: @mail_account }
      else
        format.html { render :new }
        format.json { render json: @mail_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /mail_accounts/1
  # PATCH/PUT /mail_accounts/1.json
  def update
    respond_to do |format|
      if @mail_account.update(mail_account_params)
        format.html { redirect_to @mail_account, notice: 'UserMail account was successfully updated.' }
        format.json { render :show, status: :ok, location: @mail_account }
      else
        format.html { render :edit }
        format.json { render json: @mail_account.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /mail_accounts/1
  # DELETE /mail_accounts/1.json
  def destroy
    @mail_account.destroy
    respond_to do |format|
      format.html { redirect_to mail_accounts_url, notice: 'UserMail account was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def pull_imap
    authorize(@mail_account)
    #@mail_account.delay(queue:'sync').pull_imap
    @mail_account.pull_imap
    redirect_to @mail_account
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mail_account
      @mail_account = MailAccount.find(params[:id])
      authorize(@mail_account)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mail_account_params
      params.require(:mail_account).permit(:name, :email, :user_id, :login, :password, :port, :ssl, :host)
    end
end
