open Lwt.Infix
open Lwt_unix

let handle_connection fd =
  let ic = Lwt_io.of_fd Lwt_io.Input fd in
  let oc = Lwt_io.of_fd Lwt_io.Output fd in
  let rec echo_loop () =
    Lwt_io.read_line ic >>= fun input ->
    Lwt_io.write_line oc input >>= fun () ->
    echo_loop ()
  in
  Lwt.finalize
    echo_loop
    (fun () ->
      Lwt_io.close ic >>= fun () ->
      Lwt_io.close oc
    )

let main port =
  let sockaddr = Unix.ADDR_INET (Unix.inet_addr_any, port) in
  let server_sock = Lwt_unix.socket Unix.PF_INET Unix.SOCK_STREAM 0 in
  Lwt_unix.setsockopt server_sock Unix.SO_REUSEADDR true;
  Lwt_unix.bind server_sock sockaddr;
  Lwt_unix.listen server_sock 5;
  let rec accept_loop () =
    Lwt_unix.accept server_sock >>= fun (client_sock, _) ->
    Lwt.async (fun () -> handle_connection client_sock);
    accept_loop ()
  in
  Lwt_main.run (accept_loop ())

let () =
  let port = 12345 in
  main port
