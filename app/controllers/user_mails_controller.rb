class UserMailsController < ApplicationController
  before_action :set_mail, only: [:show, :edit, :update, :destroy, :download_attachment]
  before_action :authenticate_user!

  # GET /user_mails
  # GET /user_mails.json
  def index
    @q = UserMail.ransack(params[:q])
    @user_mails = policy_scope(@q.result)
  end

  # GET /user_mails/1
  # GET /user_mails/1.json
  def show
    respond_to do |format|
      format.html do
        html = @user_mail.html_content
        @body_content = html.present? ? html.html_safe : @user_mail.plain_content || @user_mail.source_content
        @body_content = html.present? ? html.html_safe : "<div>#{@user_mail.plain_content}</div>".html_safe if params['view_as'] == 'html'
        @body_content = @user_mail.plain_content if params['view_as'] == 'plain'
        @body_content = @user_mail.source_content if params['view_as'] == 'source'
        if @user_mail.conversation.nil?
          @prev_mails = []
        else
          ref_mails = @user_mail.conversation.gsub(/[\\\[\]\"]/,'').split(',').map(&:strip)
          @prev_mails = UserMail.where(message_id: ref_mails)

        end
        #@prev_mails = ref_mails.collect{|ma| UserMail.find_by(message_id:ma)}
        @next_mails = UserMail.where('conversation LIKE ?', "%#{@user_mail.message_id}%").order(:receive_date)
      end
      format.json {}
      format.eml do
        send_file @user_mail.source_file.file.file,filename:"#{@user_mail.subject}.eml"
      end
    end

  end

  # GET /user_mails/new
  def new
    @user_mail = UserMail.new
  end

  # GET /user_mails/1/edit
  def edit
  end

  # POST /user_mails
  # POST /user_mails.json
  def create
    @user_mail = UserMail.new(mail_params)

    respond_to do |format|
      if @user_mail.save
        format.html { redirect_to @user_mail, notice: 'UserMail was successfully created.' }
        format.json { render :show, status: :created, location: @user_mail }
      else
        format.html { render :new }
        format.json { render json: @user_mail.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /user_mails/1
  # PATCH/PUT /user_mails/1.json
  def update
    respond_to do |format|
      if @user_mail.update(mail_params)
        format.html { redirect_to @user_mail, notice: 'UserMail was successfully updated.' }
        format.json { render :show, status: :ok, location: @user_mail }
      else
        format.html { render :edit }
        format.json { render json: @user_mail.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /user_mails/1
  # DELETE /user_mails/1.json
  def destroy
    @user_mail.destroy
    respond_to do |format|
      format.html { redirect_to userMails_url, notice: 'UserMail was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def download_attachment
    filename = params[:filename]
    if filename.present?
      #att = @user_mail.get_attachment(filename)
      att = @user_mail.user_mail_attachments.detect {|f| f.filename == filename}
      send_file att.file.file.file,filename: filename
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mail
      @user_mail = UserMail.find(params[:id])
      authorize @user_mail
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def mail_params
      params.require(:user_mail).permit(:from, :to, :replyto, :receive_date, :envelope_from, :message_id, :cc, :bcc, :body, :subject, :conversation, :archived)
    end
end
