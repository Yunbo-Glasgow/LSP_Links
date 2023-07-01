open Unix

let client () =
  let client_socket = socket PF_INET SOCK_STREAM 0 in
  let server_addr = ADDR_INET (inet_addr_loopback, 8080) in
  connect client_socket server_addr;
  let out_chan = out_channel_of_descr client_socket in
  let in_chan = in_channel_of_descr client_socket in
  try
    while true do
      print_string "Enter message to send to server (or type 'exit' to quit): ";
      let message = read_line () in
      if message = "exit" then
        raise End_of_file
      else (
        output_string out_chan (message ^ "\n");
        flush out_chan;
      )
    done
  with End_of_file ->
    close_in in_chan;
    close_out out_chan;
    close client_socket;
    print_endline "Disconnected from server."

let () =
  client ()
