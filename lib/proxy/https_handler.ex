defmodule Proxy.HttpsHandler do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{method: "CONNECT"} = conn, _opts) do
    handle_https_request(conn)
  end
  def call(conn, _opts), do: conn

  def handle_https_request(conn) do
    Proxy.SSLTunnel.tunnel_traffic(conn)

    %{conn | state: :sent}
    |> halt
  end
end
