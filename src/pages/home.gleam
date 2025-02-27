import gleam/http
import gleam/http/request.{type Request}
import gleam/string_tree
import lustre/element
import lustre/element/html.{html, head, body, title, h1, text}
import wisp.{type Response}
import wisp/internal

pub fn handler(req: Request(internal.Connection)) -> Response {
  case req.method {
    http.Get -> get(req)
    _ -> wisp.method_not_allowed(allowed: [http.Get])
  }
}

fn get(_req: Request(internal.Connection)) -> Response {
  wisp.ok()
  |> wisp.html_body(page())
}

fn page() -> string_tree.StringTree {
  html([], [
    head([], [title([], "Home")]),
    body([], [h1([], [text("Home")])]),
  ])
  |> element.to_document_string
  |> string_tree.from_string
}
