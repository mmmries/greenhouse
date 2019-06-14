defmodule Greenhouse.MoistureProbes do
  use GenServer
  require Logger
  alias Circuits.I2C

  @bus_name "i2c-1"
  @addr 72
  @pause_time 500
  @error_reading 10_000 #anything lower than this should be considered an error (sensor not connected?)
  @min_reading 22_793 #submerged in pure water
  @max_reading 32_767 #completely dry
  @sensors [
    %{name: :pot1, comparison: {:ain0, :gnd}},
    %{name: :pot2, comparison: {:ain1, :gnd}},
    %{name: :pot3, comparison: {:ain2, :gnd}},
    %{name: :pot4, comparison: {:ain3, :gnd}}
  ]

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, nil, opts)
  end

  def init(nil) do
    {:ok, bus} = I2C.open(@bus_name)
    {:ok, %{bus: bus}, @pause_time}
  end

  def handle_info(:timeout, %{bus: bus}=state) do
    readings = Enum.reduce(@sensors, %{}, fn(%{name: name, comparison: comparison}, map) ->
      case ADS1115.read(bus, @addr, comparison) |> elem(1) |> convert_reading() do
        {:ok, percent} -> Map.put(map, name, percent)
        {:error, _} ->
          Logger.error("Failed to read sensor for #{name}")
      end
    end)
    :ok = :influx_udp.write(%{measurement: "moisture", fields: readings})
    {:noreply, state, @pause_time}
  end

  @doc "convert the integer sensor reading to a percentage of wetness"
  @spec convert_reading(non_neg_integer()) :: {:ok, float()} | {:error, String.t()}
  def convert_reading(reading) when reading <= @error_reading do
    {:error, "could not read the sensor"}
  end
  def convert_reading(reading) do
    clamped = reading |> min(@max_reading) |> max(@min_reading)
    percent = (@max_reading - clamped) / (@max_reading - @min_reading)
    {:ok, percent}
  end
end
