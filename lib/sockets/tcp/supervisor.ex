defmodule Moongate.Socket.TCP.Supervisor do
  @moduledoc """
    This is a supervisor for Moongate.Socket.TCP.GenServer only.
    It uses the simple_one_for_one strategy, which allows
    supervised processes to be dynamically added and killed.

    When Moongate starts, the ports.json of the active world is
    loaded and a Moongate.Socket.TCP.GenServer is added to this
    supervisor for every object with `protocol` set to `"TCP"`.
    The key of the object is used as the process' port.
  """
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, nil, [name: :tcp])
  end

  @doc """
    Prepare the sockets listener supervisor.
  """
  def init(_) do
    [worker(Moongate.Socket.TCP.GenServer, [], [])]
    |> supervise(strategy: :simple_one_for_one)
  end
end
