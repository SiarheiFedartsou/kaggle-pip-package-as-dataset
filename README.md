# General

Very simple bash script which can uploads pip packages as Kaggle datasets. It can be useful in "kernel-only" competitions if you want to use some pip packages which are not installed on Kaggle by default and Internet access is disabled because of competition rules(so you can't just do `!pip install my-package`)
# Requirements

- [Kaggle CLI](https://github.com/Kaggle/kaggle-api)
- pip

# Usage

### Upload single package

```./upload_pakage.sh -p tqdm==4.1.0```

### Upload dependencies defined in `requirements.txt`

```./upload_package.sh -r requirements.txt -t some_title_for_dataset```