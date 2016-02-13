defmodule Proxy.HttpHandler do
  import Plug.Conn

  def handle_request(conn) do
    forward_request(conn)
    |> forward_response(conn)
  end

  def forward_request(conn) do
    url     = construct_url(conn)
    method  = construct_method(conn)
    body    = construct_body(conn)
    headers = construct_headers(conn)

    {:ok, response} = HTTPoison.request(method, url, body, headers)
    response
  end

  def forward_response(response, conn) do
    headers = alter_resp_headers(response.headers)
    body = response.body
    status_code = response.status_code

    %{conn | resp_headers: headers}
    |> send_resp(status_code, body)
  end

  defp construct_url(%Plug.Conn{} = conn) do
    base = conn.host <> "/" <> Enum.join(conn.path_info, "/")
    case conn.query_string do
      "" ->
        base
      qs ->
        base <> "?" <> qs
    end
  end

  defp construct_method(%Plug.Conn{method: method}) when is_binary(method) do
    method
    |> String.downcase
    |> String.to_atom
  end
  defp construct_method(_), do: :get

  defp construct_body(conn), do: construct_body(conn, "")
  defp construct_body(conn, current_body) do
    case read_body(conn) do
      {:ok, body, _} ->
        current_body <> body
      {:more, body, conn} ->
        construct_body(conn, current_body <> body)
    end
  end

  defp construct_headers(%Plug.Conn{} = conn), do: conn.req_headers

  defp alter_resp_headers(headers) do
    List.keydelete(headers, "Transfer-Encoding", 0)
  end
end
