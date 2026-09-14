{ ... }:

{
  programs.neofetch = {
    enable = true;
    settings = {
      # Порядок отображаемой информации
      info.fn = [
        "title"
        "os"
        "host"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "resolution"
        "de"
        "wm"
        "term"
        "cpu"
        "gpu"
        "memory"
      ];

      # Названия полей
      info.title.fqdn = "off";
      info.os.name = "OS";
      info.host.name = "Host";
      info.kernel.name = "Kernel";
      info.uptime.name = "Uptime";
      info.packages.name = "Packages";
      info.shell.name = "Shell";
      info.resolution.name = "Resolution";
      info.de.name = "DE";
      info.wm.name = "WM";
      info.term.name = "Terminal";
      info.cpu.name = "CPU";
      info.gpu.name = "GPU";
      info.memory.name = "Memory";

      # Источник изображения - наш ASCII-арт
      image_backend = "ascii";
      image_source = ''
             _,met$$$$$gg.
          ,g$$$$$$$$$$$$$$$P.
        ,g$$P"     """Y$$.".
       ,$$P'           `$$$.
      ',$$P       ,ggs.  `$$b:
      `d$$'     ,$P"'   .  $$$
       $$P      d$'     ,    $$P
       $$:      $$.   -    ,d$$'
       Y$b,_    'Y$$'. ,d$$P'
        `"Y$$$$PP"Y$$$$P"'
      '';

      # Настройки ASCII
      ascii.distro = "NixOS"; # Для подбора стандартных цветов
      ascii.colors = [ "green" "brightgreen" ]; # Цвета логотипа NixOS
      # Отступ текста от изображения
      gap = 4;
      
      # Цвета для полей информации (название, текст)
      colors = [ 2 7 7 2 7 7 ]; # 2=green, 7=white
    };
  };
}
