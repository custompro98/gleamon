import database/pokedex
import gleam/http
import gleam/http/request.{type Request}
import gleam/int
import gleam/list
import gleam/result
import gleam/string_tree
import lustre/attribute
import lustre/element
import lustre/element/html.{
  body, h1, head, html, table, tbody, td, text, th, thead, title, tr, a
}
import wisp.{type Response}
import wisp/internal

pub fn handler(req: Request(internal.Connection)) -> Response {
  case req.method {
    http.Get -> get(req)
    _ -> wisp.method_not_allowed(allowed: [http.Get])
  }
}

fn get(req: Request(internal.Connection)) -> Response {
  let pokemon =
    wisp.get_query(req)
    |> list.key_find("q")
    |> result.unwrap(or: "")
    |> pokedex.search(10)

  wisp.ok()
  |> wisp.html_body(page(pokemon))
}

fn page(pokemon: List(pokedex.Pokemon)) -> string_tree.StringTree {
  html([], [
    head([], [title([], "Pokemon")]),
    body([], [
      h1([], [text("Pokemon")]),
      table([], [
        thead([], [
          tr([], [
            th([], [text("Name")]),
            th([], [text("Type 1")]),
            th([], [text("Type 2")]),
          ]),
        ]),
        tbody(
          [],
          pokemon
            |> list.map(fn(poke) {
              tr([], [
                td([], [
                  a([attribute.href("/pokemon/" <> int.to_string(poke.id))], [
                    text(poke.name),
                  ]),
                ]),
                td([], [text(list.first(poke.types) |> result.unwrap(or: ""))]),
                td([], case list.length(poke.types) {
                  2 -> [text(list.last(poke.types) |> result.unwrap(or: ""))]
                  _ -> []
                }),
              ])
            }),
        ),
      ]),
    ]),
  ])
  |> element.to_document_string
  |> string_tree.from_string
}
