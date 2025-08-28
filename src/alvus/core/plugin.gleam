import alvus/core/app_spec.{type AppSpec}
import gleam/dict
import gleam/dynamic.{type Dynamic}
import gleam/dynamic/decode
import gleam/list
import gleam/option.{type Option}
import gleam/result
import gleam/string
import simplifile

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

pub fn write_codegen_files(
  app_spec: AppSpec,
  files: List(GeneratedFile),
) -> Result(Nil, String) {
  simplifile.delete(app_spec.codegen_root_path)
  simplifile.create_directory(app_spec.codegen_root_path)

  files
  |> list.each(fn(file) {
    // first create the parent dirs up until the file to be created;
    let path_parts = string.split(file.path, "/")
    let path_without_filename =
      list.take(path_parts, list.length(path_parts) - 1)
      |> string.join("/")

    let dir_creation_result = case path_without_filename |> string.is_empty() {
      True -> Ok(Nil)
      False ->
        simplifile.create_directory_all(
          app_spec.codegen_root_path
          |> string.append("/")
          |> string.append(path_without_filename),
        )
    }

    case dir_creation_result {
      Ok(_) -> {
        case
          simplifile.write(
            to: app_spec.codegen_root_path
              |> string.append("/")
              |> string.append(file.path),
            contents: file.content,
          )
        {
          Ok(_) -> Nil
          Error(err) -> {
            echo err
            Nil
          }
        }
      }
      Error(err) -> {
        echo err
        Nil
      }
    }
  })
  Ok(Nil)
}
