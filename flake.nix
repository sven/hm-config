# nix: curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
# hm: nix run nixpkgs#home-manager -- switch --flake .
# shell:
#   - /etc/shells -> enable ZSH
#   - chsh
{
  description = "Home Manager Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
  };

  outputs = {
    nixpkgs,
    home-manager,
    nix-index-database,
    catppuccin,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    homeConfigurations = {
      "myuser" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          nix-index-database.hmModules.nix-index
          {programs.nix-index-database.comma.enable = true;}
          catppuccin.homeManagerModules.catppuccin
          {
            home = {
              username = "myuser";
              homeDirectory = "/home/myuser";
              stateVersion = "24.05";
              packages = with pkgs; [
                neofetch
                curl
                wget
                devenv
                mc
                (nerdfonts.override {fonts = ["FiraCode"];})
              ];
            };
            programs = {
              home-manager.enable = true;
              direnv = {
                enable = true;
                nix-direnv.enable = true;
                enableBashIntegration = true;
              };
              git.enable = true;
              oh-my-posh = {
                enable = true;
                useTheme = "catppuccin_mocha";
              };
              zsh = {
                enable = true;
                oh-my-zsh = {
                  enable = true;
                };
                syntaxHighlighting = {
                  enable = true;
                };
              };
              neovim = {
                enable = true;
                viAlias = true;
                vimAlias = true;
              };
            };
            catppuccin.enable = true;
            fonts.fontconfig.enable = true;
          }
        ];
      };
    };
    formatter.${system} = pkgs.alejandra;
  };
}
