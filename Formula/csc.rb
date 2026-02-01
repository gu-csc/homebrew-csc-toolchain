class Csc < Formula
  desc "Göteborgs Universitet Computational Service Client (csc)"
  homepage "https://repo.compute.gu.se/"
  url "https://repo.compute.gu.se/src/csc-0.9.11.tar.gz"
  sha256 "941907e6f5714a7bf672c13bb9a76e6c1096614b2f3939efb820d2a72cd248d9"
  version "0.9.11"

  depends_on "perl"
  depends_on "cpanminus"

  def install
    # Tarball contains a single file: ./csc
    libexec.install "csc"

    # Install CPAN deps into a keg-local vendor dir (no touching system perl)
    vendor = libexec/"vendor"
    vendor.mkpath

    # Keep cpanm home/cache in keg-local dirs
    ENV["PERL_CPANM_HOME"] = (libexec/"cpanm_home").to_s
    ENV["PERL_CPANM_OPT"]  = "--notest --quiet"

    # Ensure the *Homebrew* perl is used (not /usr/bin/perl)
    # (brew sets PATH, but be explicit & safe)
    ENV.prepend_path "PATH", Formula["perl"].opt_bin

    # Runtime deps that are NOT embedded (CSC::* is embedded)
    system "cpanm",
           "--local-lib-contained", vendor,
           "JSON::MaybeXS",
           "LWP::UserAgent",
           "URI",
           "Text::Table",
           "List::MoreUtils",
           "File::HomeDir",
           "XML::LibXML",
           "Archive::Zip"

    # Wrap the executable so it finds the installed CPAN modules
    env = {
      "PERL5LIB" => [
        vendor/"lib/perl5",
        # Some installs may put arch-specific under lib/perl5/<archname>
        vendor/"lib/perl5/darwin-thread-multi-2level"
      ].select(&:exist?).join(":")
    }

    (bin/"csc").write_env_script(libexec/"csc", env)
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/csc --help")
  end
end

