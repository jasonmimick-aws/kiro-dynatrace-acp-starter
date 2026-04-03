# dev/

Internal development and testing tools. Not required for using the starter repo.

## Dockerfile

Containerized environment with kiro-cli, dtctl, and AWS CLI pre-installed. Useful for CI/CD or testing without local installs.

```bash
docker build --platform linux/amd64 -t kiro-dt-dev dev/
docker run -it -e DT_TENANT -e DT_PLATFORM_TOKEN kiro-dt-dev
```
