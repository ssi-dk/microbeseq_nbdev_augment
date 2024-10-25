# Info
This repo contains a file `make_nbdev_env.sh` which can be run on the command line in order to set up a blank folder for SSI development through nbdev. The other files are referenced in `make_nbdev_env.sh` and will be aquired via `wget`. Make sure to run it in an empty PROJECT_NAME folder.

NOTE: PROJECT_NAME must adhere to github  repo naming standards AND python package naming standards.

‼️ You do NOT need to clone this repo! Just run the command below in an empty folder.

If you're a developer from SSI.dk please check the restricted [wiki](https://dksund.sharepoint.com/:fl:/g/contentstorage/CSP_7c761ee7-b577-4e08-8517-bc82392bf65e/EY5URO2bse5PupGxlyBlWqYBqb54BQ7ICFIzFzjrjKbuug?e=3igKQv&nav=cz0lMkZjb250ZW50c3RvcmFnZSUyRkNTUF83Yzc2MWVlNy1iNTc3LTRlMDgtODUxNy1iYzgyMzkyYmY2NWUmZD1iJTIxNXg1MmZIZTFDRTZGRjd5Q09TdjJYblkwVlNiWXFYcE1yaHVrVmZqTVJUVEE4X1VwZjhTd1JxcjRNdmFrSmh2RCZmPTAxVlVLVzVWTU9LUkNPM0c1UjVaSDNWRU5SUzRRR0tXVkcmYz0lMkYmYT1Mb29wQXBwJnA9JTQwZmx1aWR4JTJGbG9vcC1wYWdlLWNvbnRhaW5lciZ4PSU3QiUyMnclMjIlM0ElMjJUMFJUVUh4a2EzTjFibVF1YzJoaGNtVndiMmx1ZEM1amIyMThZaUUxZURVeVpraGxNVU5GTmtaR04zbERUMU4yTWxodVdUQldVMkpaY1Zod1RYSm9kV3RXWm1wTlVsUlVRVGhmVlhCbU9GTjNVbkZ5TkUxMllXdEthSFpFZkRBeFZsVkxWelZXU1RJMVJsaFBNalkyUlZkQ1FqTTFRVmhKVTBkRFVVcFdXa1klM0QlMjIlMkMlMjJpJTIyJTNBJTIyNzRmNzM1ZmUtYzg4Ny00MjhhLWFkZmYtNTEyZTg2YmNmZmM3JTIyJTdE) for additional information.

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
If running the commands above didn't work, check the output, if it's telling you to do something do it to fix your problem. Otherwise there's additional debugging to do. To run again please remove the stuff in the PROJECT_NAME and run it again.
