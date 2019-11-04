// Copyright (c) 2014-2018, The Dinastycoin Project
// 
// All rights reserved.
// 
// Redistribution and use in source and binary forms, with or without modification, are
// permitted provided that the following conditions are met:
// 
// 1. Redistributions of source code must retain the above copyright notice, this list of
//    conditions and the following disclaimer.
// 
// 2. Redistributions in binary form must reproduce the above copyright notice, this list
//    of conditions and the following disclaimer in the documentation and/or other
//    materials provided with the distribution.
// 
// 3. Neither the name of the copyright holder nor the names of its contributors may be
//    used to endorse or promote products derived from this software without specific
//    prior written permission.
// 
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
// MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL
// THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
// STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF
// THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QtQml>
#include <QStandardPaths>
#include <QNetworkAccessManager>
#include <QIcon>
#include <QDebug>
#include <QDesktopServices>
#include <QObject>
#include <QDesktopWidget>
#include <QScreen>
#include <QRegExp>
#include <QThread>
#include "clipboardAdapter.h"
#include "filter.h"
#include "oscursor.h"
#include "oshelper.h"
#include "WalletManager.h"
#include "Wallet.h"
#include "QRCodeImageProvider.h"
#include "PendingTransaction.h"
#include "UnsignedTransaction.h"
#include "TranslationManager.h"
#include "TransactionInfo.h"
#include "TransactionHistory.h"
#include "model/TransactionHistoryModel.h"
#include "model/TransactionHistorySortFilterModel.h"
#include "AddressBook.h"
#include "model/AddressBookModel.h"
#include "Subaddress.h"
#include "model/SubaddressModel.h"
#include "SubaddressAccount.h"
#include "model/SubaddressAccountModel.h"
#include "wallet/api/wallet2_api.h"
#include "Logger.h"
#include "MainApp.h"
#include "qt/ipc.h"
#include "qt/utils.h"
#include "src/qt/TailsOS.h"
#include "src/qt/KeysFiles.h"
#include "src/qt/DinastycoinSettings.h"
#include "qt/prices.h"

// IOS exclusions
#ifndef Q_OS_IOS
#include "daemon/DaemonManager.h"
#endif

#ifdef WITH_SCANNER
#include "QrCodeScanner.h"
#endif

bool isIOS = false;
bool isAndroid = false;
bool isWindows = false;
bool isMac = false;
bool isLinux = false;
bool isTails = false;
bool isDesktop = false;
bool isOpenGL = true;

int main(int argc, char *argv[])
{
    // platform dependant settings
#if !defined(Q_OS_ANDROID) && !defined(Q_OS_IOS)
    bool isDesktop = true;
#elif defined(Q_OS_LINUX)
    bool isLinux = true;
#elif defined(Q_OS_ANDROID)
    bool isAndroid = true;
#elif defined(Q_OS_IOS)
    bool isIOS = true;
#endif
#ifdef Q_OS_WIN
    bool isWindows = true;
#elif defined(Q_OS_LINUX)
    bool isLinux = true;
    bool isTails = TailsOS::detect();
#elif defined(Q_OS_MAC)
    bool isMac = true;
#endif

    // detect low graphics mode (start-low-graphics-mode.bat)
    if(qgetenv("QMLSCENE_DEVICE") == "softwarecontext")
        isOpenGL = false;

    // disable "QApplication: invalid style override passed" warning
    if (isDesktop) putenv((char*)"QT_STYLE_OVERRIDE=fusion");
#ifdef Q_OS_LINUX
    // force platform xcb
    if (isDesktop) putenv((char*)"QT_QPA_PLATFORM=xcb");
#endif

//    // Enable high DPI scaling on windows & linux
//#if !defined(Q_OS_ANDROID) && QT_VERSION >= 0x050600
//    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
//    qDebug() << "High DPI auto scaling - enabled";
//#endif

    // Turn off colors in dinastycoind log output.
    qputenv("TERM", "goaway");

    MainApp app(argc, argv);

    app.setApplicationName("dinastycoin-core");
    app.setOrganizationDomain("dinastycoin.com");
    app.setOrganizationName("dinastycoin-project");

    // Ask to enable Tails OS persistence mode, it affects:
    // - Log file location
    // - QML Settings file location (dinastycoin-core.conf)
    // - Default wallets path
    // Target directory is: ~/Persistent/Dinastycoin
    if (isTails) {
        if (!TailsOS::detectDataPersistence())
            TailsOS::showDataPersistenceDisabledWarning();
        else
            TailsOS::askPersistence();
    }

    QString dinastycoinAccountsDir;
    #if defined(Q_OS_WIN) || defined(Q_OS_IOS)
        QStringList dinastycoinAccountsRootDir = QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation);
    #else
        QStringList dinastycoinAccountsRootDir = QStandardPaths::standardLocations(QStandardPaths::HomeLocation);
    #endif

    if(isTails && TailsOS::usePersistence){
        dinastycoinAccountsDir = QDir::homePath() + "/Persistent/Dinastycoin/wallets";
    } else if (!dinastycoinAccountsRootDir.empty()) {
        dinastycoinAccountsDir = dinastycoinAccountsRootDir.at(0) + "/Dinastycoin/wallets";
    } else {
        qCritical() << "Error: accounts root directory could not be set";
        return 1;
    }

#if defined(Q_OS_LINUX)
    if (isDesktop) app.setWindowIcon(QIcon(":/images/appicon.ico"));
#endif

    filter *eventFilter = new filter;
    app.installEventFilter(eventFilter);

    QCommandLineParser parser;
    QCommandLineOption logPathOption(QStringList() << "l" << "log-file",
        QCoreApplication::translate("main", "Log to specified file"),
        QCoreApplication::translate("main", "file"));

    parser.addOption(logPathOption);
    parser.addHelpOption();
    parser.process(app);

    Dinastycoin::Utils::onStartup();

    // Log settings
    const QString logPath = getLogPath(parser.value(logPathOption));
    Dinastycoin::Wallet::init(argv[0], "dinastycoin-wallet-gui", logPath.toStdString().c_str(), true);
    qInstallMessageHandler(messageHandler);

    // loglevel is configured in main.qml. Anything lower than
    // qWarning is not shown here unless DINASTYCOIN_LOG_LEVEL env var is set
    bool logLevelOk;
    int logLevel = qEnvironmentVariableIntValue("DINASTYCOIN_LOG_LEVEL", &logLevelOk);
    if (logLevelOk && logLevel >= 0 && logLevel <= Dinastycoin::WalletManagerFactory::LogLevel_Max){
        Dinastycoin::WalletManagerFactory::setLogLevel(logLevel);
    }
    qWarning().noquote() << "app startd" << "(log: " + logPath + ")";

    // Desktop entry
#ifdef Q_OS_LINUX
    registerXdgMime(app);
#endif

    IPC *ipc = new IPC(&app);
    QStringList posArgs = parser.positionalArguments();

    for(int i = 0; i != posArgs.count(); i++){
        QString arg = QString(posArgs.at(i));
        if(arg.isEmpty() || arg.length() >= 512) continue;
        if(arg.contains(reURI)){
            if(!ipc->saveCommand(arg)){
                return 0;
            }
        }
    }

    // start listening
    QTimer::singleShot(0, ipc, SLOT(bind()));

    // screen settings
    // Mobile is designed on 128dpi
    qreal ref_dpi = 128;
    QRect geo = QApplication::desktop()->availableGeometry();
    QRect rect = QGuiApplication::primaryScreen()->geometry();
    qreal dpi = QGuiApplication::primaryScreen()->logicalDotsPerInch();
    qreal physicalDpi = QGuiApplication::primaryScreen()->physicalDotsPerInch();
    qreal calculated_ratio = physicalDpi/ref_dpi;

    QString GUI_VERSION = "-";
    QFile f(":/version.js");
    if(!f.open(QFile::ReadOnly)) {
        qWarning() << "Could not read qrc:///version.js";
    } else {
        QByteArray contents = f.readAll();
        f.close();

        QRegularExpression re("var GUI_VERSION = \"(.*)\"");
        QRegularExpressionMatch version_match = re.match(contents);
        if (version_match.hasMatch()) {
            GUI_VERSION = version_match.captured(1);  // "v0.13.0.3"
        }
    }

    qWarning().nospace().noquote() << "Qt:" << QT_VERSION_STR << " GUI:" << GUI_VERSION
                                   << " | screen: " << rect.width() << "x" << rect.height()
                                   << " - dpi: " << dpi << " - ratio:" << calculated_ratio;

    // registering types for QML
    qmlRegisterType<clipboardAdapter>("dinastycoinComponents.Clipboard", 1, 0, "Clipboard");

    // Temporary Qt.labs.settings replacement
    qmlRegisterType<DinastycoinSettings>("dinastycoinComponents.Settings", 1, 0, "DinastycoinSettings");

    qmlRegisterUncreatableType<Wallet>("dinastycoinComponents.Wallet", 1, 0, "Wallet", "Wallet can't be instantiated directly");


    qmlRegisterUncreatableType<PendingTransaction>("dinastycoinComponents.PendingTransaction", 1, 0, "PendingTransaction",
                                                   "PendingTransaction can't be instantiated directly");

    qmlRegisterUncreatableType<UnsignedTransaction>("dinastycoinComponents.UnsignedTransaction", 1, 0, "UnsignedTransaction",
                                                   "UnsignedTransaction can't be instantiated directly");

    qmlRegisterUncreatableType<WalletManager>("dinastycoinComponents.WalletManager", 1, 0, "WalletManager",
                                                   "WalletManager can't be instantiated directly");

    qmlRegisterUncreatableType<TranslationManager>("dinastycoinComponents.TranslationManager", 1, 0, "TranslationManager",
                                                   "TranslationManager can't be instantiated directly");

    qmlRegisterUncreatableType<WalletKeysFilesModel>("dinastycoinComponents.walletKeysFilesModel", 1, 0, "WalletKeysFilesModel",
                                                   "walletKeysFilesModel can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionHistoryModel>("dinastycoinComponents.TransactionHistoryModel", 1, 0, "TransactionHistoryModel",
                                                        "TransactionHistoryModel can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionHistorySortFilterModel>("dinastycoinComponents.TransactionHistorySortFilterModel", 1, 0, "TransactionHistorySortFilterModel",
                                                        "TransactionHistorySortFilterModel can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionHistory>("dinastycoinComponents.TransactionHistory", 1, 0, "TransactionHistory",
                                                        "TransactionHistory can't be instantiated directly");

    qmlRegisterUncreatableType<TransactionInfo>("dinastycoinComponents.TransactionInfo", 1, 0, "TransactionInfo",
                                                        "TransactionHistory can't be instantiated directly");
#ifndef Q_OS_IOS
    qmlRegisterUncreatableType<DaemonManager>("dinastycoinComponents.DaemonManager", 1, 0, "DaemonManager",
                                                   "DaemonManager can't be instantiated directly");
#endif
    qmlRegisterUncreatableType<AddressBookModel>("dinastycoinComponents.AddressBookModel", 1, 0, "AddressBookModel",
                                                        "AddressBookModel can't be instantiated directly");

    qmlRegisterUncreatableType<AddressBook>("dinastycoinComponents.AddressBook", 1, 0, "AddressBook",
                                                        "AddressBook can't be instantiated directly");

    qmlRegisterUncreatableType<SubaddressModel>("dinastycoinComponents.SubaddressModel", 1, 0, "SubaddressModel",
                                                        "SubaddressModel can't be instantiated directly");

    qmlRegisterUncreatableType<Subaddress>("dinastycoinComponents.Subaddress", 1, 0, "Subaddress",
                                                        "Subaddress can't be instantiated directly");

    qmlRegisterUncreatableType<SubaddressAccountModel>("dinastycoinComponents.SubaddressAccountModel", 1, 0, "SubaddressAccountModel",
                                                        "SubaddressAccountModel can't be instantiated directly");

    qmlRegisterUncreatableType<SubaddressAccount>("dinastycoinComponents.SubaddressAccount", 1, 0, "SubaddressAccount",
                                                        "SubaddressAccount can't be instantiated directly");

    qRegisterMetaType<PendingTransaction::Priority>();
    qRegisterMetaType<TransactionInfo::Direction>();
    qRegisterMetaType<TransactionHistoryModel::TransactionInfoRole>();

    qRegisterMetaType<NetworkType::Type>();
    qmlRegisterType<NetworkType>("dinastycoinComponents.NetworkType", 1, 0, "NetworkType");

#ifdef WITH_SCANNER
    qmlRegisterType<QrCodeScanner>("dinastycoinComponents.QRCodeScanner", 1, 0, "QRCodeScanner");
#endif

    QQmlApplicationEngine engine;

    OSCursor cursor;
    engine.rootContext()->setContextProperty("globalCursor", &cursor);
    OSHelper osHelper;
    engine.rootContext()->setContextProperty("oshelper", &osHelper);

    engine.addImportPath(":/fonts");

    engine.rootContext()->setContextProperty("dinastycoinAccountsDir", dinastycoinAccountsDir);

    WalletManager *walletManager = WalletManager::instance();

    engine.rootContext()->setContextProperty("walletManager", walletManager);

    engine.rootContext()->setContextProperty("translationManager", TranslationManager::instance());

    engine.addImageProvider(QLatin1String("qrcode"), new QRCodeImageProvider());

    engine.rootContext()->setContextProperty("mainApp", &app);

    engine.rootContext()->setContextProperty("IPC", ipc);

    engine.rootContext()->setContextProperty("qtRuntimeVersion", qVersion());

    engine.rootContext()->setContextProperty("walletLogPath", logPath);

    engine.rootContext()->setContextProperty("tailsUsePersistence", TailsOS::usePersistence);

// Exclude daemon manager from IOS
#ifndef Q_OS_IOS
    const QStringList arguments = (QStringList) QCoreApplication::arguments().at(0);
    DaemonManager * daemonManager = DaemonManager::instance(&arguments);
    engine.rootContext()->setContextProperty("daemonManager", daemonManager);
#endif

    engine.rootContext()->setContextProperty("isWindows", isWindows);
    engine.rootContext()->setContextProperty("isMac", isMac);
    engine.rootContext()->setContextProperty("isLinux", isLinux);
    engine.rootContext()->setContextProperty("isIOS", isIOS);
    engine.rootContext()->setContextProperty("isAndroid", isAndroid);
    engine.rootContext()->setContextProperty("isOpenGL", isOpenGL);
    engine.rootContext()->setContextProperty("isTails", isTails);

    engine.rootContext()->setContextProperty("screenWidth", geo.width());
    engine.rootContext()->setContextProperty("screenHeight", geo.height());

#ifndef Q_OS_IOS
    const QString desktopFolder = QStandardPaths::writableLocation(QStandardPaths::DesktopLocation);
    if (!desktopFolder.isEmpty())
        engine.rootContext()->setContextProperty("desktopFolder", desktopFolder);
#endif

    // Wallet .keys files model (wizard -> open wallet)
    WalletKeysFilesModel walletKeysFilesModel(walletManager);
    engine.rootContext()->setContextProperty("walletKeysFilesModel", &walletKeysFilesModel);
    engine.rootContext()->setContextProperty("walletKeysFilesModelProxy", &walletKeysFilesModel.proxyModel());

    // Get default account name
    QString accountName = qgetenv("USER"); // mac/linux
    if (accountName.isEmpty())
        accountName = qgetenv("USERNAME"); // Windows
    if (accountName.isEmpty())
        accountName = "My dinastycoin Account";

    engine.rootContext()->setContextProperty("defaultAccountName", accountName);
    engine.rootContext()->setContextProperty("homePath", QDir::homePath());
    engine.rootContext()->setContextProperty("applicationDirectory", QApplication::applicationDirPath());
    engine.rootContext()->setContextProperty("idealThreadCount", QThread::idealThreadCount());

    bool builtWithScanner = false;
#ifdef WITH_SCANNER
    builtWithScanner = true;
#endif
    engine.rootContext()->setContextProperty("builtWithScanner", builtWithScanner);

    QNetworkAccessManager *manager = new QNetworkAccessManager();
    Prices prices(manager);
    engine.rootContext()->setContextProperty("Prices", &prices);

    // Load main window (context properties needs to be defined obove this line)
    engine.load(QUrl(QStringLiteral("qrc:///main.qml")));
    if (engine.rootObjects().isEmpty())
    {
        qCritical() << "Error: no root objects";
        return 1;
    }
    QObject *rootObject = engine.rootObjects().first();
    if (!rootObject)
    {
        qCritical() << "Error: no root objects";
        return 1;
    }

#ifdef WITH_SCANNER
    QObject *qmlCamera = rootObject->findChild<QObject*>("qrCameraQML");
    if (qmlCamera)
    {
        qWarning() << "QrCodeScanner : object found";
        QCamera *camera_ = qvariant_cast<QCamera*>(qmlCamera->property("mediaObject"));
        QObject *qmlFinder = rootObject->findChild<QObject*>("QrFinder");
        qobject_cast<QrCodeScanner*>(qmlFinder)->setSource(camera_);
    }
    else
        qCritical() << "QrCodeScanner : something went wrong !";
#endif

    QObject::connect(eventFilter, SIGNAL(sequencePressed(QVariant,QVariant)), rootObject, SLOT(sequencePressed(QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(sequenceReleased(QVariant,QVariant)), rootObject, SLOT(sequenceReleased(QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(mousePressed(QVariant,QVariant,QVariant)), rootObject, SLOT(mousePressed(QVariant,QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(mouseReleased(QVariant,QVariant,QVariant)), rootObject, SLOT(mouseReleased(QVariant,QVariant,QVariant)));
    QObject::connect(eventFilter, SIGNAL(userActivity()), rootObject, SLOT(userActivity()));
    QObject::connect(eventFilter, SIGNAL(uriHandler(QUrl)), ipc, SLOT(parseCommand(QUrl)));
    return app.exec();
}
