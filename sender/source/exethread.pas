
unit exethread;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Process, BaseUnix, Unix, LazUTF8, FileUtil,
  DateUtils, StdCtrls, Forms, Dialogs, ExtCtrls, ComCtrls;

type
  TPrexeThreaded = class(TThread)
  private
    FCmd: AnsiString;
    FParams: array of string;
    FListBox: TListBox;
    FProgressBar: TProgressBar;
    FResult: AnsiString;
    FTempString: AnsiString;
    FProgressMode: Integer;
    FFinished: Boolean;
    FProcess: TProcess;
    procedure UpdateListBox;
    procedure AddListBoxLine;
  protected
    procedure Execute; override;
  public
    constructor Create(const Cmd: AnsiString; Params: array of string;
      ListBox: TListBox; ProgressBar: TProgressBar = nil;
      ProgressMode: Integer = 0);
    destructor Destroy; override;
    procedure Stop;
    property ResultText: AnsiString read FResult;
    property Finished: Boolean read FFinished;
  end;

procedure ListboxAddScroll(ListBox: TListBox; Item: string);
function PrexeThreadedBash(command: AnsiString; box: TListBox;
  progressbar: TProgressBar = nil; progressmode: Integer = 0): TPrexeThreaded;

var
  terminate_all: Boolean;
   th: TPrexeThreaded;

implementation

procedure ListboxAddScroll(ListBox: TListBox; Item: string);
var
  TopIndex: Integer;
  Visible, ih, Count: Integer;
begin
  Count := ListBox.Items.Add(Item);

  ih := ListBox.ItemHeight;
  if ih < 4 then
    ih := ListBox.Canvas.TextHeight('Wy') + 4;

  Visible := ListBox.ClientHeight div ih;
  TopIndex := Count - Visible + 2;

  if TopIndex < 0 then
    TopIndex := 0;

  ListBox.TopIndex := TopIndex;
  ListBox.Repaint;
end;

constructor TPrexeThreaded.Create(const Cmd: AnsiString;
  Params: array of string; ListBox: TListBox;
  ProgressBar: TProgressBar; ProgressMode: Integer);
begin
  inherited Create(True);

  FCmd := Cmd;
  FParams := Copy(Params);
  FListBox := ListBox;
  FProgressBar := ProgressBar;
  FProgressMode := ProgressMode;
  FResult := '';
  FFinished := False;
  FProcess := nil;

  FreeOnTerminate := True;

  if Assigned(FProgressBar) then
    FProgressBar.Max := 1000;

  Start;
end;

destructor TPrexeThreaded.Destroy;
begin
  if Assigned(FProcess) then
    FreeAndNil(FProcess);

  inherited Destroy;
end;

procedure TPrexeThreaded.Stop;
begin
  Terminate;

  if Assigned(FProcess) then
  begin
    try
      if FProcess.Running then
      begin
        fpKill(FProcess.ProcessID, SIGTERM);
        Sleep(200);

        if FProcess.Running then
          fpKill(FProcess.ProcessID, SIGKILL);
      end;
    except
    end;
  end;
end;

procedure TPrexeThreaded.UpdateListBox;
const
  pass2step = 4;
  pass3step = 2;
  pass4step = 1;

  basestart3 = pass2step * 40;
  basestart4 = basestart3 + pass3step * 40;

  p_sum = basestart4 + pass4step * 40;
var
  x, Count: Integer;
  s: string;
  pass: Integer;
begin
  if Assigned(FListBox) and (FListBox.Items.Count > 0) then
    FListBox.Items[FListBox.Items.Count - 1] := FTempString;

  if (FProgressMode = 1) and Assigned(FProgressBar) and
     (FListBox.Items.Count >= 2) then
  begin
    s := FListBox.Items[FListBox.Items.Count - 2];

    Count := 0;
    pass := 0;

    if Pos('pass 2', s) > 0 then pass := 2;
    if Pos('pass 3', s) > 0 then pass := 3;
    if Pos('pass 4', s) > 0 then pass := 4;

    if pass = 2 then
    begin
      s := FTempString;
      for x := 1 to Length(s) do
        if s[x] = 'X' then
          Inc(Count, pass2step);

      FProgressBar.Position := FProgressBar.Max * Count div p_sum;
    end;

    if pass = 3 then
    begin
      s := FTempString;
      for x := 1 to Length(s) do
        if s[x] = 'X' then
          Inc(Count, pass3step);

      FProgressBar.Position :=
        FProgressBar.Max * (Count + basestart3) div p_sum;
    end;

    if pass = 4 then
    begin
      s := FTempString;
      for x := 1 to Length(s) do
        if s[x] = 'X' then
          Inc(Count, pass4step);

      FProgressBar.Position :=
        FProgressBar.Max * (Count + basestart4) div p_sum;
    end;
  end;
end;

procedure TPrexeThreaded.AddListBoxLine;
begin
  if Assigned(FListBox) then
    ListboxAddScroll(FListBox, '');
end;

procedure TPrexeThreaded.Execute;
const
  BufferSize = 2048;
var
  buf: array[0..BufferSize - 1] of Char;
  bytesRead, cPos, i, xpos: Integer;
  su, sm: AnsiString;
begin
  FFinished := False;
  xpos := 0;
  FResult := '';

  if Assigned(FListBox) then
    Synchronize(@AddListBoxLine);

  FProcess := TProcess.Create(nil);

  try
    FProcess.Executable := FCmd;
    FProcess.Options := [poUsePipes, poStderrToOutPut, poDefaultErrorMode];
    FProcess.PipeBufferSize := BufferSize;

    for i := 0 to High(FParams) do
      FProcess.Parameters.Add(FParams[i]);

    FProcess.Execute;

    while (FProcess.Running or (FProcess.Output.NumBytesAvailable > 0))  and not Terminated
      and not terminate_all do
    begin
      Sleep(50);

      if FProcess.Output.NumBytesAvailable <= 0 then
        Continue;

      bytesRead := FProcess.Output.Read(buf, BufferSize);
      cPos := 0;

      while cPos < bytesRead do
      begin
        su := '';

        while (cPos < bytesRead) and (buf[cPos] > #31) do
        begin
          su := su + buf[cPos];
          Inc(cPos);
        end;

        if su <> '' then
        begin
          FResult := FResult + su;

          if Assigned(FListBox) and (FListBox.Items.Count > 0) then
          begin
            sm := FListBox.Items[FListBox.Items.Count - 1];

            Insert(su, sm, xpos + 1);
            Inc(xpos, Length(su));
            Delete(sm, xpos + 1, Length(sm));

            FTempString := sm;

            if not Terminated then
              Synchronize(@UpdateListBox);
          end;
        end;

        if cPos < bytesRead then
        begin
          case buf[cPos] of
            #10:
              begin
                Inc(cPos);
                xpos := 0;

                if Assigned(FListBox) and not Terminated then
                  Synchronize(@AddListBoxLine);
              end;

            #13:
              begin
                Inc(cPos);
                xpos := 0;
              end;

            #8:
              begin
                Inc(cPos);
                Dec(xpos);
                if xpos < 0 then
                  xpos := 0;
              end;
          else
            Inc(cPos);
          end;
        end;
      end;
    end;

    if terminate_all or Terminated then
    begin
      if Assigned(FProcess) and FProcess.Running then
      begin
        fpKill(FProcess.ProcessID, SIGTERM);
        Sleep(200);

        if FProcess.Running then
          fpKill(FProcess.ProcessID, SIGKILL);
      end;
    end;

  finally
    FFinished := True;
  end;
end;

function PrexeThreadedBash(command: AnsiString; box: TListBox;
  progressbar: TProgressBar = nil; progressmode: Integer = 0): TPrexeThreaded;
begin
  terminate_all := False;
  Result := TPrexeThreaded.Create('bash', ['-c', command], box,
    progressbar, progressmode);
end;

end.


