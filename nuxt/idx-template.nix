{ pkgs, ... }:

let
  # The Node.js version to use. This is read from the `.nvmrc` file
  # in the workspace root. If the file doesn't exist, it defaults to "20".
  nodeVersion = pkgs.lib.strings.fileContents ./.nvmrc or "20";
  # The corresponding Nix package for the Node.js version.
  nodejs = pkgs."nodejs_$\{nodeVersion\}_x";

  # The package manager to use. This is configured in the bootstrap script.
  packageManager = "PACKAGE_MANAGER";
  # The command to install dependencies.
  installCommand = "PM_COMMAND";
  # The command to run the development server.
  devCommand = "DEV_COMMAND";
in
{
  # metadata for the template
  name = "Nuxt";
  description = "Create a Nuxt application.";
  author = "Google";
  tags = ["web", "framework", "ssr", "ssg", "typescript", "javascript"];
  icon = ./icon.png;

  # a nix expression for the development environment
  environment.dev = ./dev.nix;

  # what to do to bootstrap the project
  bootstrap = {
    args = {
      packageManager = {
        description = "The package manager to use for the project.";
        oneOf = ["npm", "yarn", "pnpm", "bun"];
        default = "npm";
      };
    };
    script = ''
      # create a .nvmrc file with a default version
      echo "20" > "$out"/.nvmrc

      # initialize the nuxt project
      echo "No" | \
      npx -y nuxi@latest init "$out" \
        --package-manager $\{packageManager\} \
        --no-install \
        --no-git \
        --force

      # copy over the .idx configuration
      mkdir "$out"/.idx
      cp $\{./dev.nix\} "$out"/.idx/dev.nix
      chmod -R +w "$out"

      #
      # Below, we are dynamically configuring the dev.nix based on the chosen package manager.
      #
      PM_COMMAND="echo 'install command is not set'"
      if [ "$\{packageManager\}" = "npm" ]; then
        PM_COMMAND="npm install"
        DEV_COMMAND="npm run dev"
      elif [ "$\{packageManager\}" = "yarn" ]; then
        PM_COMMAND="yarn"
        DEV_COMMAND="yarn dev"
      elif [ "$\{packageManager\}" = "pnpm" ]; then
        PM_COMMAND="pnpm install"
        DEV_COMMAND="pnpm run dev"
      elif [ "$\{packageManager\}" = "bun" ]; then
        PM_COMMAND="bun install"
        DEV_COMMAND="bun run dev"
      fi

      sed -i "s/PACKAGE_MANAGER/$\{packageManager\}/g" "$out"/.idx/dev.nix
      sed -i "s|PM_COMMAND|''$\{PM_COMMAND\}''|g" "$out"/.idx/dev.nix
      sed -i "s|DEV_COMMAND|''$\{DEV_COMMAND\}''|g" "$out"/.idx/dev.nix
    '';
  };
}