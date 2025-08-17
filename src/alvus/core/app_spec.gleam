import gleam/dict.{type Dict}
import gleam/dynamic.{type Dynamic}

pub type AppSpec {
  AppSpec(plugin_storage: dict.Dict(String, Dynamic), codegen_root_path: String)
}
