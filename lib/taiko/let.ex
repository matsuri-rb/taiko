defmodule Taiko.Let do
  @moduledoc """
  Lazy-evaluation, somewhat based on let() from the Ruby community. This
  is intended for complex logic or where some computations are expensive.

  This is an attempt to work with Elixir (hygenic macros, immutable data structure)

  Examples:

  ```
  let(:current_temperature), do: WeatherService.expensive_fetch_temperature()
  let(:desired_temperature), do: Agent.get_desired_temperature()

  # Computes and memoize :desired_temperature and :current_temperature before
  # computing and memoizing the results of this
  let(:temperature_delta, with: [:desired_temperature, :current_temperature]) do
    ctx[:desired_temperature] - ctx[:current_temperature]
  end
  ```

  ### Inputs

  let(:presented_temperature, with: [:current_temperature]) do
    ctx[:current_temperature]
    |> convert_temp_to_unit(ctx[:temp_unit])
  end

  def temperature_info(temp_unit) do
    %{temperature_unit: temp_unit}
    |> with_presented_temperature()
  end

  ### Aliasing

  A powerful feature of the Ruby-based let() is the use of method overriding to
  modify the logic. With an immutable data structures, what we do instead is to
  bind it into a different key:

  let(:current_temperature), do: WeatherService.expensive_fetch_temperature()
  let(:desired_temperature_from_agent), do: Agent.get_desired_temperature()
  let(:desired_temperature_from_env), do: System.get_env("DESIRED_TEMPERATURE")

  def temperature_info(:env) do
    %{}
    |> with_desired_temperature_from_env(as: :desired_temperature )
  end

  def temperature_info(:agent) do
    %{}
    |> with_desired_temperature_from_agent(as: :desired_temperature )
  end

  """

  defmacro let(name, do: block) when is_atom(name) do
    quote do
      def unquote(:"with_#{name}")(ctx),
        do: with_memoization(ctx, unquote(name), fn (var!(ctx)) -> unquote(block) end)
    end
  end

  defmacro let(name, [with: bind_with], do: block) when is_atom(name) and is_list(bind_with) do
    # Set default calling module to the caller of this macro
    bind_with = Enum.map(bind_with, &(expand_binding(&1, __CALLER__.module)))
    quote do
      def unquote(:"with_#{name}")(ctx),
        do: with_memoization(ctx, unquote(name), fn (var!(ctx)) -> unquote(block) end, [with: unquote(bind_with)])

      def unquote(:"with_#{name}")(ctx, as: key_alias),
        do: with_memoization(ctx, key_alias, fn (var!(ctx)) -> unquote(block) end, [with: unquote(bind_with)])
    end
  end

  def expand_binding({m, f}, _calling_mod) when is_atom(f), do: {m, f}
  def expand_binding(f, calling_mod) when is_atom(f), do: {calling_mod, f}

  def with_memoization(ctx, key, f, []), do: with_memoization(ctx, key, f)
  def with_memoization(ctx, key, f, [with: bind_with]) do
    bind_with
    |> Enum.reduce(ctx, fn ({m, x}, ctx) -> apply(m, :"with_#{x}", [ctx]) end)
    |> with_memoization(key, f)
  end

  def with_memoization(ctx, key, f) do
    case Map.get(ctx, key, nil) do
      nil ->
        res = case f do
                f when is_function(f, 0) ->
                  f.()
                f when is_function(f, 1) ->
                  f.(ctx)
              end
        Map.put(ctx, key, res)
      %Task{} = task ->
        # If the memoized value is a Task, await it to get the real value
        Map.put(ctx, key, Task.await(task))
      _res ->
        ctx
    end
  end
end
