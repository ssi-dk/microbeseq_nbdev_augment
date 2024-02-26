# Info
This repo contains a file `post_nbdev.sh` which can be run on the command line in order to set up a blank folder for SSI development through nbdev. The other files are referenced in post_nbdev.sh and will be aquired via wget.

# Requirements
- conda
- git

# Usage
```bash
wget https://raw.githubusercontent.com/ssi-dk/microbeseq_nbdev_augment/main/post_nbdev.sh;
mkdir PROJECT_NAME;
cd PROJECT_NAME;
bash ../post_nbdev.sh;
```