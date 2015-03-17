defmodule FleetApi.UnitState do
  @moduledoc """
  A unit state represents the current state of a given unit.
  """
  defstruct name: nil, hash: nil, machineID: nil, systemdLoadState: nil, systemdActiveState: nil, systemdSubState: nil

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