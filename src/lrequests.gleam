import gleam/json
import gleam/list as l
import gleam/dynamic.{field, list, string}
import gleam/io
import gleam/hackney
import gleam/http.{Get}
import gleam/http/request

pub type Data {
  Data(data: List(Asset))
}

// Data(data: Asset)

pub type Asset {
  Asset(id: String)
}

pub fn main() {
  // Prepare a HTTP request record
  let request =
    request.new()
    |> request.set_method(Get)
    |> request.set_host("api.coincap.io/v2/assets")
  // |> request.set_host("api.coincap.io/v2/assets/bitcoin")

  let assert Ok(res) = hackney.send(request)

  let assert Ok(result) = cat_from_json(res.body)

  result.data
  |> l.each(print_asset_id)
}

fn print_asset_id(asset: Asset) {
  io.println(asset.id)
}

pub fn cat_from_json(json_string: String) -> Result(Data, json.DecodeError) {
  let data_decoder =
    dynamic.decode1(
      Data,
      field("data", of: list(dynamic.decode1(Asset, field("id", of: string)))),
    )

  // field("data", of: dynamic.decode1(Asset, field("id", of: string))),
  json.decode(from: json_string, using: data_decoder)
}
