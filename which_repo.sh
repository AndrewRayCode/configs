IS_GIT_DIR=false
IS_HG_DIR=false

gitTest=`git status 2> /dev/null`
hgTest=`hg status 2> /dev/null`

if [[ "$gitTest" != "" ]]; then
    IS_GIT_DIR=true
fi

if [[ "$hgTest" != "" ]]; then
    IS_HG_DIR=true
fi
