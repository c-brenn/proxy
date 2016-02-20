defmodule Proxy.Tools do
  import Plug.Conn

  def construct_url(%Plug.Conn{} = conn) do
    base = conn.host <> "/" <> Enum.join(conn.path_info, "/")
    case conn.query_string do
      "" ->
        base
      qs ->
        base <> "?" <> qs
    end
  end

  def construct_method(%Plug.Conn{method: method}) when is_binary(method) do
    method
    |> String.downcase
    |> String.to_atom
  end
  def construct_method(_), do: :get

  def construct_body(conn), do: construct_body(conn, "")
  def construct_body(conn, current_body) do
    case read_body(conn) do
      {:ok, body, _} ->
        current_body <> body
      {:more, body, conn} ->
        construct_body(conn, current_body <> body)
    end
  end

  def construct_headers(%Plug.Conn{} = conn), do: conn.req_headers

  def alter_resp_headers(headers) do
    List.keydelete(headers, "Transfer-Encoding", 0)
  end
end
