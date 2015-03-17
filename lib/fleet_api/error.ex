defmodule Error do
  @moduledoc """
  Wraps error messages received from the Fleet API.
  """
  defstruct code: nil, message: nil

  def from_map(error_map) do
    %Error{
      code: error_map["code"],
      message: error_map["message"]
    }
  end
end