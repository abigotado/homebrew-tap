class ConfluenceCli < Formula
  desc "Agent-first Confluence Cloud CLI with native macOS Keychain storage"
  homepage "https://github.com/abigotado/confluence-cli"
  url "https://github.com/abigotado/confluence-cli/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "e169fea8e00ba1cdaa4d7a572c267afca31b0de1407f87bf478b5d660b36ef55"
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
    url "https://proxy.golang.org/github.com/spf13/pflag/@v/v1.0.9.zip"
    sha256 "83910188d8735f84a48a80ab78351edac0b569896f2b3a244c696a07da9aa5ed"
  end

  resource "golang.org/x/sys" do
    url "https://proxy.golang.org/golang.org/x/sys/@v/v0.44.0.zip"
    sha256 "f1fa1052808e6bd6eb9c5372c053b2370a582532fac5d6a4600e7a6fab190ff3"
  end

  resource "golang.org/x/term" do
    url "https://proxy.golang.org/golang.org/x/term/@v/v0.43.0.zip"
    sha256 "0d12dd77f2c620f236e59421d604f6bcd1f9212a4083a1c0ec13425c67bc6e81"
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
      (buildpath/"vendor/github.com/spf13/pflag").install Pathname("spf13/pflag@v1.0.9").children
    end
    resource("golang.org/x/sys").stage do
      (buildpath/"vendor/golang.org/x/sys").install Pathname("x/sys@v0.44.0").children
    end
    resource("golang.org/x/term").stage do
      (buildpath/"vendor/golang.org/x/term").install Pathname("x/term@v0.43.0").children
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
      # github.com/spf13/pflag v1.0.9
      ## explicit; go 1.12
      github.com/spf13/pflag
      # golang.org/x/sys v0.44.0
      ## explicit; go 1.25.0
      golang.org/x/sys/plan9
      golang.org/x/sys/unix
      golang.org/x/sys/windows
      # golang.org/x/term v0.43.0
      ## explicit; go 1.25.0
      golang.org/x/term
    EOS
    commit = "fea31521770b756ff61ae6426628073ba3778ceb"
    commit_time = "2026-08-27T17:46:09Z"
    ldflags = %W[
      -X github.com/abigotado/confluence-cli/internal/cli.releaseVersion=v#{version}
      -X github.com/abigotado/confluence-cli/internal/cli.releaseCommit=#{commit}
      -X github.com/abigotado/confluence-cli/internal/cli.releaseCommitTime=#{commit_time}
    ].join(" ")
    system "go", "build", *std_go_args(output: bin/"confluence-cli", ldflags: ldflags), "./cmd/confluence-cli"
  end

  test do
    version_command = "#{bin}/confluence-cli version -o json --fields version,commit,commit_time"
    version_response = JSON.parse(shell_output(version_command))
    assert version_response["ok"]
    assert_equal "v#{version}", version_response.dig("data", "version")
    assert_equal "fea31521770b756ff61ae6426628073ba3778ceb", version_response.dig("data", "commit")
    assert_equal "2026-08-27T17:46:09Z", version_response.dig("data", "commit_time")

    contract_response = JSON.parse(shell_output("#{bin}/confluence-cli contract -o json"))
    assert contract_response["ok"]
    assert_equal 1, contract_response.dig("data", "envelope_version")

    linkage = shell_output("/usr/bin/otool -L #{bin}/confluence-cli")
    assert_match "/System/Library/Frameworks/Security.framework/", linkage

    binary = File.binread(bin/"confluence-cli")
    refute_match "/usr/bin/security", binary
  end
end
