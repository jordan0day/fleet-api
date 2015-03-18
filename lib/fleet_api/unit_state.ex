defmodule FleetApi.UnitState do
  @moduledoc """
  Defines a `FleetApi.UnitState` struct, representing the current state of a particular unit.

  The following fields are public:

  * `name`               - unique identifier of entity.
  * `hash`               - SHA1 hash of underlying unit file.
  * `machineID`          - ID of machine from which this state originated.
  * `systemdLoadState`   - load state as reported by systemd.
  * `systemdActiveState` - active state as reported by systemd.
  * `systemdSubState`    - sub state as reported by systemd.
  A unit state represents the current state of a given unit.
  """
  @type t :: %__MODULE__{}

  defstruct name: nil, hash: nil, machineID: nil, systemdLoadState: nil, systemdActiveState: nil, systemdSubState: nil

  @spec from_map(%{String.t => any}) :: FleetApi.UnitState.t
  def from_map(state_map) do
    %__MODULE__{
      name: state_map["name"],
      hash: state_map["hash"],
      machineID: state_map["machineID"],
      systemdLoadState: state_map["systemdLoadState"],
      systemdActiveState: state_map["systemdActiveState"],
      systemdSubState: state_map["systemdSubState"]
    }

  end
end