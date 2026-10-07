class Csc < Formula
  desc "Universitet of Gothenburg - cSpace Service Client (csc)"
  homepage "https://repo.compute.gu.se/"
  version "0.9.14"
  revision 1

  url "https://repo.compute.gu.se/src/csc-0.9.14-1.tar.gz"
  sha256 "ced81d9d774f4c252d7db7a861e34b14410122b8c35c4c8fc67bee08cfdaf929"

  depends_on "perl"
  depends_on "cpanminus"

  def install
    libexec.install "csc"
    man1.install "share/man/man1/csc.1"

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
           "File::Globstar",
           "XML::LibXML",
           "Archive::Zip",
           "LWP::Protocol::https",
           "URI::Escape::XS",
           "Any::URI::Escape",
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

