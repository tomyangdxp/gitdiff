#!/bin/bash
USAGE='[--cached] [<rev-list-options>...]

Show file size changes between two commits or the index and a commit.'

SUBDIRECTORY_OK=1
. "$(git --exec-path)/git-sh-setup"
args=$(git rev-parse --sq "$@")
[ -n "$args" ] || usage
cmd="diff-tree -r"
[[ $args =~ "--cached" ]] && cmd="diff-index"
eval "git $cmd $args" | {
  total=0
  while read A B C D M P
  do
    case $M in
      M) bytes=$(( $(git cat-file -s $D) - $(git cat-file -s $C) )) ;;
      A) bytes=$(git cat-file -s $D) ;;
      D) bytes=-$(git cat-file -s $C) ;;
      *)
        echo >&2 warning: unhandled mode $M in \"$A $B $C $D $M $P\"
        continue
        ;;
    esac
    total=$(( $total + $bytes ))
    printf '%d\t%s\n' $bytes "$P"
    if [[ "$depth" -ne "0" ]]; then
      echo "File $P is changed"
      if echo "$file" | grep 'src'; then
        folder="${file:0:5}";
        echo "Rebuild $folder";
        cd $folder;
        if echo "$folder" | grep 'war'; then
          /cygdrive/c/Fujitsu/BDM/Projects/CommonCode/apache-ant-1.9.16/bin/ant create-war;
        elif echo "$folder" | grep 'ejb'; then
          /cygdrive/c/Fujitsu/BDM/Projects/CommonCode/apache-ant-1.9.16/bin/ant create-jar;
        fi
        cd ..;
      fi
    fi
  done
  echo "Package the application"
  cd ear
  /cygdrive/c/Fujitsu/BDM/Projects/CommonCode/apache-ant-1.9.16/bin/ant create-ear;
}