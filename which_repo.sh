IS_GIT_DIR=false
IS_HG_DIR=false
IS_SVN_DIR=false

gitTest=`git status 2> /dev/null`
if [[ "$gitTest" != "" ]]; then
    IS_GIT_DIR=true

else 
    hgTest=`hg summary 2> /dev/null`
    if [[ "$hgTest" != "" ]]; then
        IS_HG_DIR=true
    else
        svnTest=`svn info 2> /dev/null`
        if [[ "$svnTest" != "" ]]; then
            IS_SVN_DIR=true
        else
            echo "This is not a Git, Mercurial nor Subversion repository. Are you drunk?"
        fi
    fi
fi
