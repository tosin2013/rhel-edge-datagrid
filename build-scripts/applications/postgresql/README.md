# PostgreSQL
[PostgreSQL](https://www.postgresql.org/), also known as Postgres, is a free and open-source relational database management system emphasizing extensibility and SQL compliance. It was originally named POSTGRES, referring to its origins as a successor to the Ingres database developed at the University of California, Berkeley. [Wikipedia](https://en.wikipedia.org/wiki/PostgreSQL)
---
**Edit Source file:**
```
vi build-scripts/applications/postgresql/app_env
```

**Change EXTERNAL_ENDPOINT**
*the fqdn or ip may be used*
```
export EXTERNAL_ENDPOINT="192.168.1.10"
or 
export EXTERNAL_ENDPOINT="rhel-edge.example.com"
```

**Run build script**
```
 ./build-scripts/applications/postgresql/postgresql.sh 
```