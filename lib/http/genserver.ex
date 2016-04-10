defmodule Moongate.HTTP.GenServer do
  use GenServer
  use Moongate.Macros.Processes
  use Moongate.Macros.Worlds

  def start_link({port, path}) do
    link(%Moongate.HTTP.GenServer.State{path: path, port: port}, "socket", "#{port}")
  end

  def handle_cast({:init}, state) do
    Moongate.Say.pretty("Listening on port #{state.port} (HTTP)...", :green)
    listen(state)

    {:noreply, state}
  end

  defp listen(state) do
    Application.ensure_all_started(:cowboy)
    dispatch = :cowboy_router.compile([{:_, routes(state.path)}])
    {:ok, _} = :cowboy.start_http(:http, 100, [port: state.port], [
      env: [dispatch: dispatch],
      middlewares: [:cowboy_router, Moongate.HTTP.Middleware.Headers, :cowboy_handler]
    ])
  end

  defp routes(path) do
    [
      {"/", :cowboy_static, {:priv_file, :moongate, "#{world_directory}/#{path}/index.html"}},
      {"/moongate.js", :cowboy_static, {:priv_file, :moongate, "clients/js/public/app.js"}},
      {"/moongate.js.map", :cowboy_static, {:priv_file, :moongate, "clients/js/public/app.js.map"}},
      {"/[...]", :cowboy_static, {:priv_dir,  :moongate, "#{world_directory}/#{path}"}}
    ]
  end
end
