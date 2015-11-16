defmodule Moongate.SyncEvent do
  defstruct keys: [], values: []
end

defmodule Moongate.Pool do
  import Moongate.Macros.SocketWriter

  defmacro attributes(attribute_map) do
    quote do
      def __moongate__pool_attributes(_), do: __moongate__pool_attributes
      def __moongate__pool_attributes do
        attributes = Map.merge(unquote(attribute_map), %{
          origin: {:origin}
        })
        attributes
      end
    end
  end

  defmacro mutate(target, attribute, delta, params) do
    quote do
      GenServer.cast(self(), {:mutate, unquote(target), unquote(attribute), unquote(delta), unquote(params)})
    end
  end

  defmacro cascades(cascade_list) do
    quote do
      def __moongate__pool_cascades(_), do: __moongate__pool_cascades
      def __moongate__pool_cascades do
        unquote(cascade_list)
      end
    end
  end

  defmacro touches(touch_list) do
    quote do
      def __moongate__pool_touches(_), do: __moongate__pool_touches
      def __moongate__pool_touches do
        unquote(touch_list)
      end
    end
  end

  def ask(_, _) do
  end

  def attr(member, key) do
    Moongate.Data.pool_member_attr(member, key)
  end

  def tagged(event, member, message) do
    {:tagged, :drop, "#{member[:__moongate_pool_index]}"}
  end

  def sync(event, pool, keys), do: sync(event.pools[pool], keys)
  def sync(pool, keys) do
    keys = [:__moongate_pool_index] ++ keys
    attributes = Enum.map(pool, fn(member) ->
      Enum.map(keys, fn(key) ->
        attribute = member[key]

        case attribute do
          {value, transforms} when is_number(value) ->
            represented_transforms = Enum.map(transforms, &("›#{&1.mode}:#{&1.by}")) |> Enum.join
            "#{attr(member, key)}#{represented_transforms}"
          {value, transforms} -> value
          %Moongate.SocketOrigin{} -> attribute.id
          value -> value
        end
      end)
    end)
    %Moongate.SyncEvent{
      keys: keys,
      values: attributes
    }
  end

  def bubble(event, key) do
    stage_name = Atom.to_string(event.stage)
    stage = String.to_atom("stage_#{stage_name}")
    GenServer.cast(stage, {:bubble, event, event.this[:__moongate__parent], key})
  end

  def tell(member, message) do
    {origin, _} = member[:origin]

    case message do
      %Moongate.SyncEvent{} -> write_to(origin, :sync, Moongate.Packets.sync(message))
      {:tagged, tag, index} -> write_to(origin, tag, index)
      _ -> nil
    end
  end
end
