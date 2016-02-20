defmodule Proxy.CacheLookup do
  import Plug.Conn
  alias Proxy.{Cache, Tools}
  require Logger

  def init(opts), do: opts
  def call(%Plug.Conn{method: "GET"} = conn, _opts) do
    url = Tools.construct_url(conn)
    case Cache.lookup(url) do
      {:ok, {:valid, response}} ->
        Logger.info("CACHE -- HIT: #{url}")
        serve_cached_response(response, conn)
      {:ok, {:requires_check, response}} ->
        Logger.info("CACHE -- HIT - Requires expiry check: #{url}")
        check_expiry(conn, response, url)
      _ ->
        Logger.info("CACHE -- MISS: #{url}")
        conn
    end
  end
  def call(conn, _opts), do: conn

  defp serve_cached_response(%{body: body, headers: headers, status_code: status_code}, conn) do
      headers = Tools.alter_resp_headers(headers)
      %{conn| resp_headers: headers}
      |> send_resp(status_code, body)
      |> halt
  end

  defp check_expiry(conn, cached_resp, url) do
    case Enum.find(cached_resp.headers, fn {key, _} -> String.downcase(key) == "etag" end) do
      nil ->
        make_new_request(url, conn)
      etag ->
        check_etag(etag, url, cached_resp, conn)
    end
  end

  defp make_new_request(url, conn) do
    Logger.info("CACHE -- EXPIRED --  re-requesting#{url}")
    data = case HTTPoison.get(url) do
      {:ok, response} ->
        {url, response, conn.method}
      {:error, %{reason: reason}} ->
        {:error, reason, url}
    end
    Proxy.HttpHandler.cache_response(data)
    |> Proxy.HttpHandler.forward_response(conn)
    |> halt
  end

  defp check_etag({_, etag}, url, cached_response, conn) do
    data = case HTTPoison.get(url, [{"If-None-Match", etag}]) do
      {:ok, %{status_code: 304}} ->
        Logger.info("CACHE -- CHECKING ETAG -- Not modified: #{url}")
        cached_response
      {:ok, response} ->
        Logger.info("CACHE -- CHECKING ETAG -- Modified and re-requested: #{url}")
        Proxy.HttpHandler.cache_response({url, response, conn.method})
      {:error, %{reason: reason}} ->
        {:error, reason, url}
    end
    data
    |> Proxy.HttpHandler.forward_response(conn)
    |> halt
  end
end
