defmodule FleetApi do
  defmodule UnitOption do
    defstruct section: nil, name: nil, value: nil

    def from_map(option_map) do
      %UnitOption{
        section: option_map["section"],
        name: option_map["name"],
        value: option_map["value"]
      }
    end
  end

  defmodule Unit do
    defstruct name: nil, options: [], desiredState: nil, currentState: nil, machineID: nil

    def from_map(unit_map) do
      %Unit{
        name: unit_map["name"],
        options: unit_map["options"] |> Enum.map(&UnitOption.from_map/1),
        desiredState: unit_map["desiredState"],
        currentState: unit_map["currentState"],
        machineID: unit_map["machineID"]
      }
    end
  end

  defmodule UnitState do
    defstruct name: nil, hash: nil, machineID: nil, systemdLoadState: nil, systemdActiveState: nil, systemdSubState: nil

    def from_map(state_map) do
      %UnitState{
        name: state_map["name"],
        hash: state_map["hash"],
        machineID: state_map["machineID"],
        systemdLoadState: state_map["systemdLoadState"],
        systemdActiveState: state_map["systemdActiveState"],
        systemdSubState: state_map["systemdSubState"]
      }

    end
  end

  defmodule Machine do
    defstruct id: nil, primaryIP: nil, metadata: nil

    def from_map(machine_map) do
      %Machine{
        id: machine_map["id"],
        primaryIP: machine_map["primaryIP"],
        metadata: machine_map["metadata"]
      }
    end
  end

  defmodule Error do
    defstruct code: nil, message: nil

    def from_map(error_map) do
      %Error{
        code: error_map["code"],
        message: error_map["message"]
      }
    end
  end

  defp add_query_param(url, name, value) do
    separator = if String.contains?(url, "?"), do: "&", else: "?"

    url <> separator <> name <> "=" <> value
  end

  defp paginated_request(method, url, headers, body, expected_status \\ 200, resp_bodies \\ [], next_page_token \\ "") do
    request_url = if next_page_token == "" do
      url
    else
      add_query_param(url, "nextPageToken", next_page_token)
    end

    case request(method, request_url, headers, body, expected_status) do
      {:ok, %{"nextPageToken" => token} = resp_body} ->
        paginated_request(method, url, headers, body, expected_status, [resp_body] ++ resp_bodies, token)
      {:ok, resp_body} ->
        {:ok, [resp_body] ++ resp_bodies}
      error -> error
    end
  end

  defp request(method, url, headers, body, expected_status \\ 200) do
    case HTTPoison.request(method, url, body, headers) do
      {:ok, %HTTPoison.Response{status_code: expected_status} = response} ->
        {:ok, Poison.decode!(response.body)}
      {:ok, response} ->
        {:error, "Expected response status #{expected_status} but got #{response.status_code}"}
      error -> error
    end
  end

  def list_units(node_url) do
    case paginated_request(:get, node_url <> "/fleet/v1/units", [], "") do
      {:ok, resp_bodies} ->
        units = resp_bodies
                |> Enum.flat_map(fn resp -> resp["units"] end)
                |> Enum.map(&Unit.from_map/1)

        {:ok, units}
    end
  end

  def get_unit(node_url, unit_name) do
    case HTTPoison.get(node_url <> "/fleet/v1/units/" <> unit_name) do
      {:ok, %{status_code: 200, body: body}} ->
        unit = body
               |> Poison.decode!
               |> Unit.from_map

        {:ok, unit}
    end
  end

  def list_unit_states(node_url, opts \\ []) do
    url = node_url <> "/fleet/v1/state"
    machine_id = Keyword.get(opts, :machine_id)
    unit_name = Keyword.get(opts, :unit_name)

    url = cond do
      machine_id && unit_name -> url <> "?machineID=" <> machine_id <> "&unitName=" <> unit_name
      machine_id -> url <> "?machineID=" <> machine_id
      unit_name -> url <> "?unitName=" <> unit_name
      true -> url
    end

    case paginated_request(:get, url, [], "") do
      {:ok, resp_bodies} ->
        states = resp_bodies
                 |> Enum.flat_map(fn resp -> resp["states"] end)
                 |> Enum.map(&UnitState.from_map/1)
        {:ok, states}
    end
  end

  def list_machines(node_url) do
    case paginated_request(:get, node_url <> "/fleet/v1/machines", [], "") do
      {:ok, resp_bodies} ->
        machines = resp_bodies
                   |> Enum.flat_map(fn resp -> resp["machines"] end)
                   |> Enum.map(&Machine.from_map/1)

        {:ok, machines}
    end
  end
end
