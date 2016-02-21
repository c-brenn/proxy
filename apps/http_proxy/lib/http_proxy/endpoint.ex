defmodule HttpProxy.Endpoint do
  use Plug.Builder
  alias HttpProxy.{
    HttpHandler,
    HttpsHandler,
    Blacklist,
    CacheLookup,
    HttpSetup,
    Logger
  }

  plug HttpSetup
  plug Blacklist
  plug HttpsHandler
  plug CacheLookup
  plug HttpHandler

  def init(opts), do: opts

  def start_link do
    port = 8080
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [], port: port)
  end
end
