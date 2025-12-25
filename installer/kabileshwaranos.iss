; Inno Setup script for KabileshwaranOS desktop app
; Build the Flutter release first: flutter build windows --release

#define MyAppName "KabileshwaranOS"
#define MyAppVersion "1.0.0"
#define MyAppPublisher "Kabileshwaran"
#define MyAppExeName "my_first_app.exe"
#define MySourceDir "..\\build\\windows\\x64\\runner\\Release"
#define MyIcon "..\\windows\\runner\\resources\\app_icon.ico"

[Setup]
AppId={{0C27B54D-77D8-4D2E-8AB5-4D1B42B030C7}}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
SetupIconFile={#MyIcon}
DefaultDirName={pf}\KabileshwaranOS
DefaultGroupName=KabileshwaranOS
DisableProgramGroupPage=no
; Output directory relative to this script file
OutputDir=dist
OutputBaseFilename=KabileshwaranOS-Setup
Compression=lzma
SolidCompression=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a &desktop icon"; Flags: unchecked

[Files]
Source: "{#MySourceDir}\\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{group}\KabileshwaranOS"; Filename: "{app}\{#MyAppExeName}"
Name: "{commondesktop}\KabileshwaranOS"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Launch {#MyAppName}"; Flags: nowait postinstall skipifsilent
