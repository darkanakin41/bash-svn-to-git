# SVN TO GIT

SVN to GIT command generator is a tool that i wrote in order to migrate SVN Repositories to Git one.

## How To
This is pretty simple to use : 
1. Duplicate the [example configuration file](./configuration.sh.dist) into ```configuration.sh``` and update it with your informations.
2. Run the ```authors.sh``` script in order to retrieve the list of all users who worked on the SVN repository
3. In the same folder, create the ```authors.txt``` file and replace informations on the right side of the equal sign with Git user information, should look something like this, with one line per user : 
```txt
    plejeune = Pierre LEJEUNE <lejeune.pierre.41@gmail.com>
```
4. Now, execute the ```generator.sh``` file, it will display all commands that need to be executed:
```sh
λ sh generator.sh
### Creation of the folder ###
mkdir workdir && cd workdir

### Intialisation of the GIT SVN Repository ###
git svn init http://svn.com/pierrelejeune/project --stdlayout --prefix=svn/ --no-minimize-url

### Complete the authors.txt file with authors.sh in order to match svn user to git's one###

### Addition of the file into the GIT SVN Configuration ###
cp ../authors.txt .git/svn/authors.txt
git config --add svn.authorsfile .git/svn/authors.txt

### Add the branches to the configuration ###
git config --unset svn-remote.svn.branches
git config --add svn-remote.svn.fetch branches/BRANCH:refs/remotes/svn/branches/BRANCH
git config --add svn-remote.svn.fetch branches/1:refs/remotes/svn/branches/1
git config --add svn-remote.svn.fetch branches/BRANCH:refs/remotes/svn/branches/BRANCH
git config --add svn-remote.svn.fetch branches/2:refs/remotes/svn/branches/2

### Add the tags to the configuration ###
git config --unset svn-remove.svn.tags
git config --add svn-remove.svn.tags tags/{TAG,1,TAG,2}:refs/remotes/svn/tags/*

### Retrieval of the content of the SVN Repository ###
### N.B : this part may crash if the repository is huge. So, feel free to execute this command until the whole repository is retrieve ###
git svn fetch

### SVN to GIT branches conversion ###
for branch in `git branch -r | grep "branches/" | sed 's| svn/branches/||'`; do git branch $branch refs/remotes/svn/branches/$branch; done

### SVN to GIT tags conversion ###
for tag in `git branch -r | grep "tags/" | sed 's| svn/tags/||'`; do git tag -a -m "Converting SVN tags" $tag refs/remotes/svn/tags/$tag; done

### Configuration of the target Git Repository ###
git remote add gitrepo http://gitlab.com/pierrelejeune/project.git

### Push the sources to the Git Repository ###
git push --all gitrepo && git push --tags gitrepo
```

Those are all instructions that you need to execute in order to migrate a SVN Repository to a Git one