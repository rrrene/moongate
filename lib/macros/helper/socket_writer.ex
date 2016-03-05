defmodule Moongate.Macros.SocketWriter do
  def write_to(target, tag, message) do
    write_to(target, tag, Atom.to_string(Process.info(self())[:registered_name]), message)
  end
  def write_to(target, tag, name, message) do
    timestamp = Moongate.Time.current_ms
    tag = Atom.to_string(tag)

    if is_list(message) do
      parts = Enum.map(message, &Moongate.Atoms.to_strings/1)
      parsed_parts = String.strip(Enum.join(parts, "·"))
      packet_length = byte_size("#{timestamp}" <> name <> tag <> List.to_string(parts))
      parsed_message = "#{packet_length}{#{timestamp}·#{name}·#{tag}·#{parsed_parts}}"
    else
      packet_length = byte_size("#{timestamp}" <> name <> tag <> message)
      parsed_message = "#{packet_length}{#{timestamp}·#{name}·#{tag}·#{String.strip(message)}}"
    end

    pid = Process.whereis(String.to_atom("events_" <> target.id))

    if pid do
      case target.protocol do
        :tcp -> write_to_tcp(target, parsed_message)
        :udp -> write_to_udp(target, parsed_message)
        :web -> write_to_web(target, parsed_message)
      end
    end
  end

  def write_to_tcp(target, message) do
    target.port |> Socket.Stream.send! message
  end

  def write_to_udp(target, message) do
    target.port |> Socket.Datagram.send! message, {target.ip, String.to_integer(target.id)}
  end

  def write_to_web(target, message) do
    target.port |> Socket.Web.send!({:text, message})
  end
end
