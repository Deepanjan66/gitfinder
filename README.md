# Gitfinder

Gitfinder is a commandline utility that will allow you to look for and find git repositories on your local machine. This
is particularly useful if you opened a git repository a long time ago and forgot where you cloned it the last time.
Gitfinder allows you to use different filters to locate your lost repository and start working on them.

More features will be added as I further develop the program.

# How to install gitfinder

Gitfinder has only been tested on Linux and Mac setups so far. To use, clone the repository and then

```
cp gitfinder.sh /usr/local/bin/gitfinder
```

Once this is done, you can run gitfinder from anywhwere on the terminal

# How to use gitfinder

You can run `gitfinder` directly without any flags to find all the git repositories that are under the current directory
(gitfinder will recursively go through all the directories under the current directory to find the repositories). You
can run `gitfinder` from your root directory to find all the git repositories that you have ever cloned/created on your
local machine. Otherwise, gitfinder does support a few flags in its current state. You can use the `-h` flag to see them.
The output has been shown below:

```
> gitfinder -h
Usage: gitfinder <flags> <values>
Flags:
   -h : Help. This will show all the available commands
   -f : Show results by folder name
   -c  "string" : Search repositories by string in commit messages
```

