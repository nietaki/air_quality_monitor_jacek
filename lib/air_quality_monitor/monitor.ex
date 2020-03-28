defmodule AirQualityMonitor.Monitor do
  alias Circuits.UART
  require Logger
  use GenServer

  @uart_name "ttyAMA0"

  defstruct [
    :sensor_pid
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  @impl GenServer
  def init(_opts) do
    Logger.warn("starting")
    {:ok, pid} = UART.start_link()
    UART.open(pid, @uart_name, speed: 9600, active: false)
    :timer.send_interval(5000, self(), :read_from_sensor)
    state = %__MODULE__{
      sensor_pid: pid
    }
    {:ok, state}
  end

  @impl GenServer
  def handle_info(:read_from_sensor, state) do
    Logger.warn("reading")
    {:ok, bytes} = UART.read(state.sensor_pid)
    Logger.warn inspect(bytes)
    {:noreply, state}
  end
end
