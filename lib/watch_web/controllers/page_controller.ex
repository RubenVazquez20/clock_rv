defmodule WatchWeb.PageController do
  use WatchWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
