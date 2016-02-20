defmodule Proxy.CacheLookup do
  import Plug.Conn
  alias Proxy.{Cache, Tools}
  require Logger

  def init(opts), do: opts
  def call(conn, _opts) do
    url = Tools.construct_url(conn)
    case Cache.lookup(url) do
      {:ok, response} ->
        Logger.info("CACHE HIT: #{url}")
        serve_cached_response(response, conn)
      _ -> conn
    end
  end

  defp serve_cached_response(%{body: body, headers: headers, status_code: status_code}, conn) do
      headers = Tools.alter_resp_headers(headers)
      %{conn| resp_headers: headers}
      |> send_resp(status_code, body)
      |> halt
  end
end
