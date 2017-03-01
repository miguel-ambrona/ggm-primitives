open Core_kernel.Std

let sha256 (seed : string) =
  let command = Format.sprintf "echo %s | openssl sha256" in
  let (c_in, _c_out) = Unix.open_process (command seed) in
  let output = input_line c_in in
  let hash = List.hd_exn (List.rev (String.split ~on:'=' output)) |> String.strip in
  hash
