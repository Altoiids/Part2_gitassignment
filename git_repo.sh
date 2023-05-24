#!/bin/bash


commit_and_push() {
read -rp "enter commit message: " commit
    git commit -m "$commit"
    git push -u origin main
}

if [ -z "$git config --global user.name" ]; then
read -rp "Enter your GitHub username: " name
git config --global user.name $name
fi

username=$(git config --global user.name)

read -r -s -p "Enter your personal access token: " github_token
echo
echo -e "For repo name you have to follow certain rules: \n1. Repo name should start with a capital letter\n2. Should have atleast 5 character\n3. Your repo name can only contain alphanumerics and "." "-" "_" "
read -rp "Enter your repository name: " reponame
if [[ "$reponame" =~ ^[A-Z].{4,}$  ]]; then
mkdir $reponame
cd $reponame
git init

output=$(curl -L -X POST -H "Authorization: Bearer $github_token" https://api.github.com/user/repos -d "{\"name\":\"$reponame\"}")
git remote add origin "https://$github_token@github.com/$username/$reponame.git"
  if echo "$output" | grep -q "creation failed."; then
     echo "Duplicacy error occurred. Ending the script."
     exit 1  
  fi

response_code=$(curl -s -o /dev/null -w "%{http_code}" -L -X POST -H "Authorization: Bearer $github_token" https://api.github.com/user/repos -d "{\"name\":\"$reponame\"}")

if [[ "$response_code" != "422" ]]; then
  echo "Bad credentials error occurred. Ending the script."
  exit 1  
 fi

 
echo "press 1 to make a new file in this repo,  press 2 to initialise an empty repo press, 3 to initialise a repo with readme file"
read -r input
    if [ "$input" -eq 1 ]; then
    echo "After entering the file name you will be redirected to text editor where you can enter the content of file"
    read -rp "enter filename: " filename
    touch "$filename"
    nano $filename
    git add "$filename"
    commit_and_push

    elif [ "$input" -eq 2 ]; then
      exit 0
    elif [ "$input" -eq 3 ]; then
     echo "Initial commit" > README.md
     git add README.md
     git commit -m "Initial commit"
     git push -u origin main 
    else
      exit 0
    fi

else
    echo "Invalid Repo name"
fi
