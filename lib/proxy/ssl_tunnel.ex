defmodule Proxy.SSLTunnel do
  alias Proxy.SSLStream
  require Logger

  def tunnel_traffic(conn) do
    conn
    |> open_tunnel
    |> stream_data

    close_tunnel
    log_closed(conn)
  end

  def open_tunnel(conn) do
    client_socket = get_client_socket(conn)
    remote_socket = open_remote_connection(conn)

    :gen_tcp.send(client_socket, "HTTP/1.1 200 Connection established\r\n\r\n")

    {client_socket, remote_socket}
  end

  defp get_client_socket(conn) do
    conn.adapter |> elem(1) |> elem(1)
  end

  defp open_remote_connection(conn) do
    [host, port] = String.split(conn.request_path, ":")
    host = String.to_char_list(host)
    port = String.to_integer(port)

    Logger.info("Opening SSL tunnel to #{host}")

    {:ok, socket} = :gen_tcp.connect(host, port, [:binary, active: false])
    socket
  end

  defp stream_data({client_socket, remote_socket}) do
    start_stream_task(remote_socket, client_socket)
    start_stream_task(client_socket, remote_socket)
  end

  defp start_stream_task(to, from) do
    {:ok, pid} = Task.Supervisor.start_child(
      Proxy.SSLSupervisor,
      fn -> SSLStream.stream(to, from, self()) end)
    :ok = :gen_tcp.controlling_process(from, pid)
  end

  defp close_tunnel do
    receive do
      :connection_closed -> :ok
    end
  end

  defp log_closed(conn) do
    [host, _] = String.split(conn.request_path, ":")
    Logger.info("Closing SSL tunnel to #{host}")
  end
end
