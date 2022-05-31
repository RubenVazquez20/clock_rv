defmodule WatchWeb.WatchLive do
  use WatchWeb, :live_view

  def mount(_params, _session, socket) do
    GenServer.start_link(WatchWeb.ClockManager, self())
    GenServer.start_link(WatchWeb.StopwatchManager, self())
    GenServer.start_link(WatchWeb.IndigloManager, self())
    {:ok, assign(socket, time: "12:00:00", indiglo: "white")}
  end

  def render(assigns) do
    ~L"""
    <svg width="250" height="250">
      <image xlink:href="/images/watch.gif"></image>
      <rect phx-click="top-left" x="2" y="60" width="12" height="12" stroke="white" stroke-width="1", fill="transparent" />
      <rect phx-click="bottom-left" x="2" y="160" width="12" height="12" stroke="white" stroke-width="1", fill="transparent" />
      <rect phx-click="top-right" x="207" y="58" width="12" height="12" stroke="white" stroke-width="1", fill="transparent" />
      <rect phx-click="bottom-right" x="209" y="160" width="12" height="12" stroke="white" stroke-width="1", fill="transparent" />
      <rect x="52" y="100" width="120" height="50" style="fill:<%= @indiglo %>" />

      <text x="73" y="135" font-family="monospace" font-size="18px" fill="black" font-weight="bold" xml:space="preserve"><%= @time %></text>
    </svg>
    """
  end
  def handle_event(event, _payload, socket) do
    IO.inspect event
    :gproc.send({:p, :l, :ui_event}, String.to_atom(event))
    {:noreply, socket}
  end

  def handle_cast({:set_time_display, str}, socket) do
    {:noreply, assign(socket, time: str)}
  end

  def handle_cast(:set_indiglo, socket) do
    {:noreply, assign(socket, indiglo: "cyan")}
  end

  def handle_cast(:unset_indiglo, socket) do
    {:noreply, assign(socket, indiglo: "white")}
  end
end
