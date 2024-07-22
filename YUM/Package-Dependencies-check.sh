consolidated example of the commands:

# List dependencies:

sudo yum deplist python-urllib3

sudo dnf repoquery --whatrequires python-urllib3

# Uninstall the package:


sudo yum remove python-urllib3
sudo dnf remove python-urllib3

# What provides
yum provides filepath
yum whatprovides '*bin/grep'

rpm -q --whatprovides /etc/ngnix/nginx.conf


# Find package from a specific file
rpm -qf <filename>

rpm -q system-release --qf "%{VERSION}\n" 


# List all files in the package
rpm -ql <packagename> 

rpm -qlp <rpmfilename>  # need to test
