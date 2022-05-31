defmodule WatchWeb.IndigloManager do
  use GenServer

  def init(ui) do
    :gproc.reg({:p, :l, :ui_event})
    {:ok, %{ui_pid: ui, st: IndigloOff}}
  end

  def handle_info(:"top-right", %{ui_pid: ui, st: IndigloOff} = state) do
    GenServer.cast(ui, :set_indiglo)
    {:noreply, state |> Map.put(:st, IndigloOn)}
  end

  def handle_info(:"top-right", %{st: IndigloOn} = state) do
    Process.send_after(self(), :waiting_indiglooff, 2000)
    {:noreply, state |> Map.put(:st, Waiting)}
  end

  def handle_info(:waiting_indiglooff, %{ui_pid: ui, st: Waiting} = state) do
    GenServer.cast(ui, :unset_indiglo)
    {:noreply, state |> Map.put(:st, IndigloOff)}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end
end
