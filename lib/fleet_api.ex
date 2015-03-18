defmodule FleetApi do
  @moduledoc """
  This module contains callback declarations for interacting with a Fleet API endpoint.
  """
  use Behaviour

  @doc """
  Retrieve the list of units that the Fleet cluster currently knows about.
  """
  defcallback list_units(pid) :: {:ok, [FleetApi.Unit.t]}

  @doc """
  Retrieve the details for a specific unit in the Fleet cluster.
  """
  defcallback get_unit(pid, unit_name :: String.t) :: {:ok, FleetApi.Unit.t}

  @doc """
  Remove a unit from the Fleet cluster.
  """
  defcallback delete_unit(pid, unit_name :: String.t) :: :ok

  @doc """
  Adds or updates a unit in the Fleet cluster. If the cluster doesn't contain a
  unit with the given name, then a new unit is added to it. If a unit with the
  given name exists, it is updated with the new unit definition.
  """
  defcallback set_unit(pid, unit_name :: String.t, FleetApi.Unit.t) :: :ok

  @doc """
  Get the detailed state information for all the units in the Fleet cluster.

  You may optionally provide options `machineID` and/or `unitName` to filter
  the response to a particular host or unit.
  """
  defcallback list_unit_states(pid, opts :: [{atom, String.t}]) :: {:ok, [FleetApi.UnitState.t]}

  @doc """
  Retrieve the list of nodes currently in the Fleet cluster.
  """
  defcallback list_machines(pid) :: {:ok, [FleetApi.Machine.t]}

  defmacro __using__(_) do
    quote do
      use FleetApi.Api
      @behaviour FleetApi

      @doc """
      
      """
      def list_units(pid) do
        pid
        |> get_node_url
        |> api_list_units
      end

      def get_unit(pid, unit_name) do
        pid
        |> get_node_url
        |> api_get_unit(unit_name)
      end

      def delete_unit(pid, unit_name) do
        pid
        |> get_node_url
        |> api_delete_unit(unit_name)
      end

      def set_unit(pid, unit_name, unit) do
        pid
        |> get_node_url
        |> api_set_unit(unit_name, unit)
      end

      def list_unit_states(pid, opts \\ []) do
        pid
        |> get_node_url
        |> api_list_unit_states(opts)
      end

      def list_machines(pid) do
        pid
        |> get_node_url
        |> api_list_machines
      end

      @doc """
      Retrieves the Fleet API node URL, based on either etcd discovery or direct setting of the node url.
      """
      defcallback get_node_url(pid) :: String.t
    end
  end
end
