{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  pname = "gigamate-acpi";
  version = "4.4.3";

  src = ./src/gigamate_acpi;

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  postPatch = ''
    sed -i 's/#define DRIVER_VERSION .*/#define DRIVER_VERSION "4.4.3"/' gigamate_acpi.c
  '';

  installPhase = ''
    runHook preInstall
    install -D gigamate_acpi.ko -t $out/lib/modules/${kernel.modDirVersion}/extra
    runHook postInstall
  '';

  meta = {
    description = "GigaMate ACPI WMI kernel module for Gigabyte laptops";
    homepage = "https://github.com/goodeesh/GigaMate";
    license = lib.licenses.gpl2Only;
    platforms = [ "x86_64-linux" ];
  };
}
