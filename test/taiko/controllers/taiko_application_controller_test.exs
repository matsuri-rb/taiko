defmodule Taiko.Controller.TaikoApplicationControllerTest do
  @moduledoc false
  use ExUnit.Case, async: false
  use Bonny.Axn.Test

  alias Taiko.Controller.TaikoApplicationController

  test "add is handled and returns axn" do
    axn = axn(:add)
    result = TaikoApplicationController.call(axn, [])
    assert is_struct(result, Bonny.Axn)
  end

  test "modify is handled and returns axn" do
    axn = axn(:modify)
    result = TaikoApplicationController.call(axn, [])
    assert is_struct(result, Bonny.Axn)
  end

  test "reconcile is handled and returns axn" do
    axn = axn(:reconcile)
    result = TaikoApplicationController.call(axn, [])
    assert is_struct(result, Bonny.Axn)
  end

  test "delete is handled and returns axn" do
    axn = axn(:delete)
    result = TaikoApplicationController.call(axn, [])
    assert is_struct(result, Bonny.Axn)
  end
end
