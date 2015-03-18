defmodule FleetApi.UnitOption do
  @moduledoc """
  Defines a `FleetApi.UnitOption` struct, representing one segment of the information used to describe a unit.

  The following fields are public:

  * `name`    - name of option (e.g. "BindsTo", "After", "ExecStart").
  * `section` - name of section that contains the option (e.g. "Unit", "Service", "Socket").
  * `value`   - value of option (e.g. "/usr/bin/docker run busybox /bin/sleep 1000").
  """
  @type t :: %__MODULE__{}

  defstruct section: nil, name: nil, value: nil

  @spec from_map(%{String.t => any}) :: FleetApi.UnitOption.t
  def from_map(option_map) do
    %__MODULE__{
      section: option_map["section"],
      name: option_map["name"],
      value: option_map["value"]
    }
  end
end