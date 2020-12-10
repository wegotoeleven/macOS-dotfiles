# macOS dotfiles

## Table of Contents

- [Purpose](#purpose)
- [Includes:](#includes)
  - [Included functions:](#included-functions)
- [How to contribute](#how-to-contribute)
- [Support](#support)
- [License](#license)
  
## Purpose

This is my collection of dotfiles that I use to customise my macOS terminal environment. 

## Includes:

- .profile for bash and sh
- .zshrc for zsh. I don't use tools like `ohmyzsh` as I prefer to configure my environment manually
- .vimrc for Vim configuration

With the change to the default shell in macOS Catalina, my .zshrc dotfile contains the majority of configuration as it's my promary shell.
To this end, most of my functions are contained here, and not in my .profile dotfile.

### Included functions:

- sign
- unsign
- checksign
- changemac
- makedmg
- whatismyip
- finduti
- exportcert
- generatepubkey
- expandurl
- removequarantine
- activate

## How to contribute

1. Fork this project, if required
2. Create a new branch (`git checkout -b myNewBranch`)
3. Make changes, and commit (`git commit -am "myChanges"`)
4. Push to the new branch (`git push origin myNewBranch`)
5. Create new pull request

## Support

Use at your own risk. I will accept no responsibility for loss or damage caused by these scripts.

## License

This work is licensed under http://creativecommons.org/licenses/by/4.0/.

These scripts may be freely modified for personal or commercial purposes but may not be republished for profit without prior consent.
