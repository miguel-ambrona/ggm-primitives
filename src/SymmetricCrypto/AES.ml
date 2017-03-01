open Core_kernel.Std

let read_output c_in =
  let rec go output =
    try go (output ^ (input_line c_in) ^ "\n") with
      | End_of_file -> output
  in
  go ""

let encrypt ~key ~in_file ~out_file =
  let command =
    match out_file with
    | None     -> Format.sprintf "openssl enc -aes-256-cbc -base64 -in %s -K %s -iv 0" in_file key
    | Some out -> Format.sprintf "openssl enc -aes-256-cbc -base64 -in %s -K %s -iv 0 -out %s" in_file key out
  in
  let (c_in, _c_out) = Unix.open_process command in
  let res = read_output c_in in
  Format.printf "%s" res;
  ()

let decrypt ~key ~in_file ~out_file =
  let command =
    match out_file with
    | None     -> Format.sprintf "openssl enc -aes-256-cbc -d -base64 -in %s -K %s -iv 0" in_file key
    | Some out -> Format.sprintf "openssl enc -aes-256-cbc -d -base64 -in %s -K %s -iv 0 -out %s" in_file key out
  in
  let (c_in, _c_out) = Unix.open_process command in
  let res = read_output c_in in
  Format.printf "%s" res;
  ()
