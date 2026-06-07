unit Unit2;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, process;

type

  { TForm2 }

  TForm2 = class(TForm)
    BtSaveChanges: TButton;
    Button1: TButton;
    Button2: TButton;
    ComboBox1: TComboBox;
    EdTarget: TEdit;
    EdPort: TEdit;
    EdSize: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Memo1: TMemo;
    procedure BtSaveChangesClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure update;
  private

  public

  end;

var
  Form2: TForm2;

implementation

{$R *.frm}

{ TForm2 }


uses
  unit1;

procedure TForm2.FormCreate(Sender: TObject);
begin

end;


procedure TForm2.update;
var
  p, p2, x, n: integer;
  s: string;
  SL: TStringList;
begin
  combobox1.Items.Clear;
  memo1.Lines.Clear;

  if form1.configlist.Count < 1 then
  begin
    combobox1.Text := '';
    exit;
  end;

  for x := 0 to form1.configlist.Count - 1 do
  begin
    p := pos('-i ', form1.configlist[x]) + 3;
    if p > 3 then
      p2 := pos(';', form1.configlist[x], p);
    if p2 > 0 then
      combobox1.Items.Add(copy(form1.configlist[x], p, p2 - p));

  end;
  combobox1.ItemIndex := 0;



  SL := TStringList.Create;
  try
    SL.Delimiter := ';';
    SL.StrictDelimiter := True;
    SL.DelimitedText := form1.configlist[0];
    memo1.Lines := sl;

    s := form1.configlist[0];
    p := pos('-pkt_size ', s);
    p := pos(' ', s, p);
    Delete(s, 1, p);


    p := pos(';', s);

    Delete(s, p, maxint);

    edsize.Text := trim(s);

    //   rtp://239.255.0.1:5010

    s := form1.configlist[0];
    while pos(' ', s) > 0 do Delete(s, pos(' ', s), 1);  // alle leerzeichen entfernen

    p := pos('rtp://', s);
    Delete(s, 1, p + 5);

    p := pos(':', s);

    edtarget.Text := copy(s, 1, p - 1);

    s:=  copy(s, p + 1, maxint);
    while copy(s,length(s))=';' do delete (s,length(s),1);
    edport.Text := s;


  finally
    SL.Free;
  end;
end;


procedure TForm2.FormShow(Sender: TObject);
begin
  update;
end;



procedure TForm2.ComboBox1Change(Sender: TObject);
var
  sl: TStringList;
  x: integer;
begin
  if combobox1.ItemIndex > 0 then
  begin
    sl := TStringList.Create;
    sl.Add(form1.configlist[combobox1.ItemIndex]);
    for x := 0 to combobox1.Items.Count - 1 do
      if x <> combobox1.ItemIndex then  sl.Add(form1.configlist[x]);
    sl.SaveToFile(form1.configfilename);
    form1.configlist.Text := sl.Text;
    combobox1.ItemIndex := 0;
    sl.Free;
    update;
  end;
end;



procedure TForm2.BtSaveChangesClick(Sender: TObject);
//changes immer nach index 0
var
  p, p2, x: integer;
  s: string;
begin
  // ändern von  -pkt_size 736
  for x := 0 to memo1.Lines.Count - 1 do
    if pos('-pkt_size', memo1.Lines[x]) > 0 then
    begin
      memo1.Lines[x] := '-pkt_size ' + edsize.Text;
      break;
    end;

  //    rtp://$ip:$port
  for x := 0 to memo1.Lines.Count - 1 do
    if pos('rtp://', memo1.Lines[x]) > 0 then
    begin
      memo1.Lines[x] := 'rtp://' + edtarget.Text + ':' + edport.Text;
      break;
    end;
  // configlist erstellen
  form1.configlist[0] := '';
  for x := 0 to memo1.Lines.Count - 1 do
   if memo1.lines[x] > '' then
       form1.configlist[0] := form1.configlist[0] + memo1.Lines[x] + ';';
  // speichern
  form1.configlist.SaveToFile(form1.configfilename);
  form1.restart;
end;

procedure TForm2.Button1Click(Sender: TObject);
begin
  if form1.configlist.Count > 0 then
  if MessageDlg(
       'Remove Device Settings',
       'Do you really want to remove the device from settings "' + combobox1.text + '"?',
       mtConfirmation,
       [mbYes, mbNo],
       0
     ) = mrYes then
  begin
    form1.configlist.Delete(0);
    update;
    form1.configlist.SaveToFile(form1.configfilename);
  end;
end;

procedure TForm2.Button2Click(Sender: TObject);
var
  s: string;
begin
  s := 'ffmpeg' + #10 + '-f pulse' + #10 + '-i default' + #10 +'-acodec pcm_s16le'+#10+'-ar 48000' + #10 + '-ac 2' + #10 + '-f rtp' + #10 + '-pkt_size 736' + #10 + '-fflags nobuffer' + #10 + '-flags low_delay' + #10 +
    '-max_delay 0' + #10 + '-flush_packets 1' + #10 + 'rtp://239.255.0.1:5010';

  memo1.Text := s;

end;




end.
