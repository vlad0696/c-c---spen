unit Unit3;

interface

uses
   Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
   System.Classes, Vcl.Graphics,
   Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Grids, Vcl.StdCtrls;

type
   tarr_symbols = array of ansichar;
   twords = array of string;

   tID = record
      id: string;
      amount: integer;
   end;

   tIDs = array of tID;

   TForm3 = class(TForm)
      OpenDialog1: TOpenDialog;
      all_text_memo: TMemo;
      result_table: TStringGrid;
      Open_button: TButton;
      Result_button: TButton;
      procedure FormCreate(Sender: TObject);
      procedure Open_buttonClick(Sender: TObject);
      procedure main;
      procedure Result_buttonClick(Sender: TObject);
      function input_text: tarr_symbols;
      function delete_comments(all_text: tarr_symbols): tarr_symbols;
      function input_main_words: twords;
      function found_id(all_text: tarr_symbols; main_words: twords): tIDs;
      function spen_id(all_text: tarr_symbols; ids: tIDs): tIDs;
      function delete_space(ids: tIDs): tIDs;
      function delete_unnecessary_ids(ids: tIDs): tIDs;
      function delete_repeating_ids(ids: tIDs): tIDs;
      procedure output(ids: tIDs);
   private
      { Private declarations }
   public
      { Public declarations }
   end;

var
   Form3: TForm3;

implementation

{$R *.dfm}

function TForm3.delete_comments(all_text: tarr_symbols): tarr_symbols;
var
   i, j: integer;
   text_without_comments: tarr_symbols;
begin
   i := 1;
   j := 1;
   while i <> length(all_text) do
   begin
      if (all_text[i - 1] = '/') and (all_text[i] = '*') then
         while (all_text[i - 1] <> '*') or (all_text[i] <> '/') do
            inc(i);

      if all_text[i - 1] = '"' then
      begin
         while (all_text[i - 1] <> '"') do
         begin
            inc(i);
            if (all_text[i - 1] = '\') and (all_text[i] = '"') then
               inc(i);
         end;
      end;
      setlength(text_without_comments, j);
      text_without_comments[j - 1] := all_text[i - 1];
      inc(i);
      inc(j);
   end;
   result := text_without_comments;
end;

function TForm3.delete_repeating_ids(ids: tIDs): tIDs;
var
   i, j: integer;
begin
   for i := 0 to length(ids) - 2 do
      for j := i + 1 to length(ids) - 1 do
         if ids[i].id = ids[j].id then
            ids[j].id := 'null';
   result := ids;
end;

function TForm3.delete_space(ids: tIDs): tIDs;
var
   i, j: integer;
   string_withot_spaces: string;
begin
   for i := 0 to length(ids) - 1 do
   begin
      string_withot_spaces := '';
      for j := 1 to length(ids[i].id) do
         if ids[i].id[j] <> ' ' then
            string_withot_spaces := string_withot_spaces + ids[i].id[j];
      ids[i].id := string_withot_spaces;
   end;
   result := ids;
end;

function TForm3.delete_unnecessary_ids(ids: tIDs): tIDs;
const
   symbols: set of char = ['a' .. 'z', 'A' .. 'Z', '_', '0' .. '9'];
var
   i, j, count,numeber_of_elements: integer;
   ids_without_useless: tIDs;
begin
   numeber_of_elements := 0;
   for i := 0 to length(ids) - 1 do
   begin
      inc(numeber_of_elements);
      setlength(ids_without_useless,numeber_of_elements);
      for j := 0 to length(ids[i].id) do
         if ids[i].id[j] in symbols then
            ids_without_useless[numeber_of_elements - 1].id := ids_without_useless[numeber_of_elements - 1].id +
              ids[i].id[j];
   end;
   result := ids_without_useless;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
   all_text_memo.Clear;
   result_table.Cells[0, 0] := 'Идентефикатор:';
   result_table.Cells[1, 0] := 'Спен:';
end;

function TForm3.found_id(all_text: tarr_symbols; main_words: twords): tIDs;
const
   letters: set of ansichar = ['A' .. 'Z', 'a' .. 'z', '_'];
var
   i, j, k: integer;
   id_count: integer;
   ids: tIDs;
   temporarery_word, found_word: ansistring;
begin
   id_count := 1;
   for i := 0 to length(main_words) - 1 do
   begin
      j := 0;
      while j <> length(all_text) - length(main_words[i]) - 1 do
      begin
         found_word := '';
         temporarery_word := main_words[i];
         for k := 1 to length(temporarery_word) do
         begin
            if (all_text[j + k - 1] = temporarery_word[k]) then
               found_word := found_word + all_text[j + k - 1]
            else
               found_word := '';
         end;
         if found_word = temporarery_word then
         begin
            if (not(all_text[j - 1] in letters)) or
              (not(all_text[j + k - 1] in letters)) then
            begin
               inc(j, k - 1);
               setlength(ids, id_count);
               while (all_text[j] <> ';') and (all_text[j] <> '{') do
               begin
                  if all_text[j] = ',' then
                  begin
                     inc(id_count);
                     setlength(ids, id_count);
                  end
                  else if (all_text[j] <> ' ') or (all_text[j] <> '*') then
                     ids[id_count - 1].id := ids[id_count - 1].id + all_text[j];
                  inc(j);
               end;
               inc(id_count);
            end;
         end;
         inc(j);
      end;
   end;
   result := ids;
end;

function TForm3.input_main_words: twords;
var
   words_file: textfile;
   i: integer;
   key_words: twords;
begin
   assignfile(words_file, 'input.txt');
   reset(words_file);
   i := 1;
   while not eof(words_file) do
   begin
      setlength(key_words, i);
      readln(words_file, key_words[i - 1]);
      inc(i);
   end;
   result := key_words;
end;

function TForm3.input_text: tarr_symbols;
var
   file_name: textfile;
   i: integer;
   all_text: tarr_symbols;
   temp_symbol, temp: ansichar;
begin
   setlength(all_text, 0);
   assignfile(file_name, OpenDialog1.FileName);
   reset(file_name);
   i := 1;
   while not(eof(file_name)) do
   begin
      setlength(all_text, i);
      read(file_name, temp_symbol);
      if temp_symbol = '/' then
      begin
         read(file_name, temp);
         if temp = '/' then
            readln(file_name)
         else
         begin
            all_text[i - 1] := temp_symbol;
            inc(i);
            setlength(all_text, i);
            all_text[i - 1] := temp;
            inc(i)
         end;
      end
      else
      begin
         all_text[i - 1] := temp_symbol;
         inc(i);
      end;
   end;
   closefile(file_name);
   result := all_text;
end;

procedure TForm3.main;
var
   all_text: tarr_symbols;
   main_words: twords;
   ids: tIDs;
begin
   all_text := input_text;
   all_text := delete_comments(all_text);
   main_words := input_main_words;
   ids := found_id(all_text, main_words);
   ids := delete_space(ids);
   ids := delete_unnecessary_ids(ids);
   ids := delete_repeating_ids(ids);
   ids := spen_id(all_text, ids);
   output(ids);
end;

procedure TForm3.Open_buttonClick(Sender: TObject);
begin
   if OpenDialog1.Execute then
      all_text_memo.lines.LoadFromFile(OpenDialog1.FileName);
end;

procedure TForm3.output(ids: tIDs);
var
   i, j, all_spen: integer;
begin
   result_table.RowCount := length(ids) + 1;
   all_spen := 0;
   j:=0;
   for i := 0 to length(ids) - 1 do
   begin
      if (ids[i].id <> 'null') and (ids[i].amount<>0) then
      begin
         result_table.RowCount := i + 1-j;
         result_table.Cells[0, i + 1-j] := ids[i].id;
         result_table.Cells[1, i + 1-j] := inttostr(ids[i].amount-1);
         inc(all_spen, ids[i].amount-1);
      end
      else
      begin
         inc(j);
      end;
   end;
   inc(i);
   result_table.RowCount := i + 1-j;
   result_table.Cells[0, i - j] := 'Общий спен =';
   result_table.Cells[1, i - j] := inttostr(all_spen);
end;

procedure TForm3.Result_buttonClick(Sender: TObject);
begin
   main;
end;

function TForm3.spen_id(all_text: tarr_symbols; ids: tIDs): tIDs;
const
   symbols: set of char = ['a' .. 'z', 'A' .. 'Z', '_', '1' .. '9'];
var
   i, j, k, count_id: integer;
   string_id: ansistring;
begin
   for i := 0 to length(ids) - 1 do
   begin
      j := 0;
      string_id := ids[i].id;
      while (j <> length(all_text) - length(string_id) - 1) do
      begin
         count_id := 0;
         for k := 1 to length(string_id) do
            if all_text[j + k - 1] = string_id[k] then
               inc(count_id)
            else
               count_id := 0;
         if count_id = length(string_id) then
            if (not(all_text[j - 1] in symbols)) and
              (not(all_text[j + k - 1] in symbols)) then
               inc(ids[i].amount);
         inc(j)
      end;
   end;
   result := ids;
end;

end.
