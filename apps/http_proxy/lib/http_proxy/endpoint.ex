defmodule HttpProxy.Endpoint do
  use Plug.Builder
  alias HttpProxy.{
    HttpHandler,
    HttpsHandler,
    Blacklist,
    CacheLookup,
    HttpSetup,
  }
  require Logger

  plug HttpSetup
  plug Blacklist
  plug HttpsHandler
  plug CacheLookup
  plug HttpHandler

  def init(opts), do: opts

  def start_link do
    port = 8080
    Logger.info("Running #{__MODULE__} on port #{port}")
    {:ok, _} = Plug.Adapters.Cowboy.http(__MODULE__, [], port: port)
  end
end
