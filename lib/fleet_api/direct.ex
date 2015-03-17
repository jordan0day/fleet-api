defmodule FleetApi.Direct do
  @moduledoc """
  Accesses the Fleet API via a directly-identified node URL.  
  """

  use FleetApi

  @doc """
  Stores the node URL to use. Keeps state using an Agent, and starts the agent
  if necessary.
  """
  @spec set_node_url(String.t) :: :ok
  def set_node_url(fleet_node_url) do
    # Check if the agent has been started yet...
    if Process.whereis(FleetApi.Direct) == nil do
      # If it hasn't been started, start it and set the node url.
      {:ok, _pid} = Agent.start(fn -> fleet_node_url end, name: FleetApi.Direct)
      :ok
    else
      # If the agent has already been started, just update it's state.
      Agent.update(FleetApi.Direct, fn _url -> fleet_node_url end)
    end
  end

  @doc """
  Retrieves the node url previously stored. If the storage agent hasn't been started yet,
  returns {:error, :node_url_not_set}.
  """
  @spec get_node_url() :: {:ok, String.t} | {:error, :node_url_not_set}
  def get_node_url do
    if Process.whereis(FleetApi.Direct) == nil do
      {:error, :node_url_not_set}
    else
      {:ok, Agent.get(FleetApi.Direct, &(&1))}
    end
  end

  @doc """
  Callback implementation of FleetApi.node_url/0
  """
  @spec node_url() :: String.t
  def node_url() do
    case get_node_url do
      {:ok, node_url} -> node_url
      {:error, :node_url_not_set} ->
        raise "Node URL not set. Ensure you call FleetApi.Direct.set_node_url/1 with the node URL to use."
    end
  end
end