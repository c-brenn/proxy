defmodule Proxy.Router do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  def init(opts), do: opts

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [], port: 8080)
  end

  match _ do
    handle_request(conn)
  end

  defp handle_request(%{method: "CONNECT"} = conn) do
    IO.puts "woweee"
    conn
    |> send_resp(200, "https :)")
    |> halt
  end

  defp handle_request(conn) do
    conn
    |> send_resp(200, "hello world")
    |> halt
  end
end
