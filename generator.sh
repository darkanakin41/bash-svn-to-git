#!/bin/bash

source ./configuration.sh

########################################################################################################################
##################################################### FUNCTIONS ########################################################
########################################################################################################################

# Equivalent du implode de php joinArrayBy <glue> <array>
function arrayJoinBy { local IFS="$1"; shift; echo "$*"; }

########################################################################################################################
################################################ COMMANDS GENERATION ###################################################
########################################################################################################################

echo "### Creation of the folder ###"
echo "mkdir ${folder} && cd ${folder}"

echo ""
echo "### Intialisation of the GIT SVN Repository ###"
echo "git svn init ${svnRepository} --stdlayout --prefix=svn/ --no-minimize-url"

echo ""
echo "### Complete the authors.txt file with authors.sh in order to match svn user to git's one###"

echo ""
echo "### Addition of the file into the GIT SVN Configuration ###"
echo "cp ../authors.txt .git/svn/authors.txt"
echo "git config --add svn.authorsfile .git/svn/authors.txt"

echo ""
echo "### Add the branches to the configuration ###"
echo "git config --unset svn-remote.svn.branches"
for branch in ${branches[@]}; do
    echo "git config --add svn-remote.svn.fetch branches/${branch}:refs/remotes/svn/branches/${branch}"
done

echo ""
echo "### Add the tags to the configuration ###"
echo "git config --unset svn-remove.svn.tags"
if [[ ${#tags[@]} > 0 ]]; then
    echo "git config --add svn-remove.svn.tags tags/{$(arrayJoinBy ',' ${tags[@]})}:refs/remotes/svn/tags/*"
fi

echo ""
echo "### Retrieval of the content of the SVN Repository ###"
echo "### N.B : this part may crash if the repository is huge. So, feel free to execute this command until the whole repository is retrieve ###"
echo "git svn fetch"

echo ""
echo "### SVN to GIT branches conversion ###"
echo 'for branch in `git branch -r | grep "branches/" | sed '"'"'s| svn/branches/||'"'"'`; do git branch $branch refs/remotes/svn/branches/$branch; done'

if [[ ${#tags[@]} > 0 ]]; then
    echo ""
    echo "### SVN to GIT tags conversion ###"
    echo 'for tag in `git branch -r | grep "tags/" | sed '"'"'s| svn/tags/||'"'"'`; do git tag -a -m "Converting SVN tags" $tag refs/remotes/svn/tags/$tag; done'
fi

echo ""
echo "### Configuration of the target Git Repository ###"
echo "git remote add gitrepo ${gitRepository}"

echo ""
echo "### Push the sources to the Git Repository ###"
echo "git push --all gitrepo && git push --tags gitrepo"
