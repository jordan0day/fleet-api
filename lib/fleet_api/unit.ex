defmodule FleetApi.Unit do
  @moduledoc """
  Defines a `FleetApi.Unit` struct, representing a service in a fleet cluster.

  The following fields are public:

  * `name`         - unique identifier of entity.
  * `options`      - list of UnitOption entities.
  * `desiredState` - state the user wishes the unit to be in ("inactive", "loaded", or "launched").
  * `currentState` - state the unit is currently in (same possible values as desiredState).
  * `machineID`    - ID of machine to which the unit is scheduled.
  """
  @type t :: %__MODULE__{}
  alias FleetApi.UnitOption
  
  defstruct name: nil, options: [], desiredState: nil, currentState: nil, machineID: nil

  @spec from_map(%{String.t => any}) :: FleetApi.Unit.t
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