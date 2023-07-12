unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm1 }

  TForm1 = class(TForm)
    btnStartScan: TButton;
    btnGetFiles: TButton;
    LibraryList: TMemo;
    LibraryNotFoundList: TMemo;
    LibraryLocationList: TMemo;
    stLocation: TStaticText;
    stFound: TStaticText;
    stNotFound: TStaticText;
    procedure btnStartScanClick(Sender: TObject);
    procedure btnGetFilesClick(Sender: TObject);
  private

  public

  end;

var
  Form1: TForm1;

implementation

{$R *.lfm}

uses
  StrUtils,process,FileUtil,LazFileUtils,LookupStringList;

const
  UNIXSEARCHDIRS : array [0..6] of string = (
  '/lib',
  '/usr/lib',
  '/usr/local/lib',
  {$ifdef CPUX86}
  '/lib/i686-linux-gnu',
  '/usr/lib/i686-linux-gnu',
  '/usr/local/lib/i686-linux-gnu',
  {$endif CPUX32}
  {$ifdef CPUX86_64}
  '/lib/x86_64-linux-gnu',
  '/usr/lib/x86_64-linux-gnu',
  '/usr/local/lib/x86_64-linux-gnu',
  {$endif CPUX86_64}
  {$ifdef CPUARM}
  {$ifdef CPUARMHF}
  '/lib/arm-linux-gnueabihf',
  '/usr/lib/arm-linux-gnueabihf',
  '/usr/local/lib/arm-linux-gnueabihf',
  {$else}
  '/lib/arm-linux-gnueabi',
  '/usr/lib/arm-linux-gnueabi',
  '/usr/local/lib/arm-linux-gnueabi',
  {$endif CPUARMHF}
  {$endif CPUARM}
  {$ifdef CPUAARCH64}
  '/lib/aarch64-linux-gnu',
  '/usr/lib/aarch64-linux-gnu',
  '/usr/local/lib/aarch64-linux-gnu',
  {$endif CPUAARCH64}
  {$ifdef CPU32}
  '/lib32'
  {$endif CPU32}
  {$ifdef CPU64}
  '/lib64'
  {$endif CPU64}
  );

  {$ifdef Haiku}
  HAIKUSEARCHDIRS : array [0..3] of string = (
  '/boot/system/lib/x86',
  '/boot/system/non-packaged/lib/x86',
  '/boot/system/lib',
  '/boot/system/non-packaged/lib'
  );
  {$endif}

const FPCLIBS : array [0..42] of string = (
  'crtbegin.o',
  'crtbeginS.o',
  'crtend.o',
  'crtendS.o',
  'crt1.o',
  'crti.o',
  'crtn.o',
  'Mcrt1.o',
  'Scrt1.o',
  'grcrt1.o',
  'ld-linux.so.2',
  'ld-linux-x86-64.so.2',
  'libanl.so.1',
  'libcrypt.so.1',
  'libc.so.6',
  'libc_nonshared.a',
  'libgcc.a',
  'libdb1.so.2',
  'libdb2.so.3',
  'libdl.so.2',
  'libglib-2.0.so.0',
  'libgobject-2.0.so.0',
  'libgthread-2.0.so.0',
  'libgmodule-2.0.so.0',
  'libm.so.6',
  'libmvec_nonshared.a',
  'libmvec.so.1',
  'libnsl.so.1',
  'libnss_compat.so.2',
  'libnss_dns6.so.2',
  'libnss_dns.so.2',
  'libnss_files.so.2',
  'libnss_hesiod.so.2',
  'libnss_ldap.so.2',
  'libnss_nisplus.so.2',
  'libnss_nis.so.2',
  'libpthread.so.0',
  'libpthread_nonshared.a',
  'libresolv.so.2',
  'librt.so.1',
  'libthread_db.so.1',
  'libutil.so.1',
  'libz.so.1'
);

const FPCLINKLIBS : array [0..10] of string = (
  'ld.so',
  'libc.so',
  'libdl.so',
  'libgobject-2.0.so',
  'libglib-2.0.so',
  'libgthread-2.0.so',
  'libgmodule-2.0.so',
  'libm.so',
  'libpthread.so',
  'librt.so',
  'libz.so'
);

const LAZLIBS : array [0..19] of string = (
  'libgdk-x11-2.0.so.0',
  'libgtk-x11-2.0.so.0',
  'libX11.so.6',
  'libXtst.so.6',
  'libgdk_pixbuf-2.0.so.0',
  'libgobject-2.0.so.0',
  'libglib-2.0.so.0',
  'libgthread-2.0.so.0',
  'libgmodule-2.0.so.0',
  'libpango-1.0.so.0',
  'libcairo.so.2',
  'libatk-1.0.so.0',
  'libicui18n.so',
  'libgtk-3.so.0',
  'libsqlite3.so.0',
  'libusb-1.0.so.0',
  'libGL.so',
  'libGLU.so',
  'libEGL.so',
  'libvulkan.so.1'
);

const LAZLINKLIBS : array [0..6] of string = (
  'libgdk-x11-2.0.so',
  'libgtk-x11-2.0.so',
  'libX11.so',
  'libgdk_pixbuf-2.0.so',
  'libpango-1.0.so',
  'libcairo.so',
  'libatk-1.0.so'
);

const QTLIBS : array [0..14] of string = (
  'libQt5Pas.so.1',
  'libQt5Core.so.5',
  'libQt5GUI.so.5',
  'libQt5Network.so.5',
  'libQt5Pas.so.1',
  'libQt5PrintSupport.so.5',
  'libQt5Widgets.so.5',
  'libQt5X11Extras.so.5',
  'libQt6Pas.so.6',
  'libQt6Core.so.6',
  'libQt6DBus.so.6',
  'libQt6GUI.so.6',
  'libQt6Pas.so.6',
  'libQt6PrintSupport.so.6',
  'libQt6Widgets.so.6'
);

const QTLINKLIBS : array [0..1] of string = (
  'libQt5Pas.so',
  'libQt6Pas.so'
);

function GetSourceCPU:string;
begin
  result:=lowercase({$i %FPCTARGETCPU%});
end;

function GetSourceOS:string;
begin
  result:=lowercase({$i %FPCTARGETOS%});
end;

function GetSourceCPUOS:string;
begin
  result:=GetSourceCPU+'-'+GetSourceOS;
end;

function GetStartupObjects:string;
const
  LINKFILE='crtbegin.o';
  SEARCHDIRS : array [0..5] of string = (
    '/usr/local/lib/',
    '/usr/lib/',
    '/usr/local/lib/gcc/',
    '/usr/lib/gcc/',
    '/lib/gcc/',
    '/lib/'
    );

var
  LinkFiles     : TStringList;
  Output,s1,s2  : string;
  i,j           : integer;
  FoundLinkFile : boolean;
  OutputLines   : TStringList;
begin
  FoundLinkFile:=false;
  result:='';

  for i:=Low(SEARCHDIRS) to High(SEARCHDIRS) do
  begin
    s1:=SEARCHDIRS[i];
    if FileExists(s1+LINKFILE) then FoundLinkFile:=true;
    if FoundLinkFile then
    begin
      result:=s1;
      break;
    end;
  end;

  {$ifdef Haiku}
  if (NOT FoundLinkFile) then
  begin
    s1:='/boot/system/develop/tools/x86/lib';
    if NOT DirectoryExists(s1) then s1:='/boot/system/develop/tools/lib';
    if DirectoryExists(s1) then
    begin
      LinkFiles := TStringList.Create;
      try
        FindAllFiles(LinkFiles, s1, '*.o', true);
        if (LinkFiles.Count>0) then
        begin
          for i:=0 to (LinkFiles.Count-1) do
          begin
            if Pos(DirectorySeparator+LINKFILE,LinkFiles[i])>0 then
            begin
              result:=ExtractFileDir(LinkFiles[i]);
              FoundLinkFile:=true;
              break;
            end;
          end;
        end;
      finally
        LinkFiles.Free;
      end;
    end;
    if (NOT FoundLinkFile) then
    begin
      s1:='/boot/system/develop/lib/x86/';
      if NOT DirectoryExists(s1) then s1:='/boot/system/develop/lib/';
      if FileExists(s1+'crti.o') then FoundLinkFile:=true;
      if FoundLinkFile then result:=s1;
    end;
  end;
  {$endif}

  if FoundLinkFile then exit;

  try
    Output:='';
    if RunCommand('gcc',['-print-prog-name=cc1'], Output,[poUsePipes, poStderrToOutPut]{$IF DEFINED(FPC_FULLVERSION) AND (FPC_FULLVERSION >= 30200)},swoHide{$ENDIF}) then
    begin
      s1:=Trim(Output);
      if FileExists(s1) then
      begin
        s2:=ExtractFileDir(s1);
        if FileExists(s2+DirectorySeparator+LINKFILE) then
        begin
          result:=s2;
          FoundLinkFile:=true;
        end;
      end;
    end;

    if (NOT FoundLinkFile) then
    begin
      Output:='';
      if RunCommand('gcc',['-print-search-dirs'], Output,[poUsePipes, poStderrToOutPut]{$IF DEFINED(FPC_FULLVERSION) AND (FPC_FULLVERSION >= 30200)},swoHide{$ENDIF}) then
      begin
        Output:=TrimRight(Output);
        if Length(Output)>0 then
        begin
          OutputLines:=TStringList.Create;
          try
            OutputLines.Text:=Output;
            if OutputLines.Count>0 then
            begin
              for i:=0 to (OutputLines.Count-1) do
              begin
                s1:=OutputLines.Strings[i];
                j:=Pos('libraries:',s1);
                if j=1 then
                begin
                  j:=Pos(DirectorySeparator,s1);
                  if j>0 then
                  begin
                    Delete(s1,1,j-1);
                    LinkFiles := TStringList.Create;
                    try
                      LinkFiles.StrictDelimiter:=true;
                      LinkFiles.Delimiter:=':';
                      LinkFiles.DelimitedText:=s1;
                      if LinkFiles.Count>0 then
                      begin
                        for j:=0 to (LinkFiles.Count-1) do
                        begin
                          s2:=ExcludeTrailingPathDelimiter(LinkFiles.Strings[j]);
                          //s2:=ExtractFileDir(LinkFiles.Strings[j]);
                          if FileExists(s2+DirectorySeparator+LINKFILE) then
                          begin
                            result:=s2;
                            FoundLinkFile:=true;
                            break;
                          end;
                        end;
                      end;
                    finally
                      LinkFiles.Free;
                    end;
                  end;
                  break;
                end;
              end;
            end;
          finally
            OutputLines.Free;
          end;
        end;
      end;
    end;

    if (NOT FoundLinkFile) then
    begin
      Output:='';
      if RunCommand('gcc',['-v'], Output,[poUsePipes, poStderrToOutPut]{$IF DEFINED(FPC_FULLVERSION) AND (FPC_FULLVERSION >= 30200)},swoHide{$ENDIF}) then
      begin

        s1:='COLLECT_LTO_WRAPPER=';
        i:=Ansipos(s1, Output);
        if (i>0) then
        begin
          s2:=RightStr(Output,Length(Output)-(i+Length(s1)-1));
          // find space as delimiter
          i:=Ansipos(' ', s2);
          // find lf as delimiter
          j:=Ansipos(#10, s2);
          if (j>0) AND (j<i) then i:=j;
          // find cr as delimiter
          j:=Ansipos(#13, s2);
          if (j>0) AND (j<i) then i:=j;
          if (i>0) then delete(s2,i,MaxInt);
          s2:=ExtractFileDir(s2);
          if FileExists(s2+DirectorySeparator+LINKFILE) then
          begin
            result:=s2;
            FoundLinkFile:=true;
          end;
        end;

        if (NOT FoundLinkFile) then
        begin
          s1:=' --libdir=';
          //s1:=' --libexecdir=';
          i:=Ansipos(s1, Output);
          if (i>0) then
          begin
            s2:=RightStr(Output,Length(Output)-(i+Length(s1)-1));
            // find space as delimiter
            i:=Ansipos(' ', s2);
            // find lf as delimiter
            j:=Ansipos(#10, s2);
            if (j>0) AND (j<i) then i:=j;
            // find cr as delimiter
            j:=Ansipos(#13, s2);
            if (j>0) AND (j<i) then i:=j;
            if (i>0) then delete(s2,i,MaxInt);
            result:=IncludeTrailingPathDelimiter(s2);
          end;

          i:=Ansipos('gcc', result);
          if i=0 then result:=result+'gcc'+DirectorySeparator;

          s1:=' --build=';
          i:=Ansipos(s1, Output);
          if i=0 then
          begin
            s1:=' --target=';
            i:=Ansipos(s1, Output);
          end;
          if (i>0) then
          begin
            s2:=RightStr(Output,Length(Output)-(i+Length(s1)-1));
            // find space as delimiter
            i:=Ansipos(' ', s2);
            // find lf as delimiter
            j:=Ansipos(#10, s2);
            if (j>0) AND (j<i) then i:=j;
            // find cr as delimiter
            j:=Ansipos(#13, s2);
            if (j>0) AND (j<i) then i:=j;
            if (i>0) then delete(s2,i,MaxInt);
            result:=result+s2+DirectorySeparator;
          end;

          s1:='gcc version ';
          i:=Ansipos(s1, Output);
          if (i>0) then
          begin
            s2:=RightStr(Output,Length(Output)-(i+Length(s1)-1));
            // find space as delimiter
            i:=Ansipos(' ', s2);
            // find lf as delimiter
            j:=Ansipos(#10, s2);
            if (j>0) AND (j<i) then i:=j;
            // find cr as delimiter
            j:=Ansipos(#13, s2);
            if (j>0) AND (j<i) then i:=j;
            if (i>0) then delete(s2,i,MaxInt);
            result:=result+s2;
            if FileExists(result+DirectorySeparator+LINKFILE) then
            begin
              FoundLinkFile:=true;
            end;
          end;
        end;
      end;
    end;

  except
    // ignore errors
  end;

  //In case of errors or failures, do a brute force search of gcc link file
  if (NOT FoundLinkFile) then
  begin
    {$IF (defined(BSD)) and (not defined(Darwin))}
    result:='/usr/local/lib/gcc';
    {$else}
    result:='/usr/lib/gcc';
    {$endif}

    if DirectoryExists(result) then
    begin
      LinkFiles := TStringList.Create;
      try
        FindAllFiles(LinkFiles, result, '*.o', true);
        if (LinkFiles.Count>0) then
        begin
          for i:=0 to (LinkFiles.Count-1) do
          begin
            if Pos(DirectorySeparator+LINKFILE,LinkFiles[i])>0 then
            begin
              result:=ExtractFileDir(LinkFiles[i]);
              FoundLinkFile:=true;
              break;
            end;
          end;
        end;
      finally
        LinkFiles.Free;
      end;
    end;
  end;
end;

function GetDistro(const aID:string=''):string;
var
  {$if defined(Darwin) OR defined(MSWindows)}
  Major,Minor,Build,Patch: Integer;
  {$endif}
  i,j: Integer;
  AllOutput : TStringList;
  s,t:ansistring;
  success:boolean;
begin
  t:='unknown';
  success:=false;
  {$ifdef Unix}
    {$ifndef Darwin}
      s:='';
      if RunCommand('cat',['/etc/os-release'],s,[poUsePipes, poStderrToOutPut]{$IF DEFINED(FPC_FULLVERSION) AND (FPC_FULLVERSION >= 30200)},swoHide{$ENDIF}) then
      begin
        if Pos('No such file or directory',s)=0 then
        begin
          AllOutput:=TStringList.Create;
          try
            AllOutput.Text:=s;
            s:='';
            if Length(aID)>0 then
            begin
              s:=AllOutput.Values[aID];
            end
            else
            begin
              s:=AllOutput.Values['NAME'];
              if Length(s)=0 then s := AllOutput.Values['ID_LIKE'];
              if Length(s)=0 then s := AllOutput.Values['DISTRIB_ID'];
              if Length(s)=0 then s := AllOutput.Values['ID'];
            end;
            success:=(Length(s)>0);
          finally
            AllOutput.Free;
          end;
        end;
      end;
      if (NOT success) then
      begin
        s:='';
        if RunCommand('cat',['/etc/system-release'],s,[poUsePipes, poStderrToOutPut]{$IF DEFINED(FPC_FULLVERSION) AND (FPC_FULLVERSION >= 30200)},swoHide{$ENDIF}) then
        begin
          if Pos('No such file or directory',s)=0 then
          begin
            AllOutput:=TStringList.Create;
            try
              AllOutput.Text:=s;
              s:='';
              s:=AllOutput.Values['NAME'];
              if Length(s)=0 then s := AllOutput.Values['ID_LIKE'];
              if Length(s)=0 then s := AllOutput.Values['DISTRIB_ID'];
              if Length(s)=0 then s := AllOutput.Values['ID'];
              success:=(Length(s)>0);
            finally
              AllOutput.Free;
            end;
          end;
        end;
      end;
      if (NOT success) then
      begin
        s:='';
        if RunCommand('hostnamectl',[],s,[poUsePipes, poStderrToOutPut]{$IF DEFINED(FPC_FULLVERSION) AND (FPC_FULLVERSION >= 30200)},swoHide{$ENDIF}) then
        begin
          AllOutput:=TStringList.Create;
          try
            AllOutput.NameValueSeparator:=':';
            AllOutput.Delimiter:=#10;
            AllOutput.StrictDelimiter:=true;
            AllOutput.DelimitedText:=s;
            s:='';
            for i:=0 to  AllOutput.Count-1 do
            begin
              j:=Pos('Operating System',AllOutput.Strings[i]);
              if j>0 then s:=s+Trim(AllOutput.Values[AllOutput.Names[i]]);
              j:=Pos('Kernel',AllOutput.Strings[i]);
              if j>0 then s:=s+' '+Trim(AllOutput.Values[AllOutput.Names[i]]);
            end;
            success:=(Length(s)>0);
          finally
            AllOutput.Free;
          end;
        end;
      end;
      if (NOT success) then t:='unknown' else
      begin
        s:=DelChars(s,'"');
        t:=Trim(s);
      end;
      {$ifdef BSD}
      if (t='unknown') then
      begin
        if RunCommand('uname',['-r'],s,[poUsePipes, poStderrToOutPut]{$IF DEFINED(FPC_FULLVERSION) AND (FPC_FULLVERSION >= 30200)},swoHide{$ENDIF})
           then t := GetSourceOS+' '+lowercase(Trim(s));
      end;
      {$endif}

      if (t='unknown') then t := GetSourceOS;

      if (NOT success) then if RunCommand('uname',['-r'],s,[poUsePipes, poStderrToOutPut]{$IF DEFINED(FPC_FULLVERSION) AND (FPC_FULLVERSION >= 30200)},swoHide{$ENDIF})
         then t := t+' '+lowercase(Trim(s));

    {$else Darwin}
      if RunCommand('sw_vers',['-productName'], s) then
      begin
        if Length(s)>0 then t:=Trim(s);
      end;
      if Length(s)=0 then t:=GetSourceOS;
      if RunCommand('sw_vers',['-productVersion'], s) then
      begin
        if Length(s)>0 then
        begin
          VersionFromString(s,Major,Minor,Build,Patch);
          t:=t+' '+InttoStr(Major)+'.'+InttoStr(Minor)+'.'+InttoStr(Build);
        end;
      end;
    {$endif Darwin}
  {$endif Unix}

  result:=t;
end;

{ TForm1 }

procedure TForm1.btnStartScanClick(Sender: TObject);
const
  MAGICNEEDED = '(NEEDED)';
  MAGICSHARED = 'Shared library:';

var
  GccDirectory:string;
  SearchLib,SearchDir:string;
  FinalSearchResultList:TLookupStringList;
  sl:string;
procedure CheckAndAddLibrary(aLib:string);
var
  SearchResultList:TStringList;
  SearchResult:string;
  FileName:string;
  i: integer;
  sd,sr,s:string;
begin
  SearchResultList:=TStringList.Create;
  try
    {$ifdef Haiku}
    for sd in HAIKUSEARCHDIRS do
    {$else}
    for sd in UNIXSEARCHDIRS do
    {$endif}
    begin
      {$ifdef Haiku}
      {$ifndef CPUX86}
      if (RightStr(sd,4)='/x86') then continue;
      {$endif}
      {$endif}
      FileName:=sd+DirectorySeparator+aLib;
      if FileExists(FileName) then
      begin
        FinalSearchResultList.Add('['+ExtractFileName(FileName)+']');
        // libc.so might be a text-file, so skip analysis
        if ExtractFileName(FileName)='libc.so' then
        begin
          FileName:='';
          break;
        end;
        // Skip static files from analysis
        if ExtractFileExt(FileName)='.a' then
        begin
          FileName:='';
          break;
        end;
        while FileIsSymlink(FileName) do FileName:=GetPhysicalFilename(FileName,pfeException);
        SearchResult:='';
        RunCommand('readelf',['-d','-W',FileName],SearchResult,[]);
        SearchResultList.Text:=SearchResult;
        if (SearchResultList.Count=0) then continue;
        for sr in SearchResultList do
        begin
          s:=sr;
          if (Pos(MAGICNEEDED,s)>0) then
          begin
            i:=Pos(MAGICSHARED,s);
            if (i<>-1) then
            begin
              s:=Trim(Copy(s,i+Length(MAGICSHARED),MaxInt));
              if (FinalSearchResultList.Add(s)<>-1) then
              begin
                s:=Copy(s,2,Length(s)-2);
                CheckAndAddLibrary(s);
              end;
            end;
          end;
        end;
        FileName:='';
        break;
      end;
    end;
    if (Length(FileName)>0) then
    begin
      FileName:=GccDirectory+DirectorySeparator+aLib;
      if FileExists(FileName) then
      begin
        FinalSearchResultList.Add('['+aLib+']');
        FileName:='';
      end;
      if (Length(FileName)>0) then
      begin
        LibraryNotFoundList.Lines.Append('Not found: '+aLib);
      end;
    end;
  finally
    SearchResultList.Free;
  end;
end;
begin
  LibraryList.Lines.Clear;
  LibraryNotFoundList.Lines.Clear;
  LibraryLocationList.Lines.Clear;

  //sd:=SysUtils.GetEnvironmentVariable('LIBRARY_PATH');
  //if (Length(sd)=0) then sd:=SysUtils.GetEnvironmentVariable('LD_LIBRARY_PATH');
  //if ((Length(sd)>0) AND (DirectoryExists(sd))) then
  //begin
  //end;
  GccDirectory:=GetStartupObjects;

  FinalSearchResultList:=TLookupStringList.Create;
  try
    for SearchLib in FPCLIBS do
    begin
      CheckAndAddLibrary(SearchLib);
    end;
    for SearchLib in FPCLINKLIBS do
    begin
      CheckAndAddLibrary(SearchLib);
    end;
    for SearchLib in LAZLIBS do
    begin
      CheckAndAddLibrary(SearchLib);
    end;
    for SearchLib in LAZLINKLIBS do
    begin
      CheckAndAddLibrary(SearchLib);
    end;
    for SearchLib in QTLIBS do
    begin
      CheckAndAddLibrary(SearchLib);
    end;
    for SearchLib in QTLINKLIBS do
    begin
      CheckAndAddLibrary(SearchLib);
    end;
    FinalSearchResultList.Sort;
    LibraryList.Lines.Text:=FinalSearchResultList.Text;

    for sl in FinalSearchResultList do
    begin
      SearchLib:=Copy(sl,2,Length(sl)-2);

      {$ifdef Haiku}
      for SearchDir in HAIKUSEARCHDIRS do
      {$else}
      for SearchDir in UNIXSEARCHDIRS do
      {$endif}
      begin
        {$ifdef Haiku}
        {$ifndef CPUX86}
        if (RightStr(SearchDir,4)='/x86') then continue;
        {$endif}
        {$endif}
        if FileExists(SearchDir+DirectorySeparator+SearchLib) then
        begin
          LibraryLocationList.Lines.Append(SearchDir+DirectorySeparator+SearchLib);
          SearchLib:='';
          break;
        end;
      end;
      if (Length(SearchLib)>0) then
      begin
        if FileExists(GccDirectory+DirectorySeparator+SearchLib) then
        begin
          LibraryLocationList.Lines.Append(GccDirectory+DirectorySeparator+SearchLib);
          SearchLib:='';
        end;
      end;
      if (Length(SearchLib)>0) then
      begin
        LibraryNotFoundList.Lines.Append('Copy not found: '+SearchLib);
      end;
    end;
  finally
    FinalSearchResultList.Free;
  end;
end;

procedure TForm1.btnGetFilesClick(Sender: TObject);
var
  Index:integer;
  FileName,TargetFile,LinkFile:string;
  aList:TStringList;
begin
  ForceDirectories(Application.Location+'libs');

  aList:=TStringList.Create;
  try
    aList.Add('These libraries were sourced from: '+GetDistro+' version '+GetDistro('VERSION'));
    aList.SaveToFile(Application.Location+'libs'+DirectorySeparator+'actual_library_version_fpcup.txt');
  finally
    aList.Free;
  end;

  for Index:=Pred(LibraryLocationList.Lines.Count) downto 0 do
  begin
    FileName:=LibraryLocationList.Lines.Strings[Index];
    TargetFile:=ExtractFileName(FileName);
    for LinkFile in FPCLINKLIBS do
    begin
      if (Pos(LinkFile,TargetFile)=1) then
      begin
        CopyFile(FileName,Application.Location+'libs'+DirectorySeparator+LinkFile);
        break;
      end;
    end;
    for LinkFile in LAZLINKLIBS do
    begin
      if (Pos(LinkFile,TargetFile)=1) then
      begin
        CopyFile(FileName,Application.Location+'libs'+DirectorySeparator+LinkFile);
        break;
      end;
    end;
    for LinkFile in QTLINKLIBS do
    begin
      if (Pos(LinkFile,TargetFile)=1) then
      begin
        CopyFile(FileName,Application.Location+'libs'+DirectorySeparator+LinkFile);
        break;
      end;
    end;
    if CopyFile(FileName,Application.Location+'libs'+DirectorySeparator+TargetFile) then
    begin
      LibraryLocationList.Lines.Delete(Index);
      Application.ProcessMessages;
    end;
  end;
end;

end.

