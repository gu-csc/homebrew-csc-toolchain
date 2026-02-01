class Csc < Formula
  desc "Göteborgs Universitet Computational Service Client (csc)"
  homepage "https://repo.compute.gu.se/"
  version "0.9.11"

  # Publish this tarball from your repo manager into:
  #   /repo/publish/current/bootstrap/macos/
  # and serve it as:
  #   https://repo.compute.gu.se/src/csc-0.9.11.tar.gz
  #
  # The tarball should contain a single file: `csc` (the executable Perl script),
  # with embedded CSC::* modules.
  url "https://repo.compute.gu.se/src/csc-0.9.11.tar.gz"
  sha256 "REPLACE_WITH_SHA256_OF_TARBALL"

  depends_on "perl"
  depends_on "cpanminus"

  def install
    # Install the csc script into libexec, then wrap it with PERL5LIB
    libexec.install "csc"

    # Install CPAN deps locally (NOT embedding into the script; installed alongside).
    # This requires outbound internet access to CPAN during brew install/upgrade.
    vendor = libexec/"vendor"
    vendor.mkpath

    # Keep CPAN build cache inside the keg
    ENV["PERL_CPANM_HOME"] = (libexec/"cpanm").to_s
    ENV["PERL_CPANM_OPT"]  = "--notest"

    # Install runtime deps that are NOT CSC::* (those are embedded)
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

    # Wrap csc so it can find CPAN-installed modules
    env = {
      "PERL5LIB" => [
        vendor/"lib/perl5",
      ].join(":")
    }
    (bin/"csc").write_env_script(libexec/"csc", env)
  end

  test do
    # Basic sanity check
    system "#{bin}/csc", "--help"
  end
end

