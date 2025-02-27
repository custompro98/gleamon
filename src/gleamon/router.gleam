import pages/pokemon
import gleamon/web
import pages/home
import pages/pokemons
import wisp.{type Request, type Response}

/// The HTTP request handler- your application!
/// 
pub fn handle_request(req: Request) -> Response {
  // Apply the middleware stack for this request/response.
  use req <- web.middleware(req)

  case wisp.path_segments(req) {
    [] -> home.handler(req)
    ["pokemon"] -> pokemons.handler(req)
    ["pokemon", id] ->  pokemon.handler(req, id)
    _ -> wisp.not_found()
  }
}
