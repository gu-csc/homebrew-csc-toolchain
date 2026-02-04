class Csc < Formula
  desc "Universitet of Gothenburg - Computational Service Client (csc)"
  homepage "https://repo.compute.gu.se/"
  version "0.9.12"

  url "https://repo.compute.gu.se/src/csc-0.9.12.tar.gz"
  sha256 "fa82faa5629f13464e2bd7b4f679449b667bc63f6b3c0d2b0f44684127308967"

  depends_on "perl"
  depends_on "cpanminus"

  def install
    libexec.install "csc"

    perl = Formula["perl"].opt_bin/"perl"

    # Ensure the script runs with Homebrew perl (your tarball has #!/usr/bin/env perl)
    inreplace libexec/"csc", %r{\A#!\s*/usr/bin/env\s+perl\s*$}, "#!#{perl}\n"

    vendor = libexec/"vendor"
    vendor.mkpath

    # Make sure we can find cpanm in PATH, but execute it with Homebrew perl
    ENV.prepend_path "PATH", Formula["cpanminus"].opt_bin

    # Keep cpanm build/cache inside the keg
    ENV["PERL_CPANM_HOME"] = (libexec/"cpanm_home").to_s
    ENV["PERL_CPANM_OPT"]  = "--notest --quiet"

    # Determine perl archname (e.g. darwin-thread-multi-2level)
    arch = Utils.safe_popen_read(perl.to_s, "-MConfig", "-e", "print $Config{archname}")

    # Install only non-core deps + HTTPS stack
    system perl, "-S", "cpanm",
           "--local-lib-contained", vendor,
           "List::MoreUtils",
           "Text::Table",
           "JSON::MaybeXS",
           "LWP::UserAgent",
           "URI",
           "File::HomeDir",
           "XML::LibXML",
           "Archive::Zip",
           "LWP::Protocol::https",
           "IO::Socket::SSL",
           "Mozilla::CA",
           "Net::SSLeay"

    env = {
      "PERL5LIB" => [
        vendor/"lib/perl5",
        vendor/"lib/perl5"/arch,
      ].join(":"),
    }

    (bin/"csc").write_env_script(libexec/"csc", env)
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/csc --help")
  end
end

