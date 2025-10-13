defmodule Taiko.Pipeline do
  @moduledoc """
  Helpers and macros for executing a simplified task pipeline:

  1. Functions being executed must return {:ok, _} or {:error, exit_code, reason}
  2. As long as {:ok, _} is being returned, the next task will be executed
  3. Otherwise, exit code and error gets logged.

  This is very similar to using the with() special form, but I was unable to use
  macros to generate code that uses with().

  This is constructed in a way that pipelines can execute nested pipelines
  """

  @doc """
  Builds a pipeline by wrapping everything in the list in a function
  """
  defmacro build_pipeline(tasks) do
    tasks
    |> Enum.map(fn (x) ->
         quote do: fn() -> unquote(x) end
    end)
  end

  @doc """
  Executes a list of functions. If the function matches {:ok, _} then continue to
  the next task. If it returns anything else, abort, log, and return the error

  Ignores nil. This lets us add conditionals pipeline stages without having to
  compact it.
  """
  def exec_pipeline([]), do: {:ok, :_}
  def exec_pipeline([nil | rest]), do: exec_pipeline(rest)
  def exec_pipeline([nested | rest]) when is_list(nested) do
    exec_pipeline(nested)
    exec_pipeline(rest)
  end
  def exec_pipeline([task_f | rest]) when is_function(task_f) do
    case task_f.() do
      {:ok, _} ->
        # Tail recursion
        exec_pipeline(rest)
      err ->
        LolOperator.Shellout.log_shell_error(err)
        err
    end
  end

  def handle_pipeline_results(results) when is_list(results) do
    results
    |> Enum.filter(
    fn {:ok, _} -> false
       _err -> true
    end)
    |> case do
      [] -> {:ok, results}
      err -> {:error, err}
    end
  end
end

