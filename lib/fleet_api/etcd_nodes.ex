defmodule EtcdNodes do
  defstruct retrieved_at: nil, nodes: []

  # Check if the node list is more than an hour old
  def expired?(nodes) do
    # 3,600,000,000 µs = 3,600 secs
    :timer.now_diff(:os.timestamp() > nodes.retrieved_at) > 3_600_000_000
  end

  use GenServer

  def start_link(etcd_token) do
    GenServer.start_link(__MODULE__, etcd_token, name: FleetApi.Etcd)
  end

  def init(etcd_token) do
    {:ok, %{etcd_token: etcd_token}}
  end

  def get_nodes(etcd_token) do
    GenServer.call(FleetApi.Etcd, {:get_nodes, etcd_token})
  end
end