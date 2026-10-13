# frozen_string_literal: true

# Homebrew Formula for the standard macOS YouTrack CLI.
class YoutrackAgentCli < Formula
  desc "Agent-first JetBrains YouTrack CLI with native macOS Keychain storage"
  homepage "https://github.com/abigotado/youtrack-agent-cli"
  url "https://github.com/abigotado/youtrack-agent-cli/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "9ec29b12c1895e16594ee63feca6745e238fc58a963fca2695d713a525d47d57"
  license "MIT"

  depends_on "go" => :build
  depends_on :macos

  resource "github.com/creack/pty" do
    url "https://proxy.golang.org/github.com/creack/pty/@v/v1.1.24.zip"
    sha256 "754e25253e76a5583b80d57d3add3afe68fc4d9f2a490968a9d1eda8c8fd8815"
  end

  resource "github.com/inconshreveable/mousetrap" do
    url "https://proxy.golang.org/github.com/inconshreveable/mousetrap/@v/v1.1.0.zip"
    sha256 "526674de624d7db108cfe7653ef110ccdfd97bc85026254224815567928ed243"
  end

  resource "github.com/spf13/cobra" do
    url "https://proxy.golang.org/github.com/spf13/cobra/@v/v1.10.2.zip"
    sha256 "a00aae6fcd631e0fde52c98604452ff70e1b73c3b8a560d68db15aff5e26872d"
  end

  resource "github.com/spf13/pflag" do
    url "https://proxy.golang.org/github.com/spf13/pflag/@v/v1.0.10.zip"
    sha256 "a246b8c9d3daa87d6c634cdfee1bdf7fa53d5817eeef4fa0c6da43edd12de4ca"
  end

  resource "golang.org/x/sys" do
    url "https://proxy.golang.org/golang.org/x/sys/@v/v0.49.0.zip"
    sha256 "e73a06591ca0d7016ce3ccb45c36a8ed7128468aecc1a357f94d815c760c6b31"
  end

  resource "golang.org/x/term" do
    url "https://proxy.golang.org/golang.org/x/term/@v/v0.47.0.zip"
    sha256 "d990d5ab94dfa41ba980645b721bba7490064337a01bb03e6cacace70e8df0bf"
  end

  def install
    ENV["CGO_ENABLED"] = "1"
    ENV["GOPROXY"] = "off"
    ENV["GOSUMDB"] = "off"
    ENV["GOTOOLCHAIN"] = "local"
    ENV["GOFLAGS"] = "-mod=vendor -trimpath"
    resource("github.com/creack/pty").stage do
      (buildpath/"vendor/github.com/creack/pty").install Pathname("creack/pty@v1.1.24").children
    end
    resource("github.com/inconshreveable/mousetrap").stage do
      module_root = Pathname("inconshreveable/mousetrap@v1.1.0")
      (buildpath/"vendor/github.com/inconshreveable/mousetrap").install module_root.children
    end
    resource("github.com/spf13/cobra").stage do
      (buildpath/"vendor/github.com/spf13/cobra").install Pathname("spf13/cobra@v1.10.2").children
    end
    resource("github.com/spf13/pflag").stage do
      (buildpath/"vendor/github.com/spf13/pflag").install Pathname("spf13/pflag@v1.0.10").children
    end
    resource("golang.org/x/sys").stage do
      (buildpath/"vendor/golang.org/x/sys").install Pathname("x/sys@v0.49.0").children
    end
    resource("golang.org/x/term").stage do
      (buildpath/"vendor/golang.org/x/term").install Pathname("x/term@v0.47.0").children
    end
    (buildpath/"vendor/modules.txt").write <<~EOS
      # github.com/creack/pty v1.1.24
      ## explicit; go 1.18
      github.com/creack/pty
      # github.com/inconshreveable/mousetrap v1.1.0
      ## explicit; go 1.18
      github.com/inconshreveable/mousetrap
      # github.com/spf13/cobra v1.10.2
      ## explicit; go 1.15
      github.com/spf13/cobra
      # github.com/spf13/pflag v1.0.10
      ## explicit; go 1.12
      github.com/spf13/pflag
      # golang.org/x/sys v0.49.0
      ## explicit; go 1.25.0
      golang.org/x/sys/plan9
      golang.org/x/sys/unix
      golang.org/x/sys/windows
      # golang.org/x/term v0.47.0
      ## explicit; go 1.25.0
      golang.org/x/term
    EOS
    commit = "c75d4cd97acf98f1f83512fb0b38ad3c91a2a024"
    commit_time = "2026-10-13T19:56:58Z"
    ldflags = %W[
      -X github.com/abigotado/youtrack-agent-cli/internal/cli.releaseVersion=v#{version}
      -X github.com/abigotado/youtrack-agent-cli/internal/cli.releaseCommit=#{commit}
      -X github.com/abigotado/youtrack-agent-cli/internal/cli.releaseCommitTime=#{commit_time}
    ].join(" ")
    system "go", "build", *std_go_args(output: bin/"youtrack-agent-cli", ldflags: ldflags), "./cmd/youtrack-agent-cli"
  end

  test do
    ENV["HOME"] = testpath

    version_command = "#{bin}/youtrack-agent-cli version -o json --fields version,commit,commit_time"
    version_response = JSON.parse(shell_output(version_command))
    assert version_response["ok"]
    assert_equal "v#{version}", version_response.dig("data", "version")
    assert_equal "c75d4cd97acf98f1f83512fb0b38ad3c91a2a024", version_response.dig("data", "commit")
    assert_equal "2026-10-13T19:56:58Z", version_response.dig("data", "commit_time")

    contract_response = JSON.parse(shell_output("#{bin}/youtrack-agent-cli contract -o json"))
    assert contract_response["ok"]
    assert_equal 1, contract_response.dig("data", "envelope_version")

    help = shell_output("#{bin}/youtrack-agent-cli --help")
    assert_match "auth", help
    assert_match "mutation", help
    assert_match "operator-write", help

    capabilities = JSON.parse(shell_output("#{bin}/youtrack-agent-cli capabilities -o json"))
    assert capabilities["ok"]
    assert_equal true, capabilities.dig("data", "operator_write_supported")
    assert_equal false, capabilities.dig("data", "native_user_presence_supported")
    assert_equal false, capabilities.dig("data", "locally_ready")
    assert_equal "operator_confirmed", capabilities.dig("data", "confirmation_mode")
    assert_equal "local_configuration_only", capabilities.dig("data", "readiness_scope")

    operator_help = shell_output("#{bin}/youtrack-agent-cli operator-write apply --help")
    assert_match "--confirm-intent", operator_help
    assert_match "--plan-id", operator_help

    operator_response = JSON.parse(shell_output("#{bin}/youtrack-agent-cli operator-write apply -o json", 2))
    refute operator_response["ok"]
    assert_equal "PROFILE_REQUIRED", operator_response.dig("error", "code")

    native_command = %W[
      #{bin}/youtrack-agent-cli mutation apply --profile test
      --plan-id YTAP-AAAAAAAAAAAAAAAAAAAAAAAAAA --yes -o json
    ].join(" ")
    native_response = JSON.parse(shell_output(native_command, 2))
    refute native_response["ok"]
    assert_equal "USAGE", native_response.dig("error", "code")
    assert_match "--yes is not accepted", native_response.dig("error", "message")

    comments_help = shell_output("#{bin}/youtrack-agent-cli inspect comments --help")
    assert_match "--id", comments_help
    assert_match "--limit", comments_help
    assert_match "--offset", comments_help

    comments_response = JSON.parse(shell_output("#{bin}/youtrack-agent-cli inspect comments --id APP-1 -o json", 2))
    refute comments_response["ok"]
    assert_equal "PROFILE_REQUIRED", comments_response.dig("error", "code")

    linkage = shell_output("/usr/bin/otool -L #{bin}/youtrack-agent-cli")
    assert_match "/System/Library/Frameworks/Security.framework/", linkage

    binary = File.binread(bin/"youtrack-agent-cli")
    refute_match "/usr/bin/security", binary
  end
end
