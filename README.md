# gitlist-docker

A ready to use docker image with preinstalled nginx and gitlist gitlist-1.0.1

You can use it to quickly expose a web interface of the git repositories in a
directory of your host machine.

## Usage

You can build the image like this

    git clone <this repo>
    cd gitlist-docker
    docker build -t gitlist .

And run it like this

    docker run -p 8888:80 -v /path/repo:/repos gitlist

The web interface will be available on host machine at port 8888 and will show
repositories inside /path/repo

You can optionally set these environment variables:

    TZ (timezone) example: 'America/Los_Angeles'
    -e TZ='America/Los_Angeles'

    DATEFORMAT examples: 'd/m/Y H:i:s', 'm/d/Y H:i:s'
    -e 'DATEFORMAT'='m/d/Y H:i:s'

    THEME options: 'default' or 'bootstrap3'
    -e 'THEME'='bootstrap3'
