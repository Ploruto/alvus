import alvus/core/app_spec.{type AppSpec}
import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/option.{type Option}
import gleam/result

pub type GeneratedFile {
  GeneratedFile(path: String, description: String, content: String)
}

pub type CodegenPlugin(plugin_data, decode_error) {
  CodegenPlugin(
    plugin_pipeline: fn(AppSpec) -> #(AppSpec, List(GeneratedFile)),
    encoder: fn(plugin_data) -> Dynamic,
    decoder: fn(Dynamic) -> Result(plugin_data, decode_error),
    get_plugin_data: fn(AppSpec) -> Option(plugin_data),
  )
}

pub fn insert_plugin_data(
  spec: AppSpec,
  plugin_data_key: String,
  plugin_data_value: Dynamic,
) -> AppSpec {
  app_spec.AppSpec(
    spec.plugin_storage
      |> dict.insert(plugin_data_key, plugin_data_value),
    spec.codegen_root_path,
    logs: spec.logs,
  )
}
