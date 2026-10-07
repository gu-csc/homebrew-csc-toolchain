class Csc < Formula
  desc "Universitet of Gothenburg - cSpace Service Client (csc)"
  homepage "https://repo.compute.gu.se/"
  version "0.9.14"
  revision 2

  url "https://repo.compute.gu.se/src/csc-0.9.14-1.tar.gz"
  sha256 "ced81d9d774f4c252d7db7a861e34b14410122b8c35c4c8fc67bee08cfdaf929"

  depends_on "cpanminus" => :build
  depends_on "pkgconf" => :build
  depends_on "libxml2"
  depends_on "openssl@3"
  depends_on "perl"

  def install
    libexec.install "csc"
    man1.install "share/man/man1/csc.1"

    perl = (Formula["perl"].opt_bin/"perl").to_s
    libxml2 = Formula["libxml2"]

    # Run csc and cpanm with the same Homebrew Perl.
    inreplace libexec/"csc", %r{\A#!\s*/usr/bin/env\s+perl\s*$}, "#!#{perl}\n"

    vendor = libexec/"vendor"
    vendor.mkpath

    ENV.prepend_path "PATH", Formula["cpanminus"].opt_bin
    ENV.prepend_path "PATH", Formula["pkgconf"].opt_bin
    ENV.prepend_path "PATH", libxml2.opt_bin
    ENV.prepend_path "PKG_CONFIG_PATH", libxml2.opt_lib/"pkgconfig"

    # Alien::Libxml2 must use the declared Homebrew library.
    ENV["ALIEN_INSTALL_TYPE"] = "system"
    ENV["OPENSSL_PREFIX"] = Formula["openssl@3"].opt_prefix.to_s

    # Keep caches out of the installed keg; verbose output reaches Homebrew's logs.
    ENV["PERL_CPANM_HOME"] = (buildpath/"cpanm_home").to_s
    ENV["PERL_CPANM_OPT"] = "--notest --verbose --no-interactive"

    arch = Utils.safe_popen_read(perl, "-MConfig", "-e", "print $Config{archname}").strip

    # String arguments also avoid Pathname serialization in Homebrew error reports.
    system perl, "-S", "cpanm",
           "--local-lib-contained", vendor.to_s,
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
    # CSC 0.9.14 prints help/version via Perl die; check the output independently
    # of its nonzero informational exit status.
    assert_match "Usage:", shell_output("#{bin}/csc --help", nil)
    assert_match "0.9.14 (rev 1)", shell_output("#{bin}/csc version", nil)
  end
end

