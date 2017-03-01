open Core_kernel.Std
open Abbrevs

let main =
  if Array.length Sys.argv = 1 then
    (
     Test.test (); F.print_flush ();
    )
  else
    match Sys.argv.(1) with
    | _ -> failwith "Not supported yet"
