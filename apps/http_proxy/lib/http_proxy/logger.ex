defmodule HttpProxy.Logger do
  require Logger
  alias AdminConsole.EventBroadcaster

  def info(message) when is_binary(message) do
    message
    |> broadcast(:info)
    |> Logger.info
  end

  def error(message) when is_binary(message) do
    message
    |> broadcast(:error)
    |> Logger.info
  end

  defp broadcast(message, type) do
    EventBroadcaster.send_event(%{type: type, message: message})
    message
  end
end
