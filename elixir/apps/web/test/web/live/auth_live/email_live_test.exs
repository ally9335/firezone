defmodule Web.Auth.EmailLiveTest do
  use Web.ConnCase, async: true
  alias Domain.{AccountsFixtures, AuthFixtures}

  test "renders email page", %{conn: conn} do
    account = AccountsFixtures.create_account()
    provider = AuthFixtures.create_email_provider(account: account)

    {:ok, lv, html} = live(conn, ~p"/#{account}/sign_in/providers/email/#{provider}")

    assert html =~ "Please check your email"
    assert has_element?(lv, ~s|a[href="https://mail.google.com/mail/"]|, "Open Gmail")
    assert has_element?(lv, ~s|a[href="https://outlook.live.com/mail/"]|, "Open Outlook")
  end
end
