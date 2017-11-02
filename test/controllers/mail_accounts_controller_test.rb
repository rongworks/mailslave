require 'test_helper'

class MailAccountsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @mail_account = mail_accounts(:one)
  end

  test "should get index" do
    get mail_accounts_url
    assert_response :success
  end

  test "should get new" do
    get new_mail_account_url
    assert_response :success
  end

  test "should create mail_account" do
    assert_difference('MailAccount.count') do
      post mail_accounts_url, params: { mail_account: { email: @mail_account.email, host: @mail_account.host, login: @mail_account.login, name: @mail_account.name, password: @mail_account.password, port: @mail_account.port, ssl: @mail_account.ssl, user_id: @mail_account.user_id } }
    end

    assert_redirected_to mail_account_url(MailAccount.last)
  end

  test "should show mail_account" do
    get mail_account_url(@mail_account)
    assert_response :success
  end

  test "should get edit" do
    get edit_mail_account_url(@mail_account)
    assert_response :success
  end

  test "should update mail_account" do
    patch mail_account_url(@mail_account), params: { mail_account: { email: @mail_account.email, host: @mail_account.host, login: @mail_account.login, name: @mail_account.name, password: @mail_account.password, port: @mail_account.port, ssl: @mail_account.ssl, user_id: @mail_account.user_id } }
    assert_redirected_to mail_account_url(@mail_account)
  end

  test "should destroy mail_account" do
    assert_difference('MailAccount.count', -1) do
      delete mail_account_url(@mail_account)
    end

    assert_redirected_to mail_accounts_url
  end
end
