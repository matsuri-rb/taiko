defmodule Taiko.Operator do
  @moduledoc """
  Defines the operator.

  The operator resource defines custom resources, watch queries and their
  controllers and serves as the entry point to the watching and handling
  processes.
  """

  use Bonny.Operator, default_watch_namespace: "default"

  step(Bonny.Pluggable.Logger, level: :info)
  step(:delegate_to_controller)
  step(Bonny.Pluggable.ApplyStatus)
  step(Bonny.Pluggable.ApplyDescendants)

  @impl Bonny.Operator
  def controllers(watching_namespace, _opts) do
    [
      %{
        query:
          K8s.Client.watch("taiko.matusri-rb.io/v1alpha1", "TaikoApplication",
            namespace: watching_namespace
          ),
        controller: Taiko.Controller.TaikoApplicationController
      }
    ]
  end

  @impl Bonny.Operator
  def crds() do
    [
      %Bonny.API.CRD{
        names: %{
          kind: "TaikoApplication",
          plural: "taikoapplications",
          shortNames: [],
          singular: "taikoapplication"
        },
        group: "taiko.matusri-rb.io",
        versions: [Taiko.API.V1Alpha1.TaikoApplication],
        scope: :Namespaced
      }
    ]
  end
end
