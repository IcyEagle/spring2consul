# spring2consul

This tiny project is designed as a simple supplementary solution
for [Spring Distributed Configuration with Consul](https://cloud.spring.io/spring-cloud-consul/reference/html/#spring-cloud-consul-config).  
It helps to upload your JSON/YAML configuration files from local filesystem to Consul with a way which is described
in the corresponding [Spring topic](https://cloud.spring.io/spring-cloud-consul/reference/html/#spring-cloud-consul-config-format).

## Configuration directory structure

To make it possible to synchronize only a specific profile (and optionally shared configuration),
all profile-specific configurations are located in separate directories.
It simplifies using the script in CI pipelines and associate jobs with particular profiles,
thus you don't have to synchronize all at once and you can roll out updates gradually step by step
starting with *development* environment.

`configs/` - default root directory

`configs/shared/` - directory for configuration files which are applied for every profile 

`configs/profiles/PROFILE/` - directory for configuration files which are relevant only for specific profile.
You should create a separate directory for every profile.  

See `example/` folder as a reference.

## Example

Let's set `CONSUL_ROOT=settings ACTIVE_PROFILE=dev` and see how it will look like in Consul:
```
configs/shared/application.yaml
configs/shared/kafka-backend.yaml
configs/profiles/dev/application.yaml
configs/profiles/dev/redis.yaml
configs/profiles/dev/kafka-backend.yaml
configs/profiles/prod/kafka-backend.yaml
```

Using default settings this structure will be mapped into Consul as:
```
/settings/application/data
/settings/kafka-backend/data
/settings/application-dev/data
/settings/redis-dev/data
/settings/kafka-backend-dev/data
```

## Environment variables

`API_URL` (required) - specify Consul API endpoint. *Example: https://consul-private.infra.eu*

`CONSUL_ROOT` (required) - Consul directory path where the data should be uploaded.
*If you expect to see your configuration files uploaded to `configuration/system/application-dev/data` (where `application` - is a filename and `dev` - is a profile),
then the variable value should be `configuration/system`*

`CONFIG_LOCATION` (default `configs/`) - specify the root directory for your configuration folders

`ACTIVE_PROFILE` - specify which profile should be synchronized with Consul.
It may be convenient to synchronize only selected profile if you bind this script to CI pipeline job. 
All profiles will be synchronized if the variable is not set

`PROFILE_SEPARATOR` (default `-`) - specify which string should be placed between filename and its environment
to form the Consul directory name. For details refer to [Spring page](https://cloud.spring.io/spring-cloud-consul/reference/html/#customizing)

`DATA_KEY` (default `data`) - specify the filename which is used to store YAML file content
under the corresponding directory. For details refer to [Spring page](https://cloud.spring.io/spring-cloud-consul/reference/html/#spring-cloud-consul-config-format)

`NO_SHARED_PROFILE` (default - disabled) - set the variable if you don't want
synchronizing configuration files located directly in your `CONFIG_LOCATION`.
These files are supposed to be used in all environments with a lower precedence
in comparison with environment-specific files (see Spring docs to get more about configuration overriding)

`ACL_TOKEN` - Consul authorization token if required

## Docker hub

Yes, it's published [there](https://hub.docker.com/repository/docker/icyeagle/spring2consul)!