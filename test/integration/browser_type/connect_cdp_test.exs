defmodule Playwright.BrowserType.ConnectCDPTest do
  use Playwright.TestCase, async: true, args: ["--remote-debugging-port=9222"]

  alias Playwright.Browser

  @tag exclude: [:page]
  test "can connect to an existing CDP session via http endpoint", %{browser: browser} do
    assert [] = Browser.contexts(browser)

    cdp_browser =
      Playwright.BrowserType.connect_over_cdp(
        browser,
        "http://localhost:9222/"
      )

    assert length(Browser.contexts(browser)) == 1

    Browser.close(cdp_browser)
  end

  # test_connect_to_an_existing_cdp_session
  # test_connect_to_an_existing_cdp_session_twice
  # test_conect_over_a_ws_endpoint
end
