defmodule Taiko.Helpers do
  @doc """
  Useful helper functions
  """

  def maybe(true, f) when is_function(f), do: f.()
  def maybe(true, v), do: v
  def maybe(false, _), do: nil
  def maybe(nil, _), do: nil

  def blank?(nil), do: true
  def blank?(""), do: true
  def blank?([]), do: true
  def blank?(%{}), do: true
  def blank?(_), do: false

  def present_or_default(nil, default), do: default
  def present_or_default(value, _), do: value

  def number_or_zero(nil), do: 0
  def number_or_zero(x) when is_number(x), do: x
  def number_or_zero(_), do: 0

  def dedup_keywords(list) when is_list(list) do
    list
    |> Enum.reverse
    |> Enum.into(%{})
    |> Enum.into([])
  end

  @doc """
  Modified from https://stackoverflow.com/a/61559842

  Safe version, will only atomize to an existing key
  """
  def atomize_keys(map) when is_map(map), do: Map.new(map, &atomize_keys/1)
  def atomize_keys(list) when is_list(list), do: Enum.map(list, &atomize_keys/1)
  def atomize_keys({key, val}) when is_binary(key),
    do: atomize_keys({String.to_existing_atom(key), val})
  def atomize_keys({key, val}), do: {key, atomize_keys(val)}
  def atomize_keys(term), do: term

  @doc """
  Modified from https://stackoverflow.com/a/61559842

  Unsafe version, will atomize all string keys
  """
  def unsafe_atomize_keys(map) when is_map(map), do: Map.new(map, &unsafe_atomize_keys/1)
  def unsafe_atomize_keys(list) when is_list(list), do: Enum.map(list, &unsafe_atomize_keys/1)
  def unsafe_atomize_keys({key, val}) when is_binary(key),
    do: unsafe_atomize_keys({String.to_atom(key), val})
  def unsafe_atomize_keys({key, val}), do: {key, unsafe_atomize_keys(val)}
  def unsafe_atomize_keys(term), do: term
end
