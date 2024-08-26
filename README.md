# Info
This repo contains a file `make_nbdev_env.sh` which can be run on the command line in order to set up a blank folder for SSI development through nbdev. The other files are referenced in `make_nbdev_env.sh` and will be aquired via `wget`. Make sure to run it in an empty PROJECT_NAME folder.

‼️ You do NOT need to clone this repo! Just run the command below in an empty folder.

# Requirements
- conda
- git

# Usage
```bash
wget https://raw.githubusercontent.com/ssi-dk/microbeseq_nbdev_augment/main/make_nbdev_env.sh;
mkdir PROJECT_NAME;
cd PROJECT_NAME;
bash ../make_nbdev_env.sh;
```
