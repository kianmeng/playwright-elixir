defmodule Playwright.Transport.WebSocket do
  @moduledoc false
  # A transport for negotiating messages with a running Playwright websocket
  # server.

  defstruct([
    :gun,
    :process_monitor,
    :stream_ref
  ])

  # module API
  # ----------------------------------------------------------------------------

  def setup([ws_endpoint]) do
    uri = URI.parse(ws_endpoint)

    with {:ok, gun_pid} <- :gun.open(to_charlist(uri.host), port(uri), %{connect_timeout: 30_000}),
         {:ok, _protocol} <- :gun.await_up(gun_pid, :timer.seconds(5)),
         {:ok, stream_ref} <- ws_upgrade(gun_pid, uri.path),
         :ok <- wait_for_ws_upgrade() do
      ref = Process.monitor(gun_pid)

      %__MODULE__{
        gun: gun_pid,
        process_monitor: ref,
        stream_ref: stream_ref
      }
    else
      error -> error
    end
  end

  def post(message, %{gun: gun, stream_ref: stream_ref}) do
    :gun.ws_send(gun, stream_ref, {:text, message})
  end

  def parse({:gun_ws, _gun_pid, _stream_ref, {:text, message}}, state) do
    {[message], state}
  end

  # private
  # ----------------------------------------------------------------------------

  defp port(%{port: port}) when not is_nil(port), do: port
  defp port(%{scheme: "ws"}), do: 80
  defp port(%{scheme: "wss"}), do: 443

  defp wait_for_ws_upgrade do
    receive do
      {:gun_upgrade, _pid, _stream_ref, ["websocket"], _headers} ->
        :ok

      {:gun_response, _pid, _stream_ref, _, status, _headers} ->
        {:error, status}

      {:gun_error, _pid, _stream_ref, reason} ->
        {:error, reason}
    after
      1000 ->
        exit(:timeout)
    end
  end

  defp ws_upgrade(gun_pid, path), do: {:ok, :gun.ws_upgrade(gun_pid, path)}
end
