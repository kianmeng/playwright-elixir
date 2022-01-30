defmodule Playwright.BrowserType.ConnectCDPTest do
  use Playwright.TestCase, async: true, args: ["--remote-debugging-port=9222"]

  alias Playwright.Browser
  alias Playwright.BrowserContext
  alias Playwright.Page

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

  @tag exclude: [:page]
  test "can connect to an existing CDP session twice", %{browser: browser, assets: assets} do
    cdp_browser1 =
      Playwright.BrowserType.connect_over_cdp(
        browser,
        "http://localhost:9222/"
      )

    cdp_browser2 =
      Playwright.BrowserType.connect_over_cdp(
        browser,
        "http://localhost:9222/"
      )

    assert length(contexts(cdp_browser1)) == 1

    page1 =
      contexts(cdp_browser1)
      |> List.first()
      |> BrowserContext.new_page()

    Page.goto(page1, assets.empty)

    assert length(contexts(cdp_browser2)) == 1

    page2 =
      contexts(cdp_browser2)
      |> List.first()
      |> BrowserContext.new_page()

    num_pages1 =
      contexts(cdp_browser1)
      |> List.first()
      |> pages()
      |> length()

    assert num_pages1 == 2
    # assert len(cdp_browser1.contexts[0].pages) == 2
    # assert len(cdp_browser2.contexts[0].pages) == 2

    # port = find_free_port()
    # browser_server = await browser_type.launch(
    #     **launch_arguments, args=[f"--remote-debugging-port={port}"]
    # )
    # endpoint_url = f"http://localhost:{port}"
    # cdp_browser1 = await browser_type.connect_over_cdp(endpoint_url)
    # cdp_browser2 = await browser_type.connect_over_cdp(endpoint_url)
    # assert len(cdp_browser1.contexts) == 1
    # page1 = await cdp_browser1.contexts[0].new_page()
    # await page1.goto(server.EMPTY_PAGE)

    # assert len(cdp_browser2.contexts) == 1
    # page2 = await cdp_browser2.contexts[0].new_page()
    # await page2.goto(server.EMPTY_PAGE)

    # assert len(cdp_browser1.contexts[0].pages) == 2
    # assert len(cdp_browser2.contexts[0].pages) == 2

    # await cdp_browser1.close()
    # await cdp_browser2.close()
    # await browser_server.close()
  end

  # test_conect_over_a_ws_endpoint
  defp contexts(browser), do: Browser.contexts(browser)
  defp pages(context), do: BrowserContext.pages(context)
end
