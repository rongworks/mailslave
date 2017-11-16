module UserMailsHelper
  def email_fields(mails)
      if mails.nil?
        return ""
      end
      mail_list = JSON.parse(mails)
      if mail_list.count > 0
        mail_list.map do |mail|
          content_tag :span do
            mail_to(mail, mail,class:'badge badge-secondary')
          end
        end.join('  ').html_safe
      end
  end

  def show_attachments(mail)
    attached_files = mail.user_mail_attachments.map do |att|
        link_to(att.file_identifier,download_attachment_user_mail_path(filename:att.file_identifier),class:'badge badge-info')
    end.join().html_safe
  end

  def get_content(mail)
    content = mail.html_content ? mail.html_content.html_safe : mail.plain_content || ""
    content_tag :span, content if content
  end

  def display_body(text)
    if strip_tags(text) != text
      content_tag(:div,text)
    else
      content_tag(:pre,text)
    end
  end
end
