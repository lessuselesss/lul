function lsp --description "List files with rainbow-colored persistent directories"
    set -l persist_dirs ".ssh" Documents Downloads Music Pictures Videos \
        ".mozilla" ".config" ".local" dotfiles ".cache"

    set -l rainbow_colors red yellow green cyan blue magenta
    set -l color_offset 0

    for item in (ls -1 $argv)
        set -l is_persist 0
        for pdir in $persist_dirs
            if string match -q "$pdir*" "$item"
                set is_persist 1
                break
            end
        end

        if test $is_persist -eq 1
            echo -n "📌 "
            set -l item_len (string length $item)
            for i in (seq $item_len)
                set -l char (string sub -s $i -l 1 $item)
                set -l color_idx (math "($i + $color_offset) % 6 + 1")
                set_color $rainbow_colors[$color_idx] --bold
                echo -n $char
            end
            set color_offset (math "$color_offset + $item_len")
            set_color normal
            echo
        else
            set_color brblack
            echo "   $item"
            set_color normal
        end
    end
end
