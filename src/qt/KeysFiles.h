// Copyright (c) 2014-2019, The Dinastycoin Project
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

#ifndef KEYSFILES_H
#define KEYSFILES_H

#include <qqmlcontext.h>
#include "libwalletqt/WalletManager.h"
#include "NetworkType.h"
#include <QtCore>

class WalletKeysFiles
{
public:
    WalletKeysFiles(const qint64 &modified, const qint64 &created, const QString &path, const quint8 &networkType, const QString &address);

    qint64 modified() const;
    qint64 created() const;
    QString path() const;
    quint8 networkType() const;
    QString address() const;

private:
    qint64 m_modified;
    qint64 m_created;
    QString m_path;
    quint8 m_networkType;
    QString m_address;
};

class WalletKeysFilesModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum KeysFilesRoles {
        ModifiedRole = Qt::UserRole + 1,
        PathRole,
        NetworkTypeRole,
        AddressRole,
        CreatedRole
    };

    WalletKeysFilesModel(WalletManager *walletManager, QObject *parent = 0);

    Q_INVOKABLE void refresh(const QString &dinastycoinAccountsDir);
    Q_INVOKABLE void clear();

    void findWallets(const QString &dinastycoinAccountsDir);
    void addWalletKeysFile(const WalletKeysFiles &walletKeysFile);
    int rowCount(const QModelIndex & parent = QModelIndex()) const;

    QSortFilterProxyModel &proxyModel();
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    QHash<int, QByteArray> roleNames() const;

protected:

private:
    QList<WalletKeysFiles> m_walletKeyFiles;
    WalletManager *m_walletManager;

    QAbstractItemModel *m_walletKeysFilesItemModel;
    QSortFilterProxyModel m_walletKeysFilesModelProxy;
};

#endif // KEYSFILES_H
