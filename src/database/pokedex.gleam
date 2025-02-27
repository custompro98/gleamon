import gleam/dict
import gleam/dynamic/decode
import gleam/json
import gleam/list
import gleam/option
import gleam/string
import simplifile

pub type Pokemon {
  Pokemon(
    id: Int,
    name: String,
    species: String,
    description: String,
    types: List(String),
  )
}

pub fn search(query: String, limit: Int) -> List(Pokemon) {
  load()
  |> list.filter(fn(pokemon) {
    string.starts_with(pokemon.name |> string.lowercase, query)
  })
  |> list.take(limit)
}

pub fn get(query: Int) -> option.Option(Pokemon) {
  load()
  |> list.filter(fn(pokemon) { pokemon.id == query })
  |> list.first
  |> option.from_result
}

fn load() -> List(Pokemon) {
  let assert Ok(file) = simplifile.read("./pokedex.json")
  let assert Ok(pokemon) = decode(file)

  pokemon
}

fn decode(str: String) -> Result(List(Pokemon), json.DecodeError) {
  let pokemon_decoder = {
    // Core information
    use id <- decode.field("id", decode.int)
    use names <- decode.field("name", decode.dict(decode.string, decode.string))
    use species <- decode.field("species", decode.string)
    use description <- decode.field("description", decode.string)
    use types <- decode.field("type", decode.list(decode.string))

    let assert Ok(name) = dict.get(names, "english")

    decode.success(Pokemon(id, name, species, description, types))
  }

  json.parse(from: str, using: decode.list(pokemon_decoder))
}
