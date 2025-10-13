defmodule Taiko.Shellout do
  require Logger

  import Taiko.Helpers

  def kubectl(cmd), do: kubectl(cmd, context: nil)
  def kubectl_query!(cmd), do: kubectl_query!(cmd, context: nil)

  def kubectl(cmd, opts) do
    cmd
    |> kubectl_cmd(context: opts[:context])
    |> shell(opts)
  end

  @doc """
  Wrapper that will parse the output of a kubectl cmd and return it
  Will not send the output to stdout
  """
  def kubectl_query!(cmd, opts) do
    # Force json output
    opts = accepted_args_for_query(opts)

    results =
      cmd
      |> kubectl_cmd(opts)
      |> shell(opts)

    case results do
      {:ok, %Porcelain.Result{out: out}} ->
        case Jason.decode(out) do
          {:ok, json} ->
            json
          {:error, err} ->
            Logger.error("Unable to decode results: #{:erlang.iolist_to_binary(cmd)} #{inspect(err)}")
            raise err
        end
      {:error, exit_code, _} ->
        Logger.error("Unable to execute: #{:erlang.iolist_to_binary(cmd)} (exit: #{exit_code})")
        raise {:kubectl_error, exit_code}
    end
  end

  def kubectl_cmd(cmd), do: kubectl_cmd(cmd, context: nil)
  def kubectl_cmd(cmd, args),
    do: ["kubectl ", kubectl_args(args), " ", cmd]

  def kubectl_args(opts) when is_list(opts), do: transform_args(opts, &kubectl_args/1)
  def kubectl_args({:context, context}) when is_binary(context), do: ["--context=", context, " "]
  def kubectl_args({:format, format}) when is_binary(format), do: ["-o ", format, " "]
  def kubectl_args(_), do: nil

  def shell(cmd), do: shell(cmd, [])
  def shell(cmd, opts) when is_list(cmd), do: shell(:erlang.iolist_to_binary(cmd), opts)
  def shell(cmd, opts) when is_binary(cmd) do
    verbose = present_or_default(opts[:verbose], true)
    async = present_or_default(opts[:async], false)
    livestream = present_or_default(opts[:livestream], true)

    if verbose, do: Logger.info("$ #{cmd}")

    stdout = IO.binstream(:stdio, :line)
    stderr = IO.binstream(:stderr, :line)
    proc_opts = if livestream do
                  [out: stdout, err: stderr]
                else
                  [err: stderr]
                end

    if async do
      Porcelain.spawn_shell(cmd, proc_opts)
    else
      case Porcelain.shell(cmd, proc_opts) do
        %Porcelain.Result{status: 0} = res ->
          {:ok, res}
        %Porcelain.Result{status: exit_code} = res ->
          {:error, exit_code, res}
      end
    end
  end

  def log_shell_error({:error, exit_code, _}),
    do: Logger.error("Unable to execute. Exit code: #{exit_code}")

  def log_shell_error(err),
    do: Logger.error("Unhandled error: #{inspect(err)}")


  def transform_args(args, f) when is_list(args) do
    args
    |> Enum.map(f)
    |> Enum.reject(&is_nil/1)
  end

  def accepted_args_for_query(args) do
    [{:format, "json"} | [{:livestream, false} | args]]
    |> dedup_keywords()
  end

end
