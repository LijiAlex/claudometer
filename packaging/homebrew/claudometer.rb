class Claudometer < Formula
  desc "macOS menu bar app for Claude usage limits"
  homepage "https://github.com/LijiAlex/claudometer"
  url "https://github.com/LijiAlex/claudometer/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "b893a76434cb195b7097121ae8873c499fe5947355b674f0756b80b48d3d020c"
  license "MIT"
  # Builds with Xcode Command Line Tools (Homebrew requires them already);
  # full Xcode is NOT needed — `swift build` under CLT compiles this app.
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
