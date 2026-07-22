final: prev: {
  davinci-resolve-studio = prev.callPackage ./davinci-resolve/package.nix {
    studioVariant = true;
  };
}
