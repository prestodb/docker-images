# iop4.2-hive [![][layers-badge]][layers-link] [![][version-badge]][dockerhub-link]
           
[layers-badge]: https://images.microbadger.com/badges/image/prestodb/iop4.2-hive.svg
[layers-link]: https://microbadger.com/images/prestodb/iop4.2-hive
[version-badge]: https://images.microbadger.com/badges/version/prestodb/iop4.2-hive.svg
[dockerhub-link]: https://hub.docker.com/r/prestodb/iop4.2-hive

Docker image with HDFS, YARN and HIVE installed. Please note that running services have lower memory heap size set.
For more details please check the [hadoop-env.sh](files/conf/hadoop-env.sh) configuration file.
If you want to work on larger datasets please tune those settings accordingly, the current settings should be optimal
for general correctness testing.

## Run

```
$ docker run -d --name hadoop-master -h hadoop-master prestodb/iop4.2-hive
```

## Oracle license

By using this image, you accept the Oracle Binary Code License Agreement for Java SE available here:
[http://www.oracle.com/technetwork/java/javase/terms/license/index.html](http://www.oracle.com/technetwork/java/javase/terms/license/index.html)
