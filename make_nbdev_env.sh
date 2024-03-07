# This script helps you modify a nbdev_new project with templated files for SSI based projects. It required a public repo where the files will come from

# Ensure script fails on errors
set -e

# Check that the current folder is empty
if [ "$(ls -A .)" ]; then
    echo "Current directory is not empty, please run this in a blank directory"
    # ask user if they want to clear current directory
    read -p "Do you want to clear the current directory? (y/n) " -n 1 -r
    # if they dont just exit
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "";
        echo "Exiting";
        exit 1;    
    else 
        echo "";
        echo "Clearing current directory";
        find . -mindepth 1 -delete;  # want to ensure hidden files are removed as well
    fi
fi

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
    echo "https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/defaults/conda.dev.env.yaml"
    wget https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/defaults/conda.dev.env.yaml
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
wget --directory $GIT_REPO_NAME/config https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/defaults/config.default.env;
wget --directory $GIT_REPO_NAME/config https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/defaults/config.default.yaml; 
wget -O $NBDEV_PROJECT_FOLDER/nbs/00_core.ipynb --directory nbs https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/nbs/00_core.ipynb;
wget -O $NBDEV_PROJECT_FOLDER/nbs/01_hello_world.ipynb --directory nbs https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/nbs/01_hello_world.ipynb;
wget -O $NBDEV_PROJECT_FOLDER/LICENSE https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/LICENSE;
wget -O $NBDEV_PROJECT_FOLDER/.gitignore https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/.gitignore;

# add to the end of the settings.ini file
if [ "$(tail -n1 settings.ini | wc -l)" -eq "0" ] || [ "$(tail -n1 settings.ini | wc -c)" -ne "1" ]; then
  echo "" >> settings.ini
fi

echo "requirements = fastcore python_dotenv envyaml" >> settings.ini;
echo "console_scripts = " >> settings.ini;
echo "    core_hello_world=$GIT_REPO_NAME.core:cli" >> settings.ini;
echo "    hello_two_world=$GIT_REPO_NAME.hello_world:cli" >> settings.ini;

# replace the marker in the file $NBDEV_PROJECT_FOLDER/nbs/00_core.ipynb, it can occur multiple times
sed -i'' "s/\$PACKAGE_NAME/$GIT_REPO_NAME/g" $NBDEV_PROJECT_FOLDER/nbs/00_core.ipynb;
sed -i'' "s/\$PACKAGE_NAME/$GIT_REPO_NAME/g" $NBDEV_PROJECT_FOLDER/nbs/01_hello_world.ipynb;


# make the value of GIT_REPO_NAME to all caps
GIT_REPO_NAME_UPPER=$(echo $GIT_REPO_NAME | tr '[:lower:]' '[:upper:]');
# for the config.default.env, adjust project name to the GIT_REPO_NAME.
sed -i'' "s/PROJECTNAME/$GIT_REPO_NAME_UPPER/g" $GIT_REPO_NAME/config/config.default.env;
sed -i'' "s/PROJECTNAME/$GIT_REPO_NAME_UPPER/g" $GIT_REPO_NAME/config/config.default.yaml;

echo "include config/config.default.env" >> MANIFEST.in;
echo "include config/config.default.yaml" >> MANIFEST.in;

# make the package
nbdev_prepare;

# ensure the package is installed for dev testing
python -m pip install -e '.[dev]';



# testing hello world works with $GIT_USER_NAME but make sure it's passed as a string
core_hello_world "$GIT_USER_NAME";

# Create a default folder structure, if you adjust this adjust .gitignore as well where needed
mkdir -p $NBDEV_PROJECT_FOLDER/input/; touch $NBDEV_PROJECT_FOLDER/input/.gitkeep;
mkdir -p $NBDEV_PROJECT_FOLDER/output/; touch $NBDEV_PROJECT_FOLDER/output/.gitkeep;
#mkdir -p $NBDEV_PROJECT_FOLDER/config/; touch $NBDEV_PROJECT_FOLDER/config/.gitkeep;
wget -O $NBDEV_PROJECT_FOLDER/input/sample_sheet.tsv --directory input https://raw.githubusercontent.com/$TEMPLATE_GIT_REPO/$TEMPLATE_GIT_BRANCH/defaults/sample_sheet.tsv;

# add all the files to git including hidden files
git add .;

echo "Files added to git, be sure to push them to a repo";

echo "Setup complete, you can now run add a destrination package";