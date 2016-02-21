defmodule HttpProxy.Endpoint do
  use Plug.Builder
  alias HttpProxy.{
    HttpHandler,
    HttpsHandler,
    Blacklist,
    CacheLookup,
    HttpSetup
  }
  require Logger

  # plug Plug.Logger
  plug Blacklist
  plug HttpsHandler
  plug HttpSetup
  plug CacheLookup
  plug HttpHandler

  def init(opts), do: opts

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [], port: 8080)
  end
end
