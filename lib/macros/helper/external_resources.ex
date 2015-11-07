defmodule Moongate.Macros.ExternalResources do
  defmacro __before_compile__(_env) do
    if Mix.env() == :test do
      world = "test"
    else
      world = Application.get_env(:moongate, :world) || "default"
    end
    {:ok, modules} = File.ls("priv/worlds/#{world}/modules")

    Enum.map(modules, fn(resource) ->
      quote do
        @external_resource "priv/worlds/#{unquote(world)}/modules/#{unquote(resource)}"
      end
    end)

    if File.dir?("priv/worlds/#{world}/modules/scopes/") do
      {:ok, scopes} = File.ls("priv/worlds/#{world}/modules/scopes/")
      Enum.map(scopes, fn(resource) ->
        quote do
          @external_resource "priv/worlds/#{unquote(world)}/modules/scopes/#{unquote(resource)}"
        end
      end)
    end

    quote do
      def world_name do
        unquote(world)
      end
    end
  end

  defmacro __using__(_) do
    quote do
      @before_compile Moongate.Macros.ExternalResources
    end
  end
end
