defmodule WatchWeb.StopwatchManager do
  use GenServer

  def init(ui) do
    :gproc.reg({:p, :l, :ui_event})
    GenServer.cast(ui, {:set_time_display, "00:00.00" })
    {:ok, %{ui_pid: ui, count: ~T[00:00:00.00], st1: Working, st2: Paused, mode: Time}}
  end

  # ----------------------------------------------------
  #  Working --- bottom-left/count = 0; set_time_display() ----> Working
  # ----------------------------------------------------
  def handle_info(:"bottom-left", %{ui_pid: ui, st1: Working, mode: SWatch} = state) do
    GenServer.cast(ui, {:set_time_display, "00:00.00" })
    {:noreply, %{state | count: ~T[00:00:00.00]}}
  end

  def handle_info(:"top-left", %{st1: Working, mode: SWatch} = state) do
    {:noreply, %{state | mode: Time}}
  end

  def handle_info(:"top-left", %{ui_pid: ui, st1: Working, mode: Time, count: count} = state) do
    GenServer.cast(ui, {:set_time_display, Time.truncate(count, :millisecond) |> Time.to_string  |> String.slice(3, 8) })
    {:noreply, %{state | mode: SWatch}}
  end

  ###################################################################

  def handle_info(:"bottom-right", %{st2: Paused, mode: SWatch} = state) do
    Process.send_after(self(), :counting_counting, 10)
    {:noreply, state |> Map.put(:st2, Counting)}
  end

  def handle_info(:"bottom-right", %{st2: Counting, mode: SWatch} = state) do
    {:noreply, state |> Map.put(:st2, Paused)}
  end

  def handle_info(:counting_counting, %{st2: Counting, ui_pid: ui, count: count, mode: mode} = state) do
    Process.send_after(self(), :counting_counting, 10)
    count = Time.add(count, 10, :millisecond)
    if mode == SWatch do
      GenServer.cast(ui, {:set_time_display, Time.truncate(count, :millisecond) |> Time.to_string  |> String.slice(3, 8) })
    end
    # IO.inspect(count)
    {:noreply, state |> Map.put(:count, count)}
  end

  def handle_info(_event, state) do
    {:noreply, state}
  end
end
