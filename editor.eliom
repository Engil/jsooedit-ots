{shared{
  open Eliom_lib
  open Eliom_content
  open Html5.D
}}
module Editor_app =
  Eliom_registration.App (
    struct
      let application_name = "editor"
    end)

      let send_patch =
  Eliom_service.Ocaml.post_coservice'
    ~rt:(Eliom_service.rt :
           [`Applied of int * string | `Refused of int * string]
             Eliom_service.rt)
    ~post_params: (Eliom_parameter.ocaml "lol" Json.t<string>)
    ()

let get_document_service =
  Eliom_service.Ocaml.coservice'
    ~rt:(Eliom_service.rt : [`Result of (string * int) | `NotConnected] Eliom_service.rt)
    ~get_params: (Eliom_parameter.unit)
    ()

let main_service =
  Eliom_service.App.service ~path:[] ~get_params:Eliom_parameter.unit ()

let () =
  let eref = Eliom_reference.eref ~scope:Eliom_common.site_scope
      "document" in


  let append_shadowcopy, get_shadowcopy =
    ((fun elm -> Eliom_reference.set eref elm),
     (fun () -> Eliom_reference.get eref)) in

  Eliom_registration.Ocaml.register
    ~service:send_patch
    (fun () patch ->
       Lwt.return @@ `Applied (0, ""));

  let get_document name = get_shadowcopy ()
    >>= fun s ->
    Lwt.return (`Result (s, 0)) in

  Eliom_registration.Ocaml.register
    ~service:get_document_service
    (fun () () -> get_document ());

  let elt = Eliom_content.Html5.D.raw_textarea ~a:[] ~name:"editor" () in
  Editor_app.register
    ~service:main_service
    (fun () () ->
       ignore {unit Lwt.t{
           Lwt.return (Client.onload %Client.bus %elt ())
         }};
       Lwt.return @@
         (Eliom_tools.F.html
            ~title:"editor"
            ~css:[["css";"editor.css"]]
            Html5.F.(body [
                div ~a:[a_class ["coll"]]
                  [
                    div
                      ~a:[a_id
                            "content"][]
                  ]
              ])))
