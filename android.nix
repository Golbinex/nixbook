with import <nixpkgs> {};

let
  androidComposition = androidenv.composeAndroidPackages {
    cmdLineToolsVersion = "8.0";
    toolsVersion = "26.1.1";
    platformToolsVersion = "33.0.3";
    buildToolsVersions = [ "30.0.3" "33.0.3" "34.0.0" "35.0.0" ];
    includeEmulator = false;
    emulatorVersion = "33.0.3";
    platformVersions = [ "30" "32" "33" "34" "35" ];
    includeSources = false;
    includeSystemImages = false;
    systemImageTypes = [ "google_apis_playstore" ];
    abiVersions = [ "arm64-v8a" ];
    cmakeVersions = [ "3.10.2" ];
    includeNDK = true;
    ndkVersions = ["22.0.7026061"];
    useGoogleAPIs = false;
    useGoogleTVAddOns = false;
    includeExtras = [
      "extras;google;gcm"
    ];
	extraLicenses = ["android-sdk-license"];
  };
in
pkgs.mkShell rec {
  #android_sdk.accept_license = true;
  NIXPKGS_ACCEPT_ANDROID_SDK_LICENSE=1;
  ANDROID_HOME = "${androidComposition.androidsdk}/libexec/android-sdk";
  ANDROID_NDK_ROOT = "${ANDROID_HOME}/ndk-bundle";
  GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidComposition.androidsdk}/libexec/android-sdk/build-tools/34.0.0/aapt2";

  #android_sdk.accept_license = true;
  # Use the same buildToolsVersion here
  #GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${ANDROID_HOME}/build-tools/${buildToolsVersion}/aapt2";
}
