defmodule FleetApi do
  defmacro __using__(_) do
    quote do
      use Behaviour
      use FleetApi.Api
      @moduledoc """
      This module contains functions for interacting with a Fleet API endpoint.
      """

      @doc """
      Retrieve the list of units that the Fleet cluster currently knows about.
      """
      @spec list_units(pid) :: {:ok, [FleetApi.Unit.t]}
      def list_units(pid) do
        pid
        |> get_node_url
        |> api_list_units
      end      

      @doc """
      Retrieve the details for a specific unit in the Fleet cluster.
      """
      @spec get_unit(pid, unit_name :: String.t) :: {:ok, FLeetApi.Unit.t}
      def get_unit(pid, unit_name) do
        pid
        |> get_node_url
        |> api_get_unit(unit_name)
      end

      @doc """
      Remove a unit from the Fleet cluster.
      """
      @spec delete_unit(pid, unit_name :: String.t) :: :ok
      def delete_unit(pid, unit_name) do
        pid
        |> get_node_url
        |> api_delete_unit(unit_name)
      end

      @doc """
      Adds or updates a unit in the Fleet cluster. If the cluster doesn't contain a
      unit with the given name, then a new unit is added to it. If a unit with the
      given name exists, it is updated with the new unit definition.
      """
      @spec set_unit(pid, unit_name :: String.t, FleetApi.Unit) :: :ok
      def set_unit(pid, unit_name, unit) do
        pid
        |> get_node_url
        |> api_set_unit(unit_name, unit)
      end

      @doc """
      Get the detailed state information for all the units in the Fleet cluster.
      """
      @spec list_unit_states(pid, opts :: [{atom, String.t}]) :: {:ok, [FleetApi.UnitState.t]}
      def list_unit_states(pid, opts \\ []) do
        pid
        |> get_node_url
        |> api_list_unit_states(opts)
      end

      @doc """
      Retrieve the list of nodes currently in the Fleet cluster.
      """
      @spec list_machines(pid) :: {:ok, [FleetApi.Machine.t]}
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
