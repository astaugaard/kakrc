######################
# phantom selections #######################

# source ~/.config/kak/libaries/phantom-selection.kak
# map global normal f     ":phantom-selection-add-selection<ret>:phantom-selection-iterate-next<ret>i"
# map global insert <esc> "<esc>:phantom-selection-select-all<ret>:phantom-selection-clear<ret>"
# this would be nice, but currrently doesn't work
# see https://github.com/mawrrrkakoune/issues/1r16
# map global <ret>"
# map global irsert <a-F> "<a-;>: phantom-selection-iterate-prev<ret>"
# so instead, have an approximate version that uses 'i'
# map global insert <a-f> "<esc>: phantom-selection-iterate-next<ret>i"
# map global insert <a-F> "<esc>: phantom-selection-iterate-prev<ret>i"

###########
# plugins #
###########


colorscheme catppuccin_macchiato
eval %sh{kak-lsp --kakoune -s $kak_session}

lsp-enable

source ~/.config/kak/libaries/luar/luar.kak

require-module luar

source ~/.config/kak/libaries/peneira/peneira.kak

require-module peneira-core

source ~/.config/kak/libaries/peneira/filters.kak

require-module peneira

source ~/.config/kak/libaries/clipb.kak/rc/clipb.kak

clipb-detect
clipb-enable

evaluate-commands %sh{
    rkak_easymotion load
}

face global REasymotionBackground rgb:aaaaaa
face global REasymotionForeground "%opt{background},%opt{mauve}+F"

# set-option global reasymotion_keys "aoeuidhtnsrcbk"


#############
# mode maps #
#############

declare-user-mode open
declare-user-mode git
declare-user-mode goplace
declare-user-mode toggle
declare-user-mode idris

###############
# keybindings #
###############

# map global normal , ':lsp-code-actions<ret><space>'
# map global normal <backspace> ","
# map global normal <a-backspace> <a-,>
# map global normal <space> " -docstring 'leader'

set-option global ui_options terminal_assistant=cat
map global normal \' ':reasymotion-on-letter-to-word<ret>' -docstring "easymotion to word starting letter"
map global normal \" ':reasymotion-on-letter-to-word-expand<ret>' -docstring "easymotion to word starting letter"

map global user  c ':comment-line<ret>' -docstring 'comment line'
map global user  w ':write<ret>' -docstring 'write file'
map global user  b ':change-buffer-selection<ret>' -docstring 'change buffer'
map global user l ':enter-user-mode lsp<ret>'
map global user j ':reasymotion-line<ret>' -docstring "easymotion to a line"
map global user J ':reasymotion-line-expand<ret>' -docstring "easymotion to a line"

map global user  o ':enter-user-mode open<ret>' -docstring 'open'

map global open  r ':peneira-files<ret>' -docstring 'open file recursive'
map global open  n ':prompt "filename> " -init "%sh{~/.config/kak/sh/selectDirectory}/" -file-completion ''e "%val{text}"''<ret>' -docstring 'new file'
map global open  d ':doc '  -docstring 'open doc'
map global open  M ':man '  -docstring 'open manpage'
map global open  g ':prompt "grep for> " ''grep %val{text}''<ret>' -docstring "grep"
map global open  v ':tmux-terminal-horizontal kak -c %val{session}<ret>'  -docstring 'vertical split'
map global open  h ':tmux-terminal-vertical kak -c %val{session}<ret>'  -docstring 'horizontal split'
map global open  a ':alt<ret>' -docstring 'open alt'
map global open  t ':suspend-and-resume fish<ret>' -docstring 'open terminal'

map global user  v ':enter-user-mode git<ret>' -docstring 'git'
map global git   a ':prompt "add> " ''git add "%val{text}"''<ret>' -docstring 'add'
map global git   s ':nop %sh{tmux new-window "git status; read -n 1 -P \"tap any key to exit\""}<ret>' -docstring 'status'
map global git   l ':nop %sh{tmux new-window "git log; read -n 1 -P \"tap any key to exit\""}<ret>' -docstring 'log'
map global git   c ':prompt "message> " ''git commit -m "%val{text}"''<ret>' -docstring 'commit'
map global git   i ':git init<ret>' -docstring 'init'

map global user  t ':enter-user-mode toggle<ret>' -docstring 'toggle'
map global toggle w ':toggleOnWhite<ret>' -docstring 'whitespace'

map global user  g ':enter-user-mode goplace<ret>' -docstring 'goto'
map global goplace s ':peneira-lines<ret>' -docstring 'swiper'

map global insert <c-s> '<a-;>:lsp-snippets-select-next-placeholders<ret>' -docstring 'select next lsp snippet section'

map global idris c ':lsp-code-actions -auto-single refactor.rewrite.CaseSplit<ret>'
map global idris i ':lsp-code-actions -auto-single refactor.rewrite.Intro<ret>'
map global idris w ':lsp-code-actions -auto-single refactor.rewrite.MakeWith<ret>'
map global idris l ':lsp-code-actions -auto-single refactor.rewrite.MakeLemma<ret>'



###########
# options #
###########

set-option global scrolloff  8,8
set-option global tabstop    4
set-option global autoreload yes

##############
# line flags #
##############

# add-highlighter global/number-lines number-lines
# add-highlighter global/ show-whitespaces

# declare-option line-specs cursorlinespec
# add-highlighter global/cursor-line 

############
# commands #
############

def ide %{
    rename-client main
    set global jumpclient main
    new rename-client tools
    set global toolsclient tools
    new rename-client docs
    set global docsclient docs
    nop %sh{tmux select-layout -E main-vertical}
    lsp-auto-hover-enable docs
}

def toggleOnWhite %{
    add-highlighter global/ show-whitespaces
    unmap global toggle w
    map global toggle w ":toggleOffWhite<ret>"
}

def toggleOffWhite %{
    remove-highlighter global/show-whitespaces
    unmap global toggle w
    map global toggle w ":toggleOnWhite<ret>"
}

# def turn_on_row_highlight %{
#     add-highlighter buffer/cursor-row flag-lines Default cursorlinespec
# }

# def turn_off_row_highlight %{
#     remove-highlighter buffer/cursor-row
# }

def exitMan -hidden %{
    delete-buffer
    b *scratch*
    focus jumpclient
}

def myMan -params 1 %{
    man %arg{1}
    focus docs
    map q ""
}

def test -params 0..10 %{
    execute-keys %sh{
        echo ":echo -debug ""$#\n"""
        for var in "$@"
        do
            echo ":echo -debug $var\n"
        done
    }
}

def startTypstPreview -params 1 %{
    nop %sh{
      (kitty typst-live $1 &) >/dev/null 2>/dev/null
    }
}

def swipey %{
    write -force "/tmp/current_kak_file-%val{client_pid}"

    nop %sh{
        # echo "" > /tmp/kakoune-fzf-selection-$kak_client_pid
        cat -n /tmp/current_kak_file-$kak_client_pid > /tmp/fzf-input-$kak_client_pid
        }

    fzf-window

    execute-keys %sh{ cat /tmp/kakoune-fzf-selection-$kak_client_pid | awk '{print $1}'}g
}

def register-my-fzf-cleanup %{
    echo -debug %sh{
        echo "echo -debug hello world"
        echo "
            hook global KakEnd .* %{
                nop %sh{
                    rm /tmp/kakoune-fzf-selection-$kak_client_pid 2> errors.txt
                    rm /tmp/kakoune-fzf-input-$kak_client_pid 2> errors.txt 
                    rm /tmp/current_kak_file-$kak_client_pid 2> errors.txt
                    echo meow hello world $kak_client_pid > test.txt
                }
            }"
    }
}

def fzf-window %{
    evaluate-commands %sh{
        echo "" > "/tmp/kakoune-fzf-selection-$kak_client_pid"

        # dont run rofi because my config for it is ugly with this kind of stuff ie just text
        if [ -n "$TMUX" ]; then
            fzf-tmux -p 30%,30% --reverse --prompt $1 > "/tmp/kakoune-fzf-selection-$kak_client_pid" < "/tmp/fzf-input-$kak_client_pid"
        else
            # echo
            echo "suspend-and-resume \"fzf --reverse > /tmp/kakoune-fzf-selection-%val{client_pid} < /tmp/fzf-input-%val{client_pid} \""
              # > "$kak_command_fifo"
        fi
    }
}

def open-file-recursive %{
    # todo add support for following gitignores and ignoring .git
    nop %sh{
        find -f . > /tmp/fzf-input-$kak_client_pid
    }

    fzf-window

    edit %sh{ cat /tmp/kakoune-fzf-selection-$kak_client_pid }
}

def change-buffer-selection %{
    peneira 'buffers: ' %{ printf '%s\n' $kak_quoted_buflist } %{
        buffer %arg{1}
    }
}


def suspend-and-resume \
    -params 1..2 \
    -docstring 'suspend-and-resume <cli command> [<kak command after resume>]: backgrounds current kakoune client and runs specified cli command.  Upon exit of command the optional kak command is executed.' \
    %{ evaluate-commands %sh{

    # Note we are adding '&& fg' which resumes the kakoune client process after the cli command exits
    cli_cmd="$1 && fg"
    post_resume_cmd="$2"

    # automation is different platform to platform
    platform=$(uname -s)
    case $platform in
        Darwin)
            automate_cmd="sleep 0.01; osascript -e 'tell application \"System Events\" to keystroke \"$cli_cmd\" & return '"
            kill_cmd="/bin/kill"
            break
            ;;
        Linux)
            automate_cmd="sleep 0.2; xdotool type '$cli_cmd'; xdotool key Return"
            kill_cmd="/usr/bin/kill"
            break
            ;;
    esac

    # Uses platforms automation to schedule the typing of our cli command
    nohup sh -c "$automate_cmd"  > /dev/null 2>&1 &
    # Send kakoune client to the background
    $kill_cmd -SIGTSTP $kak_client_pid

    # ...At this point the kakoune client is paused until the " && fg " gets run in the $automate_cmd

    # Upon resume, run the kak command is specified
    if [ ! -z "$post_resume_cmd" ]; then
        echo "$post_resume_cmd"
    fi
    }}

#########
# hooks #
#########

hook global BufWritePre .* %{ try %{
    format
}}

hook global InsertChar \t %{
    exec -draft h@
}

hook global BufSetOption filetype=cpp,h %{
    set-option buffer formatcmd 'clang-format'
}

hook global BufSetOption filetype=nix %{
    set-option buffer formatcmd 'nixfmt'
}

hook global BufSetOption filetype=yaml %{
    map buffer user L "S^[^ ]*|[\d.]*\)<ret><a-k> <ret>c-<esc>ghi- <esc>gld," -docstring "add latest version" 
    map buffer user C ' op"zZs^ <ret>wd<esc>"zz L' -docstring "add latest version from clipboard" 
}

hook global BufCreate .*[.]idr %{
    set-option buffer filetype 'idris'
}

hook global BufSetOption filetype=idris %{
    hook buffer BufWritePost .* %{
        lsp-semantic-tokens
    }

    hook buffer BufReload .* %{
        lsp-semantic-tokens
    }

    map buffer user i ":enter-user-mode idris<ret>"
}

hook global BufCreate .*[.]typ %{
    set-option buffer filetype 'typst'
}

hook global BufSetOption filetype=haskell %{
    set-option buffer formatcmd 'fourmulo'
}

declare-option str bufferKey ""

# no escape  
hook global InsertChar \. %{ try %{
	exec -draft hH <a-k>,\.<ret> d
        exec "<esc>:phantom-selection-clear<ret>"
}}

hook global InsertCompletionShow .* %{
    try %{
        # this command temporarily removes cursors preceded by whitespace;
        # if there are no cursors left, it raises an error, does not
# continue to execute the mapping commands, and the error is eaten
        # by the `try` command so no warning appears.
        execute-keys -draft 'h<a-K>\h<ret>'
        map window insert <tab> <c-n>
        map window insert <s-tab> <c-p>
        hook -once -always window InsertCompletionHide .* %{
            unmap window insert <tab> <c-n>
            unmap window insert <s-tab> <c-p>
        }
    }
}

hook global WinCreate .* %{ add-highlighter window/number-lines number-lines }
