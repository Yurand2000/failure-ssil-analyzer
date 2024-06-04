open In_channel
open Lisproject.Parserlexer
open Lisproject.Prelude.Analysis.Parser

(* Command Line Arguments *)
let usage_message = "Usage: " ^ Sys.argv.(0) ^ " [-v|--verbose] <input file> [-o <output file>]"

let verbose = ref false
let input_file = ref ""
let output_file = ref ""

let anon_fun filename =
  input_file := filename

let speclist = [
  ("-v", Arg.Set verbose, "Verbose - Print processing status to stdout");
  ("--verbose", Arg.Set verbose, "");
  ("-o", Arg.Set_string output_file, "Set output file")
]

(* Utility Functions *)
let if_verbose fn = if !verbose then fn
let fail message = prerr_string message; exit(1)

let parse_input source =
  let handle_error source lexeme_pos msg =
    let lines = String.split_on_char '\n' source in
    let line = List.nth lines (lexeme_pos.Location.line - 1) in
    let prefix = String.make (lexeme_pos.Location.start_column - 1) ' ' in
    let middle =
      String.make
        (lexeme_pos.Location.end_column - lexeme_pos.Location.start_column + 1)
        '^'
    in
    Printf.sprintf "Error: Syntax error at line %d - column (start, end): (%d,%d).\n%s\n%s%s\n*** %s\n\n"
      lexeme_pos.Location.line lexeme_pos.Location.start_column lexeme_pos.Location.end_column line prefix middle msg
  in

  let lexbuf = Lexing.from_string ~with_positions:true source in
  try
    lexbuf
    |> Parsing.parse Lexer.lex
    |> fun ast -> match Either.find_left ast with
      | Some command -> command
      | None -> fail ""
  with Lexer.Lexing_error (pos, msg) | Parsing.Syntax_error (pos, msg) ->
    fail (handle_error source pos msg)

(* Main Function *)
let () =
  Arg.parse speclist anon_fun usage_message;
  if String.equal !input_file "" then (
    print_endline usage_message;
    exit(0)
  );

  if String.equal !output_file "" then (
    output_file := !input_file ^ ".out"
  );

  if_verbose (print_endline ("[0] Reading input file: " ^ !input_file));
  let input = input_all (open_gen [Open_rdonly] 0 !input_file) in
  if String.equal input "" then
    fail ("Error: empty input file\n" ^ usage_message);
  
  if_verbose (print_endline ("[1] Parsing input..."));
  let _ast = parse_input input in
  
  if_verbose (print_endline ("[2] Constructing Control Flow Graph..."));
  if_verbose (print_endline ("[3] Analysis..."));
  if_verbose (print_endline ("[4] Writing output to file: " ^ !output_file));
  ()
