defmodule FleetApi.Unit do
  @moduledoc """
  A unit describes a running service in a fleet cluster.
  """
  alias FleetApi.UnitOption
  
  defstruct name: nil, options: [], desiredState: nil, currentState: nil, machineID: nil

  def from_map(unit_map) do
    %__MODULE__{
      name: unit_map["name"],
      options: unit_map["options"] |> Enum.map(&UnitOption.from_map/1),
      desiredState: unit_map["desiredState"],
      currentState: unit_map["currentState"],
      machineID: unit_map["machineID"]
    }
  end
end