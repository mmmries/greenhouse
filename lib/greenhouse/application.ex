defmodule Greenhouse.Application do
  @moduledoc false

  @target Mix.target()

  use Application

  def start(_type, _args) do
    opts = [strategy: :one_for_one, name: Greenhouse.Supervisor]
    Supervisor.start_link(children(@target), opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Starts a worker by calling: Greenhouse.Worker.start_link(arg)
      # {Greenhouse.Worker, arg},
    ]
  end

  def children(_target) do
    [
      #%{id: :pump1, start: {Greenhouse.Pump, :start_link, [%{pin: 17, name: :pump1}]}},
      #%{id: :pump2, start: {Greenhouse.Pump, :start_link, [%{pin: 27, name: :pump2}]}},
      #%{id: :pump3, start: {Greenhouse.Pump, :start_link, [%{pin: 22, name: :pump3}]}},
      #%{id: :pump4, start: {Greenhouse.Pump, :start_link, [%{pin: 18, name: :pump4}]}},
      {Greenhouse.MoistureProbes, []}
    ]
  end
end
