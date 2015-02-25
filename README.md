


# g

Autocomplete functionality given your current github command context.

There are two files for this function to work at it's best:

* 'env': the "environment" for 'g'.  Source the file in your .profile or .bashrc.
```{bash}
"source env" >> ~/.profile
```
It contains three major components.
  * Git configurations.  Add these lines to your ~/.gitconfig.
  * Bash prompt. It contains a function to add the current git branch to your prompt in the terminal.  This is nice when you don't have a picture to look at.  (just uncomment the PS1 line)
  * Auto Ccompletion. It contains a function that will autocomplete items in the 'g' function and will autocomplete branch names.  Files are not directly autocompleted as there are too many situations to handle.  So, it prints the current status or usage and gives control back to the terminal. The purpose of this auto complete function is to allow you to use the tab key as much as possible to give you the most context.

* 'g': this file contains the meat of the functionality.  Place it in your $PATH somewhere.  It's one giant case/switch statement, but it works just fine for speed.  The descriptions are in the 'env' function '_g'. Dont' forget to "chmod +x ./g"

I have a function called 'lime' that opens files into my text editor (used inside resolve).  Replace that as necessary, but it should accept multiple file names.

The basic 'g pull' and 'g push' now work for both regular git and git-svn repositories.

Examples:

```bash
# add all files
g a .

# get current status
g st

# resolve merge conflicts
g resolve

# checkout other branch
g co BRANCH_NAME

# make_new branch with global remote hook and checkout that branch
g make_branch BRANCH_NAME

# see latest diff
g d
g diff
g d master #see changes of current branch referencing from master

# see latest logs
g l

# see logs with changes
g lp

# undo all changes to an uncommited file
g undo FILE FILE2

# un-commit a file
g unstage FILE FILE2
```

Don't forget to use the tab key to help you remember what you can do!
