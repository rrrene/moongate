defmodule Moongate.UDPSocket do
  defstruct port: nil
end

defmodule Moongate.Sockets.UDP.Socket do
  use Moongate.Macros.Packets
  use Moongate.Macros.Translator

  def start_link(port) do
    link(%Moongate.UDPSocket{port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Listening on port #{state.port} (UDP)...", :green)
    {:ok, server} = Socket.UDP.open(state.port)
    server |> udp_listen
    {:noreply, server}
  end

  def handler({packet, {ip, port}}, server) do
    incoming = packet_to_list(packet)

    unless pid_for_name(:events, "#{port}") do
      spawn_new(:events, "#{port}")
    end

    if hd(incoming) != :invalid_message do
      tell_async(:events, "#{port}", {:event, tl(incoming), hd(incoming), {server, :udp, ip}})
    end

    server |> udp_listen
  end

  def udp_listen(server) do
    server |> Socket.Datagram.recv! |> handler(server)
  end
end