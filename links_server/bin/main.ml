open Unix

let server () =
  let server_socket = socket PF_INET SOCK_STREAM 0 in
  let server_addr = ADDR_INET (inet_addr_loopback, 8080) in
  bind server_socket server_addr;
  listen server_socket 5;
  print_endline "Server started, waiting for connections...";
  while true do
    let client_socket, _ = accept server_socket in
    let in_chan = in_channel_of_descr client_socket in
    try
      while true do
        let line = input_line in_chan in
        print_endline ("Received from client: " ^ line);
      done
    with End_of_file ->
      close_in in_chan;
      close client_socket;
      print_endline "Client disconnected."
  done

let () =
  server ()
