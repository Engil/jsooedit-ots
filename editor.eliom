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

let main_service =
  Eliom_service.App.service ~path:[] ~get_params:Eliom_parameter.unit ()

let () =
  Editor_app.register
    ~service:main_service
    (fun () () ->
      Lwt.return
        (Eliom_tools.F.html
           ~title:"editor"
           ~css:[["css";"editor.css"]]
           Html5.F.(body [
             div ~a:[a_class ["coll"]]
             [
               div ~a:[a_id "content"][]
             ]
          ])))
