defmodule Proxy.Router do
  use Plug.Router
  alias Proxy.{HttpHandler, HttpsHandler}
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

  defp handle_request(%Plug.Conn{method: "CONNECT"} = conn) do
    HttpsHandler.handle_request(conn)
  end

  defp handle_request(conn) do
    HttpHandler.handle_request(conn)
  end
end
