defmodule FleetApi.Direct do
  @moduledoc """
  Accesses the Fleet API via a directly-identified node URL.  
  """
  use FleetApi
  use GenServer

  ## GenServer initialization

  def start_link(node_url) do
    GenServer.start_link(__MODULE__, node_url)
  end

  def init(node_url) do
    {:ok, node_url}
  end 

  @doc """
  Callback implementation of FleetApi.get_node_url/0
  """
  @spec get_node_url(pid) :: String.t
  def get_node_url(pid) do
    GenServer.call(pid, :get_node_url)
  end

  def handle_call(:get_node_url, _from, node_url) do
    {:reply, node_url, node_url}
  end
end
