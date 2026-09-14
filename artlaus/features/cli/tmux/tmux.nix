{ config, pkgs, ... }:

{
  programs.tmux = {
    enable = true;

    # Определяем плагины tmux
    plugins = with pkgs.tmuxPlugins; [
      tmux-sensible
      vim-tmux-navigator
      tmux-yank
    ];

    # Основная конфигурация tmux, перенесенная из tmux.conf
    extraConfig = ''
# 1. ОСНОВНЫЕ НАСТРОЙКИ
# Префикс C-`
set-option -g prefix C-`
unbind-key C-b
bind-key C-` send-prefix

# Включаем поддержку мыши
set -g mouse on

# История скроллинга
set -g history-limit 5000

# Нумерация с нуля (как в WezTerm)
set -g base-index 0
setw -g pane-base-index 0
set-option -g renumber-windows on

# Быстрая перезагрузка конфига
bind r source-file ~/.tmux.conf \; display "Конфиг перезагружен!"


# 2. ОПТИМИЗАЦИИ ДЛЯ NEOVIM И СОВРЕМЕННЫХ ТЕРМИНАЛОВ
# Убираем задержку Esc в Neovim
set-option -sg escape-time 10

# Включаем отслеживание фокуса окна
set-option -g focus-events on

# Продвинутые цвета и стили
set -g default-terminal "${TERM}"
set -as terminal-overrides ',*:Smulx=\E[4::%p1%dm'  # undercurl support
set -as terminal-overrides ',*:Setulc=\E[58::2::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'  # underscore colours
set -as terminal-features ",alacritty:RGB" # Включаем RGB для Alacritty

# 3. ВНЕШНИЙ ВИД
# Расположение статус-бара внизу
set -g status-position bottom

# Цвета из вашего конфига
set -g status-style "bg=#000000,fg=#448866"
set -g window-status-current-style "bg=#66FF99,fg=#001a0d,bold"
set -g window-status-style "bg=#000000,fg=#448866"
set -g window-status-activity-style "bg=#000000,fg=#FFD500"

# Формат статус-бара
set -g status-left ""
set -g status-right "#(echo -n '#{pane_current_command}') | %d.%m.%Y %M:%S "
setw -g window-status-format " #I:#W "
setw -g window-status-current-format " #I:#W "
set -g status-justify left


# 4. ГОРЯЧИЕ КЛАВИШИ
# Ваши старые бинды
bind-key n new-window
bind-key q confirm-before -p "close pane? (y/n)" kill-pane
bind-key b previous-window
bind-key f next-window
bind-key h split-window -h
bind-key v split-window -v

# НОВАЯ "УМНАЯ" НАВИГАЦИЯ
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\S+\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h' 'select-pane -L'
bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j' 'select-pane -D'
bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k' 'select-pane -U'
bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l' 'select-pane -R'

# Ресайз панелей
bind-key -r Left  resize-pane -L 5
bind-key -r Right resize-pane -R 5
bind-key -r Down  resize-pane -D 5
bind-key -r Up    resize-pane -U 5
    '';
  };
}
