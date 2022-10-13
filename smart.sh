# Script by Meliorator. irc://irc.freenode.net/Meliorator
# modified by Ranpha
[ ! "$@" ] && echo "Usage: $0 type [type] [type]"

[ ! -e smart-logs ] && mkdir log
[ ! -d smart-logs ] && Can not create smart-logs dir && exit 1

a=0

for t in "$@"; do

        case "$t" in
                offline)  l=error;;
                short|long)  l=selftest;;
                *) echo $t is an unrecognised test type. Skipping... && continue
        esac

       for hd in  /dev/disk/by-id/ata*; do
                r=$(( $(smartctl -t $t -d ata $hd | grep 'Please wait' | awk '{print $3}') ))
                echo Check $hd - $t test in $r minutes
                [ $r -gt $a ] && a=$r
       done
     echo "Waiting $a minutes for all tests to complete"
                sleep $(($a))m

        for hd in /dev/disk/by-id/ata*; do
                smartctl -l $l -d ata $hd 2>&1 >> log/smart-${t}-${hd##*/}.log
        done

        
done

for i in {1..10}; do
        sleep .01
        echo -n -e \\a
done

echo "All tests have completed"