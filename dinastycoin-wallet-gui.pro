# qml components require at least QT 5.9.7
lessThan (QT_MAJOR_VERSION, 5) | lessThan (QT_MINOR_VERSION, 9) {
  error("Can't build with Qt $${QT_VERSION}. Use at least Qt 5.9.7")
}

TEMPLATE = app

QT += svg qml gui-private quick widgets

WALLET_ROOT=$$PWD/dinastycoin

CONFIG += c++11 link_pkgconfig
packagesExist(libusb-1.0) {
    PKGCONFIG += libusb-1.0
}
packagesExist(hidapi-libusb) {
    PKGCONFIG += hidapi-libusb
}
#!win32 {
GCC_VERSION = $$system("g++ -dumpversion")
GCC_VERSION = $$split(GCC_VERSION, .)
GCC_VERSION_MAJOR = $$member(GCC_VERSION, 0)
GCC_VERSION_MINOR = $$member(GCC_VERSION, 1)
greaterThan(GCC_VERSION_MAJOR, 9) | if(equals(GCC_VERSION_MAJOR, 9) : greaterThan(GCC_VERSION_MINOR, 0)) {
    GCC_9_1_OR_GREATER = TRUE
}

!win32 | !isEmpty(GCC_9_1_OR_GREATER) {
    QMAKE_CXXFLAGS += -fPIC -fstack-protector -fstack-protector-strong
    QMAKE_LFLAGS += -fstack-protector -fstack-protector-strong
}

!win32 {
    packagesExist(protobuf) {
        PKGCONFIG += protobuf
    }
}


# cleaning "auto-generated" bitdinastycoin directory on "make distclean"
QMAKE_DISTCLEAN += -r $$WALLET_ROOT

INCLUDEPATH +=  $$WALLET_ROOT/include \
                $$PWD/src/libwalletqt \
                $$PWD/src/QR-Code-generator \
                $$PWD/src \
                $$WALLET_ROOT/src

HEADERS += \
    filter.h \
    clipboardAdapter.h \
    oscursor.h \
    src/libwalletqt/WalletManager.h \
    src/libwalletqt/Wallet.h \
    src/libwalletqt/PendingTransaction.h \
    src/libwalletqt/TransactionHistory.h \
    src/libwalletqt/TransactionInfo.h \
    src/libwalletqt/QRCodeImageProvider.h \
    src/libwalletqt/Transfer.h \
    src/NetworkType.h \
    oshelper.h \
    TranslationManager.h \
    src/model/TransactionHistoryModel.h \
    src/model/TransactionHistorySortFilterModel.h \
    src/QR-Code-generator/BitBuffer.hpp \
    src/QR-Code-generator/QrCode.hpp \
    src/QR-Code-generator/QrSegment.hpp \
    src/model/AddressBookModel.h \
    src/libwalletqt/AddressBook.h \
    src/model/SubaddressModel.h \
    src/libwalletqt/Subaddress.h \
    src/model/SubaddressAccountModel.h \
    src/libwalletqt/SubaddressAccount.h \
    src/zxcvbn-c/zxcvbn.h \
    src/libwalletqt/UnsignedTransaction.h \
    Logger.h \
    MainApp.h \
    src/qt/FutureScheduler.h \
    src/qt/ipc.h \
    src/qt/KeysFiles.h \
    src/qt/utils.h \
    src/qt/prices.h \
    src/qt/macoshelper.h \
    src/qt/DinastycoinSettings.h \
    src/qt/TailsOS.h

SOURCES += main.cpp \
    filter.cpp \
    clipboardAdapter.cpp \
    oscursor.cpp \
    src/libwalletqt/WalletManager.cpp \
    src/libwalletqt/Wallet.cpp \
    src/libwalletqt/PendingTransaction.cpp \
    src/libwalletqt/TransactionHistory.cpp \
    src/libwalletqt/TransactionInfo.cpp \
    src/libwalletqt/QRCodeImageProvider.cpp \
    oshelper.cpp \
    TranslationManager.cpp \
    src/model/TransactionHistoryModel.cpp \
    src/model/TransactionHistorySortFilterModel.cpp \
    src/QR-Code-generator/BitBuffer.cpp \
    src/QR-Code-generator/QrCode.cpp \
    src/QR-Code-generator/QrSegment.cpp \
    src/model/AddressBookModel.cpp \
    src/libwalletqt/AddressBook.cpp \
    src/model/SubaddressModel.cpp \
    src/libwalletqt/Subaddress.cpp \
    src/model/SubaddressAccountModel.cpp \
    src/libwalletqt/SubaddressAccount.cpp \
    src/zxcvbn-c/zxcvbn.c \
    src/libwalletqt/UnsignedTransaction.cpp \
    Logger.cpp \
    MainApp.cpp \
    src/qt/FutureScheduler.cpp \
    src/qt/ipc.cpp \
    src/qt/KeysFiles.cpp \
    src/qt/utils.cpp \
    src/qt/prices.cpp \
    src/qt/DinastycoinSettings.cpp \
    src/qt/TailsOS.cpp

CONFIG(DISABLE_PASS_STRENGTH_METER) {
    HEADERS -= src/zxcvbn-c/zxcvbn.h
    SOURCES -= src/zxcvbn-c/zxcvbn.c
    DEFINES += "DISABLE_PASS_STRENGTH_METER"
}

!ios {
    HEADERS += src/daemon/DaemonManager.h
    SOURCES += src/daemon/DaemonManager.cpp
}

lupdate_only {
SOURCES = *.qml \
          components/*.qml \
          components/effects/*.qml \
          pages/*.qml \
          pages/settings/*.qml \
          pages/merchant/*.qml \
          wizard/*.qml \
          wizard/*js
}

# Linker flags required by Trezor
TREZOR_LINKER = $$cat($$WALLET_ROOT/lib/trezor_link_flags.txt)

ios:armv7 {
    message("target is armv7")
    LIBS += \
        -L$$PWD/../ofxiOSBoost/build/libs/boost/lib/armv7 \
}
ios:arm64 {
    message("target is arm64")
    LIBS += \
        -L$$PWD/../ofxiOSBoost/build/libs/boost/lib/arm64 \
}

LIBS_COMMON = \
    -lwallet_merged \
    -llmdb \
    -lepee \
    -lunbound \
    -lsodium \
    -leasylogging \
    -lrandomx

!ios:!android {
    LIBS += -L$$WALLET_ROOT/lib \
        $$LIBS_COMMON
}

android {
    message("Host is Android")
    LIBS += -L$$WALLET_ROOT/lib \
        $$LIBS_COMMON
}



QMAKE_CXXFLAGS += -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1 -Wformat -Wformat-security
QMAKE_CFLAGS += -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1 -Wformat -Wformat-security

ios {
    message("Host is IOS")

    QMAKE_LFLAGS += -v
    QMAKE_IOS_DEVICE_ARCHS = arm64
    CONFIG += arm64
    LIBS += -L$$WALLET_ROOT/lib-ios \
        $$LIBS_COMMON

    LIBS+= \
        -L$$PWD/../OpenSSL-for-iPhone/lib \
        -L$$PWD/../ofxiOSBoost/build/libs/boost/lib/arm64 \
        -lboost_serialization \
        -lboost_thread \
        -lboost_system \
        -lboost_date_time \
        -lboost_filesystem \
        -lboost_regex \
        -lboost_chrono \
        -lboost_program_options \
        -lssl \
        -lcrypto \
        -ldl
}

CONFIG(WITH_SCANNER) {
    if( greaterThan(QT_MINOR_VERSION, 5) ) {
        message("using camera scanner")
        QT += multimedia
        DEFINES += "WITH_SCANNER"
        INCLUDEPATH += $$PWD/src/QR-Code-scanner
        HEADERS += \
            src/QR-Code-scanner/QrScanThread.h \
            src/QR-Code-scanner/QrCodeScanner.h
        SOURCES += \
            src/QR-Code-scanner/QrScanThread.cpp \
            src/QR-Code-scanner/QrCodeScanner.cpp
        android {
            INCLUDEPATH += $$PWD/../ZBar/include
            LIBS += -lzbarjni -liconv
        } else {
            LIBS += -lzbar
        }
    } else {
        message("Skipping camera scanner because of Incompatible Qt Version !")
    }
}


# currently we only support x86 build as qt.io only provides prebuilt qt for x86 mingw

win32 {

    # QMAKE_HOST.arch is unreliable, will allways report 32bit if mingw32 shell is run.
    # Obtaining arch through uname should be reliable. This also fixes building the project in Qt creator without changes.
    MSYS_HOST_ARCH = $$system(uname -a | grep -o "x86_64")

    # WIN64 Host settings
    contains(MSYS_HOST_ARCH, x86_64) {
        message("Host is 64bit")
        MSYS_ROOT_PATH=c:/msys64

    # WIN32 Host settings
    } else {
        message("Host is 32bit")
        MSYS_ROOT_PATH=c:/msys32
    }

    # WIN64 Target settings
    contains(QMAKE_HOST.arch, x86_64) {
        MSYS_MINGW_PATH=/mingw64

    # WIN32 Target settings
    } else {
        MSYS_MINGW_PATH=/mingw32
    }
    
    MSYS_PATH=$$MSYS_ROOT_PATH$$MSYS_MINGW_PATH

    # boost root path
    BOOST_PATH=$$MSYS_PATH/boost
    BOOST_MINGW_PATH=$$MSYS_MINGW_PATH/boost

    LIBS+=-L$$MSYS_PATH/lib
    LIBS+=-L$$MSYS_MINGW_PATH/lib
    LIBS+=-L$$BOOST_PATH/lib
    LIBS+=-L$$BOOST_MINGW_PATH/lib
    
    QMAKE_LFLAGS += -static-libgcc -static-libstdc++

    LIBS+= \
        -Wl,-Bdynamic \
        -lwinscard \
        -lwsock32 \
        -lIphlpapi \
        -lcrypt32 \
        -lhidapi \
        -lgdi32 $$TREZOR_LINKER \
        -Wl,-Bstatic \
        -lboost_serialization-mt \
        -lboost_thread-mt \
        -lboost_system-mt \
        -lboost_date_time-mt \
        -lboost_filesystem-mt \
        -lboost_regex-mt \
        -lboost_chrono-mt \
        -lboost_program_options-mt \
        -lboost_locale-mt \
        -licuio \
        -licuin \
        -licuuc \
        -licudt \
        -licutu \
        -liconv \
        -lstdc++ \
        -lpthread \
        -lsetupapi \
        -lssl \
        -lsodium \
        -lcrypto \
        -lws2_32
    
    !contains(QMAKE_TARGET.arch, x86_64) {
        message("Target is 32bit")
        ## Windows x86 (32bit) specific build here
        ## there's 2Mb stack in libwallet allocated internally, so we set stack=4Mb
        ## this fixes app crash for x86 Windows build
        QMAKE_LFLAGS += -Wl,--stack,4194304
    } else {
        message("Target is 64bit")
    }

    QMAKE_LFLAGS += -Wl,--dynamicbase -Wl,--nxcompat
}

linux {
    CONFIG(static) {
        message("using static libraries")
        LIBS+= -Wl,-Bstatic    
        QMAKE_LFLAGS += -static-libgcc -static-libstdc++
        QMAKE_LIBDIR += /usr/local/ssl/lib
   #     contains(QT_ARCH, x86_64) {
            LIBS+= -lunbound \
                   -lusb-1.0 \
                   -lhidapi-hidraw \
                   -ludev
   #     }
    } else {
      # On some distro's we need to add dynload
      LIBS+= -ldl
    }

    LIBS+= \
        -lboost_serialization \
        -lboost_thread \
        -lboost_system \
        -lboost_date_time \
        -lboost_filesystem \
        -lboost_regex \
        -lboost_chrono \
        -lboost_program_options \
        -lssl \
        -llmdb \
        -lsodium \
        -lhidapi-libusb \
        -lcrypto $$TREZOR_LINKER

    if(!android) {
        LIBS+= \
            -Wl,-Bdynamic \
            -lGL \
            -lX11
    }
    # currently dinastycoin has an issue with "static" build and linunwind-dev,
    # so we link libunwind-dev only for non-Ubuntu distros
    CONFIG(libunwind_off) {
        message(Building without libunwind)
    } else {
        message(Building with libunwind)
        LIBS += -Wl,-Bdynamic -lunwind
    }

    QMAKE_LFLAGS += -pie -Wl,-z,relro -Wl,-z,now -Wl,-z,noexecstack
}

macx {
    # mixing static and shared libs are not supported on mac
    # CONFIG(static) {
    #     message("using static libraries")
    #     LIBS+= -Wl,-Bstatic
    # }
    QT += macextras
    OBJECTIVE_SOURCES += src/qt/macoshelper.mm
    LIBS+= \
        -L/usr/local/lib \
        -L/usr/local/opt/openssl/lib \
        -L/usr/local/opt/boost/lib \
        -lboost_serialization \
        -lboost_thread-mt \
        -lboost_system \
        -lboost_date_time \
        -lboost_filesystem \
        -lboost_regex \
        -lboost_chrono \
        -lboost_program_options \
        -framework CoreFoundation \
        -framework AppKit \
        -lhidapi \
        -lssl \
        -lsodium \
        -lcrypto \
        -ldl $$TREZOR_LINKER

    QMAKE_LFLAGS += -pie
}


# translation stuff
TRANSLATIONS = $$files($$PWD/translations/dinastycoin-core_*.ts)

CONFIG(release, debug|release) {
    DESTDIR = release/bin
    LANGUPD_OPTIONS = -locations none -no-ui-lines -no-obsolete
    LANGREL_OPTIONS = -compress -nounfinished -removeidentical

} else {
    DESTDIR = debug/bin
    LANGUPD_OPTIONS =
#    LANGREL_OPTIONS = -markuntranslated "MISS_TR "
}

TRANSLATION_TARGET_DIR = $$OUT_PWD/translations

!ios {
    isEmpty(QMAKE_LUPDATE) {
        win32:LANGUPD = $$[QT_INSTALL_BINS]\lupdate.exe
        else:LANGUPD = $$[QT_INSTALL_BINS]/lupdate
    }

    isEmpty(QMAKE_LRELEASE) {
        win32:LANGREL = $$[QT_INSTALL_BINS]\lrelease.exe
        else:LANGREL = $$[QT_INSTALL_BINS]/lrelease
    }

    langupd.command = \
        $$LANGUPD $$LANGUPD_OPTIONS $$shell_path($$_PRO_FILE) -ts $$_PRO_FILE_PWD/$$TRANSLATIONS



    langrel.depends = langupd
    langrel.input = TRANSLATIONS
    langrel.output = $$TRANSLATION_TARGET_DIR/${QMAKE_FILE_BASE}.qm
    langrel.commands = \
        $$LANGREL $$LANGREL_OPTIONS ${QMAKE_FILE_IN} -qm $$TRANSLATION_TARGET_DIR/${QMAKE_FILE_BASE}.qm
    langrel.CONFIG += no_link

    QMAKE_EXTRA_TARGETS += langupd deploy deploy_win
    QMAKE_EXTRA_COMPILERS += langrel

    # Compile an initial version of translation files when running qmake
    # the first time and generate the resource file for translations.
    !exists($$TRANSLATION_TARGET_DIR) {
        mkpath($$TRANSLATION_TARGET_DIR)
    }
    qrc_entry = "<RCC>"
    qrc_entry += '  <qresource prefix="/">'
    write_file($$TRANSLATION_TARGET_DIR/translations.qrc, qrc_entry)
    for(tsfile, TRANSLATIONS) {
        qmfile = $$TRANSLATION_TARGET_DIR/$$basename(tsfile)
        qmfile ~= s/.ts$/.qm/
        system($$LANGREL $$LANGREL_OPTIONS $$tsfile -qm $$qmfile)
        qrc_entry = "    <file>$$basename(qmfile)</file>"
        write_file($$TRANSLATION_TARGET_DIR/translations.qrc, qrc_entry, append)
    }
    qrc_entry = "  </qresource>"
    qrc_entry += "</RCC>"
    write_file($$TRANSLATION_TARGET_DIR/translations.qrc, qrc_entry, append)
    RESOURCES += $$TRANSLATION_TARGET_DIR/translations.qrc
}


# Update: no issues with the "slow link process" anymore,
# for development, just build debug version of libwallet_merged lib
# by invoking 'get_libwallet_api.sh Debug'
# so we update translations everytime even for debug build

PRE_TARGETDEPS += langupd compiler_langrel_make_all

RESOURCES += qml.qrc
CONFIG += qtquickcompiler

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH = fonts

# Default rules for deployment.
include(deployment.pri)
macx {
    deploy.commands += macdeployqt $$sprintf("%1/%2/%3.app", $$OUT_PWD, $$DESTDIR, $$TARGET) -qmldir=$$PWD
}

win32 {
    deploy.commands += windeployqt $$sprintf("%1/%2/%3.exe", $$OUT_PWD, $$DESTDIR, $$TARGET) -release -no-translations -qmldir=$$PWD
    # Win64 msys2 deploy settings
    contains(QMAKE_HOST.arch, x86_64) {
        deploy.commands += $$escape_expand(\n\t) $$PWD/windeploy_helper.sh $$DESTDIR
    }
}

linux:!android {
    deploy.commands += $$escape_expand(\n\t) $$PWD/linuxdeploy_helper.sh $$DESTDIR $$TARGET
}

android{
    deploy.commands += make install INSTALL_ROOT=$$DESTDIR && androiddeployqt --input android-libdinastycoin-wallet-gui.so-deployment-settings.json --output $$DESTDIR --deployment bundled --android-platform android-21 --jdk /usr/lib/jvm/java-8-openjdk-amd64 -qmldir=$$PWD
}


OTHER_FILES += \
    .gitignore \
    $$TRANSLATIONS

DISTFILES += \
    notes.txt \
    dinastycoin/src/wallet/CMakeLists.txt


# windows application icon
RC_ICONS = images/appicon.ico

# mac Info.plist & application icon
QMAKE_INFO_PLIST = $$PWD/share/Info.plist
ICON = $$PWD/images/appicon.icns
