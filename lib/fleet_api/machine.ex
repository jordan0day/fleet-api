defmodule FleetApi.Machine do
  @moduledoc """
  A machine represents a fleet cluster node.
  """
  defstruct id: nil, primaryIP: nil, metadata: nil

  def from_map(machine_map) do
    %__MODULE__{
      id: machine_map["id"],
      primaryIP: machine_map["primaryIP"],
      metadata: machine_map["metadata"]
    }
  end
end