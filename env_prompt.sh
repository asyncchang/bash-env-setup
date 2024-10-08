
# Function to get the current Git branch
parse_git_branch() {
  git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

# Set the prompt
PS1='\[\e[01;32m\]\u@\h\[\e[0m\]:\[\e[01;34m\]\w\[\e[0m\]\[\e[01;33m\]$(parse_git_branch)\[\e[0m\]\n\$ '

