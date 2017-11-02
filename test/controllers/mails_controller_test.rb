require 'test_helper'

class MailsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user_mail = mails(:one)
  end

  test "should get index" do
    get userMails_url
    assert_response :success
  end

  test "should get new" do
    get new_userMail_url
    assert_response :success
  end

  test "should create @user_mail" do
    assert_difference('UserMail.count') do
      post userMails_url, params: {user_mail: {bcc: @user_mail.bcc, body: @user_mail.body, cc: @user_mail.cc, envelope_from: @user_mail.envelope_from, from: @user_mail.from, message_id: @user_mail.message_id, receive_date: @user_mail.receive_date, replyto: @user_mail.replyto, subject: @user_mail.subject, to: @user_mail.to } }
    end

    assert_redirected_to userMail_url(Mail.last)
  end

  test "should show @user_mail" do
    get userMail_url(@user_mail)
    assert_response :success
  end

  test "should get edit" do
    get edit_userMail_url(@user_mail)
    assert_response :success
  end

  test "should update @user_mail" do
    patch userMail_url(@user_mail), params: {user_mail: {bcc: @user_mail.bcc, body: @user_mail.body, cc: @user_mail.cc, envelope_from: @user_mail.envelope_from, from: @user_mail.from, message_id: @user_mail.message_id, receive_date: @user_mail.receive_date, replyto: @user_mail.replyto, subject: @user_mail.subject, to: @user_mail.to } }
    assert_redirected_to userMail_url(@user_mail)
  end

  test "should destroy @user_mail" do
    assert_difference('UserMail.count', -1) do
      delete userMail_url(@user_mail)
    end

    assert_redirected_to userMails_url
  end
end
