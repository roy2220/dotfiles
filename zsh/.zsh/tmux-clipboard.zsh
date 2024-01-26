() {

local widget
for widget in vi-yank vi-yank-eol; do
    eval "
        function _wrapped-${widget} {
            zle .${widget}
            tmux set-buffer \${CUTBUFFER}
            echo -n \${CUTBUFFER} | pbcopy
        }
    "
    zle -N ${widget} _wrapped-${widget}
done
for widget in vi-put-before vi-put-after; do
    eval "
        function _wrapped-${widget} {
            CUTBUFFER=\$(tmux show-buffer)
            zle .${widget}
        }
    "
    zle -N ${widget} _wrapped-${widget}
done

}
