let prompt_chars = {
    white_fg: "\e[37m"
    black_fg: "\e[30m"
    italic: "\e[3m"
    reset: "\e[0m"
    right_char: ""
    wrong_char: ""
    root_icon: ""
    icon_fg: (color2ansi 255 146 72 "fg")
    icon_bg: (color2ansi 255 146 72 "bg")
    name_fg: (color2ansi 255 146 72 "fg")
    name_bg: (color2ansi 255 146 72 "bg")
    path_fg: (color2ansi 52 100 164 "fg")
    path_bg: (color2ansi 52 100 164 "bg")
    git_fg: (color2ansi 196 110 170 "fg")
    git_bg: (color2ansi 196 110 170 "bg")
    status_fg: (color2ansi 46 149 153 "fg")
    status_bg: (color2ansi 46 149 153 "bg")
    status_err_fg: (color2ansi 240 83 80 "fg")
    status_err_bg: (color2ansi 240 83 80 "bg")
    shells_fg: (color2ansi 122 64 152 "fg")
    shells_bg: (color2ansi 122 64 152 "bg")
    time_fg: (color2ansi 137 52 143 "fg")
    time_bg: (color2ansi 137 52 143 "bg")
    root_fg: (color2ansi 248 102 122 "fg")
    root_bg: (color2ansi 248 102 122 "bg")
    vi_fg: (color2ansi 78 144 61 "fg")
    vi_bg: (color2ansi 78 144 61 "bg")
}

def create-left-prompt [] {
    let status = {
        icon: (get-system-icon -r " ")
        user: (get-user-name)
        path: ($env.PWD | format-path (if (is-windows) { "\\" } else { "/" }) -d $"\e[0;1;37m($prompt_chars.path_bg)" -s $"\e[0;2m($prompt_chars.path_bg)" -u)
        git: (get-git-info)
        exit: $env.LAST_EXIT_CODE
        admin: (is-admin)
        shells: (get-where-shells -dl "#")
        time: (get-execution-time-s)
    }
    return (
        [
            (prompt-block "" "" $prompt_chars.name_fg $prompt_chars.name_bg $status.user $prompt_chars.black_fg $status.icon)
            (prompt-block "" "" $prompt_chars.path_fg $prompt_chars.path_bg $status.path $prompt_chars.white_fg " ")
            (
                if $status.git != "" {
                    prompt-block "" "" $prompt_chars.git_fg $prompt_chars.git_bg $status.git $prompt_chars.white_fg " "
                } else { "" }
            )
            (
                if $status.exit == 0 {
                    prompt-block "" "" $prompt_chars.status_fg $prompt_chars.status_bg $prompt_chars.right_char $prompt_chars.white_fg ""
                } else {
                    prompt-block "" "" $prompt_chars.status_err_fg $prompt_chars.status_err_bg $"($prompt_chars.wrong_char) ($status.exit)" $prompt_chars.white_fg ""
                }
            )
            (
                if $status.shells != "" {
                    prompt-block "" "" $prompt_chars.shells_fg $prompt_chars.shells_bg $status.shells $prompt_chars.white_fg " "
                } else { "" }
            )
            (
                if $status.time > 0.5 {
                    prompt-block "" "" $prompt_chars.time_fg $prompt_chars.time_bg $"($status.time)s" $prompt_chars.white_fg " "
                } else { "" }
            )
            (
                if $status.admin {
                    prompt-block "" "" $prompt_chars.root_fg $prompt_chars.root_bg $prompt_chars.root_icon $prompt_chars.white_fg ""
                } else { "" }
            )
            " "
        ] | str join ""
    )
}

def transient-create-left-prompt [] {
    let path = ($env.PWD | get-path-last -u)
    
    return (
        prompt-block "" " " $prompt_chars.path_fg $prompt_chars.path_bg $path $prompt_chars.white_fg " "
    )
}

def vi-ins-prompt [] {
    let prompt = (prompt-block "\b" " " $prompt_chars.vi_fg $prompt_chars.vi_bg "I" $prompt_chars.white_fg " ")

    return $prompt
}

def vi-nor-prompt [] {
    let prompt = (prompt-block "\b" " " $prompt_chars.vi_fg $prompt_chars.vi_bg "N" $prompt_chars.white_fg " ")

    return $prompt
}

def prompt-block [
    start_char: string
    end_char: string
    block_fg: string
    block_bg: string
    block_text: string
    text_fg: string
    icon: string
] {
    return (
        [
            $prompt_chars.reset
            $block_fg
            $start_char
            $prompt_chars.reset
            $block_bg
            $text_fg
            $" ($icon)($block_text) "
            $prompt_chars.reset
            $block_fg
            $end_char
            $prompt_chars.reset
        ] | str join ""
    )
}

$env.PROMPT_COMMAND = {|| create-left-prompt }
$env.PROMPT_COMMAND_RIGHT = {||}
$env.PROMPT_INDICATOR = $""
$env.PROMPT_MULTILINE_INDICATOR = $"($prompt_chars.name_fg)➥ "
$env.PROMPT_INDICATOR_VI_INSERT = {|| vi-ins-prompt }
$env.PROMPT_INDICATOR_VI_NORMAL = {|| vi-nor-prompt }
$env.TRANSIENT_PROMPT_COMMAND = {|| transient-create-left-prompt }
$env.TRANSIENT_PROMPT_COMMAND_RIGHT = ""
$env.TRANSIENT_PROMPT_INDICATOR = $""
$env.TRANSIENT_PROMPT_MULTILINE_INDICATOR = $"($prompt_chars.path_fg)➥ "
$env.TRANSIENT_PROMPT_INDICATOR_VI_INSERT = ""
$env.TRANSIENT_PROMPT_INDICATOR_VI_NORMAL = ""
