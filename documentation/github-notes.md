# to make only one version

    rm -rf .git;
    git init;
    git checkout -b main;
    find . -exec touch {} \;
    git add .;
    git commit -m "checkpoint commit";
    git remote add origin https://github.com/2n1nyn1n2/vz-cyberpunk-card-game.git;
    git push -u --force origin main;
    git branch --set-upstream-to=origin/main main;
    git pull;git push;


