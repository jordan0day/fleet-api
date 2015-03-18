defmodule FleetApi.Machine do
  @moduledoc """
  Defines a `FleetApi.Machine` struct, representing a host in the Fleet
  cluster. It uses the host's [machine-id](http://www.freedesktop.org/software/systemd/man/machine-id.html)
  as a unique identifier.

  The following fields are public:

  * `id`        - unique identifier of Machine entity.
  * `primaryIP` - IP address that should be used to communicate with this host.
  * `metadata`  - dictionary of key-value data published by the machine.
  """
  @type t :: %__MODULE__{}
  defstruct id: nil, primaryIP: nil, metadata: nil

  @spec from_map(%{String.t => any}) :: FleetApi.Machine.t
  def from_map(machine_map) do
    %__MODULE__{
      id: machine_map["id"],
      primaryIP: machine_map["primaryIP"],
      metadata: machine_map["metadata"]
    }
  end
end