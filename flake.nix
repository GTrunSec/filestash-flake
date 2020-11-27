{
  description = "";

  inputs = {
    nixpkgs.url = "nixpkgs/8bdebd463bc77c9b83d66e690cba822a51c34b9b";
    ranz2nix = { url = "github:andir/ranz2nix"; flake = false;};
    filestash = { url = "github:mickael-kerjean/filestash"; flake = false;};
  };

  outputs = { self, nixpkgs, ranz2nix, filestash }: {
    packages.x86_64-linux.filestash =
      with import nixpkgs { system = "x86_64-linux";};
      let
        src = pkgs.fetchFromGitHub {
          owner = "mickael-kerjean";
          repo = "filestash";
          rev = filestash.rev;
          sha256 = filestash.narHash;
        };
        goPackagePath = "github.com/mickael-kerjean/filestash";
      in
        buildGoPackage {
          name = "filestash";
          inherit src;
          buildInputs = [ pkgconfig ];
          inherit goPackagePath;
          CGO_CFLAGS_ALLOW = "-fopenmp";
          PKG_CONFIG_PATH = "${pkgconfig}";
          preBuild = let
            ldFlags = stdenv.lib.concatStringsSep " " [
              "-X ${goPackagePath}/server/common.BUILD_DATE=2020-Nov"
              "-X ${goPackagePath}/server/common.BUILD_REF=${src.rev}"
              "-o dist/filestash server/main.go"
            ];
          in ''
            buildFlagsArray=( "-tags" "fts5" "-ldflags" "${ldFlags}")
            '';
          goDeps = ./deps.nix;
          meta = {
            description = "🦄 A modern web client for SFTP, S3, FTP, WebDAV, Git, Minio, LDAP, CalDAV, CardDAV, Mysql, Backblaze, ...";
            homePage = "https://github.com/mickael-kerjean/";
          };
        };

    defaultPackage.x86_64-linux = self.packages.x86_64-linux.filestash;

  };
}
