class TrelloCli < Formula
  desc "Agent-first Trello CLI with native macOS Keychain storage"
  homepage "https://github.com/abigotado/trello-cli"
  url "https://github.com/abigotado/trello-cli/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "cb3d7c7f3ff8e39b2094e9f1ee3db51dc66c079d9f2fdad3b4f5e56d71dcff6a"
  license "MIT"

  depends_on "go" => :build
  depends_on :macos

  def install
    ENV["CGO_ENABLED"] = "1"
    ldflags = "-X github.com/abigotado/trello-cli/internal/cli.releaseVersion=v#{version}"
    system "go", "build", *std_go_args(output: bin/"trello-cli", ldflags:), "./cmd/trello-cli"
  end

  test do
    version_response = JSON.parse(shell_output("#{bin}/trello-cli version -o json"))
    assert version_response["ok"]
    assert_equal "v#{version}", version_response.dig("data", "version")

    contract_response = JSON.parse(shell_output("#{bin}/trello-cli contract -o json"))
    assert contract_response["ok"]
    assert_equal 1, contract_response.dig("data", "envelope_version")

    linkage = shell_output("/usr/bin/otool -L #{bin}/trello-cli")
    assert_match "/System/Library/Frameworks/Security.framework/", linkage
  end
end
