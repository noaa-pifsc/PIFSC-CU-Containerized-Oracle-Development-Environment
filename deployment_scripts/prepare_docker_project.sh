#! /bin/sh

#development container deployment script

echo "running Oracle dev container deployment script"

# load the project configuration script to set the runtime variable values
. ./sh_script_config/project_config.sh


mkdir $root_directory/docker
mkdir $project_directory
mkdir $project_directory/tmp


#checkout the git projects into the same temporary docker directory
git clone $ode_git_url $project_directory/tmp/dsc-pifsc-oracle-developer-environment

echo "clone the project repository"

# copy the project repository's docker folder to the root project folder, this is where the docker commands will be run from:
cp -R $project_directory/tmp/dsc-pifsc-oracle-developer-environment/docker $project_directory/docker
cp -R $project_directory/tmp/dsc-pifsc-oracle-developer-environment/deployment_scripts $project_directory/deployment_scripts









# This is where the project dependencies are cloned and added to the development container's file system so they are available when the docker container is built and executed
echo "clone the project dependencies"



	echo "clone the DSC project's dependencies"

	git clone $dsc_git_url $project_directory/tmp/pifsc-dsc

	echo "copy the docker files from the repository to the docker subfolder"

	# create the docker DSC folder
	mkdir $project_directory/docker/src/DSC

	# copy the docker files from the repository to the docker subfolder
	cp -r $project_directory/tmp/pifsc-dsc/SQL $project_directory/docker/src/DSC/SQL


	echo "The DSC project's dependencies have been added to the $project_directory"


echo "remove all temporary files"
rm -rf $project_directory/tmp


echo "the docker project files are now ready for configuration and image building/deployment"

read
