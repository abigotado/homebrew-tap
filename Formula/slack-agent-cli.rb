class SlackAgentCli < Formula
  desc "Provider-neutral Slack CLI with native macOS Keychain storage"
  homepage "https://github.com/abigotado/slack-agent-cli"
  url "https://github.com/abigotado/slack-agent-cli/releases/download/v0.2.3/slack-agent-cli-0.2.3.tar.gz"
  sha256 "824fed1e64e76f1832394ee439008810d56cedbc2b8a8347b09296cbb45d4ea4"
  license "MIT"

  depends_on "go" => :build
  depends_on :macos

  resource "github.com/inconshreveable/mousetrap" do
    url "https://proxy.golang.org/github.com/inconshreveable/mousetrap/@v/v1.1.0.zip"
    sha256 "526674de624d7db108cfe7653ef110ccdfd97bc85026254224815567928ed243"
  end

  resource "github.com/spf13/cobra" do
    url "https://proxy.golang.org/github.com/spf13/cobra/@v/v1.10.2.zip"
    sha256 "a00aae6fcd631e0fde52c98604452ff70e1b73c3b8a560d68db15aff5e26872d"
  end

  resource "github.com/spf13/pflag" do
    url "https://proxy.golang.org/github.com/spf13/pflag/@v/v1.0.9.zip"
    sha256 "83910188d8735f84a48a80ab78351edac0b569896f2b3a244c696a07da9aa5ed"
  end

  resource "golang.org/x/sys" do
    url "https://proxy.golang.org/golang.org/x/sys/@v/v0.47.0.zip"
    sha256 "cdac013ddced0262926ec29ffcda645da39670e61c7e5b761e572b6b1809bb1b"
  end

  def install
    ENV["CGO_ENABLED"] = "1"
    ENV["GOPROXY"] = "off"
    ENV["GOSUMDB"] = "off"
    ENV["GOTOOLCHAIN"] = "local"
    ENV["GOFLAGS"] = "-mod=vendor -trimpath"
    resource("github.com/inconshreveable/mousetrap").stage do
      module_root = Pathname("inconshreveable/mousetrap@v1.1.0")
      (buildpath/"vendor/github.com/inconshreveable/mousetrap").install module_root.children
    end
    resource("github.com/spf13/cobra").stage do
      (buildpath/"vendor/github.com/spf13/cobra").install Pathname("spf13/cobra@v1.10.2").children
    end
    resource("github.com/spf13/pflag").stage do
      (buildpath/"vendor/github.com/spf13/pflag").install Pathname("spf13/pflag@v1.0.9").children
    end
    resource("golang.org/x/sys").stage do
      (buildpath/"vendor/golang.org/x/sys").install Pathname("x/sys@v0.47.0").children
    end
    (buildpath/"vendor/modules.txt").write <<~EOS
      # github.com/inconshreveable/mousetrap v1.1.0
      ## explicit; go 1.18
      github.com/inconshreveable/mousetrap
      # github.com/spf13/cobra v1.10.2
      ## explicit; go 1.15
      github.com/spf13/cobra
      # github.com/spf13/pflag v1.0.9
      ## explicit; go 1.12
      github.com/spf13/pflag
      # golang.org/x/sys v0.47.0
      ## explicit; go 1.25.0
      golang.org/x/sys/unix
    EOS
    system "go", "build", *std_go_args(output: bin/"slack-agent-cli"), "./cmd/slack-agent-cli"
  end

  test do
    ENV["HOME"] = testpath

    version_response = JSON.parse(shell_output("#{bin}/slack-agent-cli version"))
    assert version_response["ok"]
    assert_equal 1, version_response["v"]
    assert_equal "v#{version}", version_response.dig("data", "version")
    assert_equal "f346da9ee93a50bee47a9c84b53debcf09735609", version_response.dig("data", "commit")

    contract_response = JSON.parse(shell_output("#{bin}/slack-agent-cli contract"))
    assert contract_response["ok"]
    assert_equal 1, contract_response.dig("data", "envelope_version")

    auth_list_response = JSON.parse(shell_output("#{bin}/slack-agent-cli auth list"))
    assert auth_list_response["ok"]
    assert_equal 0, auth_list_response.dig("meta", "count")

    profile_required = JSON.parse(shell_output("#{bin}/slack-agent-cli me", 2))
    refute profile_required["ok"]
    assert_equal "PROFILE_REQUIRED", profile_required.dig("error", "code")

    linkage = shell_output("/usr/bin/otool -L #{bin}/slack-agent-cli")
    assert_match "/System/Library/Frameworks/Security.framework/", linkage

    binary = File.binread(bin/"slack-agent-cli")
    refute_match "/usr/bin/security", binary
  end
end
