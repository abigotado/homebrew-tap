class JiraAgentCli < Formula
  desc "Agent-first Jira Cloud CLI with native macOS Keychain storage"
  homepage "https://github.com/abigotado/jira-cli"
  url "https://github.com/abigotado/jira-cli/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "c15d8cfb218ba7e508ce4aec61c0ab29c81e76d012e37cfb36e24b79240011ed"
  license "MIT"

  depends_on "go" => :build
  depends_on :macos

  def install
    ENV["CGO_ENABLED"] = "1"
    ldflags = "-X github.com/abigotado/jira-cli/internal/cli.releaseVersion=v#{version}"
    system "go", "build", *std_go_args(output: bin/"jira-cli", ldflags:), "./cmd/jira-cli"
  end

  test do
    version_response = JSON.parse(shell_output("#{bin}/jira-cli version -o json"))
    assert version_response["ok"]
    assert_equal "v#{version}", version_response.dig("data", "version")

    contract_response = JSON.parse(shell_output("#{bin}/jira-cli contract -o json"))
    assert contract_response["ok"]
    assert_equal 1, contract_response.dig("data", "envelope_version")

    linkage = shell_output("/usr/bin/otool -L #{bin}/jira-cli")
    assert_match "/System/Library/Frameworks/Security.framework/", linkage
  end
end
