{ config, pkgs, lib, theme, ... }:

let
  c = theme.colors;
in

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;

    # Конфигурация Yazi из yazi.toml (settings)
    settings = {
      mgr = {
        ratio = [ 1 4 3 ];
        sort_by = "alphabetical";
        sort_sensitive = false;
        sort_reverse = false;
        sort_dir_first = true;
        sort_translit = false;
        sort_fallback = "alphabetical";
        linemode = "none";
        show_hidden = true;
        show_symlink = true;
        scrolloff = 5;
        mouse_events = [ "click" "scroll" ];
      };

      preview = {
        wrap = "no";
        tab_size = 2;
        max_width = 600;
        max_height = 900;
        cache_dir = "";
        image_delay = 30;
        image_filter = "triangle";
        image_quality = 75;
        ueberzug_scale = 1;
        ueberzug_offset = [ 0 0 0 0 ];
      };

      opener = {
        edit = [
          {
            run = "${config.home.sessionVariables.EDITOR or "nvim"} %s";
            desc = "${config.home.sessionVariables.EDITOR or "nvim"}";
            block = true;
            for = "unix";
          }
          {
            run = "code %s";
            orphan = true;
            desc = "code";
            for = "windows";
          }
          {
            run = "code -w %s";
            block = true;
            desc = "code (block)";
            for = "windows";
          }
        ];
        open = [
          {
            run = "xdg-open %s1";
            desc = "Open";
            for = "linux";
          }
          {
            run = "open %s";
            desc = "Open";
            for = "macos";
          }
          {
            run = "start \"\" %s1";
            orphan = true;
            desc = "Open";
            for = "windows";
          }
          {
            run = "termux-open %s1";
            desc = "Open";
            for = "android";
          }
        ];
        reveal = [
          {
            run = "xdg-open %d1";
            desc = "Reveal";
            for = "linux";
          }
          {
            run = "open -R %s1";
            desc = "Reveal";
            for = "macos";
          }
          {
            run = "explorer /select,%s1";
            orphan = true;
            desc = "Reveal";
            for = "windows";
          }
          {
            run = "termux-open %d1";
            desc = "Reveal";
            for = "android";
          }
          {
            run = "exiftool %s1; echo 'Press enter to exit'; read _";
            block = true;
            desc = "Show EXIF";
            for = "unix";
          }
        ];
        extract = [
          {
            run = "ya pub extract --list %s";
            desc = "Extract here";
          }
        ];
        play = [
          {
            run = "mpv --force-window %s";
            desc = "Play";
            for = "unix";
            orphan = true;
          }
          {
            run = "mpv --force-window %s";
            desc = "Play";
            for = "windows";
            orphan = true;
          }
          {
            run = "mediainfo %s1; echo 'Press enter to exit'; read _";
            block = true;
            desc = "Show media info";
            for = "unix";
          }
        ];
      };

      open = {
        rules = [
          { url = "*/"; use = [ "edit" "open" "reveal" ]; }
          { mime = "text/*"; use = [ "edit" "reveal" ]; }
          { mime = "image/*"; use = [ "open" "reveal" ]; }
          { mime = "{audio,video}/*"; use = [ "play" "reveal" ]; }
          { mime = "application/{json,ndjson,javascript,wine-extension-ini}"; use = [ "edit" "reveal" ]; }
          { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; use = [ "extract" "reveal" ]; }
          { mime = "inode/empty"; use = [ "edit" "reveal" ]; }
          { url = "*"; use = [ "open" "reveal" ]; }
        ];
      };

      tasks = {
        file_workers = 3;
        plugin_workers = 5;
        fetch_workers = 5;
        preload_workers = 2;
        process_workers = 5;
        bizarre_retry = 3;
        image_alloc = 536870912;
        image_bound = [ 0 0 ];
        suppress_preload = false;
      };

      plugin = {
        fetchers = [
          { url = "*/"; run = "mime.dir"; prio = "high"; group = "mime"; }
          { url = "local://*"; run = "mime.local"; prio = "high"; group = "mime"; }
          { url = "remote://*"; run = "mime.remote"; prio = "high"; group = "mime"; }
        ];
        spotters = [
          { mime = "multi/*"; run = "multi"; }
          { url = "*/"; run = "folder"; }
          { mime = "text/*"; run = "code"; }
          { mime = "application/{mbox,javascript,wine-extension-ini}"; run = "code"; }
          { mime = "image/{avif,hei?,jxl}"; run = "magick"; }
          { mime = "image/svg+xml"; run = "svg"; }
          { mime = "image/*"; run = "image"; }
          { mime = "video/*"; run = "video"; }
          { mime = "vfs/*"; run = "vfs"; }
          { mime = "null/*"; run = "null"; }
          { url = "*"; run = "file"; }
        ];
        preloaders = [
          { mime = "image/{avif,hei?,jxl}"; run = "magick"; }
          { mime = "image/svg+xml"; run = "svg"; }
          { mime = "image/*"; run = "image"; }
          { mime = "video/*"; run = "video"; }
          { mime = "application/pdf"; run = "pdf"; }
          { mime = "font/*"; run = "font"; }
          { mime = "application/ms-opentype"; run = "font"; }
        ];
        previewers = [
          { url = "*/"; run = "folder"; sync = true; }
          { mime = "text/*"; run = "code"; }
          { mime = "application/{mbox,javascript,wine-extension-ini}"; run = "code"; }
          { mime = "application/{json,ndjson}"; run = "json"; }
          { mime = "image/{avif,hei?,jxl}"; run = "magick"; }
          { mime = "image/svg+xml"; run = "svg"; }
          { mime = "image/*"; run = "image"; }
          { mime = "video/*"; run = "video"; }
          { mime = "application/pdf"; run = "pdf"; }
          { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; run = "archive"; }
          { mime = "application/{debian*-package,redhat-package-manager,rpm,android.package-archive}"; run = "archive"; }
          { url = "*.{AppImage,appimage}"; run = "archive"; }
          { mime = "application/{iso9660-image,qemu-disk,ms-wim,apple-diskimage}"; run = "archive"; }
          { mime = "application/virtualbox-{vhd,vhdx}"; run = "archive"; }
          { url = "*.{img,fat,ext,ext2,ext3,ext4,squashfs,ntfs,hfs,hfsx}"; run = "archive"; }
          { mime = "font/*"; run = "font"; }
          { mime = "application/ms-opentype"; run = "font"; }
          { mime = "inode/empty"; run = "empty"; }
          { mime = "vfs/*"; run = "vfs"; }
          { mime = "null/*"; run = "null"; }
          { url = "*"; run = "file"; }
        ];
        prepend_fetchers = [
          { url = "*"; run = "git"; group = "git"; }
          { url = "*/"; run = "git"; group = "git"; }
        ];
      };

      input = {
        cursor_blink = false;
        cd_title = "Change directory:";
        cd_origin = "top-center";
        cd_offset = [ 0 2 50 3 ];
        create_title = [ "Create:" "Create (dir):" ];
        create_origin = "top-center";
        create_offset = [ 0 2 50 3 ];
        rename_title = "Rename:";
        rename_origin = "hovered";
        rename_offset = [ 0 1 50 3 ];
        filter_title = "Filter:";
        filter_origin = "top-center";
        filter_offset = [ 0 2 50 3 ];
        find_title = [ "Find next:" "Find previous:" ];
        find_origin = "top-center";
        find_offset = [ 0 2 50 3 ];
        search_title = "Search via {n}:";
        search_origin = "top-center";
        search_offset = [ 0 2 50 3 ];
        shell_title = [ "Shell:" "Shell (block):" ];
        shell_origin = "top-center";
        shell_offset = [ 0 2 50 3 ];
      };

      confirm = {
        trash_title = "Trash {n} selected file{s}?";
        trash_origin = "center";
        trash_offset = [ 0 0 70 20 ];
        delete_title = "Permanently delete {n} selected file{s}?";
        delete_origin = "center";
        delete_offset = [ 0 0 70 20 ];
        overwrite_title = "Overwrite file?";
        overwrite_body = "Will overwrite the following file:";
        overwrite_origin = "center";
        overwrite_offset = [ 0 0 50 15 ];
        quit_title = "Quit?";
        quit_body = "The following tasks are still running, are you sure you want to quit?";
        quit_origin = "center";
        quit_offset = [ 0 0 50 15 ];
      };

      pick = {
        open_title = "Open with:";
        open_origin = "hovered";
        open_offset = [ 0 1 50 7 ];
      };

      which = {
        sort_by = "none";
        sort_sensitive = false;
        sort_reverse = false;
        sort_translit = false;
      };
    };

    # Конфигурация Yazi из keymap.toml
    keymap = {
      # Пользовательские биндинги клавиш Yazi
      # Пример:
      # manager.prepend_keymap = [
      #   { on = ["k"]; run = "move_down"; }
      #   { on = ["j"]; run = "move_up"; }
      # ];
    };

    # Конфигурация Yazi из theme.toml
    theme = {
      flavor = {
        dark = "";
        light = "";
      };

      app = {
        overall = {
          fg = c.primary;
          bg = "reset";
        };
      };

      mgr = {
        cwd = { fg = c.primary; };
        find_keyword = {
          fg = c.warning;
          bold = true;
          italic = true;
          underline = true;
        };
        find_position = {
          fg = c.secondary;
          bg = "reset";
          bold = true;
          italic = true;
        };
        symlink_target = { italic = true; };
        marker_copied = { fg = c.success; bg = c.success; };
        marker_cut = { fg = c.error; bg = c.error; };
        marker_marked = { fg = c.primary; bg = c.primary; };
        marker_selected = { fg = c.primary; bg = c.primary; };
        marker_symbol = "│";
        count_copied = { fg = c.bg; bg = c.success; };
        count_cut = { fg = c.bg; bg = c.error; };
        count_selected = { fg = c.bg; bg = c.warning; };
        border_symbol = "│";
        border_style = { fg = c.comment; };
        syntect_theme = "";
      };

      tabs = {
        active = { bg = c.primary; bold = true; };
        inactive = { fg = c.primary; bg = c.bgAlt; };
        sep_inner = { open = ""; close = ""; };
        sep_outer = { open = ""; close = ""; };
      };

      mode = {
        normal_main = { bg = c.primary; bold = true; };
        normal_alt = { fg = c.primary; bg = c.bgAlt; };
        select_main = { bg = c.error; bold = true; };
        select_alt = { fg = c.error; bg = c.bgAlt; };
        unset_main = { bg = c.error; bold = true; };
        unset_alt = { fg = c.error; bg = c.bgAlt; };
      };

      indicator = {
        parent = { reversed = true; };
        current = { fg = c.bg; bg = c.warning; };
        preview = { underline = true; };
        padding = { open = ""; close = ""; };
      };

      status = {
        overall = {
          fg = c.primary;
          bg = c.bg;
        };
        sep_left = { open = ""; close = ""; };
        sep_right = { open = ""; close = ""; };
        perm_sep = { fg = c.comment; };
        perm_type = { fg = c.success; };
        perm_read = { fg = c.warning; };
        perm_write = { fg = c.error; };
        perm_exec = { fg = c.primary; };
        progress_label = { bold = true; };
        progress_normal = { fg = c.success; bg = c.bgAlt; };
        progress_error = { fg = c.warning; bg = c.error; };
      };

      which = {
        cols = 3;
        mask = { bg = c.bgAlt; };
        cand = { fg = c.primary; };
        rest = { fg = c.comment; };
        desc = { fg = c.secondary; };
        separator = "  ";
        separator_style = { fg = c.comment; };
      };

      confirm = {
        border = { fg = c.primary; };
        title = { fg = c.primary; };
        body = {};
        list = {};
        btn_yes = { reversed = true; };
        btn_no = {};
        btn_labels = [ "  [Y]es  " "  (N)o  " ];
      };

      spot = {
        border = { fg = c.primary; };
        title = { fg = c.primary; };
        tbl_col = { fg = c.primary; };
        tbl_cell = { fg = c.warning; reversed = true; };
      };

      notify = {
        title_info = { fg = c.secondary; };
        title_warn = { fg = c.warning; };
        title_error = { fg = c.error; };
        icon_info = "";
        icon_warn = "";
        icon_error = "";
      };

      pick = {
        border = { fg = c.primary; };
        active = { fg = c.secondary; bold = true; };
        inactive = {};
      };

      input = {
        border = { fg = c.primary; };
        title = {};
        value = {};
        selected = { reversed = true; };
      };

      cmp = {
        border = { fg = c.primary; };
        active = { reversed = true; };
        inactive = {};
        icon_file = "";
        icon_folder = "";
        icon_command = "";
      };

      tasks = {
        border = { fg = c.primary; };
        title = {};
        hovered = { fg = c.secondary; bold = true; };
      };

      help = {
        on = { fg = c.primary; };
        run = { fg = c.secondary; };
        desc = {};
        hovered = { reversed = true; bold = true; };
        footer = { fg = c.bg; bg = c.primary; };
      };

      filetype = {
        rules = [
          { mime = "image/*"; fg = c.secondary; }
          { mime = "{audio,video}/*"; fg = c.warning; }
          { mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}"; fg = c.error; }
          { mime = "application/{pdf,doc,rtf}"; fg = c.primary; }
          { mime = "text/*"; fg = c.primary; }
          { mime = "vfs/{absent,stale}"; fg = c.comment; }
          { url = "*"; is = "orphan"; bg = c.error; }
          { url = "*"; is = "exec"; fg = c.success; }
          { url = "*"; is = "dummy"; bg = c.error; }
          { url = "*/"; is = "dummy"; bg = c.error; }
          { url = "*/"; fg = c.primary; }
        ];
      };

      icon = {
        globs = [];
        dirs = [];
        files = [];
        exts = [];
        conds = [
          { "if" = "orphan"; text = ""; fg = c.primary; }
          { "if" = "link"; text = ""; fg = c.comment; }
          { "if" = "dir & hovered"; text = ""; fg = c.primary; }
          { "if" = "dir"; text = ""; fg = c.primary; }
          { "if" = "!dir"; text = ""; fg = c.primary; }
        ];
      };
    };
  };
}
