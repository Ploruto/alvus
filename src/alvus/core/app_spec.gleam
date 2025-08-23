import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}

pub type LogLevel {
  Debug
  Info
  Warning
  Err
}

pub type PluginLogs {
  PluginLogs(logs: List(#(LogLevel, String)))
}

pub type AppSpec {
  AppSpec(
    plugin_storage: dict.Dict(String, Dynamic),
    codegen_root_path: String,
    logs: dict.Dict(String, List(#(LogLevel, String))),
  )
}
