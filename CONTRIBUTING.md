Thank you for considering contributing to *VerticaLab* and helping to make it even better than it is today!

This document will guide you through the contribution process. There are a number of ways you can help:

 - [Bug Reports](#bug-reports)
 - [Feature Requests](#feature-requests)
 - [Code Contributions](#code-contributions)

# Bug Reports

If you find a bug, submit an [issue](https://github.com/vertica/vertica-demo/issues) with a complete and reproducible bug report. If the issue can't be reproduced, it will be closed. If you opened an issue, but figured out the answer later on your own, comment on the issue to let people know, then close the issue.

# Feature Requests

Feel free to share your ideas for how to improve *VerticaLab*. We’re always open to suggestions.
You can open an [issue](https://github.com/vertica/vertica-demo/issues)
with details describing what feature(s) you'd like to be added or changed. For example: a new extension that could improve *VerticaLab* experience, a better way to organise extensions, etc...

If you would like to implement the feature yourself, open an issue to ask before working on it. Once approved, please refer to the [Code Contributions](#code-contributions) section.

# Code Contributions

## Step 1: Fork

Fork the project [on Github](https://github.com/vertica/vertica-demo) and check out your copy locally.

```shell
git clone git@github.com:YOURUSERNAME/vertica-demo.git
cd vertica-demo
```

Your GitHub repository **YOURUSERNAME/vertica-demo** will be called "origin" in
Git. You should also setup **vertica/vertica-demo** as an "upstream" remote.

```shell
git remote add upstream git@github.com:vertica/vertica-demo.git
git fetch upstream
```
### Configure Git for the first time

Make sure git knows your [name](https://help.github.com/articles/setting-your-username-in-git/ "Set commit username in Git") and [email address](https://help.github.com/articles/setting-your-commit-email-address-in-git/ "Set commit email address in Git"):

```shell
git config --global user.name "John Smith"
git config --global user.email "email@example.com"
```

## Step 2: Branch

Create a new branch for the work with a descriptive name:

```shell
git checkout -b my-fix-branch
```

## Step 3: Set up a development environment for extensions

**Skip this step if your changes do not involve adding/changing an extension.**


### Install conda using miniconda
Start by installing miniconda, following [Conda’s installation documentation](https://docs.conda.io/projects/conda/en/latest/user-guide/install/index.html}).

### Install NodeJS, JupyterLab, etc. in a conda environment
Next create a conda environment that includes: the latest release of JupyterLab, [cookiecutter](https://github.com/cookiecutter/cookiecutter), [NodeJS](https://nodejs.org/en/).

It’s a best practice to leave the root conda environment (i.e., the environment created by the miniconda installer) untouched and install your project-specific dependencies in a named conda environment. Run this command to create a new environment named `jupyterlab-ext`.

```
conda create -n jupyterlab-ext --override-channels --strict-channel-priority -c conda-forge -c nodefaults jupyterlab=3 cookiecutter nodejs jupyter-packaging
```
Now activate the new environment so that all further commands you run work out of that environment.
```
conda activate jupyterlab-ext
```

## Step 4: Create an extension project
**Skip this step if your changes do not involve adding/changing an extension.**

You should complete [Step 3](#step-3-set-up-a-development-environment-for-extensions) before.


Go the *extensions* directory and use cookiecutter to create a new project for your extension
```
cd docker-verticapy/extensions
cookiecutter https://github.com/jupyterlab/extension-cookiecutter-ts
```
When prompted, enter values like the following for all of the cookiecutter prompts 
```
Select kind:
1 - frontend
2 - server
3 - theme
Choose from 1, 2, 3 [1]: 1
author_name []: Your Name
author_email []: your@name.org
labextension_name [myextension]: ext_name
python_name [myextension]: ext_name
project_short_description [A JupyterLab extension.]: This is a short description of this new extension.
has_settings [n]: n
has_binder [n]: n
repository [https://github.com/github_username/myextension]:
```
You can find more details in [CookieCutter Documention](https://cookiecutter.readthedocs.io).

Change to the directory the cookiecutter created and list the files.
```
cd ext_name
ls
```
You should see a list like the following.
```
CHANGELOG.md  install.json  jupyterlab_apod  LICENSE   MANIFEST.in   package.json
pyproject.toml  README.md     RELEASE.md    setup.py         src       style         tsconfig.json
```
Now you can make your changes


## Step 5: Build and install the extension for development
**Skip this step if your changes do not involve adding/changing an extension.**
Anytime you want to test new changes, run the following from your extension folder.
```
jlpm run build
```
If you get a `tsc not found` error you need to install typescript with this command.
```
npm install typescript@latest -g
tsc --version
```
If you get `Cannot find module '@module_name'` errors you will need to install these dependencies. Run the following commands in the extension root folder to install the dependencies and save them to your package.json:
```
jlpm add @module_name ## for each missing module
```

### Build a local verticalab image
Build a local image containing your new extension.
Update the Dockerfile with your extension.

open a second terminal, go the repository root folder and run the following to build an image and run a verticalab container with your new extension:
```
make verticalab-build ## build the image
make verticalab-start ## start the container 
```

### Change an existing extension
The steps are almost the same, you just do not need to create a new folder.

You are now ready to create your first contribution!

## Step 6: Commits

Make some changes on your branch, then stage and commit as often as necessary:

```shell
git add .
git commit -m 'Show a random commit message'
```

When writing the commit message, try to describe precisely what the commit does.

## Step 7: Push and Rebase

You can publish your work on GitHub just by doing:

```shell
git push origin my-fix-branch
```

When you go to your GitHub page, you will notice commits made on your local branch is pushed to the remote repository.

When upstream (vertica/vertica-demo) has changed, you should rebase your work. The **rebase** command creates a linear history by moving your local commits onto the tip of the upstream commits.

You can rebase your branch locally and force-push to your GitHub repository by doing:

```shell
git checkout my-fix-branch
git fetch upstream
git rebase upstream/main
git push -f origin my-fix-branch
```

## Step 8: Make a Pull Request

When you think your work is ready to be pulled into *vertica-demo*, you should create a pull request(PR) at GitHub.

A good pull request means:
 - commits with one logical change in each
 - well-formed messages for each commit
 - documentation and tests, if needed

Go to https://github.com/YOURUSERNAME/vertica-demo and [make a Pull Request](https://help.github.com/articles/creating-a-pull-request/) to `vertica-demo:main`.

### Review
Pull requests are usually reviewed within a few days. If there are comments to address, apply your changes in new commits, rebase your branch and force-push to the same branch. In order to produce a clean commit history, our maintainers would do squash merging once your PR is approved, which means combining all commits of your PR into a single commit in the master branch.

That's it! Thank you for your code contribution!

After your pull request is merged, you can safely delete your branch and pull the changes from the upstream repository.