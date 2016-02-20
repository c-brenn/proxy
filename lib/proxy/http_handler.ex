defmodule Proxy.HttpHandler do
  alias Proxy.{Cache, Tools}
  import Plug.Conn

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

    {:ok, response} = HTTPoison.request(method, url, body, headers)
    {url, response}
  end

  defp cache_response({url, response}) do
    Cache.save(url, response)
    response
  end

  defp forward_response(response, conn) do
    headers = Tools.alter_resp_headers(response.headers)
    body = response.body
    status_code = response.status_code

    %{conn | resp_headers: headers}
    |> send_resp(status_code, body)
  end
end
