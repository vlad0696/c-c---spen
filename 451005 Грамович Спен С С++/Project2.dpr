program Project2;

uses
  Vcl.Forms,
  Unit3 in 'Unit3.pas' {Form3},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Light');
  Application.CreateForm(TForm3, Form3);
  Application.Run;
end.
