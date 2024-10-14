Usage of PGSpider docker image and PGSpider RPM packages
=====================================

The image below illustrates the process of building Docker images from source code and binary packages. First, the source code is used to build binary packages. These binary packages are then used to create the Docker image of PGSpider. Next, to create the Docker image PGSpider with FDWs, the FDW binary packages need to be installed into the Docker image PGSpider. As a result we have two Docker images, one is the PGSpider Docker image and the other is the PGSpider Docker image with FDWs.

![Alt text](images/overview.png)

- Create PGSpider RPM packages. Refer [Here](#creating-pgspider-rpm-packages)
	- RPM package is puiblished on the Package Registry of PGSpider repository.
- Create PGSpider docker image from PGSpider RPM packages. Refer [Here](#creating-pgspider-docker-images)
	- The PGSpider RPM package is required. It must be released first.
	- The PGSpider docker image is published on the Container Registry of PGSpider repository.
- Create PGSspider docker image with specific FDWs. Refer [Here](#creating-customized-pgspider-image-with-fdws)
	- The PGSpider docker image and the FDW RPM package are required. It must be released first.
- Additionally, we also provide Gitlab CI/CD pipeline for creating PGSpider RPM packages and PGSpider docker image for [PGSpider](#usage-of-run-cicd-pipeline).

Environment for creating rpm of PGSpider
=====================================
The description below is used in the specific Linux distribution RockyLinux8.
1. Docker
	- Install Docker
		```sh
		sudo yum install -y yum-utils
		sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
		sudo yum install -y docker-ce docker-ce-cli containerd.io
		sudo systemctl enable docker
		sudo systemctl start docker
		```
	- Enable the currently logged in user to use docker commands
		```sh
		sudo gpasswd -a $(whoami) docker
		sudo chgrp docker /var/run/docker.sock
		sudo systemctl restart docker
		```
	- Proxy settings (If your network must go through a proxy)
		```sh
		sudo mkdir -p /etc/systemd/system/docker.service.d
		sudo tee /etc/systemd/system/docker.service.d/http-proxy.conf << EOF
		[Service]
		Environment="HTTP_PROXY=http://proxy:port/"
		Environment="HTTPS_PROXY=http://proxy:port/"
		Environment="NO_PROXY=localhost,127.0.0.1"
		EOF
		sudo systemctl daemon-reload
		sudo systemctl restart docker
		```
2. Get the required files  
	```sh
	git clone https://tccloud2.toshiba.co.jp/swc/gitlab/db/PGSpider.git
	```

Creating PGSpider rpm packages
=====================================
1. File used here
	- rpm/*
	- rpm/PGSpider.spec
	- docker/env_rpm_optimize_image.conf
	- docker/Dockerfile_rpm
	- docker/create_rpm_binary.sh
2. Configure `docker/env_rpm_optimize_image.conf` file
	- Configure proxy
		```sh
		proxy=http://username:password@proxy:port
		no_proxy=localhost,127.0.0.1
		```
	- Configure the registry location to publish the package and version of the packages
		```sh
		location=gitlab 					# Fill in <gitlab> or <github>. In this project, please use <gitlab>
		ACCESS_TOKEN=						# Fill in the Access Token for authentication purposes to publish rpm packages to Package Registry
		PGSPIDER_PROJECT_ID=				# Fill in the ID of the PGSpider project.
		PGSPIDER_BASE_POSTGRESQL_VERSION= 	# Base Postgres version of PGSpider. Example: 16
		PGSPIDER_RELEASE_VERSION=			# Version of PGSpider rpm package
		PACKAGE_RELEASE_VERSION=			# The number of times this version of the software has been packaged. Starting from 1.
		```
3. Build execution
	```sh
	chmod +x docker/create_rpm_binary.sh
	./docker/create_rpm_binary.sh
	```
4. Confirmation after finishing executing the script
	- Terminal displays a success message. 
		```
		{"message":"201 Created"}
		...
		{"message":"201 Created"}
		```
	- RPM Packages are stored on the Package Registry of its repository
		```sh
		Menu TaskBar -> Deploy -> Package Registry
		```

Creating PGSpider docker images
=====================================
The PGSpider rpm packages are created [above](#creating-pgspider-rpm-packages) will be taken from the Package Registry to build PGSpider image.
1. File used here
	- docker/env_rpm_optimize_image.conf
	- docker/Dockerfile
	- docker/docker-entrypoint.sh
	- docker/create_pgspider_image.sh
2. Configure `docker/env_rpm_optimize_image.conf` file
	- Configure proxy: Same [Configure of Creating PGSpider rpm packages](#creating-pgspider-rpm-packages)
	- Configure the registry location to publish the package
		```sh
		location=gitlab 					# Fill in <gitlab> or <github>. In this project, please use <gitlab>
		ACCESS_TOKEN=						# Fill in the Access Token for authentication purposes to get PGSpider rpm packages from the Package Registry.
		PGSPIDER_PROJECT_ID=				# Fill in the ID of PGSpider project.
		API_V4_URL=							# Fill in API v4 URL of this repo. In this project please use <https://tccloud2.toshiba.co.jp/swc/gitlab/api/v4>
		```
	- Configure version of rpm packages: Same [Configure of Creating PGSpider rpm packages](#creating-pgspider-rpm-packages)
	- Configure PGSpider docker image
		```sh
		IMAGE_NAME=pgspider					# Name of PGSpider image
		PGSPIDER_RPM_ID=					# ID of PGSpider rpm package on the Package Registry
		PROJECT_PATH=						# Project path of repository in lower case. Example: https://tccloud2.toshiba.co.jp/swc/gitlab/db/PGSpider have project_path is "db/pgspider"
		PGSPIDER_CONTAINER_REGISTRY=		# Container registry name
		USERNAME_PGS_CONTAINER_REGISTRY=	# User name for authentication
		PASSWORD_PGS_CONTAINER_REGISTRY=	# Password for authentication
		```
3. Build execution
	```sh
	chmod +x docker/create_pgspider_image.sh
	./docker/create_pgspider_image.sh
	```
4. Confirmation after finishing executing the script  
PGSpider image is stored on the Container Registry of its repository
	```sh
	Menu TaskBar -> Deploy -> Container Registry
	```

Creating customized PGSpider image with FDWs
=====================================
1. File used here
	- docker/env_rpm_optimize_image.conf
	- docker/Dockerfile_install_fdws
	- docker/create_pgspider_with_fdw_image.sh
2. Configure `docker/env_rpm_optimize_image.conf` file
	- Configure proxy: Same [Configure of Creating PGSpider rpm packages](#creating-pgspider-rpm-packages)
	- Configure PGSpider base image and FDWs packages
		```sh
		BASEIMAGE= 							# Name of PGSpider image. Example: swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:latest
		SQLITE_FDW_URL_PACKAGE=				# Link to download sqlite_fdw rpm package from sqlite_fdw's package registry. Example: https://tccloud2.toshiba.co.jp/swc/gitlab/api/v4/projects/394/packages/generic/rpm_rhel8/16/sqlite_fdw_16-2.4.0-rhel8.x86_64-11826.rpm
		SQLITE_FDW_ACCESS_TOKEN=			# Access token to authentication on sqlite_fdw's package registry
		...
		# Same for other FDWs
		```
3. Build execution
	```sh
	chmod +x docker/create_pgspider_with_fdw_image.sh
	./docker/create_pgspider_with_fdw_image.sh
	```
4. Confirmation after finishing executing the script  
The customized PGSpider image is created with the name `customized_pgspider`
	```sh
	$ docker images
	REPOSITORY                 TAG                IMAGE ID          CREATED                
	customized_pgspider        latest             a1ae1446e5f7      14 hours ago
	```
Usage of PGSpider image
=====================================
1. Pull PGSpider image from the Registry (Unnecessary if already available)
	```sh
	echo $PASSWORD | docker login --username $USERNAME --password-stdin swc.registry.benzaiten.toshiba.co.jp
	docker pull swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:latest
	```
2. Start a PGSpider container instance
	- Via `psql`
		```sh
		$ docker run -it swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:latest
		psql (16.0)
		Type "help" for help.

		pgspider=#
		```
	- Via detach mode
		```sh
		$ docker run -d swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:latest DETACH_MODE
		```
	The default `pgspider` user and database are created in the entrypoint with initdb.
3. Forwarding Port
	```sh
	$ docker run -p 4813:4813 -d swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:latest DETACH_MODE
	$ psql -h 127.0.0.1 -p 4813 -U pgspider -d pgspider
	psql (16.0)
	Type "help" for help.

	pgspider=#
	```
4. Extend database name

	This optional environment variable can be used to define a different name for the default database that is created when the image is first started.
	```sh
	$ docker run -p 4813:4813 -e PGSPIDER_DB=new_db swc.registry.benzaiten.toshiba.co.jp/db/pgspider/pgspider:latest DETACH_MODE
	$ psql -h 127.0.0.1 -p 4813 -U pgspider -d pgspider
	psql: error: connection to server at "127.0.0.1", port 4813 failed: FATAL:  database "pgspider" does not exist
	$ psql -h 127.0.0.1 -p 4813 -U pgspider -d new_db
	psql (16.0)
	Type "help" for help.

	new_db=#
	```
Usage of Run CI/CD pipeline
=====================================
1. Go to Pipelines Screen
	```sh
	Menu TaskBar -> Build -> Pipelines
	```
2. Click `Run Pipeline` button  
![Alt text](images/GitLab/pipeline_screen.PNG)
3. Choose `Branch` or `Tag` name
4. Provide `Access Token` through `Variables`
	- Input variable key: ACCESS_TOKEN
	- Input variable value: Your access token
5. Click `Run Pipeline` button  
![Alt text](images/GitLab/run_pipeline.PNG)

How to upgrade new PGSpider version for packages
=====================================
1. Update `PGSPIDER_BASE_POSTGRESQL_VERSION` in `docker/env_rpm_optimize_image.conf` file.  
The variable `PGSPIDER_BASE_POSTGRESQL_VERSION` represents the base Postgres version of PGSpider. You must change to the corresponding new version
	```
	PGSPIDER_BASE_POSTGRESQL_VERSION=16
	```
2. Overwrite new configuration, patches, settings files from `pgrpms` repository.  
	- `pgrpms` repository: https://git.postgresql.org/gitweb/?p=pgrpms.git
	- Go to path: /rpm/redhat/main/non-common/postgresql-16/EL-8/
	- Copy the files in the `/rpm/redhat/main/non-common/postgresql-16/EL-8/` path to `rpm/` folder in root directory.
	- Compare `rpm/PGSpider.spec` with `/rpm/redhat/main/non-common/postgresql-16/EL-8/postgresql-16.spec` and update `PGSpider.spec` if necessary.
3. Rebuild new packages.  
Refer [Configure of Creating PGSpider rpm packages](#creating-pgspider-rpm-packages)