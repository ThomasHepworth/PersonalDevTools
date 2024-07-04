#!/bin/zsh

# Define the target path for the git pre-receive hook
hook_path="$(git rev-parse --git-dir)/hooks/pre-receive"

# Check if the Git repository is found
if [ -z "$(git rev-parse --git-dir 2> /dev/null)" ]; then
  echo "Error: no .git folder found".
  echo "To load this hook, you must be run in the root of a Git repository"
  exit 1
fi

# Ask user to overwrite or append the hook
echo "Do you want to overwrite (o) or append (a) to the existing pre-receive hook? (o/a):"
read user_choice

if [ "$user_choice" = "o" ]; then
  operator=">"
elif [ "$user_choice" = "a" ]; then
  operator=">>"
else
  echo "Invalid input. Exiting."
  exit 1
fi

# Create or modify the pre-receive hook
eval "cat << 'EOF' $operator '$hook_path'
#!/usr/bin/env zsh
# Pre-receive hook that blocks commits with messages not following regex rules

commit_msg_type_regex='feat|fix|refactor|style|test|docs|build'
commit_msg_scope_regex='.{1,20}'
commit_msg_description_regex='.{1,100}'
commit_msg_regex='^(${commit_msg_type_regex})(\(${commit_msg_scope_regex}\))?: (${commit_msg_description_regex})\$'
merge_msg_regex='^Merge branch '.+''\$'

zero_commit='0000000000000000000000000000000000000000'

# Do not traverse over commits that are already in the repository
excludeExisting='--not --all'

error=''
while read oldrev newrev refname; do
  # Ignore deleted branches or tags
  if [ '$newrev' = '$zero_commit' ]; then
    continue
  fi

  # Determine the revision span to check
  rev_span=\$(if [ '$oldrev' = '$zero_commit' ]; then git rev-list \$newrev \$excludeExisting; else git rev-list \$oldrev..\$newrev \$excludeExisting; fi)

  for commit in \$rev_span; do
    commit_msg_header=\$(git show -s --format=%s \$commit)
    if ! [[ '\$commit_msg_header' =~ (\${commit_msg_regex})|(\${merge_msg_regex}) ]]; then
      echo 'ERROR: Invalid commit message format: \$commit_msg_header' >&2
      error='true'
    fi
  done
done

if [ -n '\$error' ]; then
  exit 1
fi
EOF"

# Make the pre-receive hook executable
chmod +x "$hook_path"

echo "Pre-receive hook installed successfully at $hook_path"
