# This script helps you modify a nbdev_new project with templated files for SSI based projects. It required a public repo where the files will come from

# Ensure script fails on errors
set -e

# Check that .git is present
if [ ! -d .git ]; then
    git init;
fi

NBDEV_VERSION="2.3.13"

# Get var for template_git_branch, if not set use main
TEMPLATE_GIT_BRANCH=${TEMPLATE_GIT_BRANCH:-main}
TEMPLATE_GIT_REPO=${TEMPLATE_GIT_REPO:-ssi-dk/microbeseq_nbdev_augment}
# Get var for nbdev_project_folder, if not set use cwd
NBDEV_PROJECT_FOLDER=${NBDEV_PROJECT_FOLDER:-.}

# Get the git repo name, if it's not set up use the current directory name
GIT_REPO_NAME=${GIT_REPO_NAME:-$(basename `git rev-parse --show-toplevel`)}
GIT_REPO_BRANCH=${GIT_REPO_BRANCH:-$(git branch --show-current)}
GIT_USER_NAME=${GIT_USER_NAME:-$(git config user.name)}
GIT_EMAIL=${GIT_EMAIL:-$(git config user.email)}

# Conda env path location default ./.venv
CONDA_ENV_PATH=${CONDA_ENV_PATH:-.venv}

#check for write permissions
if [ ! -w $NBDEV_PROJECT_FOLDER ]; then
    echo "You do not have write permissions to this directory"
    exit 1
fi

# Check for conda.dev.env.yaml and update conda env based on the branch, create the ./venv if it does not exist based off the file
if [ ! -f conda.dev.env.yaml ]; then
    echo "https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/conda.dev.env.yaml"
    wget https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/conda.dev.env.yaml
    conda env create -p $CONDA_ENV_PATH -f conda.dev.env.yaml
else
    # File exists, exit stating you should be in a blank directory
    echo "conda.dev.env.yaml already exists, please run this in a blank directory"
    exit 1
fi

source $NBDEV_PROJECT_FOLDER/.venv/bin/activate;

# Check that nbdev is installed and at the right version, you can check the version of nbdev with pip show nbdev
nbdev_version=$(pip show nbdev | grep Version | awk '{print $2}')
if [[ $nbdev_version == $NBDEV_VERSION ]]; then
    echo "nbdev version is $NBDEV_VERSION"
else
    echo "nbdev version is not $NBDEV_VERSION"
    exit 1
fi

nbdev_new --repo $GIT_REPO_NAME --branch $TEMPLATE_GIT_BRANCH --user '$GIT_USER_NAME' --author '$GIT_USER_NAME' --author_email $GIT_EMAIL --black_formatting True --license MIT --description "TODO"; 

nbdev_prepare; # also makes the package folder

# Pull the files from the template repo
wget --directory $GIT_REPO_NAME https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/config.default.env;
wget --directory $GIT_REPO_NAME https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/config.default.yaml; 
wget -O $NBDEV_PROJECT_FOLDER/nbs/00_core.ipynb --directory nbs https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/nbs/00_core.ipynb;
wget -O $NBDEV_PROJECT_FOLDER/nbs/01_hello_world_example.ipynb --directory nbs https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/nbs/01_hello_world_example.ipynb;
wget -O $NBDEV_PROJECT_FOLDER/LICENSE https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/LICENSE;
wget -O $NBDEV_PROJECT_FOLDER/.gitignore https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/.gitignore;

# add to the end of the settings.ini file
if [ "$(tail -n1 settings.ini | wc -l)" -eq "0" ] || [ "$(tail -n1 settings.ini | wc -c)" -ne "1" ]; then
  echo "" >> settings.ini
fi
echo "requirements = fastcore python_dotenv envyaml" >> settings.ini;
echo "console_scripts = \
    core_hello_world=$GIT_REPO_NAME.core:hello_world" >> settings.ini;

# replace the marker in the file $NBDEV_PROJECT_FOLDER/nbs/00_core.ipynb, it can occur multiple times
sed -i '' "s/\$PACKAGE_NAME/$GIT_REPO_NAME/g" $NBDEV_PROJECT_FOLDER/nbs/00_core.ipynb;