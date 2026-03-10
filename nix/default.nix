{
  lib,
  stdenv,
  python3Packages,
  makeWrapper,
  wl-clipboard,
  wtype,
  xdg-utils,
  quickshell,
}:
stdenv.mkDerivation {
  pname = "jcm";
  version = "0.1";

  src = ../.;

  nativeBuildInputs = [makeWrapper];

  buildInputs = [
    python3Packages.python
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  postFixup = ''
    substituteInPlace $out/bin/jcm \
      --replace-warn 'QML_PATH="$BASE_DIR/qml/shell.qml"' 'QML_PATH="'$out'/share/jcm/qml/shell.qml"' \
      --replace-warn 'QML_PATH="./qml/shell.qml"' 'QML_PATH="'$out'/share/jcm/qml/shell.qml"'

    wrapProgram $out/bin/jcm-daemon \
      --prefix PATH : ${lib.makeBinPath [wl-clipboard wtype xdg-utils]}

    wrapProgram $out/bin/jcm \
      --prefix PATH : ${lib.makeBinPath [quickshell wl-clipboard]}:$out/bin
  '';

  meta = with lib; {
    description = "JCM (Just a Clipboard Manager)";
    homepage = "https://github.com/justanoobcoder/jcm";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
