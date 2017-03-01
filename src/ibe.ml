(* Main function of the tool *)

open Core_kernel.Std
open Abbrevs
open Printf
open MakeAlgebra
open IBE

let split_string_on_word string word =
  let n = String.length word in
  let rec aux k =
    if (k+n >= String.length string) then string, ""
    else if (String.sub string ~pos:k ~len:n) = word then
      (String.sub string ~pos:0 ~len:k),
      (String.sub string ~pos:(k+n) ~len:((String.length string)-(k+n)) )
    else aux (k+1)
  in
  aux 0

let input_file filename =
  let in_channel = open_in filename in
  let rec go lines =
    try
      let l = input_line in_channel in
      go (l :: lines)
    with
      End_of_file -> lines
  in
  let lines = go [] in
  let _ = close_in_noerr in_channel in
  String.concat ~sep:"\n" (L.rev lines)

let search_argument a =
  let rec aux i =
    if Sys.argv.(i) = a then Sys.argv.(i+1)
    else aux (i+1)
  in
  try aux 1 with
  | _ -> raise Not_found

let main =

  let man = F.sprintf "usage: %s\n" Sys.argv.(0) in
  if Array.length Sys.argv = 1 then
    output_string stderr man
  else
    let module IBE = PetitIBE (MyBilinearGroup) in
    match Sys.argv.(1) with
    | "setup" ->
       let mpk_file = try search_argument "-mpk" with | Not_found -> failwith "missing argument -mpk" in
       let msk_file = try search_argument "-msk" with | Not_found -> failwith "missing argument -msk" in

       let mpk, msk = IBE.setup () in

       let out_mpk_file = open_out mpk_file in
       fprintf out_mpk_file "%s" (IBE.string_of_mpk mpk);
       let _ = close_out_noerr out_mpk_file in
       
       let out_msk_file = open_out msk_file in
       fprintf out_msk_file "%s" (IBE.string_of_msk msk);
       let _ = close_out_noerr out_msk_file in
       ()
         
    | "keygen" ->
       let mpk_file = try search_argument "-mpk" with | Not_found -> failwith "missing argument -mpk" in
       let msk_file = try search_argument "-msk" with | Not_found -> failwith "missing argument -msk" in
       let out_file = try Some (search_argument "-out") with | Not_found -> None in
       
       let mpk = input_file mpk_file |> IBE.mpk_of_string in
       let msk = input_file msk_file |> IBE.msk_of_string in
       
       let id = (try search_argument "-id" with | Not_found -> failwith "missing argument -id") |> IBE.id_of_string in

       let sk = IBE.keygen mpk msk id in
       let sk_str = IBE.string_of_sk sk in

       begin match out_file with
       | None -> Format.printf "%s\n" sk_str
       | Some file ->
          let out = open_out file in
          fprintf out "%s\n" sk_str;
          let _ = close_out_noerr out in
          ()
       end

    | "encrypt" ->
       let mpk_file = try search_argument "-mpk" with | Not_found -> failwith "missing argument -mpk" in
       let msg_file = try search_argument "-msg" with | Not_found -> failwith "missing argument -msg" in
       let out_file = try Some (search_argument "-out") with | Not_found -> None in

       let mpk = input_file mpk_file |> IBE.mpk_of_string in
       let id = (try search_argument "-id" with | Not_found -> failwith "missing argument -id") |> IBE.id_of_string in
       
       let gt_msg = IBE.rand_msg () in
       let ct = IBE.enc mpk id gt_msg in
       let ct_str = IBE.string_of_ct ct in

       let password = SHA.sha256 (IBE.string_of_msg gt_msg) in
       F.printf "%s" password;
       AES.encrypt ~key:password ~in_file:msg_file ~out_file;
       
       begin match out_file with
       | None -> ()
       | Some file ->
          let ciphertext_str = (Format.sprintf "%s\\n" ct_str) in
          let command = Format.sprintf "printf '%s' >> %s" ciphertext_str file in
          let _ = Unix.open_process command in
          ()
       end

    | "decrypt" ->
       let mpk_file = try search_argument "-mpk" with | Not_found -> failwith "missing argument -mpk" in
       let sk_file  = try search_argument "-sk" with | Not_found -> failwith "missing argument -sk" in
       let ct_file  = try search_argument "-ct" with | Not_found -> failwith "missing argument -ct" in
       let out_file = try Some (search_argument "-out") with | Not_found -> None in

       let aes_ct, ibe_ct = split_string_on_word (input_file ct_file) "\n" in

       let mpk = input_file mpk_file |> IBE.mpk_of_string in
       let sk  = input_file sk_file  |> IBE.sk_of_string in
       let ct  = IBE.ct_of_string ibe_ct in
       
       let command = Format.sprintf "printf '%s' > %s" aes_ct "/tmp/aux.txt" in
       let _ = Unix.open_process command in

       let gt_msg = IBE.dec mpk sk ct in
       let password = SHA.sha256 (IBE.string_of_msg gt_msg) in
       F.printf "%s" password;
       AES.decrypt ~key:password ~in_file:"/tmp/aux.txt" ~out_file
                   
    | _ -> output_string stderr man
