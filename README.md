# dotfiles

macOS の個人用 dotfiles 管理リポジトリです。

---

## 🛠 セットアップ手順

```bash
# リポジトリをクローン
git clone https://github.com/<yourname>/dotfiles.git ~/dotfiles
cd ~/dotfiles

# フルセットアップ
make all
```

> 初回に Homebrew が未導入なら自動インストール

---

## ✅ 対応環境 / 前提

* macOS
* `make` (macOS 標準)
* 管理者権限 (`chsh` や `/etc/shells` 更新に使用)

---

## 🐟 ログインシェルの切り替え（fish）

`make fish_shell` で自動設定  
失敗した場合の手動手順：

```bash
# 1) /etc/shells に fish を登録（必要なら）
command -v fish | sudo tee -a /etc/shells

# 2) ログインシェルを fish に変更
chsh -s "$(brew --prefix)/bin/fish"
```

> 反映にはターミナルの再起動が必要

