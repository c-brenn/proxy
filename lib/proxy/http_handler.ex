defmodule Proxy.HttpHandler do
  alias Proxy.{Cache, Tools}
  import Plug.Conn
  require Logger

  def init(opts), do: opts

  def call(conn, _opts) do
    forward_request(conn)
    |> cache_response
    |> forward_response(conn)
  end

  defp forward_request(conn) do
    url     = Tools.construct_url(conn)
    method  = Tools.construct_method(conn)
    body    = Tools.construct_body(conn)
    headers = Tools.construct_headers(conn)

    Logger.info("HTTP -- #{conn.method} -- #{url}")

    case HTTPoison.request(method, url, body, headers) do
      {:ok, response} ->
        {url, response, conn.method}
      {:error, %{reason: reason}} ->
        {:error, reason, url}
    end
  end

  def cache_response({:error, reason}), do: {:error, reason}
  def cache_response({url, response, "GET"}) do
    Cache.save(url, response)
    response
  end
  def cache_response({_, response, _}), do: response

  def forward_response({:error, reason, url}, conn) do
    Logger.info("HTTP -- Remote error #{url} -- #{reason}")
    conn
    |> send_resp(500, "Something went wrong: #{inspect(reason)}")
    |> halt
  end
  def forward_response(response, conn) do
    headers = Tools.alter_resp_headers(response.headers)
    body = response.body
    status_code = response.status_code

    %{conn | resp_headers: headers}
    |> send_resp(status_code, body)
  end
end
