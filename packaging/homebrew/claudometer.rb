class Claudometer < Formula
  desc "macOS menu bar app for Claude usage limits"
  homepage "https://github.com/LijiAlex/claudometer"
  url "https://github.com/LijiAlex/claudometer/archive/refs/tags/v0.1.0.tar.gz"
  # Filled in when tagging v0.1.0: curl -L <url> | shasum -a 256
  sha256 "PLACEHOLDER_SHA256_COMPUTE_AT_RELEASE"
  license "MIT"
  depends_on xcode: :build
  depends_on :macos

  def install
    system "make", "app"
    prefix.install "Claudometer.app"
    bin.write_exec_script "#{prefix}/Claudometer.app/Contents/MacOS/Claudometer"
  end

  def caveats
    <<~EOS
      Launch Claudometer from Spotlight, or run `claudometer`.
      On first launch, approve the macOS Keychain prompt (Always Allow).
    EOS
  end
end
