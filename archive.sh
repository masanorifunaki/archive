#!/bin/bash
# 実行コマンドを表示
# set -v
# 実行しようとしているコマンドが表示される。変数は展開される
# set -o xtrace
readonly SCRIPT_NAME=${0##*/}

archive()
{
  local path="$1"

  if [[ -z $path ]]; then
    printf '\e[31m%s\n\e[m' "${SCRIPT_NAME}: アーカイブしたいファイルがあるディレクトリまたはファイルを指定してください。" 1>&2
    return 1
  fi

  if [[ ! -d $path && ! -f $path ]]; then
    printf '\e[31m%s\n\e[m' "${SCRIPT_NAME}: '$path'は存在しません。" 1>&2
    return 2
  fi

  if [[ -d $path && $path != */ ]]; then
    path+=/
  fi

  # dir変数に正規表現でマッチングした値を代入する。
  # マッチングしなかった場合は現在のディレクトリのパスを代入する
  if [[ $path =~ ^(.*/) ]]; then
    dir=${BASH_REMATCH[1]}
  else
    dir=${PWD}
  fi

  # 相対パスで指定された場合、絶対パスに変換する。
  local basedir=$(cd -- "$dir" && pwd)

  # アーカイブするファイルがあるディレクトリに移動し
  # tarコマンドでjpgファイルをアーカイブする。
  cd -- "$basedir"
  if tar -cf "${basedir}"_jpg.tar -- *.jpg 2> /dev/null; then
    local tardir="${basedir}"_jpg.tar
    printf '\e[36m%s\n\e[m' "アーカイブに成功しました！
${tardir}の${tardir##*/}をご確認ください。"
  else
    printf '\e[31m%s\n\e[m' "JPGファイルが見つからず...アーカイブに失敗しました。"
    return 3
  fi
}

if [[ $# -le 0 ]]; then
  printf '\e[31m%s\n\e[m' "${SCRIPT_NAME}: アーカイブしたいファイルがあるディレクトリまたはファイルを指定してください。" 1>&2
  exit 1
fi

result=0
for i in "$@"
do
  archive "$i" || result=$?
done

exit "$result"
