defmodule Proxy.CacheTest do
  use ExUnit.Case
  alias Proxy.Cache
  doctest Proxy.Cache

  test "saves content correctly" do
    host = "google.com"
    content = "<html>foo</html>"

    Cache.save(host, content)

    :timer.sleep 100

    assert {:ok, content} == Cache.lookup(host)
  end

  test "reports cache misses correctly" do
    assert :cache_miss == Cache.lookup("host.not.found")
  end
end
