# FleetApi

An elixir wrapper for the [Fleet API](https://github.com/coreos/fleet/blob/master/Documentation/api-v1.md). Connect to the API running on one of your fleet cluster nodes using either a direct node URL or an [etcd](https://etcd.io) etcd token.

[![Build Status](https://semaphoreci.com/api/v1/projects/d90076a2-33bc-458a-88e1-1a36cf82040a/375538/badge.png)](https://semaphoreci.com/jordanday/fleet-api) [![Hex pm](http://img.shields.io/hexpm/v/fleet_api.svg?style=flat)](https://hex.pm/packages/fleet_api)

## Usage
### etcd token

*Note that this is a config value you can set to override the port used to connect to the Fleet REST API when using an etcd token.*
In your app's config, you can set

```elixir
config :fleet_api, :etcd
  fix_port_number: true,
  api_port: 4001
```
To get the api to use the correct port, regardless of what might be stored in etcd.

```elixir
{:ok, pid} = FleetApi.Etcd.start_link("your etcd token")
{:ok, units} = FleetApi.Etcd.list_units(pid)

[%FleetApi.Unit{currentState: "launched", desiredState: "launched",
  machineID: "820c30c0867844129d63f4409871ba39", name: "subgun-http.service",
  options: [%FleetApi.UnitOption{name: "Description", section: "Unit",
    value: "subgun"},
   %FleetApi.UnitOption{name: "ExecStartPre", section: "Service",
    value: "-/usr/bin/docker kill subgun-%i"},
   %FleetApi.UnitOption{name: "ExecStartPre", section: "Service",
    value: "-/usr/bin/docker rm subgun-%i"}...]
```

### Direct node URL

```elixir
{:ok, pid} = FleetApi.Direct.start_link("http://your-node-host-or-ip:7002")
{:ok, units} = FleetApi.Direct.list_units(pid)

[%FleetApi.Unit{currentState: "launched", desiredState: "launched",
  machineID: "820c30c0867844129d63f4409871ba39", name: "subgun-http.service",
  options: [%FleetApi.UnitOption{name: "Description", section: "Unit",
    value: "subgun"},
   %FleetApi.UnitOption{name: "ExecStartPre", section: "Service",
    value: "-/usr/bin/docker kill subgun-%i"},
   %FleetApi.UnitOption{name: "ExecStartPre", section: "Service",
    value: "-/usr/bin/docker rm subgun-%i"}...]
```
