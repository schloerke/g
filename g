#!/bin/bash -e

check_if_svn() {
  set +e
  _git_dir=`git rev-parse --show-toplevel 2> /dev/null`
  _gsvn_check=`cd $_git_dir; ls .git/svn 2> /dev/null`
  set -e

  if [ "$_gsvn_check" ]
  then
    echo "is git-svn repo";
  fi
}


case "$1" in

b|branches)
  git branch -av
  ;;

a|add)
  git add "${@:2}"
  g st
  ;;

add_all_deleted)
  git add -u "${@:2}"
  g st
  ;;

cherry)
  git cherry-pick "${@:2}"
  ;;

co)
  if [[ "$#" > 1 ]]
  then
    g checkout "${@:2}"
    g b
  else
    echo "please include a branch name"
  fi
  ;;

com)
  git commit -m "${@:2}"
  ;;

coma)
  git commit -am "${@:2}"
  ;;

d|db|diff)
  git diff "${@:2}"
  ;;

dc|diff_commit)
  g d --staged "${@:2}"
  ;;

delete_global_remote)
  if [[ "$#" == 2 ]]
  then
    git push origin ":$2" # delete the remote
    g prune               # clean up branches and
    git gc                # clean up your working directory
    g b                   # show current branches
  else
    echo "please include a remote name."
  fi
  ;;

delete_local_branch)
  if [[ "$#" == 2 ]]
  then
    git branch -d "$2"  # force delete the branch
    git gc              # clean up your working directory
    g b                 # show current branches
  else
    echo "please include a branch name."
  fi
  ;;

l)
  g l_all -n 15 "${@:2}" | cat
  echo ""
  ;;

l_all)
  #       magenta   white                 cyan                                   green
  # * |   1234567 - merged master --> dev <Barret Schloerke schloerke@gmail.com> (3 hours ago)
  git log --graph --pretty=format:'%C(magenta)%h%Creset -%C(yellow)%d%Creset %C(white)%s %C(cyan)<%an %ae> %Cgreen(%cr) %Creset' --abbrev-commit "${@:2}"
  ;;

lp)
  # | * 1234567 - 1.0.1-dev <Barret Schloerke schloerke@gmail.com> (2 hours ago) | |
  # | | diff --git a/project/dash b/project/dash
  # | | index 2345678..3456789 100644
  # | | --- a/project/dash
  # | | +++ b/project/dash
  # | | @@ -1 +1 @@
  # | | -1.0.0
  # | | +1.0.1-dev
  g l_all -p
  ;;

make_branch)
  if [[ "$#" > 1 ]]
  then

    if [ "`check_if_svn`" ]
    then
      # is svn wrapped in git
      git svn branch -n  "${@:2}"
      branchName="$BASH_ARGV" # last arg supplied
      git checkout --track -b "$branchName" "remotes/$branchName" # to avoid warning from git about ambiguity
      git reset --hard "remotes/$branchName"

    else
      # raw git repo
      git checkout -b "${@:2}"    # make new branch X
      git push -u origin "${@:2}" # make new remote for branch X. -u adds support for git pull
      git gc                  # clean up your working directory
    fi

    g b                     # show current branches
  else
    echo "please include a new branch name."
  fi
  ;;

merge|merge_into_single)
  if [[ "$#" > 1 ]]
  then
    case "$1" in
      merge)             git merge "${@:2}";;
      merge_into_single) git merge --squash "${@:2}";;
    esac
    g b
  else
    echo "please include a branch name"
  fi
  ;;

patch)
  git add --patch
  ;;

pp)
  g pull "${@:2}"
  g push "${@:2}"
  ;;

prune)
  if [ -z "$2" ]
  then
    REMOTE="origin"
  else
    REMOTE="$2"
  fi

  git remote prune $REMOTE
  ;;

pullo)
  git pull origin "${@:2}"
  ;;

# pullr)
#   git pull --rebase "${@:2}"
#   ;;

pusho)
  git push origin "${@:2}"
  ;;

resolve)
  # get status output in a stable format
  STATUS_OUTPUT=`git status --porcelain`

  # go through all the "unmerged" setups and open that group individually
  # DD  unmerged, both deleted
  # AU  unmerged, added by us
  # UD  unmerged, deleted by them
  # UA  unmerged, added by them
  # DU  unmerged, deleted by us
  # AA  unmerged, both added
  # UU  unmerged, both modified
  for SET in DD AU UD UA DU AA UU;
  do
    # get the files for that set and remove the set code
    FILES=`echo "$STATUS_OUTPUT" | grep "$SET" | sed "s/$SET //"`
    if [ -n "$FILES" ]
    then
      lime $FILES
    fi
  done
  ;;

s|stash)
  git stash "${@:2}"
  ;;

sd|stash_drop)
  g s drop "${@:2}"
  ;;

sl|stash_list)
  g s list "${@:2}"
  ;;

sp|stash_pop)
  g s pop "${@:2}"
  ;;

ss|stash_show_files)
  g s show "${@:2}"
  ;;

ssp|stash_show_diff)
  g ss -p "${@:2}"
  ;;

st|status)
  git branch -vv
  git status "${@:2}"
  ;;

undo)
  if [[ "$#" > 1 ]]
  then
    git checkout -- "${@:2}"
    g st
  else
    echo "please include file names"
  fi
  ;;

unstage)
  if [[ "$#" > 1 ]]
  then
    git reset HEAD "${@:2}"
    g st
  else
    echo "please include file names"
  fi
  ;;

push|pull)
  if [ "`check_if_svn`" ]
  then
    # is svn wrapped in git
    case $1 in
      push) git svn dcommit;;
      pull) git svn rebase;;
    esac
  else
    # raw git repo
    git "${@:1}"
  fi
  ;;

svn_clone|svn_clone_standard)
  # http://viget.com/extend/effectively-using-git-with-subversion
  # The -s is there to signify that my Subversion repository has a standard layout (trunk/, branches/, and tags/.) If your repository doesn’t have a standard layout, you can leave that off.
  if [[ "$#" > 1 ]]
  then
    case "$1" in
      svn_clone)
        git svn clone "${@:2}" #
        ;;
      svn_clone_standard)
        git svn clone -s "${@:2}" #
        ;;
    esac
    location="$BASH_ARGV" # last arg supplied
    folder=`basename "$location"`
    cd "$folder"

    git svn show-ignore > .gitignore # keep track of the hidden files

    git gc                  # clean up your working directory
    g b                     # show current branches
    echo ""
    echo "cd '$folder'"
    echo ""

  else
    echo "please include a repo location."
  fi
  ;;

mv)
  if [[ "$#" > 2 ]]
  then
    git mv "$2" "git_tmp_file"
    git mv "git_tmp_file" "$3"
    g st
  else
    echo "please include 2 file names"
  fi
  ;;


upstream_fetch)
  g fetch upstream
  ;;

upstream_merge)
  if [[ "$#" > 1 ]]
  then
    g merge upstream/"$2"
  else
    g merge upstream/master
  fi
  ;;


upstream_set)
  if [[ "$#" > 1 ]]
  then
    git remote add upstream "$2"
    g st
  else
    echo "please include another git repo"
  fi
  ;;

*)
  # all else fails, send to git
  git "$@"
  ;;
esac

