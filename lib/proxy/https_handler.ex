defmodule Proxy.HttpsHandler do
  import Plug.Conn

  def init(opts), do: opts

  def call(%Plug.Conn{method: "CONNECT"} = conn, _opts) do
    handle_https_request(conn)
  end
  def call(conn, _opts), do: conn

  def handle_https_request(conn) do
    conn
    |> open_tunnel
    |> stream_data
    |> close_tunnel

    %{conn | state: :sent}
    |> halt
  end

  defp open_tunnel(conn) do
    client_socket = get_client_socket(conn)
    remote_socket = open_remote_connection(conn)

    Socket.Stream.send!(
      client_socket,
      "HTTP/1.1 200 Connection established\r\n\r\n")

    {client_socket, remote_socket}
  end

  defp get_client_socket(conn) do
    conn.adapter |> elem(1) |> elem(1)
  end

  defp open_remote_connection(conn) do
    [host, port] = String.split(conn.request_path, ":")
    port = String.to_integer(port)
    Socket.TCP.connect!(host, port)
  end

  defp stream_data({client_socket, remote_socket}) do
    upstream   = start_stream_task(remote_socket, client_socket)
    downstream = start_stream_task(client_socket, remote_socket)

    {upstream, downstream}
  end

  defp start_stream_task(to, from) do
    Task.async(fn () ->
        stream(to, from)
    end)
  end

  defp stream(to, from) do
    try do
      receive_data(from)
      |> send_data(to, from)
    catch
      _ -> :connection_closed
    end
  end

  defp receive_data(socket), do: Socket.Stream.recv!(socket)

  defp send_data(data, to, from) when is_binary(data) do
    try do
      Socket.Stream.send!(to, data)
      stream(to, from)
    catch
      _ -> :connection_closed
    end
  end
  defp send_data(_, _, _), do: :connection_closed

  defp close_tunnel({upstream_task, downstream_task}) do
    await_completion([upstream_task, downstream_task])
  end

  defp await_completion(tasks) do
    running_tasks = Task.yield_many(tasks)
    case Enum.any?(running_tasks, fn {_, res} -> is_nil(res) end) do
      true ->
        await_completion(tasks)
      _ -> nil
    end
  end



end
