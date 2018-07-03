class ArchiveMailer < ApplicationMailer
  #layout 'mailer'
  def send_to_archive_mail(params)
    @from = params[:from]
    @to = params[:to]
    @subject = params[:subject]
    @attachment = params[:attachment]

    attachments["#{@subject}.xeml"] = @attachment
    mail(from: @from, to:@to, subject:"[ARCHIVED]#{@subject}")
  end
end
