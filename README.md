# Docker-Install

rm  -rf  /etc/yum.repos.d/pgdg-redhat-all.repo

curl -sSL https://raw.githubusercontent.com/farooq-001/Docker-Install/master/docker-InstallRockyLinux8.10.sh | bash

curl -sSL https://raw.githubusercontent.com/farooq-001/Docker-Install/master/Install-docker-compose.sh | bash

curl -sSL https://raw.githubusercontent.com/farooq-001/Docker-Install/master/guacamole.sh | bash



#### podman ####
sudo dnf remove podman skopeo runc containers-common

sudo dnf clean all

sudo dnf install docker-ce docker-ce-cli containerd.io
