defmodule HttpProxy.Blacklist do
  import Plug.Conn
  alias HttpProxy.Logger

  # Agent used to keep track of black list

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def blocked?(host) do
    Agent.get(__MODULE__, &Enum.any?(&1, fn(url) -> String.starts_with?(host, url) end))
  end

  def block(host) do
    Logger.info("BLOCKING HOST -- #{host}")
    Agent.update(__MODULE__, &([host|&1]))
  end

  def list_blocked do
    Agent.get(__MODULE__, &(&1))
  end

  # Plug used to filter requests using blacklist

  def init(opts), do: opts

  def call(conn, _opts) do
    url = conn.assigns.url
    if blocked?(url) do
      Logger.info("Blocked request to #{url}")
      conn
      |> send_resp(403, "Endpoint blocked!")
      |> halt
    else
      conn
    end
  end
end
