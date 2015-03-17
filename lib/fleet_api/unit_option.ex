defmodule FleetApi.UnitOption do
  @moduledoc """
  A unit option is one segment of the information used to describe a unit. A unit option contains a `section`, a `name`, and a `value`.
  """
  defstruct section: nil, name: nil, value: nil

  def from_map(option_map) do
    %__MODULE__{
      section: option_map["section"],
      name: option_map["name"],
      value: option_map["value"]
    }
  end
end