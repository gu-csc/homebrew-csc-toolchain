class Csc < Formula
  desc "Göteborgs Universitet Computational Service Client (csc)"
  homepage "https://repo.compute.gu.se/"
  url "https://repo.compute.gu.se/src/csc-0.9.11.tar.gz"
  sha256 "941907e6f5714a7bf672c13bb9a76e6c1096614b2f3939efb820d2a72cd248d9"
  version "0.9.11"

  depends_on "perl"
  depends_on "cpanminus"

  def install
    libexec.install "csc"

    # Force the script to run with Homebrew perl (NOT macOS /usr/bin/perl)
    perl = Formula["perl"].opt_bin/"perl"
    inreplace libexec/"csc", %r{\A#!\s*/usr/bin/env\s+perl\s*$}, "#!#{perl}\n"

    vendor = libexec/"vendor"
    vendor.mkpath

    # Keep cpanm state inside the keg
    ENV["PERL_CPANM_HOME"] = (libexec/"cpanm_home").to_s
    ENV["PERL_CPANM_OPT"]  = "--notest --quiet"

    # Install runtime deps (CSC::* are embedded in csc)
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

    env = {
      "PERL5LIB" => (vendor/"lib/perl5").to_s
    }

    (bin/"csc").write_env_script(libexec/"csc", env)
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/csc --help")
  end
end

