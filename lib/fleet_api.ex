defmodule FleetApi do
  @moduledoc """
  This module contains callback declarations for interacting with a Fleet API endpoint.
  """
  use Behaviour

  @doc """
  Retrieve the list of units that the Fleet cluster currently knows about.
  """
  defcallback list_units(pid) :: {:ok, [FleetApi.Unit.t]} | {:error, any}

  @doc """
  Retrieve the details for a specific unit in the Fleet cluster.
  """
  defcallback get_unit(pid, unit_name :: String.t) :: {:ok, FleetApi.Unit.t} | {:error, any}

  @doc """
  Remove a unit from the Fleet cluster.
  """
  defcallback delete_unit(pid, unit_name :: String.t) :: :ok | {:error, any}

  @doc """
  Adds or updates a unit in the Fleet cluster. If the cluster doesn't contain a
  unit with the given name, then a new unit is added to it. If a unit with the
  given name exists, it is updated with the new unit definition.
  """
  defcallback set_unit(pid, unit_name :: String.t, FleetApi.Unit.t) :: :ok | {:error, any}

  @doc """
  Get the detailed state information for all the units in the Fleet cluster.

  You may optionally provide options `machineID` and/or `unitName` to filter
  the response to a particular host or unit.
  """
  defcallback list_unit_states(pid, opts :: [{atom, String.t}]) :: {:ok, [FleetApi.UnitState.t]} | {:error, any}

  @doc """
  Retrieve the list of nodes currently in the Fleet cluster.
  """
  defcallback list_machines(pid) :: {:ok, [FleetApi.Machine.t]} | {:error, any}

  @doc """
  Retrieve the API Discovery document JSON for the Fleet API.
  """
  defcallback get_api_discovery(pid) :: {:ok, Map.t} | {:error, any}

  defmacro __using__(_) do
    quote do
      use FleetApi.Api
      @behaviour FleetApi

      # To handle errors that may occur inside get_node_url, we'll wrap any
      # calls to API functions with call_with_url, which will either return
      # with the error info, or pass the resolved URL on down to the API func.
      defp call_with_url({:error, reason}, _fn), do: {:error, reason}

      defp call_with_url(node_url, fun) do
        fun.(node_url)
      end

      def list_units(pid) do
        pid
        |> get_node_url
        |> call_with_url(&api_list_units/1)
      end

      def get_unit(pid, unit_name) do
        pid
        |> get_node_url
        |> call_with_url(&(api_get_unit(&1, unit_name)))
      end

      def delete_unit(pid, unit_name) do
        pid
        |> get_node_url
        |> call_with_url(&(api_delete_unit(&1, unit_name)))
      end

      def set_unit(pid, unit_name, unit) do
        pid
        |> get_node_url
        |> call_with_url(&(api_set_unit(&1, unit_name, unit)))
      end

      def list_unit_states(pid, opts \\ []) do
        pid
        |> get_node_url
        |> call_with_url(&(api_list_unit_states(&1, opts)))
      end

      def list_machines(pid) do
        pid
        |> get_node_url
        |> call_with_url(&api_list_machines/1)
      end

      def get_api_discovery(pid) do
        pid
        |> get_node_url
        |> call_with_url(&api_discovery/1)
      end

      @doc """
      Retrieves the Fleet API node URL, based on either etcd discovery or direct setting of the node url.
      """
      defcallback get_node_url(pid) :: String.t
    end
  end
end
