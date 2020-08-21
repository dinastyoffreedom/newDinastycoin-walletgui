# Dinastycoin GUI

Parts are Copyright (c) 2019, The Dinastycoin team

## Development resources

- Web: [dinastycoin.com](https://dinastycoin.com)
- Mail: [admin@dinastycoin.com](mailto:admin@dinastycoin.com)
- Github: [https://github.com/dinastyoffreedom/dinastycoin-gui](https://github.com/dinastyoffreedom/newDinastycoin-walletgui)

## Introduction

Dinastycoin is a private, secure, untraceable, decentralised digital currency. You are your bank, you control your funds, and nobody can trace your transfers unless you allow them to do so.

**Privacy:** Dinastycoin uses a cryptographically sound system to allow you to send and receive funds without your transactions being easily revealed on the blockchain (the ledger of transactions that everyone has). This ensures that your purchases, receipts, and all transfers remain absolutely private by default.

**Security:** Using the power of a distributed peer-to-peer consensus network, every transaction on the network is cryptographically secured. Individual wallets have a 25 word mnemonic seed that is only displayed once, and can be written down to backup the wallet. Wallet files are encrypted with a passphrase to ensure they are useless if stolen.

**Untraceability:** By taking advantage of ring signatures, a special property of a certain type of cryptography, Dinastycoin is able to ensure that transactions are not only untraceable, but have an optional measure of ambiguity that ensures that transactions cannot easily be tied back to an individual user or computer.

## About this project

This is the GUI for the [core Dinastycoin implementation](https://github.com/dinastyoffreedom/newdinasty). It is open source and completely free to use without restrictions, except for those specified in the license agreement below. There are no restrictions on anyone creating an alternative implementation of Dinastycoin that uses the protocol and network in a compatible manner.

As with many development projects, the repository on Github is considered to be the "staging" area for the latest changes. Before changes are merged into that branch on the main repository, they are tested by individual developers in their own branches, submitted as a pull request, and then subsequently tested by contributors who focus on testing and code reviews. That having been said, the repository should be carefully considered before using it in a production environment, unless there is a patch in the repository for a particular show-stopping issue you are experiencing. It is generally a better idea to use a tagged release for stability.

## Supporting the project

Dinastycoin is a 100% community-sponsored endeavor. If you want to join our efforts, the easiest thing you can do is support the project financially. Both Dinastycoin and Bitcoin donations can be made to **donate.dinastycoin.com** if using a client that supports the [OpenAlias](https://openalias.org) standard.

The Dinastycoin donation address is: `NYz4mXJcoxV9TNiymiSYxu62qKu7bjTgDZWJjvMUKVPvZ1VGEW6VrNxh8WJjddi7Hr56MYbyK2Hp6CWZ2Uyfat9V5Lhvz2BAJe` 

The Bitcoin donation address is: `3D2iF1uccLmdeKErB2N1Rtd7N2HdRWrjdm`

GUI development funding and/or some supporting services are also graciously provided by sponsors:

There are also several mining pools that kindly donate a portion of their fees, [a list of them can be found on our Bitcointalk post](https://bitcointalk.org/index.php?topic=583449.0).

## License

See [LICENSE](LICENSE).

## Translations

Do you speak a second language and would like to help translate the Dinastycoin GUI? Check out Pootle, our localization platform, at [translate.dinastycoin.com](https://translate.dinastycoin.com/projects/dinastycoin-gui/). Choose the language and suggest a translation for a string or review an existing one. The Localization Workgroup made [a guide with step-by-step instructions](https://github.com/dinastycoin-ecosystem/dinastycoin-translations/blob/master/pootle.md) for Pootle.
&nbsp;

If you need help/support or any info you can contact the localization workgroup on the IRC channel #dinastycoin-translations (relayed on matrix/riot and MatterMost) or by email at translate[at]getdinastycoin[dot]org. For more info about the Localization workgroup: [github.com/dinastycoin-ecosystem/dinastycoin-translations](https://github.com/dinastycoin-ecosystem/dinastycoin-translations)


## Compiling the Dinastycoin GUI from source

### On Linux:

(Tested on Ubuntu 17.10 x64, Ubuntu 18.04 x64 and Gentoo x64)

1. Install Dinastycoin dependencies

  - For Debian distributions (Debian, Ubuntu, Mint, Tails...)

	`sudo apt install build-essential cmake libboost-all-dev miniupnpc libunbound-dev graphviz doxygen libunwind8-dev pkg-config libssl-dev libzmq3-dev libsodium-dev libhidapi-dev libnorm-dev libusb-1.0-0-dev libpgm-dev`

  - For Gentoo

	`sudo emerge app-arch/xz-utils app-doc/doxygen dev-cpp/gtest dev-libs/boost dev-libs/expat dev-libs/openssl dev-util/cmake media-gfx/graphviz net-dns/unbound net-libs/ldns net-libs/miniupnpc net-libs/zeromq sys-libs/libunwind dev-libs/libsodium dev-libs/hidapi`

  - For Fedora

	`sudo dnf install make automake cmake gcc-c++ boost-devel miniupnpc-devel graphviz doxygen unbound-devel libunwind-devel pkgconfig openssl-devel libcurl-devel hidapi-devel libusb-devel zeromq-devel`

2. Install Qt:

  *Note*: The Qt 5.9.7 or newer requirement makes **some** distributions (mostly based on debian, like Ubuntu 16.x or Linux Mint 18.x) obsolete due to their repositories containing an older Qt version.

 The recommended way is to install 5.9.7 from the [official Qt installer](https://www.qt.io/download-qt-installer) or [compiling it yourself](https://wiki.qt.io/Install_Qt_5_on_Ubuntu). This ensures you have the correct version. Higher versions *can* work but as it differs from our production build target, slight differences may occur.

The following instructions will fetch Qt from your distribution's repositories instead (prefer this option on ubuntu 20.04+). Take note of what version it installs. Your mileage may vary.

  - For Ubuntu 17.10+

    `sudo apt install qtbase5-dev qt5-default qtdeclarative5-dev qml-module-qtquick-controls qml-module-qtquick-controls2 qml-module-qtquick-dialogs qml-module-qtquick-xmllistmodel qml-module-qt-labs-settings qml-module-qt-labs-folderlistmodel qttools5-dev-tools qml-module-qtquick-templates2 libqt5svg5-dev`

  - For Gentoo

    `sudo emerge dev-qt/qtcore:5 dev-qt/qtdeclarative:5 dev-qt/qtquickcontrols:5 dev-qt/qtquickcontrols2:5 dev-qt/qtgraphicaleffects:5`

  - Optional : To build the flag `WITH_SCANNER`

    - For Ubuntu

      `sudo apt install qtmultimedia5-dev qml-module-qtmultimedia libzbar-dev`

    - For Gentoo

      The *qml* USE flag must be enabled.

      `emerge dev-qt/qtmultimedia:5 media-gfx/zbar`


3. Clone repository

    `git clone https://github.com/dinastyoffreedom/newDinastycoin-walletgui.git`
    
4. Make all .sh files executable
    ```
    chmod u+x newDinastycoin-walletgui/*.sh

    ```
5. Build

    ```
    cd newDinastycoin-walletgui/ && QT_SELECT=5 ./build.sh
    ```

6. The executable can be found in the build/release/bin folder:

    ```
    ~/newDinastycoin-walletgui/build/release/bin/dinastycoin-wallet-gui
    
    ```
    
### On OS X:

1. Install Xcode from AppStore

2. Install [homebrew](http://brew.sh/)

3. Install [dinastycoin](https://github.com/dinastyoffreedom/newdinastycoin) dependencies:

  `brew install boost`

  `brew install openssl` - to install openssl headers

  `brew install pkgconfig`

  `brew install cmake`

  `brew install zeromq`

  *Note*: If cmake can not find zmq.hpp file on OS X, installing `zmq.hpp` from https://github.com/zeromq/cppzmq to `/usr/local/include` should fix that error.

4. Install Qt:

  `brew install qt5`  (or download QT 5.9.7+ from [qt.io](https://www.qt.io/download-open-source/))

  If you have an older version of Qt installed via homebrew, you can force it to use 5.x like so:
  
  `brew link --force --overwrite qt5`

5. Add the Qt bin directory to your path

  - Example for Qt: `export PATH=$PATH:$HOME/Qt/5.9.7/clang_64/bin`
  - Example for Homebrew: `export PATH=$PATH:/usr/local/opt/qt/bin`

6. Grab an up-to-date copy of the dinastycoin-gui repository

  `git clone https://github.com/dinastyoffreedom/newDinastycoin-walletgui.git`

7. Go into the repository

  `cd dinastycoin-gui`

8. Start the build

  `./build.sh`

The executable can be found in the `build/release/bin` folder.

**Note:** Workaround for "ERROR: Xcode not set up properly"

Edit `$HOME/Qt/5.9.7/clang_64/mkspecs/features/mac/default_pre.prf`

replace
`isEmpty($$list($$system("/usr/bin/xcrun -find xcrun 2>/dev/null")))`

with
`isEmpty($$list($$system("/usr/bin/xcrun -find xcodebuild 2>/dev/null")))`

More info: http://stackoverflow.com/a/35098040/1683164


### On Windows:

The Dinastycoin GUI on Windows is 64 bits only; 32-bit Windows GUI builds are not officially supported anymore.

1. Install [MSYS2](https://www.msys2.org/), follow the instructions on that page on how to update system and packages to the latest versions

2. Open an 64-bit MSYS2 shell: Use the *MSYS2 MinGW 64-bit* shortcut, or use the `msys2_shell.cmd` batch file with a `-mingw64` parameter

3. Install MSYS2 packages for Dinastycoin dependencies; the needed 64-bit packages have `x86_64` in their names

    ```
    pacman -S mingw-w64-x86_64-toolchain make mingw-w64-x86_64-cmake mingw-w64-x86_64-boost mingw-w64-x86_64-openssl mingw-w64-x86_64-zeromq mingw-w64-x86_64-libsodium mingw-w64-x86_64-hidapi mingw-w64-x86_64-protobuf-c mingw-w64-x86_64-libusb
    ```

    Optional : To build the flag `WITH_SCANNER`

      ```
      pacman -S mingw-w64-x86_64-zbar
      ```

    You find more details about those dependencies in the [Dinastycoin documentation](https://github.com/dinastyoffreedom/newdinastycoin). Note that that there is no more need to compile Boost from source; like everything else, you can install it now with a MSYS2 package.

4. Install Qt5

    ```
    pacman -S mingw-w64-x86_64-qt5
    ```

    There is no more need to download some special installer from the Qt website, the standard MSYS2 package for Qt will do in almost all circumstances.

5. Install git

    ```
    pacman -S git
    ```

6. Clone repository

    ```
    git clone https://github.com/dinastyoffreedom/newDinastycoin-walletgui.git
    ```

7. Build

    ```
    cd dinastycoin-gui
    source ./build.sh release-static
    cd build
    make deploy
    ```

    **Note:** The use of `source` above is a dirty workaround for a suspected bug in the current QT version 5.11.2-3 available in the MSYS2 packaging system, see https://github.com/dinastyoffreedom/newDinastycoin-walletgui/issues/1559 for more info.

The executable can be found in the `.\release\bin` directory.
