OpenPetra Development environment with Docker
=============================================

This should provide an environment, with all requirements already installed, for the developers of OpenPetra.

You have the choice between Fedora and Ubuntu, depending which flavour of Linux you prefer...

This is how to build the Docker image:

    ./build.sh <fedora|ubuntu>

This is how to download the Docker image:

    ./install.sh <fedora|ubuntu> <empty directory which will holds your working directory of openpetra>

You will be asked to login via ssh, use the default password CHANGEME for root, which you can change.

Then you should run inside the container:

    ./init.sh

which sets up an instance of OpenPetra, starts the server, and copies the code to /root/openpetra,
which is your working directory of OpenPetra outside of the container.

You can access your container on http://localhost:8008, to test the application in your browser.

TODO: phpmyadmin to browse the database.

For developing, you can ssh into the container with `ssh -p 2008 localhost`, and then you can run eg.

    nant compileProject -D:name=Ict.Common.IO
    nant install.net
