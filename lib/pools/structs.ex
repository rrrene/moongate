defmodule Moongate.PoolMutation do
  defstruct(
    by: 0,
    mode: "linear",
    time_started: nil
  )
end

defmodule Moongate.PoolState do
  defstruct(
    attributes: %{},
    index: 0,
    members: [],
    name: nil,
    spec: nil,
    stage: nil,
    subscribers: []
  )
end
