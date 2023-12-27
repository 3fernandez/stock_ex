defmodule StockExWeb.UserRegistrationLiveTest do
  use StockExWeb.ConnCase

  import Phoenix.LiveViewTest
  import StockEx.AccountsFixtures
  import Mock

  alias StockEx.Stocks.TreasuryApiWrapper

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/users/register")

      assert html =~ "Register"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_user(user_fixture())
        |> live(~p"/users/register")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(user: %{"email" => "with spaces", "password" => "too short"})

      assert result =~ "Register"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 12 character"
    end
  end

  describe "register user" do
    test "creates account and logs the user in", %{conn: conn} do
      resp = %{
        "expense_ratio_basis_points" => 3,
        "name" => "Vanguard Group, Inc. - Vanguard Total Stock Market ETF",
        "price" => 237.8,
        "symbol" => "VTI"
      }

      with_mock(TreasuryApiWrapper, get_symbol_info: fn -> {:ok, resp} end) do
        {:ok, lv, _html} = live(conn, ~p"/users/register")

        email = unique_user_email()
        form = form(lv, "#registration_form", user: valid_user_attributes(email: email))
        render_submit(form)
        conn = follow_trigger_action(form, conn)

        assert redirected_to(conn) == ~p"/"

        # Now do a logged in request and assert on the menu
        conn = get(conn, "/")
        response = html_response(conn, 200)
        assert response =~ email
        assert response =~ "Settings"
        assert response =~ "Log out"
      end
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      user = user_fixture(%{email: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          user: %{"email" => user.email, "password" => "valid_password"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/users/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Sign in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/users/log_in")

      assert login_html =~ "Log in"
    end
  end
end
