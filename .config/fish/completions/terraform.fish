
function __complete_terraform
    set -lx COMP_LINE (commandline -cp)
    test -z (commandline -ct)
    and set COMP_LINE "$COMP_LINE "
    /home/na2cjp/.anyenv/envs/tfenv/versions/1.6.4/terraform
end
complete -f -c terraform -a "(__complete_terraform)"

