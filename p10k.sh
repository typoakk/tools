#!/bin/bash
set -e

# Сообщение об ошибке и завершение скрипта
fail() {
    printf 'Ошибка: %s\n' "$1" >&2
    exit 1
}

# Обновляем список пакетов один раз
sudo apt-get update ||
    fail "Не удалось обновить список пакетов."

# Проверяем необходимые программы
for cmd in curl git zsh; do
    if command -v "$cmd" >/dev/null 2>&1; then
        echo "$cmd уже установлен — пропускаем."
    else
        echo "Установка $cmd..."

        sudo apt-get install -y "$cmd" ||
            fail "Не удалось установить $cmd."

        command -v "$cmd" >/dev/null 2>&1 ||
            fail "После установки команда $cmd не найдена."

        echo "$cmd установлен ✅"
    fi
done

omz_dir="$HOME/.oh-my-zsh"
theme_dir="$omz_dir/custom/themes/powerlevel10k"
zshrc="$HOME/.zshrc"
theme_setting='ZSH_THEME="powerlevel10k/powerlevel10k"'

# Установка Oh My Zsh
if [[ -f "$omz_dir/oh-my-zsh.sh" ]]; then
    echo "Oh My Zsh уже установлен — пропускаем."
else
    [[ ! -e "$omz_dir" ]] ||
        fail "Путь $omz_dir занят, но файлы Oh My Zsh не найдены."

    echo "Установка Oh My Zsh..."

    installer=$(curl -fsSL \
        https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)

    ZSH="$omz_dir" sh -c "$installer" "" --unattended --keep-zshrc

    [[ -f "$omz_dir/oh-my-zsh.sh" ]] ||
        fail "После установки не найден oh-my-zsh.sh."

    echo "Oh My Zsh установлен ✅"
fi

# Установка Powerlevel10k
if [[ -f "$theme_dir/powerlevel10k.zsh-theme" ]]; then
    echo "Powerlevel10k уже установлен — пропускаем."
else
    [[ ! -e "$theme_dir" ]] ||
        fail "Путь $theme_dir занят, но файл темы не найден."

    echo "Установка Powerlevel10k..."

    mkdir -p "$omz_dir/custom/themes"
    git clone --depth=1 \
        https://github.com/romkatv/powerlevel10k.git "$theme_dir"

    [[ -f "$theme_dir/powerlevel10k.zsh-theme" ]] ||
        fail "После установки не найден файл темы."

    echo "Powerlevel10k установлен ✅"
fi

# Подключение темы
[[ -f "$zshrc" ]] || fail "Не найден файл $zshrc."

if grep -Fxq "$theme_setting" "$zshrc"; then
    echo "Powerlevel10k уже выбран в настройках."
else
    grep -q '^ZSH_THEME=' "$zshrc" ||
        fail "В $zshrc нет строки ZSH_THEME=. Проверь конфигурацию вручную."

    # Сохраняем предыдущий вариант в ~/.zshrc.bak
    sed -i.bak "s|^ZSH_THEME=.*|$theme_setting|" "$zshrc"

    echo "Powerlevel10k выбран в настройках ✅"
fi

echo "Готово. Запусти zsh, затем при необходимости выполни: p10k configure"
