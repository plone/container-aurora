# Setup with Webserver (Nginx), Frontend (Aurora), Plone Backend and Database Server (ZEO)

## Intro

Clone this repository and go to the `examples/webserver-aurora-plone-zeo` folder

```shell
git clone https://github.com/plone/plone-aurora.git
cd plone-aurora/examples/webserver-aurora-plone-zeo
```

Start the solution with `docker-compose` (or `docker compose` for newer versions)

```shell
docker-compose up -d
```

## Access the site

After startup, go to `http://localhost/` and you should see the site.
