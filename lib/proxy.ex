defmodule Proxy do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(Proxy.Router, [])
    ]

    opts = [strategy: :one_for_one, name: Proxy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def serve(_) do
    start([], [])
    :timer.sleep(:infinity)
  end
end
