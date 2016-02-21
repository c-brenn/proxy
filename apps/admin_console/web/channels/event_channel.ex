defmodule AdminConsole.EventChannel do
  use Phoenix.Channel

  def join("events:all", _message, socket) do
    {:ok, socket}
  end

  def handle_in("new_msg", _, socket) do
    broadcast! socket, "new_msg", %{body: "foooooo"}
    {:noreply, socket}
  end

  def handle_in("block", %{"url" => url}, socket) do
    HttpProxy.Blacklist.block(url)
    {:noreply, socket}
  end
end
