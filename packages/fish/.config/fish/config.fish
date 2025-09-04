fish_vi_key_bindings

if not set -q VOLTA_HOME
    set -gx VOLTA_HOME $HOME/.volta
end

fish_add_path -m $VOLTA_HOME/bin

starship init fish | source
