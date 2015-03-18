defmodule FleetApi.Error do
  @moduledoc """
  Defines a `FleetApi.Error` struct, representing erros that may be returned
  when making Fleet API calls.

  The following fields are public:

  * `code`    - The HTTP status code of the response.
  * `message` - A human-readable error message explaining the failure.
  """
  @type t :: %__MODULE__{}
  defstruct code: nil, message: nil

  @spec from_map(%{String.t => any}) :: FleetApi.Error.t
  def from_map(error_map) do
    %__MODULE__{
      code: error_map["error"]["code"],
      message: error_map["error"]["message"]
    }
  end
end