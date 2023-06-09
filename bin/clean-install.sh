if [ ! -f "package.json" ]; then
    echo ">>>>>>>>>> ERROR: Not a package"
    return
fi

MANAGERS=("pnpm" "yarn" "npm")

declare -A LOCKFILES
LOCKFILES[pnpm]="pnpm-lock.yaml"
LOCKFILES[yarn]="yarn.lock"
LOCKFILES[npm]="package-lock.json"

declare -A MARKERS
MARKERS[pnpm]="node_modules/.modules.yaml"
MARKERS[yarn]="node_modules/.yarn-integrity"
MARKERS[npm]="node_modules/.package-lock.json"

MANAGER=""

for i in "${MANAGERS[@]}"
do
    if [ -f ${LOCKFILES[$i]} ] || [ -f ${MARKERS[$i]} ]; then
        MANAGER=$i

        echo ">>>>>>>>>> Using package manager $i"
        break
    fi
done

if [ ! $MANAGER ]; then
    echo ">>>>>>>>>> Could not guess package manager"

    PS3="Choose package manager: "
    select opt in "${MANAGERS[@]}" quit
    do
        case $opt in
            "pnpm" | "yarn" | "npm")
                MANAGER=$opt
                break
                ;;
            *)
                echo ">>>>>>>>>> Exiting"
                return
        esac
    done
fi

if [ -f ${LOCKFILES[$MANAGER]} ]; then
    echo ">>>>>>>>>> Removing ${LOCKFILES[$MANAGER]}"
    rm -f "${LOCKFILES[$MANAGER]}"
fi

echo ">>>>>>>>>> Removing node_modules (recursive)"
find . -type d -name "node_modules" -ls -exec rm -rf {} + 1> /dev/null 2>& 1

echo ">>>>>>>>>> Installing with $MANAGER"
"$MANAGER" install