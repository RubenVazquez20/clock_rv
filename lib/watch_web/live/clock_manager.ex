defmodule WatchWeb.ClockManager do
  use GenServer

  def init(ui) do
    :gproc.reg({:p, :l, :ui_event})
    {_, now} = :calendar.local_time()

    Process.send_after(self(), :working_working, 1000)
    {:ok, %{ui_pid: ui, time: Time.from_erl!(now), st: Working, mode: Time, alarm: Time.from_erl!(now) |> Time.add(10), st2: ModeCtrl}}
  end

  def handle_info(:working_working, %{ui_pid: ui, time: time, alarm: alarm, st: Working, mode: mode} = state) do
    Process.send_after(self(), :working_working, 1000)
    time = Time.add(time, 1)
    if mode == Time do
      GenServer.cast(ui, {:set_time_display, Time.truncate(time, :second) |> Time.to_string })
    end
    if time == alarm do
      IO.inspect("ALARM!!!")
      :gproc.send({:p,:l, :ui_event}, :start_alarm)
    end
    {:noreply, state |> Map.put(:time, time) }
  end

  def handle_info(:"top-left", %{ui_pid: ui, st2: ModeCtrl, mode: SWatch, time: time} = state) do
    GenServer.cast(ui, {:set_time_display, Time.truncate(time, :second) |> Time.to_string })
    {:noreply, %{state | mode: Time}}
  end

  def handle_info(:"top-left", %{st2: ModeCtrl, mode: Time} = state) do
    {:noreply, %{state | mode: SWatch}}
  end

  def handle_info(_event, state), do: {:noreply, state}
end
