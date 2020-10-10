# gitlist-docker

A ready to use docker image with preinstalled nginx and GitList

You can use it to quickly visualize the git repositories on your machine.

Intended for use on Unraid, to view the flash drive's git repo.

If any repositories are not world-readable, will configure GitList to run as root automatically. Otherwise runs as www-data.

## Usage

You can build the image like this

    git clone <this repo>
    cd gitlist-docker
    docker build -t gitlist .

### Quickstart

```
docker run -p <8888>:80 -v </path/to/repos>:/repos:ro gitlist
```

Use a web browser to access gitlist at the specified port and it will show the git repositories available in the specified path.

### Full Options

```
docker run \
  -p <8888>:80/tcp \
  -e 'PASSWORD'='supersecret' \
  -e TZ='America/Los_Angeles' \
  -e DATEFORMAT='m/d/Y h:i:s a' \
  -e THEME='bootstrap3' \
  -v </path/to/repos>:/repos:ro \   # on Unraid use  -v /boot:/repos:ro
  -v </path/to/repos2>:/repos2:ro \
  -v </path/to/repos3>:/repos3:ro \
  -v </path/to/repos4>:/repos4:ro \
  -v </path/to/repos5>:/repos5:ro \
  gitlist
```

|            Parameter            | Function                                                                |
| :-----------------------------: | ----------------------------------------------------------------------- |
|  `-e 'PASSWORD'='supersecret'`  | (Optional) If a password is specified, login with username `'admin'`        |
|  `-e TZ='America/Los_Angeles'`  | (Optional) Specify your timezone in a format recognized by PHP          |
| `-e DATEFORMAT='m/d/Y h:i:s a'` | (Optional) Two common options are `'d/m/Y H:i:s'` and `'m/d/Y h:i:s a'` |
|     `-e THEME='bootstrap3'`     | (Optional) Specify either `'default'` or `'bootstrap3'`                 |

#### Volumes

You can specify up to five different directories that contain your git repositories. Note that you need to provide the directory that contains your repository, not the directory of the repository itself (so two levels up from the `.git` folder.)

It is recommended that you include `:ro` to open the paths in readonly mode.
