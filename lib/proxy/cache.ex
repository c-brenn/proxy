defmodule Proxy.Cache do
  use GenServer
  require Logger

  # Public API

  def lookup(url) when is_binary(url) do
    case :ets.lookup(:http_cache, url) do
      [{^url, data}] -> {:ok, data}
      [] -> :cache_miss
    end
  end

  def save(url, data) when is_binary(url) do
    GenServer.cast(__MODULE__, {:save, url, data})
  end

  # GenServer Implementation

  def start_link do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init(_args) do
    cache = :ets.new(:http_cache, [:set, :named_table, read_concurrency: true])
    {:ok, cache}
  end

  def handle_cast({:save, url, data}, cache) do
    :ets.insert(cache, {url, data})
    {:noreply, cache}
  end
end
