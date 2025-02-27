import database/pokedex
import gleam/http
import gleam/http/request.{type Request}
import gleam/int
import gleam/option.{None, Some}
import gleam/string
import gleam/string_tree
import lustre/element
import lustre/element/html.{
  body, h1, head, html, table, tbody, td, th, title, tr, text
}
import wisp.{type Response}
import wisp/internal

pub fn handler(req: Request(internal.Connection), id: String) -> Response {
  case req.method {
    http.Get -> get(req, id)
    _ -> wisp.method_not_allowed(allowed: [http.Get])
  }
}

fn get(_req: Request(internal.Connection), id: String) -> Response {
  let id = int.parse(id)
  case id {
    Error(_) -> wisp.bad_request()
    Ok(id) -> {
      case pokedex.get(id) {
        None -> wisp.not_found()
        Some(pokemon) -> {
          wisp.ok()
          |> wisp.html_body(page(pokemon))
        }
      }
    }
  }
}

fn page(pokemon: pokedex.Pokemon) -> string_tree.StringTree {
  html([], [
    head([], [title([], "Pokemon")]),
    body([], [
      h1([], [text(pokemon.name)]),
      table([], [
        tbody([], [
          tr([], [
            th([], [text("Species")]),
            td([], [text(pokemon.species)]),
          ]),
          tr([], [
            th([], [text("Description")]),
            td([], [text(pokemon.description)]),
          ]),
          tr([], [
            th([], [text("Type(s)")]),
            td([], [text(string.join(pokemon.types, ", "))]),
          ]),
        ]),
      ]),
    ]),
  ])
  |> element.to_document_string
  |> string_tree.from_string
}
